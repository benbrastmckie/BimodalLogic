# Implementation Plan: Weak + Finite-Context Consequence Completeness for FrameClass.Dedekind (v10 — the Doets route, Reynolds' Lemma 4 boundary case chartered)

> **REFRAMING NOTE (carried forward unchanged from v1, applies to the whole plan)**: "Strong
> completeness" is reserved, project-wide, for the genuine infinite-premise statement
> (`Γ : Set Formula` with finitary set-derivability), which is **provably unavailable** for the
> Dedekind class — its consequence relation is not compact (Reynolds 1992 Theorem 7 is *weak*
> completeness, and the restriction is genuine). The headline result for this class is **weak
> completeness** `completeness_dedekind`; the arbitrary-finite-`Γ` form, inter-derivable with it
> through the deduction theorem, is `consequence_completeness_dedekind`. No proof obligation,
> phase boundary, or route decision changes under this renaming. See
> `FormalSystem/Metalogic/StrongCompleteness.lean`'s module docstring for the per-class programme.
>
> **The Doets route is SETTLED and is not re-opened by this revision.** v7's Revision Rationale
> (v6 → v7) — the Phase 7.9 refutation, the three exhausted Dedekind axioms, the user's
> authorization, the amputation of the ℝ-extension-by-limits layer, and the ten superseded v6
> sections — stands **unamended** and is not reproduced here. It is the historical record at
> `plans/07_strong-completeness-dedekind-v7.md` §"Revision Rationale (v6 → v7)". v8 changed
> **Block D and its consumers only**; **v9 changes Block F's §6 duality accounting only**, and
> leaves v8's Block D record, its Postmortem Constraints and its Blocks E-I mathematics intact.
> **v10 is narrower still.** It corrects two Block F passages that would send the next dispatch to
> the wrong file, and charters one new sub-phase (22.1). It adds **exactly one** heading, renumbers
> nothing, re-sequences nothing, and re-costs nothing except the +3 hours that heading carries.

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Status**: [IMPLEMENTING]
- **Effort**: **~171.5 hours across 31 phase headings**, of which **~108.5 hours (Phases 9 through
  22) are spent** and **~63 hours remain**. The sum of the per-phase timings below, not a rounded
  guess. The increase over v9's ~168.5 hours is **+3 hours, entirely in Block F** (Phase 22.1),
  and it is an increase in *honesty*: v9's Phase 20 recorded the existence of a
  `ClassInteriorToRInterval` **producer** as a rendering note rather than as a task, so the
  producer appeared in no phase's deliverable list. See "Revision Rationale (v9 → v10)".
  *(v9's own figure, superseded and kept visible: **~168.5 hours across 30 phase headings**, of
  which ~88 hours (Phases 9 through 20) spent and ~80.5 remaining. The spent figure moves because
  Phases 20.4 (5 h), 20.5 (0.5 h), 21 (9 h) and 22 (6 h) all landed after v9 was written; no
  per-phase timing in this plan is altered by this revision.)*
- **Dependencies**: None. Coordinates with, but is not blocked by, the concurrent decidability
  effort that owns `FormalSystem/Metalogic/Decidability/` and `FormalSystem/Automation/` (territory
  contract below).
- **Research Inputs**:
  - **reports/09_lemma6-first-clause-blocker.md** (**primary for this revision, and its sole input
    of record**): the Tier-1 literature-grounded blocker report for Phase 22's two `[PARTIAL]`
    residuals. Read printed **p.180** (Lemma 6) and **p.179** (Lemma 4's display) as 200 dpi page
    images; refuted the Phase 22 implementer's claim that Reynolds *"states the clause and treats
    it as established"* (he gives a five-paragraph proof with an explicit case analysis and a
    Prior-U contradiction); located the real gap at **Lemma 4's boundary case**, not at Lemma 6;
    established that **no producer of `ClassInteriorToRInterval` exists anywhere in the tree**
    (seven occurrences, all definition/field/dual/hypothesis positions); refuted F2's import-cycle
    claim against the actual transitive closure while endorsing its conclusion on layering
    grounds; and **compiled 239 lines of the fix green, sorry-free and axiom-clean**, reproduced
    in full in its §3. Its §6.3 is the change list this revision executes and its §7 is the
    charter Phase 22.1 transcribes.
  - **reports/08_lemma5-mirror-blocker.md** (**primary for the v8 → v9 revision**): the Tier-1
    literature-grounded blocker report for Phase 20's fourth half. Verified verbatim off the
    printed p.179 and p.180 page images that Reynolds states §6 Lemma 5 over maximal intervals of
    `R` **only**, and that his Lemma 6 nonetheless needs the `λ` side; measured the §6 page map as
    printed = PDF page (1-based) + 164; measured the hand-mirror residual at ~540-590 lines
    against v8's ~180-line estimate; and compiled ~150 lines of an `OrderDual` duality-transport
    layer green via `lean_run_code`. Its §6 ("plan v8 deviates; sections requiring revision") is
    the change list this revision executes.
  - **handoffs/phase-10-handoff-20260728.json** (**primary for the v7 → v8 revision**): the deviation
    record and the three route-critical findings that force it — (i) the route's single point of
    failure HELD; (ii) downstream consumes a hypothesis-free carrier, not the guarded one;
    (iii) an `EANegationFixFaithful/` subtree plus `Lemma53Faithful.lean` and `Prop42Faithful.lean`
    already exist in-tree and already consume `HasDedekindINF`.
  - **summaries/07_phase-10-dense-dedekind-inf-summary.md**
  - **summaries/07_phase-9-dense-prior-defs-summary.md**
  - **The read-only faithful-subtree survey performed at this revision** (file:line anchors
    reproduced in "Faithful-Subtree Survey" below; every anchor spot-checked against the tree).
  - **The literature corpus, read verbatim at this revision** for the K⁺ finding below
    (`rabinovich_2014/chunk_0007.md`, `chunk_0015.md`, `chunk_0016.md`, `chunk_0017.md`,
    `chunk_0018.md`; `reynolds_1992/sec01_an-axiomatization-for-until-and-since-ov.md`).
  - reports/07_r3d-limit-blocker-verdict.md (the route verdict; unamended by v8 or v9)
  - plans/09_strong-completeness-dedekind-v9.md (immediate predecessor; its Revision Rationale
    (v8 → v9), its Block F charter and its execution records are carried forward below unamended
    except at the three passages named in "What v10 does, item by item")
  - plans/08_strong-completeness-dedekind-v8.md (superseded predecessor; its Revision Rationale
    (v7 → v8) and its Block D record are carried forward below unamended)
  - plans/07_strong-completeness-dedekind-v7.md (superseded predecessor; its Revision Rationale
    (v6 → v7) and its Phases 9-10 execution record stay there as history)
- **Artifacts**: plans/10_strong-completeness-dedekind-v10.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4
- **Phases**: **31 phase headings**, numbered
  **9, 10, 10.1, 11, 11.1, 12, 12.1, 13, 14, 14.1, 14.2, 14.3, 15 … 20, 20.4, 20.5, 21, 22, 22.1,
  23 … 30**.
  `phases_total = 31`, `phases_completed = 21` (every heading from 9 through 21, all
  `[COMPLETED]` — Phases 20, 20.4, 20.5 and 21 all landed after v9 was written),
  `phases_partial = 1` (**Phase 22**), `phases_not_started = 9` (**22.1**, 23-30),
  `phases_dispatchable = 10`. Counts taken by
  `grep -cE '^### Phase [0-9]+(\.[0-9]+)?: .*\[[A-Z][A-Z ]*\]$'` against this file, per marker.
  Next dispatch target: **Phase 22.1** (Phase 22's `[PARTIAL]` heading matches the scan first, and
  its body's first line redirects there — see Phase 22, which reuses the dispatch-redirect
  mechanism v9 established at Phase 20).
  *(v9's own figures, superseded and kept visible: `phases_total = 30`, `phases_completed = 17`,
  `phases_partial = 1` (Phase 20), `phases_not_started = 12`, `phases_dispatchable = 13`, next
  target Phase 20.4.)*
  **Correction to v8's own count, recorded rather than silently refreshed.** v8's metadata block
  said `phases_total = 25, phases_completed = 2` and named Phase 10.1 as the next target. Both
  figures were true when v8 was written and were never updated as Phases 10.1 through 20 landed
  and as Phases 14.1-14.3 were spliced in under the R2 protocol. The count above was taken by
  enumerating the `### Phase` headings in this file, not by incrementing v8's.
  **Numbering decision (binding, carried forward from v8 and extended).** The orchestrator's
  phase scan is
  `grep -E '^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]' … | head -1`,
  which admits **at most one** dot segment and dispatches the **first** matching heading in file
  order. v8 inserted its four new units as `10.1`, `11.1`, `12.1`; implementation spliced in
  `14.1`, `14.2`, `14.3`. **v9 adds exactly two headings, `20.4` and `20.5`, and renumbers
  nothing.** No phase from 21 through 30 moves, so every Blocks G-I cross-reference carries
  forward unchanged. `20.4` keeps the number the Phase 20 handoff and `reports/08` both already
  use for this unit; renaming it to `20.1` would orphan those references for no gain.
  **v10 adds exactly one heading, `22.1`, and renumbers nothing.** It is placed immediately after
  Phase 22 so the scan reaches Phase 22's `[PARTIAL]` heading first and is redirected there, which
  is the same ordering v9 used for 20 → 20.4. No phase from 23 through 30 moves. `22.1` keeps the
  number `reports/09` §7 already uses for this unit.
- **reports_integrated**: 01_faithful-route-strong-completeness.md,
  02_literature-coverage-audit.md, 03_limit-future-witness-blocker.md,
  04_backward-transport-blocker.md, 05_forward-guard-r3-research.md,
  07_r3d-limit-blocker-verdict.md, 08_lemma5-mirror-blocker.md (integrated in plan version 9),
  **09_lemma6-first-clause-blocker.md** (integrated in plan version 10)

---

## Revision Rationale (v9 → v10)

**This is a narrow, corrective revision, not a re-plan.** It exists because the standing directive
for this task is: when a blocker escalates, blocker research identifies the key literature and
verifies claims against it verbatim; the plan is then checked against that research; and **if the
plan deviates, the plan is revised before any further implement cycle**. `reports/09` is the
research. The check found a real deviation. This revision is the correction, and an implement
dispatch is blocked behind it.

Nothing about the route, the terminus, Block D, Blocks G-I, or any landed phase record changes.
**Exactly one heading is added (22.1); two existing passages are corrected; one Phase 29 checkbox
gains a dependency citation.** Every superseded passage is kept visible, per this plan's standing
convention.

### The deviation: a supply claim asserted in a rendering note, and measured false

The root deviation is at **Phase 20's "Rendering 1" note**, which asserted:

> *Rendering 1 — "a maximal interval of `R`".* Rendered as `ClassInteriorToRInterval M ε a t b`:
> two points `a < t < b` outside `t`'s class with `R` throughout `[a,b]`. **That is what Lemma 4
> ("no last class and no first class") plus convexity of a maximal interval supply.**

That bolded sentence is an **unproved supply claim, asserted in a rendering note and never
chartered as a task**, and `reports/09` measured it **false as stated**:

- `reynolds_lemma4_no_last_class` **does** supply the upper witness, as-is.
- `reynolds_lemma4_no_first_class` **does not** supply the lower one. It yields `R` on the **open**
  `(y, t)`; `ClassInteriorToRInterval.rThroughout` demands the **closed** `[a, t]`.
- Repo-wide, `ClassInteriorToRInterval` occurs at `BadIntervals.lean:{422, 626, 868, 954, 1026,
  1353, 1392}` — one definition, one field, one dual instantiation and four hypothesis positions.
  **There is no producer, on either side.**

**No phase in v9 — not 19, not 20, not 20.4, not 22 — had a producer of `ClassInteriorToRInterval`
as a deliverable.** Phase 22 discovered the shortfall at the point of consumption and, correctly,
named it as a new hypothesis (`HasBadIntervalSurgery`) rather than working around it. The failure
is the plan's, and this revision is where it is repaired.

**The generalization, stated once and binding on Blocks F-I**: *a rendering note that says
"X supplies Y" is a proof obligation wearing the wrong clothes. If no phase's `Owns` list produces
`Y`, the plan has a hole regardless of how confident the note sounds.* A hypothesis with no
producer is a distinct and easily-missed failure mode from a missing theorem, and it is invisible
to `grep` for the theorem name — the name is everywhere, in consumer positions only.

### Where the gap really is: Reynolds' Lemma 4 display, verified at 200 dpi

`reports/09` located the missing content **not in Lemma 6 at all**, but in a boundary case of
**Lemma 4**, traced to a one-symbol defect in Reynolds' own displayed formula on printed **p.179**.
Verified against the 200 dpi page image; the corpus display of this formula is corrupt and the
image is authoritative:

> By expressive completeness, the formula
>
> ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))
>
> has a temporal equivalent which is true only in the first classes of maximal intervals of R.

Take a maximal interval of `R` bounded below, with excluded left end point `r ∈ M` — the
configuration Reynolds' own Lemma 3 licenses — and let `x` be in its first class:

- the universal clause must hold at `y := r`, demanding `∃z` with **`r < z < x`** and `¬ρ(z)`;
- but `(r, x)` lies inside `x`'s own class, where `ρ` holds throughout;
- **no such `z` exists**, so the formula is **false** at `x` even though `x` is in the first class.

The formula stays **sound** (true only in first classes) — which is the direction Reynolds' own
Lemma 4 proof needs — but its **conclusion** is then weaker than the plain-English statement, and
Lemma 6's second paragraph goes on to consume the plain-English statement: *"Since the class can
not be first in the bad interval, r itself must be in a ∼–class in the bad interval"* needs "not
first" to produce a class strictly below inside the same `R`-interval, i.e. exactly the closed
lower witness the strict display cannot give. Reading the inner bound as **`y ≤ z`** repairs it
(at `y := r`, take `z := r`), and **Reynolds' proof goes through unchanged for the repaired
formula** — verified, not asserted: `reynolds_lemma4_no_first_class_closed` compiles green through
the tree's existing `false_of_holds_throughout_class`, which *is* Reynolds' argument factored out,
and its proof is byte-for-byte the shape of the landed `reynolds_lemma4_no_first_class`.

**Two honesty constraints, both non-negotiable and binding on Phase 22.1:**

1. **This is a defect in the SOURCE, and it is recorded as the source's** (honesty-charter Rule 7).
   The tree's transcription was **faithful and was the right thing to do**; `firstClassFormula`
   (`Lemma34.lean:785`) and `IsFirstClassPoint` (`:797`) are correct, symbol-for-symbol, and are
   **Preserved Assets — not modified by 22.1**. The repaired formula lands **beside** the faithful
   one under a different name, with a docstring quoting the printed display, stating the boundary
   configuration it fails on, and attributing the defect to the source. Anyone auditing the tree
   against p.179 still finds the faithful transcription where they expect it. **The deviation is
   flagged in the phase's deviation record, never absorbed silently.**
2. **The Phase 22 implementer's characterization of Reynolds is refuted and must not be repeated.**
   `NoGaps.lean:730-731` and the Phase 22 handoff both say *"His Lemma 6 states the clause and
   treats it as established"*. Read against printed p.180, that is **wrong**: Reynolds gives a
   **five-paragraph proof**, with an explicit three-case analysis (unbounded below / begins just
   after some `r ∈ M` / includes its left end point) and an explicit Prior-U contradiction on a
   formula `B` true at times which are not left hand end points of their classes.

**The corrected account of what is missing.** Both halves of Lemma 6's first clause are **already
landed in the tree**: *"`L` holds wherever `R` does"* as `endsInGapOnLeft_of_endsInGapOnRight`
(`BadIntervals.lean:615`, Phase 20) and *"using mirror images"* as
`endsInGapOnRight_of_endsInGapOnLeft` (`:1346`, Phase 20.4, by instantiation through `Dual.lean`).
**What is missing is the HYPOTHESIS DISCHARGE**: both landed halves take an interval witness as an
assumption and nothing produces one. The gap is therefore neither "Reynolds waved it away" nor "a
missing `ClassInteriorToLInterval` witness" — it is a producer, on the `ρ` side, downstream of a
source defect.

### The `L`-side hand mirror is the wrong direction, and this is now a settled constraint

`reports/09` §4.2 Attack 4 is explicit and is carried into Phase 22.1's hard gate: the `L`-side
witness is **not** the thing to build. Build the `ρ`-side producer (Step B) and take the `λ` side
by instantiation through `Dual.lean` — 6 lines, first-try green, the third successful use of the
transport layer. Dualising a theorem that does not exist yields nothing, so **any dispatch that
reaches for `Dual.lean` before Step B lands will spend its budget discovering that**. Building the
`L` side directly means hand-mirroring Lemma 4 — the exact cost Phase 20.4's transport layer exists
to avoid.

### What v10 does, item by item

1. **Phase 20's "Rendering 1" note is corrected.** The supply claim is replaced with the measured
   fact — Lemma 4 supplies the **upper** witness only; the lower witness needs the repaired Lemma
   4, and that repair is a **task**, not a rendering. The original sentence is kept visible as
   superseded. Phase 20 stays `[COMPLETED]`; this is an annotation to its deviation record, **not
   a reopening**.
2. **Phase 22's `[PARTIAL]` blocker note is corrected.** It transcribed the Phase 22 implementer's
   diagnosis verbatim, including *"`reynolds_lemma4_no_first_class` [gives] the lower [interiority
   witness]"* — now known false, and it would send the next dispatch to the wrong file. The
   mislocation is corrected in place with the original text kept visible so the correction is
   auditable. Phase 22 stays `[PARTIAL]` and its body now opens with a **dispatch redirect** to
   22.1, the mechanism v9 established at Phase 20.
3. **New Phase 22.1** charters F1 and F2 together, transcribed from `reports/09` §7: the repaired
   Lemma 4 (Step A), the producer (Step B), Lemma 6's first clause hypothesis-free on both sides
   (Step C), the discharge of `HasBadIntervalSurgery` (Step D), the chronicle anti-vacuity
   instantiation in a new `ChronicleInstance.lean` (F2), and the rewrite of the conditionality
   section. **239 of its ~415 lines are already compiled green in `reports/09` §3 — the charter
   says transcribe, do not re-derive.** It carries a **hard gate** on Step A, borrowed from Phase
   20.4's R15 pattern.
4. **Phase 29's anti-vacuity checkbox gains an explicit dependency citation.** No change of
   substance: its task list already says *"Land the statement so Phase 30 can consume it with
   `D1 := no_gaps_dense_prior`"*, and once 22.1 lands that consumption is direct. What is added is
   the citation that the checkbox **still needs a live `ε`, which is Phase 25's deliverable**.
5. **Consistency edits, each named here so none is silent**: the metadata block's phase counts,
   effort total and next-dispatch target; one wave-map row for 22.1 and the corresponding
   parallel-opportunity sentence; the Block F row of the block table; two rows in the
   Source-to-Implementation Mapping and the "Lemma 9 / Theorem 4 page not yet measured" note,
   which Phase 22 measured (pp.182-183, confirming the `+164` offset); four rows in Artifacts &
   Outputs; three additions to Postmortem Constraints; and a rollback paragraph plus two entries
   in "What is never a contingency". **No other passage in this file is touched.**

### What v10 does NOT do — and the caveat it explicitly does NOT retire

- **It does not retire the standing §6 conditionality caveat, and no §6 result may be described as
  discharged.** Every §6 result below Lemma 2 remains conditional on `IsContempEquivDense ε`;
  **`epsTop` is still the only `ε` this tree can exhibit**; `EndsInGapOnRight` is **empty** for it;
  there is still **no live non-trivial instance**. What 22.1 removes is **one named hypothesis**
  (`HasBadIntervalSurgery`, introduced by Phase 22) and, **at one named structure**, the Prior-U/S
  half. **The `ε` half stands until Phase 25.** The caveat text is rewritten to say exactly that
  and is **not deleted** from any module header that carries it.
- It does not re-open the route, the terminus, the amputation, v8's Block D decisions, v9's Block F
  decisions, or D13.
- It does not change any `[COMPLETED]` phase heading, delete any completed record, renumber any
  phase, re-sequence any dependency, or alter any per-phase timing.
- It does not touch the pinned `consequence_completeness_dedekind_of_engine` signature.
- It does not weaken, rename or remove any landed declaration in `DenseModelSurgery/` — in
  particular `firstClassFormula` and `IsFirstClassPoint` are untouched.

---

## Revision Rationale (v8 → v9)

**This is a targeted Block-F correction, not a re-plan.** The route, the terminus, Block D's
landed re-base and Blocks G-I's mathematics are unchanged and are not re-litigated. What changes
is the §6 duality accounting, because Phase 20 stalled on a dependency **this plan's own Phase 19
charter failed to schedule**.

### The deviation, and why it is the plan's fault rather than the implementation's

Reynolds states §6 Lemma 5 over maximal intervals of `R` **only**. Verified verbatim off the
printed p.179 page image at 200 dpi (`reports/08` §1.1):

> **LEMMA 5** *If a temporal formula holds somewhere in one ∼–class in a maximal interval of R,
> then it holds somewhere in each ∼–class in the interval.*
>
> *Furthermore, each pair of the ∼–classes in a maximal interval of R are elementarily equivalent
> ( taken as substructures of M ).*

There is no dual statement, no *"dually"*, and no `λ`-side variant anywhere on that page — and
the same holds for Lemmas 3 and 4. **This is Reynolds' own omission, not a transcription gap on
our side**, and it is deliberate: he sets up a global duality convention early (printed p.178,
*"Dually we can define λ(x) about left ends."*; Lemma 2 closes with the bare sentence
*"Dually L."*) and then states Lemmas 3-5 on one side, collecting all four duals at once with the
single sentence that closes Lemma 6 (printed p.180): *"Using mirror images of the above and
previous results we get our proof."*

v8's Phase 19 chartered the `ρ` side only, faithfully following the printed statement. v8's Phase
20 then chartered Lemma 6 as one checkbox ending *"Then mirror images"*. But *"previous results"*
in that sentence **provably refers to Lemma 5 over maximal intervals of `λ`** — it is the only
result in §6 that gets *"all classes include their left hand end points"* out of one class doing
so, which is exactly the step Reynolds' p.180 argument runs (`reports/08` §1.2 parses every
referent). **Phase 20 therefore could not have succeeded as written.** The blocker is a planning
defect, and correcting the plan is a precondition for any further implement cycle — not an
optional tidy-up afterwards.

### What Phase 20 actually landed (nothing is lost)

Phase 20 is `[PARTIAL]`, not failed, and everything below is landed, green, committed and
sorry-free:

- **Lemma 7, both halves** — including a **258-line hand-written mirror**
  (`BadIntervals.lean:968-1225`) for Reynolds' *"Similarly at the end"*, plus `reynolds_lemma7`
  (`:1230`).
- **Lemma 6, three of four halves** — `reynolds_lemma6_nonsingleton` (`:677`),
  `endsInGapOnLeft_of_endsInGapOnRight` (`:615`), `reynolds_lemma6_right_endpoint` (`:1275`),
  assembled as the three-conjunct `reynolds_lemma6` (`:1322`) over `ClassInteriorToRInterval`.
- The *bad point* / *bad interval* vocabulary, `ClassInteriorToBadInterval` (`:1017`), and the
  third gap-crossing form `false_of_holds_throughout_class_from_bounded`.
- **No `sorry`, no vacuous placeholder, no `def X := True`.** The gap is recorded in the module
  header and in the phase's blocker block, and the tree is green.

The missing fourth half is `R` wherever `L` — a mirror theorem over a `ClassInteriorToLInterval`
that **does not exist in the tree** (`grep`-confirmed at this revision: `BadIntervals.lean`
defines `ClassInteriorToRInterval` at `:416` and `ClassInteriorToBadInterval` at `:1017`, and no
`L` counterpart).

### The sizing was wrong by ~3×, and the corrected figure changes which route wins

The Phase 20 handoff sized the residual at *"~180 lines"*. `reports/08` §2.1 measured the actual
R-side spans that would have to be mirrored and found **two** chains, not one:

| Chain | File | Measured R-side residual |
|---|---|---:|
| 1 — `reynolds_lemma5_first_left` and its supports | `Lemma5.lean` | ~273 lines |
| 2 — the fourth half's own mirror chain (**omitted by the handoff entirely**) | `BadIntervals.lean` | ~271 lines |
| **Hand-mirror total** | | **~540-590 lines** |

In-file precedent corroborates rather than contradicts: Phase 20's own Lemma 7 mirror is **258
lines for a chain roughly half the size of those two**. The handoff's ~180 figure was correct for
the sub-chain it named and simply did not cover the deliverable. **v9 uses the measured figure.**

### The cheaper route exists, is ~40% smaller, and 150 of its lines are already green

The repository has **no** `OrderDual` machinery anywhere — every past/future duality in
`WeakCanonical/` is hand-written, including the 364-line `Kamp/Lemma53FaithfulPast.lean` and the
258-line Lemma 7 mirror. The cheap route was never unavailable; it was never built. `reports/08`
built and compiled its core during that dispatch via `lean_run_code`: `dual`, `d`, `dual_carrier`,
`d_lt`, `dualize`, `eval_dualize`, `swapUS`, `temporalTruth_dual`, `swapUS_involutive`,
`semanticPriorU_dual`, `contempEquivDense_dual`, `endsInGapOnRight_dual` — **~150 lines green
with three trivial residual errors**. Total route ~350 lines, and it discharges *every* remaining
§6 mirror at ~25 lines each, not only this one.

**Fidelity points the same way, and that is the deciding argument, not the line count.** Reynolds
does not re-run the proof on the left; he writes *"using mirror images … we get our proof"*. An
`OrderDual` instantiation formalizes **that sentence**. A ~560-line hand mirror formalizes a proof
he did not write. Under this project's literature-fidelity standard route (a) is the more faithful
rendering as well as the cheaper one.

**The route is chartered with its gate intact, not on optimism.** One bounded attack landed
against it (`IsContempEquivDense` clause (iii) does not transport for free — see R14) and the
recommendation was modified after that attack, not before it. Phase 20.4 therefore carries a
**hard abort condition**, not a suggestion: if Group 1 does not reproduce green in-file on the
first dispatch, the phase falls back to the hand mirror immediately and does not iterate on the
transport layer.

### What v9 does, item by item

1. **Phase 19 gets a scope-gap annotation.** It stays `[COMPLETED]` — its charter was discharged
   in full and its output is landed and green. What is recorded is that the charter itself
   covered the `ρ` side only, why that was insufficient, and where the discharge now lives.
   **This is an annotation, not a reopening.**
2. **Phase 20's Lemma 6 task is split** into *"`L` wherever `R`"* (landed) and *"`R` wherever
   `L`"* (owned by Phase 20.4), with Lemma 5's `λ` side named as an explicit dependency instead
   of hiding inside a trailing clause. Phase 20 stays `[PARTIAL]`; its body now opens with a
   dispatch redirect.
3. **New Phase 20.4** charters the duality-transport route in three groups with the Group 1 gate
   and the chartered hand-mirror fallback (split into two sub-phases, since 540-590 lines exceeds
   the H8 one-run bound).
4. **New Phase 20.5** gives the D16 residual an owner. It was closed-as-correct in Phase 17 down
   to a one-page page-range nicety and then appeared in **no** `Owns` list for Phases 20-30 — it
   would never have been picked up.
5. **The Source-to-Implementation Mapping's §6 rows are corrected** to the measured page map.
   Phases 18, 19 and 20 each recorded the drift in their deviation records, but the plan's own
   table still carried the wrong values, and the table is what a fresh dispatch reads first.
6. **Preserved Assets gains a "New in v9" table** covering what Phases 17-20 landed, so no later
   phase rebuilds `relativizeAt`, `temporalToMonadic`, the gap-lemma family or the contemp
   helpers by hand.
7. **Phase 21 is confirmed unblocked and is explicitly de-serialized from Phase 20.4.** Lemma 8's
   thirteen cases consume Lemma 7, which is complete on both sides.
8. **Postmortem Constraints are extended, never relaxed**, with the carry-forward rules named
   below (D7, D11, the gap-lemma family, the §6 display-verification rule).
9. **Every still-dispatchable phase now carries a `Verification Tier`.** v8 had the field on three
   headings only. v9 adds it to Phases 20, 20.4, 20.5, 21, 22 and 23-30 — all `full` except Phase
   20.5, which is `prose` (comment bytes only, with the `git diff -U0` and `#print axioms` checks
   named as its blind-spot cover). **The 15 remaining validator warnings are on `[COMPLETED]`
   phases 9-19 and the retained "Phase 14.2 (original charter)" historical block, and are left
   deliberately**: retrofitting a verification tier onto an already-landed record would assert
   something about how that work was verified that this revision did not observe. This is a
   decision, not an oversight.

### What v9 does NOT do

- It does not re-open the route, the terminus, the amputation, v8's Block D decisions, or **D13**
  (closed by Phase 17's re-base-table rewrite onto the faithful eq (5.2) carrier — do not
  re-open).
- It does not change any `[COMPLETED]` phase heading, delete any completed record, or renumber
  any phase.
- It does not touch the pinned `consequence_completeness_dedekind_of_engine` signature.
- It does not weaken, rename or remove any landed declaration in `DenseModelSurgery/`.

---

## Revision Rationale (v7 → v8)

**This is a targeted Block-D-and-consumers correction, not a re-plan.** The route is unchanged and
is not re-litigated. Phases 15-30 (Blocks E-I) carry forward with their numbering, territory,
timings and verification gates intact. What changes is Block D, because Phase 10 landed and what it
found does not match what v7 assumed.

### The three findings that force the revision

Verbatim from `handoffs/phase-10-handoff-20260728.json`:

1. **`severity: resolved`** — *"THE SINGLE POINT OF FAILURE HELD. `prior_hasDenseDedekindINF_dense`
   and `prior_hasDenseDedekindSUP_dense` are sorry-free and axiom-clean from `SemanticPriorU` /
   `SemanticPriorS` alone, with no discreteness, no attainment and no flow completeness."*
   R1 is discharged. The route is live.
2. **`severity: plan_amendment_needed`** — *"DOWNSTREAM CONSUMES THE TRICHOTOMY, NOT THE GUARDED
   FORM. Every `.first_occ`/`.last_occ` call site outside `Boneyard/` reaches the call from a
   `by_cases` on interior occurrence of `P` in `(z₀,z₁)`, with no hypothesis about `z₀` in
   scope."* Independently re-verified at this revision at all three by-cases-reached sites
   (`Lemma53Faithful.lean:274`, `NegFixOneFaithful.lean:422`, `NegFixListFaithful.lean:446`).
3. **`severity: plan_amendment_needed`** — *"UNPLANNED, MATERIAL TO PHASES 11-13: an
   `EANegationFixFaithful/` subtree plus `Lemma53Faithful.lean` and `Prop42Faithful.lean` ALREADY
   EXIST in-tree and ALREADY consume `HasDedekindINF` … Because they are pinned at the UNGUARDED
   carrier they cannot be instantiated at any dense Prior structure. Phases 11-13 should be
   re-scoped against what is actually on disk before dispatch."*

Finding 3 is the largest single planning error corrected here. v7's Phases 11-13 were chartered to
**build** `OnBuilderFaithful.lean`, `NegFixFaithful.lean` and `VecEANegFixFaithful.lean` from
scratch, ~990 lines, ~19 hours. **Eight faithful modules totalling 3,388 lines already exist,
sorry-free and CI-protected.** The work was never construction; it is a carrier re-base.

### The fourth finding, made at this revision: the tree's `kplus` is not the sources' `K⁺`

Phase 10's handoff records a third route-critical item — that Rabinovich's *"`r₀ = z₀` iff
`K⁺(P₁)(z₀)`"* (PDF p.8) is *"FALSE read literally"*. **That attribution is wrong, and correcting
it is what makes Block D tractable.** Read verbatim from the corpus at this revision:

| Source | Location | Verbatim |
|---|---|---|
| Rabinovich 2014 | `chunk_0007.md:33` | *"`K+(F)` (respectively, `K−(F)`) is an abbreviation for `¬((¬F)UntilTrue)` (respectively, `¬((¬F)SinceTrue)`)."* |
| Rabinovich 2014 | `chunk_0007.md:39` | *"(3) `K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`."* |
| Reynolds 1992 | abbreviations table, §1, **printed p.168** (**re-verify against the PDF before it lands in a docstring**) | `K⁺A` — *"for `¬U(⊤,¬A)`"* — reading *"`A` will be true arbitrarily soon"* |

**Neither source's `K⁺` carries a `¬A` conjunct at the point of evaluation.** Under Rabinovich's
own Definition (3), *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is not an error at all — it is a **definitional
restatement**, true verbatim.

**And this tree already knows it.** `Formula.kPlus` (`FormalSystem/Syntax/Formula.lean:180`) is
`(untl ⊤ φ.neg).neg` — the source-exact, conjunct-free `K⁺` — and its docstring (`:163-179`) cites
Reynolds' abbreviation table at **printed p.168** and GHR 1994 §10.3.1, carrying an explicit
**name-collision warning**: it is *not* the same operator as `PriorINF.lean`'s `kplusFormula`, which
carries the extra `¬P` conjunct, and *"substituting one for the other silently transcribes a
different axiom."* `Formula.kMinus` (`:193`) is the mirror.

**The seam runs straight through Block D, and no bridge lemma exists anywhere in the tree:**

| Layer | `K⁺` used | Anchor |
|---|---|---|
| The **axioms** — `Axiom.prior_U_gap`, `Axiom.prior_S_gap`, `Axiom.sep` | `Formula.kPlus` / `Formula.kMinus` — **conjunct-free** | `ProofSystem/Axioms.lean:377`, `:387`, `:390` |
| The **Prop-level carrier** — `kplus`, `kplusFormula`, `HasDedekindINF` and all eight faithful modules | conjunct-**carrying** | `PriorINF.lean:86`, `:92-94`; `DedekindINF.lean:136` |
| **Bridge between them** | **none exists** | — |

`kplus` and `kplusFormula` are internally coherent with each other — `kplus_formula_correct`
(`Lemma53.lean:162-179`) proves them equivalent, sorry-free. **The mismatch is external**: the
carrier apparatus transcribes a different `K⁺` from the one the axioms are stated with, and the
tree's own docstring forbids exactly that substitution. Phase 9's `SemanticPriorU` is the semantic
reading of an axiom stated with the conjunct-free `Formula.kPlus`; Phase 10 landed its consequence
into a carrier stated with the conjunct-carrying `kplus`. Every symptom Phase 10 observed sits on
that seam.

**v8 takes the probe position, explicitly.** Phase 10.1 is chartered to land the missing Prop-level
`kplusOpen` **as the semantic reading of the already-existing `Formula.kPlus`**, to land the
**missing bridge lemma**, and to **re-run the interval-witness refutation against the conjunct-free
antecedent** — determining by machine, not by argument, whether the guard/trichotomy apparatus is
needed at all. The plan's central bet (R11) is falsifiable in that one dispatch and on the smallest
site. It is not assumed anywhere downstream: both carriers stay landed, and the fallback to the
trichotomy is chartered rather than improvised.

This tree's `kplus` (`FormalSystem/Metalogic/WeakCanonical/Kamp/PriorINF.lean:86`) is:

```lean
def kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ¬TemporalTruth M atomMap t P ∧
  ∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r < s ∧ TemporalTruth M atomMap r P
```

— **strictly stronger than either source's `K⁺`**, by the added first conjunct. Its own docstring
says *"but not at `t` itself"*, and the comment block immediately above it
(`PriorINF.lean:75-81`) records the author mid-doubt: *"Actually wait, the Rabinovich paper uses
the notation differently."* The doubt was correct and was never resolved.

**Everything Phase 10 discovered follows from that one added conjunct, and from nothing in the
mathematics.**

- `hasDedekindINF_fails_of_interval_witness` (`DedekindINFDense.lean:455`) is a **true theorem
  about the tree's `kplus`**. At `z₀ = 1/2` on `denseWindowFlow` with `P` true exactly on `(0,1)`,
  the left disjunct `kplus M atomMap P z₀` fails *only because* `P(z₀)` holds. Under the sources'
  `K⁺` the left disjunct **holds** there — `P` is true arbitrarily soon after `1/2` — and there is
  no failure to refute.
- The endpoint guard `¬P(z₀)`, the trichotomy `HasDenseDedekindINF`, and the third disjunct
  `P(z₀)` are therefore **repairs for a formalization-level deviation**, not dense-case
  mathematical content. Phase 10's docstring calls them "original glue"; that label is right, and
  v8 records *what they are glue for*.

### Why this is decision-grade rather than cosmetic

The survey found that re-basing the two hardest consumers —
`negFixOneFaithful_cover` (`NegFixOneFaithful.lean:422`) and `negFixListFaithful_iff`
(`NegFixListFaithful.lean:446`) — **onto the trichotomy needs genuinely new proof branches**,
because their `Case1 / Case2 / Case3a/b/c` structure has no slot for a "`P` holds at `z₀`" case.
That is real, unbounded work, and it exists only because the third disjunct is uninformative:
**`P(z₀)` does not imply `r₀ = z₀`**, so a consumer that lands in it learns nothing it can use.

Onto the **source-exact `K⁺`** the same two consumers keep a **two-arm** case split — the identical
shape they have today — because the faithful carrier is a *dichotomy*, not a trichotomy. The only
change at a consumer is the *content* of the left disjunct. And the tree already discards the part
that changes: `orderedPointsExist_combine_kplus` (`Lemma53Faithful.lean:137`) opens its `kplus`
hypothesis as

```lean
  obtain ⟨-, hdense⟩ := hk
```

— the `¬P(z₀)` conjunct is **thrown away unused** at the one place disjunct (2)'s content is
consumed.

**The dichotomy is also derivable, hypothesis-free, from `SemanticPriorU` alone** — the same input
Phase 10 already used. Paper derivation at this revision (transcribe and verify; do not treat as
established): given `P` occurring in `(z₀,z₁)`, either `P` occurs arbitrarily soon after `z₀`
(the faithful left disjunct, done), or some `(z₀,s)` is `P`-free, in which case `U(⊤,¬P)(z₀)` and
`F(¬¬P)(z₀)` hold, `SemanticPriorU` at `p := ¬P` fires, and its conclusion is eq (5.2) verbatim.
No guard is needed at any step, because the case split is on the *interval*, never on `z₀`.

### What v8 does, item by item

1. **The route is unchanged.** Doets, per the user's authorization on `reports/07` verdict (b).
   Not re-opened, not re-litigated, not re-costed.
2. **Phases 9 and 10 are `[COMPLETED]` history.** Their records are preserved below in compressed
   form with their deviation annotations intact. **Nothing landed by them is deleted, reverted,
   restated or regenerated.** `DedekindINFDense.lean` and `PriorDefsDense.lean` are Preserved
   Assets from this revision forward.
3. **A new Phase 10.1 lands the source-exact `K⁺` and the faithful dichotomy carrier** beside the
   trichotomy — `kplusOpen`, `HasFaithfulDedekindINF`/`SUP`, `prior_hasFaithfulDedekindINF_dense`,
   and the shim lattice relating all four carriers. Dense siblings, nothing generalized in place.
4. **Phases 11, 11.1, 12, 12.1, 13 re-base the eight existing faithful modules** onto that carrier,
   in import-chain order, one bounded unit per phase. v7's from-scratch charters for 11-13 are
   **withdrawn as factually wrong about the tree**.
5. **Phase 10.1 also corrects two docstrings**, narrowly and by comment bytes only, so the tree
   stops asserting that a source is wrong where the source is right. This is mandatory under the
   honesty charter, which is a binding user directive.
6. **Phase 14 is re-scoped** to compose the re-based chain and `prior_hasFaithfulDedekindINF_dense`.
   Its goal, owned module and `Done when` are otherwise unchanged.
7. **Phases 15-30 are carried forward unchanged** in goal, territory, tasks, estimates, timings and
   dependencies. The only edits are dependency-arrow updates where a Block D phase number moved.
8. **The Postmortem Constraints are extended, never relaxed**, with five new binding rules drawn
   from Phase 10 (below). One existing constraint — "dense siblings, never in-place generalization"
   — is **narrowed, explicitly and with reasons**, for the eight `*Faithful*` modules only.
9. **A fallback is chartered, not assumed.** If Phase 11's measurement shows the faithful
   dichotomy does *not* collapse the case split at `NegFixOneFaithful.lean:422` /
   `NegFixListFaithful.lean:446`, the phases fall back to the trichotomy with explicit endpoint
   branches, and split under the R2 decomposition protocol. See R11.

### What v8 does NOT do

- It does not re-open the route, the terminus, the amputation, or any of v7's SETTLED decisions.
- It does not delete, revert, weaken or regenerate anything Phases 9 and 10 landed.
- It does not edit `kplus`, `kplusFormula` or `kplus_formula_correct` — the discrete pipeline
  depends on them and they are internally consistent with each other.
- It does not touch Blocks E-I's mathematics.

---

## Overview

The terminus pair is `consequence_completeness_dedekind : SemanticConsequenceDedekindDense Γ φ →
Derivable FrameClass.Dedekind Γ φ` with `completeness_dedekind` — the class headline, weak
completeness — as its `Γ = []` instance. Both are obtained by instantiating the **already landed
and pinned** `consequence_completeness_dedekind_of_engine` (`StrongCompleteness.lean:274`), whose
engine binder is

```lean
(engine : ∀ ψ : Formula, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)
```

— **per formula**, which is exactly the shape Reynolds' Theorem 7 produces (`k` is chosen from the
single formula's table). Nothing about the Doets route requires a uniform model and nothing about
the engine asks for one.

**The route, from the source.** Reynolds 1992 §9, Theorem 7, printed p.189, verbatim:

1. *"First use Burgess–Xu Corollary 1 to furnish us with a structure `M₀` such that 1. the flow of
   time of `M₀` is the rationals, 2. `M₀ ⊨ A₀(0)` and 3. all substitution instances of the axioms
   Prior-U, Prior-S and Sep are valid in `M₀`."*
2. *"By ignoring all the atoms which don't appear in `A₀` we have a temporal structure `M` from a
   finite language. `M` is still a model of `A₀`."*
3. *"The flow of time of `M` is countable, dense and without end points and D1 and D2 follow from
   the theorems 4 and 5. Thus we can apply Doets' theorem."*
4. *"Let `k` be one greater than the quantifier depth of the table `α(t)` of `A₀`. We have a
   temporal structure `R`, with flow of time the reals, satisfying the same monadic sentences of
   quantifier depth at most `k` as `M` does."*
5. *"Thus `R` like `M` is a model of `∃t α(t)`. Say `b ∈ R` and `R ⊨ α(b)`. We have `R ⊨ A₀(b)` as
   promised."*

Step 1 is **already landed** (`cantorBfmcsDense` and its three coherence theorems). Steps 3-5 are
the content of Phases 9-30, of which Phases 9 and 10 are done.

**Definition of done**: `FormalSystem/Metalogic/StrongCompleteness.lean` contains a sorry-free
`consequence_completeness_dedekind` with `completeness_dedekind` as a corollary; full `lake build`
green; `#print axioms consequence_completeness_dedekind` shows exactly
`[propext, Classical.choice, Quot.sound]`.

### Programme scale and the phase-count ceiling

**This plan deliberately exceeds the hard-mode phase-count ceiling of 8, and the deviation is
declared rather than smuggled.** The ceiling exists to stop plans inflating either phase *count* or
phase *size* rather than admitting scope. Here the opposite discipline is applied: **phase size is
held to one bounded, independently verifiable unit each** (H8's primary criterion), and the count
is whatever that discipline produces. Compressing 25 bounded units into 8 phases would mean phases
of ~1000 lines apiece with open-ended attempt surfaces — the exact failure mode that consumed
dispatches earlier in this task.

v8's four added units are the *consequence of applying the ceiling honestly*, not of relaxing it:
the eight faithful modules form a **strictly linear import chain**
(`Lemma53Faithful → BoundedFixFaithful → BoundedFixAnchoredFaithful → NegFixOneFaithful →
NegFixListFaithful → VecEANegFixFaithful → Prop42Faithful`, with `Lemma53FaithfulPast` joining at
`Prop42Faithful`), so the tree cannot be left green with a partial sweep. Each phase must end at a
chain boundary.

The evidence for the overall scale is measured, not guessed. The `.Discrete` counterpart of this
route — Reynolds Theorem 9, which needs only D1 and gets it by a *discreteness shortcut*
unavailable here — cost **2215 lines** in `IntegerModel/GoodStructuresModelSurgery.lean` and
**1155 lines** in `IntegerModel/ReynoldsBridge.lean`. The dense case additionally needs D2 (§7),
the full §6 bad-interval argument with no shortcut, Doets' shuffle, and an order-theoretic
characterization of `ℝ` that Mathlib does not contain.

**Consequence for dispatch.** Each phase below is one agent run. Phases are grouped into five
labelled blocks; a block boundary is a natural checkpoint at which the orchestrator may stop with
the task at `[PARTIAL]` and a fully honest state, because every phase ends with the tree green and
the live sorry count unchanged. If the orchestrator's budget runs out mid-programme, that is a
`[PARTIAL]` with a named next phase, **not** a blocker.

| Block | Phases | Content | Source |
|---|---|---|---|
| **D** | 9-14 (incl. 10.1, 11.1, 12.1) | Expressive completeness of `{U,S}` at the **dense** Prior carrier | Reynolds §5 Thm 3; Rabinovich Lemma 5.3 / 5.1 / Prop 4.2 |
| **E** | 15-16 | The dense monadic bridge: chronicle → `OrderedMonadicStructure` over `ℚ`, with Prior-U/Prior-S/Sep semantically valid | Reynolds §4 Cor 1, §9 steps 1-2 |
| **F** | 17-22 (incl. **20.4**, **20.5**, **22.1**) | **D1** — `∼`-classes do not end at gaps, on a dense Prior structure | Reynolds §6 Lemmas 2-9, Theorem 4 |
| **G** | 23 | **D2** — `Sep` ⇒ dense set of singleton classes | Reynolds §7 Theorem 5 |
| **H** | 24-29 | Doets' Theorem: `D1 + D2 ⇒ ∀k` an `ℝ`-flowed `≡ₖ` structure | Reynolds §8 Lemmas 11-13 + shuffle; Doets 1987 **3.3.9** |
| **I** | 30 | The engine and the terminus | Reynolds §9 Theorem 7 |

### Faithful-Subtree Survey (read-only, this revision)

**This section is the correction to v7's factual error about the tree, and it is binding: no phase
may plan against a module inventory it has not re-checked.** Every anchor below was produced by a
read-only survey at this revision and spot-checked against the tree. An implementer who finds an
anchor stale re-locates by name and records the drift; it is never a licence to re-plan.

| Module (all under `FormalSystem/Metalogic/WeakCanonical/Kamp/`) | Lines | `HasDedekind*` hypothesis sites | Destructure sites | Re-base difficulty |
|---|---|---|---|---|
| `Lemma53Faithful.lean` | 391 | `:230`, and inside `lemma53Faithful` (`:~318`) | **`:274`** (`negChainOnFaithful_iff`, by-cases-reached) | **One-arm**: the `kplus` primitives (`kplusPred :81`, `kplusPred_eval :83`, `kplusLeftBlock :~186`, `orderedPointsExist_combine_kplus :137`) all live here and are re-pointed once |
| `Lemma53FaithfulPast.lean` | 364 | `:173` | `:181` (`HasDedekindSUP.last_occ_tp`, **unconditional wrapper**) | **One-arm**, mirror. **Absent from the Phase 10 handoff's list — do not omit it** |
| `EANegationFixFaithful/BoundedFixFaithful.lean` | 371 | `:188`, `:258` | — | **Pure signature swap** (delegates without destructuring) |
| `EANegationFixFaithful/BoundedFixAnchoredFaithful.lean` | 355 | `:150`, `:230` | — | **Pure signature swap** |
| `EANegationFixFaithful/NegFixOneFaithful.lean` | 726 | `:156`, `:247`, `:339`, `:403`, `:488` | `:164` (`first_occ_tp` wrapper, unconditional); **`:422`** (`negFixOneFaithful_cover`, by-cases-reached) | **The hard site.** `Case1/Case2/Case3a/b/c` split with **no slot** for an endpoint case |
| `EANegationFixFaithful/NegFixListFaithful.lean` | 584 | `:335` | **`:446`** (`negFixListFaithful_iff`, by-cases-reached) | **The second hard site**, same reason |
| `EANegationFixFaithful/VecEANegFixFaithful.lean` | 314 | `:105`, `:138`, `:207`, `:234` (+ shim use `:312`) | — | **Pure signature swap** |
| `Prop42Faithful.lean` | 283 | `:142`, `:167` | — | **Pure signature swap** |
| **Total** | **3,388** | **19 declarations** | **5 sites, 3 by-cases-reached** | — |

**Facts that constrain every Block D phase:**

- **Zero sorries** in all eight modules (every `grep` hit is prose about the anti-vacuity failure
  mode). The sorry census outside `Boneyard/` stays exactly `Transfer.lean:1242`.
- **The whole family is CI-protected** via `NfMultiAnchorBridge.lean` — imports at `:7-18` and
  continuing *inside* a `NOTE` comment block at `:238`, `:252`, `:275`, `:297`, `:320`, `:345`
  (valid Lean; interleaving imports with comments is legal). A red faithful module reddens the
  build.
- **`WeakCanonical.lean:20-21`** directly imports `PriorDefsDense.lean` and `DedekindINFDense.lean`
  — a second CI edge, added by Phases 9 and 10.
- **`DedekindINFDense.lean` currently has no faithful-family consumer.** Its only importer is
  `WeakCanonical.lean:21`. Phase 10's carrier is landed and **unconsumed**; connecting it is
  exactly what Block D now does.
- **The three by-cases-reached sites have no left-endpoint hypothesis in scope**, re-verified.
  Phase 10's framing is confirmed.
- **The faithful family is currently unobservable on the discrete pipeline.**
  `prior_makes_disjunct2_unreachable` (`Lemma53Faithful.lean:382`) proves that under
  `SemanticPriorUZ`, `¬kplus M atomMap P z₀` holds whenever `P` occurs in `(z₀,z₁)` — so
  disjunct (2) *never fires* there; the mirror is
  `prior_makes_kminus_disjunct_unreachable` (`Lemma53FaithfulPast.lean:355`). This is the
  machine-checked statement of why the re-base is safe for the discrete pipeline **and** of why
  the dense carrier is the thing that finally makes the faithful modules do work.

### Preserved Assets

Complete, verified, and must not regress. No phase rewrites, generalizes, or "cleans up" any row.
Line anchors are as of this revision; an implementer who finds an anchor stale re-locates by name
and records the drift, never edits the target.

**New in v8** (landed by Phases 9 and 10; these rows did not exist in v7):

| Component | File / Anchor | Status | Verified |
|---|---|---|---|
| `SemanticPriorU`, `SemanticPriorS`, `semanticPriorUZ_fails_of_interval_witness`, `semanticPriorUZ_fails_on_dense`, `semanticPriorU_of_flowGLB`, `semanticPriorS_of_flowLUB`, `densePriorU_antecedent_reachable`, `denseWindowFlow`, `densePriorAtomMap` (11 declarations) | `WeakCanonical/PriorDefsDense.lean` (407 lines) | [COMPLETED] Phase 9. Sorry-free, `[propext, Classical.choice, Quot.sound]` (exclusion lemma `[propext]` only). **The dense Prior hypotheses and the vacuity witness.** Not edited by any later phase | 2026-07-28 |
| `HasGuardedDedekindINF` (`:128`), `HasDenseDedekindINF` (`:187`), `HasDenseDedekindSUP` (`:201`), `HasDedekindINF.toHasDenseDedekindINF` (`:274`), `prior_hasDenseDedekindINF_dense` (`:428`), `prior_hasDenseDedekindSUP_dense` (`:434`), `hasDedekindINF_fails_of_interval_witness` (`:455`), `denseWindow_endpoint_disjunct_forced`, and the rest of the 32 declarations | `WeakCanonical/Kamp/DedekindINFDense.lean` (631 lines) | [COMPLETED] Phase 10. Sorry-free, axiom-clean, **the route's single point of failure discharged**. **Nothing here is deleted, reverted or restated by v8.** Phase 10.1 may edit **comment bytes only**, in the narrow correction chartered there | 2026-07-28 |

**New in v9** (landed by Phases 17-20; these rows did not exist in v8, which was written before
Block F ran). Line anchors are as reported by the Phase 17-20 records and re-checked against the
tree at this revision where noted; an implementer who finds an anchor stale re-locates **by name**
and records the drift. **No phase below rebuilds any of these by hand.**

| Component | File / Anchor | Status |
|---|---|---|
| `ContempEquivDense`, `IsContempEquivDense` (clause (iii) `contemporary` at `:242`), `rhoFormula` (printed three-conjunct form), `lambdaFormula` (this tree's mirror — Reynolds prints no `λ`), `EndsInGapOnRight` (`:307`), `EndsInGapOnLeft` (`:317`), `reynolds_lemma2` (`:417`), `reynolds_lemma2_dual` (`:428`), `epsTop` (`:479`) | `DenseModelSurgery/Defs.lean` (503 lines) | [COMPLETED] Phase 17. Sorry-free. **Carries the "CORRECTION TO THE LOCAL CORPUS" record for `ρ`'s missing middle conjunct** |
| `reynolds_lemma3` and its four component theorems, `reynolds_lemma3_right` / `_left`, `reynolds_lemma4`, `classBeginsAtGapStartFormula`, `endsInGapOnRight_congr`, and the four contemp helpers `contemp_refl` / `contemp_symm` / `contemp_trans` / `contemp_of_between` (`:176-199`) | `DenseModelSurgery/Lemma34.lean` (957 lines) | [COMPLETED] Phase 18. Sorry-free. **The four contemp helpers are the whole of §6's access to `IsContempEquivDense` — every §6 use goes through `hε.equiv` / `hε.convex`, never clause (iii)** |
| `reynolds_lemma5_first` (`:591`), `reynolds_lemma5_second` (`:782`), `reynolds_lemma5` (`:805`); `kMinusFormula` / `KMinusAt` / `_eval` (`:243-268`); `classBeginsWith…` → `classLeftEndKMinusTemporal` + specs (`:271-378`); `holdsSomewhereInClassFormula` (`:300`); `exists_bound_notHolds` (`:451-479`); `false_of_classInvariant_changes` (`:510-582`) | `DenseModelSurgery/Lemma5.lean` (820 lines) | [COMPLETED] Phase 19. Sorry-free. **`ρ` side only — see the Phase 19 scope-gap annotation** |
| **`temporalAt` / `temporalToMonadic` + `eval_temporalAt`** — the temporal→monadic direction of expressive completeness, **previously absent from the tree** (only the hard monadic→temporal direction was landed, as `uSExpressivelyCompleteOverDensePrior`) | `DenseModelSurgery/Lemma5.lean` | [COMPLETED] Phase 19, **unplanned**. Reusable by any later phase needing to build a temporal formula from a monadic one. **Do not rebuild** |
| **`relativizeAt` / `evalOn` / `eval_relativizeAt`**, with `relativizeToClass` as the sentence case — relativization at **arbitrary arity** | `DenseModelSurgery/Lemma5.lean` | [COMPLETED] Phase 19, **beyond charter**. **Phase 25's two-variable `γ(z,t)` is already prepaid** — Phase 25 instantiates, it does not build |
| `IsBadPoint`, `IsBadInterval` + `IsBadInterval.maximal_among`, `badPointFormula`; `ClassInteriorToRInterval` (`:416`), `ClassInteriorToBadInterval` (`:1017`); `NotLeftEnd` / `notLeftEndFormula` / `notLeftEndTemporal` (`:332-375`); `not_endsInGapOnRight_of_immediatePredecessor` (`:390-414`); `leftEnd_iff_exists_not_notLeftEnd` (`:444-458`); `exists_leftEnd_throughout` (`:466-486`); `false_of_allClassesHaveLeftEnd` (`:514-595`) | `DenseModelSurgery/BadIntervals.lean` (1343 lines) | [COMPLETED] Phase 20 (the landed part). Sorry-free |
| `endsInGapOnLeft_of_endsInGapOnRight` (`:615-670`), `reynolds_lemma6_nonsingleton` (`:677`), `reynolds_lemma6_right_endpoint` (`:1275`), **`reynolds_lemma6` (`:1322`) — three of four conjuncts, over `ClassInteriorToRInterval`** | `DenseModelSurgery/BadIntervals.lean` | **[PARTIAL] Phase 20.** The fourth half is Phase 20.4's deliverable. **`reynolds_lemma6`'s three landed conjuncts are Preserved Assets: Phase 20.4 EXTENDS its conclusion, and may not restate, reorder or weaken what is there** |
| **The Lemma 7 mirror, `BadIntervals.lean:968-1225` (258 lines, hand-written)**, plus `endsInGapOnLeft_congr` (`:975`), `exists_contemp_lt` (`:1005`), `false_of_holds_throughout_class_upto_bounded` (`:1027`), the `beforeNotHoldsInClass*` family, and `reynolds_lemma7` (`:1230`) | `DenseModelSurgery/BadIntervals.lean` | [COMPLETED] Phase 20. **Complete on BOTH sides — this is why Phase 21 is not blocked.** It is also the measured precedent for the hand-mirror cost estimate, and Phase 20.4's transport layer retrospectively subsumes it (see the `Dual.lean` note below) |

**The three gap-crossing lemmas are now a FAMILY, and every later phase must pick deliberately.**
They differ only in their preconditions, they are easy to confuse, and Phase 20 already found by
measurement that Lemma 7 licenses **neither** of the first two. No phase may assume the unbounded
form.

| Lemma | Landed by | Precondition on the auxiliary formula holding (`hin`) | Precondition on it failing (`hout`) |
|---|---|---|---|
| `false_of_holds_throughout_class` | Phase 18, `Lemma34.lean` | **Unbounded** — true *throughout* the class | **Unbounded** — false at **every** point outside the class reachable with `R` throughout in between |
| `false_of_holds_throughout_class_bounded` | Phase 19, `Lemma5.lean:400-435` | unbounded (throughout the class) | **Bounded** — false only *"for a while after"*, licensed by `exists_bound_notHolds` |
| `false_of_holds_throughout_class_from_bounded` | Phase 20, `BadIntervals.lean` | **Bounded** — only from some `s` onwards inside the class | **Bounded** — *"false arbitrarily soon after the gap"*: a failure point at or below each given point beyond the class |
| `false_of_holds_throughout_class_upto_bounded` | Phase 20, `BadIntervals.lean:1027` | the Prior-S / past-directed mirror of the bounded form | — |

**All four are left in place unweakened and unrenamed, and every existing consumer is untouched.**
This is the D11 rule in action (below): the later, weaker forms were *landed as new names*, never
substituted for the earlier ones.

**New shared infrastructure, chartered by Phase 20.4: `DenseModelSurgery/Dual.lean`.** Once landed
it is a Preserved Asset from that phase forward, and it **retrospectively subsumes the two
hand-written past/future mirrors already paid for** — `BadIntervals.lean:968-1225` (258 lines) and
`Kamp/Lemma53FaithfulPast.lean` (364 lines). Neither is deleted or refactored; the point of
recording it is that **no future phase derives a third mirror by hand**. Every remaining §6
*"mirror image"* Reynolds waves at — Lemma 3's dual, Lemma 4's dual, and Lemma 5's — becomes an
instantiation at `(dual M, dualize ε)` of roughly 25 lines.

**Carried forward from v7** (unchanged; the authoritative long form with per-row commentary is
`plans/07_strong-completeness-dedekind-v7.md` §"Preserved Assets", which neither v8 nor v9 amends):

| Component | File / Anchor | Status |
|---|---|---|
| **`consequence_completeness_dedekind_of_engine`** (`:274-279`), `completeness_dedekind_of_engine` (`:308`), `soundness_dedekind_consequence` (`:292`), `SemanticConsequenceDedekindDense` (`:128`) | `Metalogic/StrongCompleteness.lean` (342 lines) | [COMPLETED] commit `bd9ae0ac1`. **The terminus, untouched. The pinned signature may not be restated, reordered or re-bound** |
| `real_lub_of_bddAbove` (`:127`), `dedekind_box_dense_mem` (`:149`) | `BXCanonical/CompletenessDedekind.lean` (166 lines) | [COMPLETED] the `D := ℝ` facts Phase 30 needs |
| `ValidDedekindDense` | `Semantics/Validity.lean:255` | [COMPLETED] |
| **`Chronicle.cantorBfmcsDense`** (`:552`), `rootedCantorFmcsDense` (`:500`), `rooted_cantor_fmcs_dense_at_s` (`:513`), `cantor_bfmcs_dense_restricted_tc` (`:629`), `_buc` (`:680`), `_fuc` (`:755`) | `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` (1222 lines) | [COMPLETED] **Reynolds' §4 Corollary 1. Stays at `Rat`; file stays byte-identical** |
| `limit_satisfies_c5_strong` (`:1531`), `limit_satisfies_c5'_strong` (`:1575`), `omegaChain` (`:283`) and the rest | `BXCanonical/Chronicle/ChronicleConstruction.lean` (1613 lines) | [COMPLETED] **byte-identical** |
| **`uSExpressivelyCompleteOverPrior`** (`:357`), `stavi_U_false_on_prior_UZ` (`:90`), `stavi_S_false_on_prior_SZ` (`:143`), `flatten_stavi_correct_prior` (`:211`) | `WeakCanonical/PriorExpressiveness.lean` (372 lines) | [COMPLETED] **Pinned at `SemanticPriorUZ`/`SemanticPriorSZ`, FALSE on dense flows — Block D builds a dense sibling and does not edit this file** |
| `StaviUTruth` (`:79`), `StaviSTruth` (`:110`), `StaviFormula` (`:140`), `flattenStavi` (`:446`), `flatten_stavi_correct` (`:497`) | `WeakCanonical/StaviConnectives.lean` (583 lines) | [COMPLETED] |
| `SemanticPriorUZ` (`:28`), `SemanticPriorSZ` (`:39`) | `WeakCanonical/PriorDefs.lean` (47 lines) | [COMPLETED] the **integer** Prior axioms. **Not edited** — the tree's deliberate import-cycle breaker |
| `HasDedekindINF` (`:136`), `HasDedekindSUP` (`:153`), `HasAttainedINF.toHasDedekindINF` (`:172`), `HasDefinableINF.toHasDedekindINF` (`:185`), `hasDedekindINF_admits_kplus_shape`, `prior_hasDedekindINF` (`:232`), `prior_hasDedekindSUP` (`:240`) | `WeakCanonical/Kamp/DedekindINF.lean` (291 lines) | [COMPLETED] **statements and proofs not edited**; Phase 10.1 may not touch this file at all |
| `kplus` (`:86`), `kplusFormula` (`:~93`), `kminus` (`:98`), `HasDefinableINF` (`:114`), `HasAttainedINF` (`:208`), **`prior_hasAttainedINF` (`:230`)** | `WeakCanonical/Kamp/PriorINF.lean` (296 lines) | [COMPLETED] **`kplus`'s statement is NOT edited** (the discrete pipeline depends on it). Phase 10.1 corrects its **docstring only** |
| `kampPriorExpressiveCompleteness` (`KampPrior.lean:672`), `nf_nvar_exist_all_depths` (`:363`, carries `hn : n ≤ 1`), `nfCharacterizableTemporalPrior` (`:589`), `Kamp/EANegationFix/**`, `Kamp/NfMultiAnchorBridge/**` | `WeakCanonical/Kamp/**` | [COMPLETED] **`EANegationFix/` (the attained originals) is read, not edited. `EANegationFixFaithful/` is the re-base territory** |
| `doets_lemma_1_4` | `WeakCanonical/OrderedSum.lean:41` | [COMPLETED] Doets 1989 Lemma 1.4; consumed by Phases 24, 26, 29 |
| `KEquiv` (`:81`), `kTypeOf` (`:72`), `KType` (`:61`) | `WeakCanonical/NEquivalence.lean` (1315 lines) | [COMPLETED] |
| `good` (`:78`), `VeryGood` (`:86`), `ContempEquiv` (`:729`) | `WeakCanonical/IntegerModel/GoodStructures.lean` (881 lines) | [COMPLETED] `ℤ`-interval, **closed** intervals; Block H builds `ℝ`-interval siblings beside them |
| `truth_transfer` (`:361`), **`mkSigFrom` (`:134`)** | `WeakCanonical/Transfer.lean` (1244 lines) | [COMPLETED]. **Carries the repository's single live sorry at `:1242`, in an unrelated declaration; out of scope** |
| `Formula.predFormulas` | `Syntax/Formula.lean:778` | [COMPLETED] the bimodal encoding |
| `reynolds_model_surgery_core` (`:2102`), `no_gaps_discrete_model_surgery` (`:2180`) | `WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (2215 lines) | [COMPLETED] Reynolds Theorem 4 at the discrete instance; the cost baseline for Block F |
| `multiFamTaskFrame` (`:671`), `multiFamOmega` (`:694`), `multiFamOmega_shiftClosed` (`:708`), **`countermodel_discrete_reynolds_v2`** (`:739`) | `WeakCanonical/IntegerModel/ReynoldsBridge.lean` (1155 lines) | [COMPLETED] **regression canary** |
| `NormalForm` (`:146`) and its constructors | `WeakCanonical/NormalForm.lean` (873 lines) | [COMPLETED] |
| `Axiom.prior_U_gap` (`:377`), `Axiom.prior_S_gap` (`:387`), **`Axiom.sep`** (`:390-401`), `minFrameClass` (`:524`) | `ProofSystem/Axioms.lean` | [COMPLETED]. `sep` becomes load-bearing for the first time in Phase 23 |
| **`sep_valid`** (`:1601`), `soundness_dedekind` (`:1910`) | `Metalogic/Soundness.lean` | [COMPLETED] `sep_valid` is stated directly at `ValidDedekindDense` |
| `countermodel_dense_enriched` (`:133`), `neg_consistent_of_not_derivable` (`:72`), `completeness_dense` (`:255`), `completeness_discrete` (`:296`), audit chain `:381-383` | `Metalogic/BXCanonical/Completeness.lean` (417 lines) | [COMPLETED] **regression canaries** and the terminus-plumbing template |
| `fully_restricted_parametric_completeness_from_neg_membership` (`:417`) | `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (434 lines) | [COMPLETED] **accepts `D := ℝ` unchanged** |
| `ParametricCanonicalTaskFrame`/`TaskModel`/`parametricToHistory`; `BFMCS`/`FMCS`; the six coherence predicates | `Metalogic/Algebraic/**`, `Bundle/BFMCS.lean:91`, `Bundle/FMCSDef.lean:103`, `Bundle/TemporalCoherence.lean` | [COMPLETED] generic in `D` and `fc` |
| `set_lindenbaum`, `theorem_in_mcs` (`:491`), `deductionTheorem`/`deductionConverse`, `self_mem_subformulaClosure` (`:42`) | `Metalogic/Core/**`, `Syntax/SubformulaClosure/Closure.lean` | [COMPLETED] generic in `fc` |

**The eight faithful modules are Preserved Assets in their *content* and re-base territory in their
*carrier*.** Every declaration in them is complete and sorry-free and must remain so; what Block D
changes is the hypothesis they take, never what they prove. A Block D phase that loses a
declaration, weakens a conclusion, or introduces a `sorry` has failed, not deviated.

### Amputated Assets

**Landed, sorry-free, axiom-clean Lean that is retired as forward road.** It stays in the tree, it
stays compiling, and it is not deleted, reverted or refactored. Carried forward from v7 unchanged;
the per-row commentary is at `plans/07_...v7.md` §"Amputated Assets".

| Asset | Landed by | Disposition |
|---|---|---|
| `limitSetBelow`/`Above` + 10 lemmas; `limitMCSBelow*` — `Bundle/LimitMCS.lean` (482 lines) | v6 Phases 3-4 | **Retired** |
| The 11 `LimitMCSCoherence` case lemmas — `Bundle/LimitMCSCoherence.lean` (328 lines) | v6 Phases 5-6 | **Retired** |
| `realLimitMCS*`, `FMCS.toReal*`, `BFMCS.toRealBundle` — `Bundle/RealExtension.lean` (240), `Bundle/RealExtensionBundle.lean` (433) | v6 Phases 6, 6.1 | **Retired** |
| `limitFutureWitness_of_priorU`, `limitGuardBelow_of_priorS`, `limitGuardAbove_of_priorU` and their instances — `ChronicleLimitGapWitness.lean` (221), `ChronicleLimitGuardWitness.lean` (217), `ChronicleLimitGuardAbove.lean` (224) | v6 Phases 6.2, 6.3, 7.3, 7.4 | **Retired as route.** Keep as record |
| `BFMCS.LimitFutureWitness`, `BFMCS.LimitGuardBelow`, **`BFMCS.LimitGuardEventual`** | v6 Phases 6.2-7.4 | **Retired.** No phase of v8 states, consumes or discharges them |
| `toRealBundle_forward/backward_until_since` + ~17 supporting declarations — `ChronicleRealExtension.lean` (1159 lines) | v6 Phases 7.1′, 7.2, 7.4 | **Retired** |
| All of `ChronicleGuardAccumulation.lean` (812 lines) | v6 Phases 7.5, 7.9 | **Retired as machinery. `noGuardAccumulation_not_implied_by_limit_data` must be retained** as the machine-checked postmortem exhibit |
| The `NoGuardAccumulation` component of `omegaChain`'s subtype (`ChronicleConstruction.lean:283`), `EliminationResult.guard_accum_preserved`, and the 7.6/7.7 material in `CounterexampleElimination.lean` (3897 lines) | v6 Phases 7.5-7.8 | **Retired but STRUCTURALLY LIVE.** Must keep compiling. **Do not strip it** |

### Source-to-Implementation Mapping (H3, Tier 1 — literature-backed)

Cite by **printed page** in every Lean docstring. Never cite chunk-relative `md:NN` line numbers.
The page-offset for Reynolds 1992 is PDF page `i` ↔ printed `164 + i`. **Printed-page attributions
must be re-verified against the PDF before landing in a docstring**, and any correction recorded in
the phase summary (honesty charter Rule 2).

**Rows changed or added by v8** (all others carry forward from v7 unchanged and are reproduced
below them):

| Source | Location | Lean identifier (target) | Statement used | Phase |
|---|---|---|---|---|
| **Rabinovich 2014** | **`K⁺` definition, PDF p.3** (corpus `chunk_0007.md:33,39`) | **`kplusOpen`** (new) | *"`K+(F)` … is an abbreviation for `¬((¬F)UntilTrue)`"*; *"(3) `K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`."* **No `¬F(t)` conjunct.** This is the definition the tree's `kplus` deviates from | **10.1** |
| **Reynolds 1992** | **abbreviations table, §1, printed p.168** | **`kplusOpen`** (new Prop) and the **missing bridge** to the landed `Formula.kPlus` (`Syntax/Formula.lean:180`, docstring `:163-179` citing this same table plus GHR 1994 §10.3.1) | `K⁺A` *"for `¬U(⊤,¬A)`"*, reading *"`A` will be true arbitrarily soon"*. `U(A,B)(t)` iff *"there is `s > t` such that `A(s)` and for all `u`, if `t < u < s` then `B(u)`"* | **10.1** |
| Rabinovich 2014 | Lemma 5.3 Case 2, **eq (5.2), PDF p.8** (corpus `chunk_0015.md:11-15`) | **`HasFaithfulDedekindINF`** (new), `prior_hasFaithfulDedekindINF_dense` (new) | *"Case 2: If case 1 does not hold then let `r₀ = inf{z ∈ (z₀, z₁) | P₁(z)}` … Note that `r₀ = z₀` iff `K⁺(P₁)(z₀)`. If `r₀ > z₀` then `r₀ ∈ (z₀, z₁)` and `r₀` is definable by the following ∨∃⃗∀ formula:"* then `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀} ¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))` **(5.2)** | **10.1** |
| Rabinovich 2014 | Lemma 5.3, the printed `Oₙ₊₁`, **PDF p.9** (corpus `chunk_0016.md:3`) | `negChainOnFaithful` (re-based, `Lemma53Faithful.lean`) | *"Subcase `r₀ = z₀`: In this subcase `Oₙ(P₂,…,Pₙ,z₀,z₁)` and `Oₙ₊₁(P₁,…,Pₙ₊₁,z₀,z₁)` should be equivalent. Subcase `r₀ ∈ (z₀,z₁)`: Now `Oₙ(P₂,…,Pₙ,r₀,z₁)` and `Oₙ₊₁` should be equivalent. Hence `Oₙ₊₁` can be defined as the disjunction of "`(z₀,z₁)` is empty" and the following formulas: (1) `(∀y)^{<z₁}_{>z₀} ¬P₁(y)` (2) `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` (3) `(∃r₀)^{<z₁}_{>z₀} INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁)`"* — **the printed subcase split is on `r₀ = z₀` vs `r₀ > z₀`; `K⁺` is its definable proxy and, at the source's `K⁺`, an exact one** | **11** |
| Rabinovich 2014 | Lemma 5.1 case enumeration, **PDF p.9** (corpus `chunk_0017.md:9`) | `negFixOneFaithful_cover`, `negFixListFaithful_iff` (re-based) | *"at least one of the following cases holds: Case 1: `¬α₀(z₀)` or `K⁺(¬β₁)(z₀)`. Case 2: `α₀(z₀)`, and `β₁` holds along `(z₀,z₁)`. Case 3: (1) `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀)`, and (2) there is `x ∈ (z₀,z₁)` such that `¬β₁(x)`."* — **the negation-chain discipline**: the case split is exhaustive *only* under the source's `K⁺` | **12, 12.1** |
| Rabinovich 2014 | Lemma 5.1 Case 3, **eq (5.3), PDF p.10** (corpus `chunk_0018.md:9-13`) | the eq (5.3) pieces in `NegFixOneFaithful.lean` (`infPinPoint`, `allSeg`, `somePointBlock`) | *"When the first condition holds, then the second condition is equivalent to "there is (a unique) `r₀ ∈ (z₀,z₁)` such that `r₀ = inf{z ∈ (z₀,z₁) | ¬β₁(z)}`" (If `¬K⁺(¬β₁)` holds at `z₀` and there is `x ∈ (z₀,z₁)` such that `¬β₁(x)`, then such `r₀` exists because we deal with Dedekind complete chains.)"*; `INF_{¬β₁}(z₀,z,z₁) := z₀ < z < z₁ ∧ (∀y)^{<z}_{>z₀} β₁(y) ∧ (¬β₁(z) ∨ K⁺(¬β₁)(z))` **(5.3)**; *"Hence, Case 3 is described by `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀) ∧ (∃z)^{<z₁}_{>z₀} INF_{¬β₁}(z₀,z,z₁)`"* — **the standing guard is printed at the use site, twice** | **12, 12.1** |
| Rabinovich 2014 | Prop 4.2, **PDF p.6** (corpus `chunk_0012.md:9`) | `VVecEA2.negFixFaithful_iff`, `prop42_contentful_of_faithful` (re-based) | *"Proposition 4.2. (Closure under negation) The negation of ∃⃗∀-formulas with at most two free variables is equivalent over Dedekind complete chains to a disjunction of ∃⃗∀-formulas."* | **13** |

**Carried forward from v7 unchanged** (Blocks D-tail and E-I):

| Source | Location (printed page) | Lean identifier (target) | Phase |
|---|---|---|---|
| Reynolds 1992 | §5 Thm 3, **p.176** | `SemanticPriorU` / `SemanticPriorS` — **landed** | 9 |
| Reynolds 1992 | Prior-U / Prior-S, **p.168** | `Axiom.prior_U_gap` (`:377`), `Axiom.prior_S_gap` (`:387`) — consumed | 9, 10, 10.1, 16 |
| Reynolds 1992 | §5 Thm 3 proof, **p.176** | `uSExpressivelyCompleteOverDensePrior` (new) | 14 |
| Reynolds 1992 | §9 steps 1-2, **p.189** | dense monadic bridge (new module) | 15 |
| Reynolds 1992 | §4 Cor 1, **p.174** | consumes `cantorBfmcsDense` + the three coherence theorems | 15, 16 |
| Reynolds 1992 | §6, **pp.176-177** | `ContempEquivDense`, `rhoFormula`, `lambdaFormula`, Lemma 2 | 17 |
| Reynolds 1992 | §6 Lemmas 3-4, **pp.178-179** *(corrected in v9)* | Lemma 3, Lemma 4 | 18 |
| Reynolds 1992 | §6 Lemma 5, **p.179** *(corrected in v9)* | Lemma 5, `relativizeToClass` | 19 |
| Reynolds 1992 | §6 Lemma 5 over maximal intervals of **`λ`** | `reynolds_lemma5_first_left` — **unstated by Reynolds**; licensed by the p.178 duality convention (*"Dually we can define λ(x)"*) and required by *"previous results"* at p.180 | **20.4** |
| Reynolds 1992 | §6 Lemmas 6-7, **pp.179-181** *(corrected in v9)* | Lemma 6, Lemma 7 | 20 |
| Reynolds 1992 | §6 Lemma 6, *"using mirror images of the above and previous results"*, **p.180** | `endsInGapOnRight_of_endsInGapOnLeft` over a new `ClassInteriorToLInterval`, and `reynolds_lemma6`'s fourth conjunct | **20.4** |
| Reynolds 1992 | §6 Lemma 8, **pp.181-182** *(corrected in v9)* | Lemma 8 (bad-interval surgery) | 21 |
| Reynolds 1992 | §6 Lemma 9 + **Theorem 4**, **pp.182-183 — MEASURED in Phase 22** at 200 dpi (`pdftoppm -f 18 -l 19`), confirming the `+164` offset. *(v9's row, superseded and kept visible: "≈pp.182-183 — UNVERIFIED, measure before it lands in a docstring".)* | **`no_gaps_dense_prior`** (**D1**) | 22 |
| Reynolds 1992 | §6 **Lemma 4's display, p.179, repaired at the `r ∈ M` boundary** — the inner bound read as `y ≤ z` rather than `y < z`. **The defect is the SOURCE's** (honesty-charter Rule 7); the faithful transcription `firstClassFormula` / `IsFirstClassPoint` is a Preserved Asset and is **not modified** — the repaired variant lands **beside** it | `firstClassFormulaClosed`, `IsFirstClassPointClosed`, `firstClassFormulaClosed_eval`, `firstClassTemporalClosed(_spec)`, `isFirstClassPointClosed_congr`, `not_isFirstClassPointClosed`, `reynolds_lemma4_no_first_class_closed` | **22.1** |
| Reynolds 1992 | §6 p.179 (rendering) — *"a maximal interval of `R`"*, **the producer this plan assumed and never chartered** | `exists_classInteriorToRInterval`, then `endsInGapOnLeft_of_endsInGapOnRight'` / `endsInGapOnRight_of_endsInGapOnLeft'` (hypothesis-free, the `λ` side by instantiation through `Dual.lean`), then `hasBadIntervalSurgery` | **22.1** |
| Reynolds 1992 | §7 **Theorem 5**, **pp.184-185**; Sep, **p.168** | **`dense_singletons_of_sep`** (**D2**); `Axiom.sep` consumed | 23 |
| Reynolds 1992 | §8 Lemma 11, **p.186** | `goodDense`, `veryGoodDense`, `lemma_11_dense` | 24 |
| Reynolds 1992 | §8 Lemma 12, **pp.186-187** | `epsilonDense`, `lemma_12_dense` | 25 |
| Reynolds 1992 | §8 Lemma 13, **p.187**; the shuffle, **p.186** | `lemma_13_dense`, `Shuffle` | 26 |
| Reynolds 1992 | §8, **p.188**; **Doets 1987 3.1.8** | `shuffle_extend_R`, `shuffleFlow_dedekind_complete`, `shuffleFlow_separable`, **`doets_lemma_1_5`** | 27 |
| Reynolds 1992 | §8, **p.188** | **`orderIsoRealOfDedekindDenseSeparable`** (**no Mathlib equivalent**) | 28 |
| Reynolds 1992 | §8 **Theorem 6**, **pp.185-188**; Doets 1987 **3.3.9** | **`doets_theorem_dense`** | 29 |
| Reynolds 1992 | §9 **Theorem 7**, **p.189**; §2, **p.169** | `completeness_dedekind_engine`, then the pinned `consequence_completeness_dedekind_of_engine` | 30 |
| Reynolds 1992 | §10 Thm 9, **pp.190-191** | `countermodel_discrete_reynolds_v2` — **template only** | (15, 17-22, 24-25) |
| **NO SOURCE — original work** | — | the chronicle → `OrderedMonadicStructure` dense bridge (15); the `ℝ`-order characterization (28) if no Mathlib route is found; **the guard/trichotomy apparatus of `DedekindINFDense.lean` (Phase 10), which is a formalization-level repair for the tree's `kplus` deviation and has no counterpart in either source** | 15, 28, **10.1 (labelling)** |

#### The measured §6 page map (v9 — binding for every Block F phase)

The §6 rows above were **wrong by 1-2 pages in every case** through v8, and Phases 18, 19 and 20
each recorded the drift in a deviation record while the table itself stayed stale. A fresh
dispatch reads the table first, so the table is now corrected and the map it was corrected
against is recorded here.

**Measured against the page images, printed page = PDF page (1-based) + 164 throughout §6.**

| Material | PDF page | Printed page | What v8's table said |
|---|---|---|---|
| `ρ`, Lemma 2 | 13 | 177 | 176-177 — the one row that was already right |
| Lemma 3, Lemma 4 statement | 14 | 178 | 177 ✗ |
| Lemma 4 proof, **Lemma 5**, *bad point* / *bad interval* | 15 | **179** | 178 ✗ |
| **Lemma 6**, Lemma 7 statement + proof opening | 16 | **180** | 178-179 ✗ |
| Lemma 7 proof close, surgery set-up, **Lemma 8** start | 17 | **181** | 179 ✗ |

**Binding consequences:**

1. **Every §6 page number landing in a `.lean` docstring is derived from this map or re-measured
   against the page image** — never copied from an earlier plan row and never taken from
   `pdftotext`.
2. **Lemma 9 / Theorem 4's page IS now measured — pp.182-183** (Phase 22, `pdftoppm -f 18 -l 19
   -r 200`, both pages read as images). PDF p.18 carries running header 182 and holds the whole of
   Lemma 9; PDF p.19 carries 183 and opens with Theorem 4, immediately followed by §7. The `+164`
   offset and the extrapolation both hold. *(v9's text, superseded and kept visible: "Lemma 9 /
   Theorem 4's page is not yet measured. The `≈pp.182-183` above is an extrapolation from the map,
   flagged as UNVERIFIED. Phase 22's first task is to measure it and record the result, exactly as
   Phases 18-20 did for their own lemmas.")*
3. **§6 *displayed* formulas in the corpus are unreliable and must be verified against the page
   image before transcription.** The standing defect count is **three, all displays** *(raised
   from two in v10)*: `ρ`'s missing middle conjunct (Phase 17), Lemma 4's display wrong in four
   independent places (Phase 18), and — recorded by `reports/09` — the corpus rendering of
   **Lemma 4's display in the §6 file** (`sec03_6-…md:60`), which is corrupt and was overridden by
   the 200 dpi page image. `pdftotext` is unusable on all of them — Lemma 4's display renders as
   `p(x) A vy <    z(y < z < x A`. §6 *inline prose* has checked clean against the page images in
   Phases 19, 20 and 22 and in `reports/08` and `reports/09`, so prose may be quoted from the
   corpus chunks; displays may not.
4. **Corpus prose is silently normalized and the page image is authoritative for typography too.**
   Two recorded instances: the print's *"Its not hard"* (p.180) normalized to *"It's not hard"*;
   the print's *"appropraite"* (p.182) normalized to *"appropriate"*. These are **corpus
   artifacts, not Reynolds' defects**, and are recorded as such.

### Drafted-but-archived target: `doets_lemma_1_5`

Carried forward from v7 verbatim in substance. `FormalSystem/Boneyard/SorriedDeclExcisions/
SingletonSorriedDecls.lean:58` carries a drafted `doets_lemma_1_5` with a `sorry`, behind `#exit`
(line 41), under the stale names `k_type_of` / `k_equiv` (live: `kTypeOf` `NEquivalence.lean:72`,
`KEquiv` `:81`). Its archive header (`:19-24`) reads: *"Not on the discrete completeness critical
path … **Required only for the dense case (future work).**"* It is **not built and cannot be reused
as-is**; **Phase 27 is chartered to re-state it under the live names in live code and prove it.**
Do not import `Boneyard`; do not reintroduce the `sorry`.

---

## Postmortem Constraints

Binding on every implementation dispatch for this task. Derived from the Phase 7.9 refutation, from
`reports/07`'s adversarial verification, from the accumulated record of six superseded plans, and
— new in v8 — from Phase 10's landed findings.

### Why R3d failed — the digest no phase may re-incur

**The obligation.** v6's route completed the rational chronicle to `ℝ` by inserting a limit MCS at
every unselected real. Forward Until/Since coherence at `ℝ` then required, at every gap `r`, that a
guard `ψ` known to hold *cofinally* below `r` in fact hold *eventually* (on a whole interval)
below `r`. That is `BFMCS.LimitGuardEventual`.

**Why it cannot be discharged.** Three independent findings, each landed or verbatim-sourced:

1. **The construction's data does not entail it.** `noGuardAccumulation_not_implied_by_limit_data`
   is a *theorem*, axiom-clean. The dyadic-approach family satisfies all four exported conditions
   on all of `ℚ` and refutes the invariant. This is not a stuck proof; it is a refutation.
2. **The axioms do not entail it.** All three Dedekind axioms were checked individually against the
   two-sided accumulation and all three are silent (Prior-U is *satisfied* by the pattern; Prior-S
   has no antecedent; Sep's force is a cardinality argument needing failure throughout an interval,
   which one accumulation point escapes). There is no fourth Dedekind axiom.
3. **The literature never incurs it.** Burgess 1984's completion (printed pp.109-110) builds its
   gap MCS from purely existential `Pα`/`Fα` data with **no interval datum at all**, and runs
   entirely in the `¬,∧,G,H` fragment (printed p.116) — before Until/Since enter the language.
   Reynolds never completes the rational order at all.

**The generalization every future phase must carry.** *A guard obligation that arises only because
the construction inserted a point where the literature inserts none is evidence of a wrong route,
not a hard lemma.* The user's no-needless-bridges constraint names exactly this: a step whose only
purpose is to connect two artifacts the tree happens to have.

### Why Block D needed correcting — the v8 digest

**The obligation.** Phase 10 discharged the route's single point of failure and then found that the
carrier it had to export was a **trichotomy** whose third disjunct — `P(z₀)` — is *uninformative*:
it does not imply `r₀ = z₀`, so a consumer landing in it learns nothing. The survey then found
that the two hardest consumers have a case structure with **no slot** for it.

**What it actually was.** The corpus, read verbatim at this revision, shows both sources define
`K⁺` **without** a `¬P` conjunct at the point of evaluation (`chunk_0007.md:33,39`; Reynolds'
abbreviations table). The tree's `kplus` (`PriorINF.lean:86`) adds one. Every symptom Phase 10
observed — the refutation, the guard, the trichotomy, the endpoint hole — is downstream of that
single added conjunct.

**The generalization every future phase must carry.** *Before attributing an error to a source,
check the source's own definitions of the symbols in the disputed sentence.* A definitional
deviation introduced by the formalization will present exactly as a mathematical defect in the
literature, and the tree will pass sorry-free and axiom-clean while asserting it. This is the same
family as the anti-vacuity failure mode `DedekindINF.lean` already records, one level up: not a
vacuous *hypothesis* but a mis-transcribed *primitive*.

**Do NOT**:

- **Do NOT re-open completion-by-limits, in any form.** No limit MCS at a gap of a rational
  chronicle, no `ℝ`-extension of `cantorBfmcsDense`, no repair of `NoGuardAccumulation`, no
  invariant carrying MCS-value content about freshly inserted points. Refuted at the data level and
  unreachable at the axiom level.
- **Do NOT state, consume or discharge `BFMCS.LimitGuardEventual`, `BFMCS.LimitGuardBelow` or
  `BFMCS.LimitFutureWitness`.** Retired. No phase of v8 mentions them except in prose.
- **Do NOT attempt to formalize the two-sided defeat of `prior_S_gap`.** Moot on this route.
- **Do NOT delete, revert or refactor the amputated layer.** In particular do **NOT** strip the
  `NoGuardAccumulation` component out of `omegaChain`'s subtype (`ChronicleConstruction.lean:283`)
  or out of `EliminationResult`. Inert compiling code is the correct disposition.
  **`noGuardAccumulation_not_implied_by_limit_data` must be retained.**
- **Do NOT apply `uSExpressivelyCompleteOverPrior`, `kampPriorExpressiveCompleteness`,
  `prior_hasDedekindINF`, `prior_hasAttainedINF`, `no_gaps_discrete_model_surgery`, or any other
  declaration pinned at `SemanticPriorUZ`/`SemanticPriorSZ`, at a dense flow.** They are **vacuous
  there**. Every Block D phase must ship a non-vacuity witness (anti-vacuity gate below).
- **Do NOT edit `SemanticPriorUZ` / `SemanticPriorSZ`, `uSExpressivelyCompleteOverPrior`,
  `prior_hasAttainedINF`, `prior_hasDedekindINF`, `no_gaps_discrete_model_surgery`, or
  `countermodel_discrete_reynolds_v2`.** The discrete pipeline is landed, sorry-free and
  axiom-clean and `completeness_discrete` depends on it.
- **Do NOT edit `ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean`,
  `ChronicleConstruction.lean`, `CounterexampleElimination.lean`, `cantorIsoDense`, `cantorZeroDense`
  or `CantorFDense`.** On this route the chronicle is *read*, never modified. The two frozen files
  must be **byte-identical** at the end of every phase.
- **Do NOT weaken the target to `ValidDedekind`.** `FrameClass.Dedekind` sits above
  `FrameClass.Dense`, so `density` and `dense_indicator` are admissible and both are false on `ℤ`.
  The target is `ValidDedekindDense`.
- **Do NOT make `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
  `consequence_completeness_dedekind`, or `completeness_dedekind` conditional on an undischarged
  predicate.** The single permitted added hypothesis on that chain is
  `(hfc : FrameClass.Dedekind ≤ fc)`, discharged by `decide`. **There is no conditional terminus.**
- **Do NOT prove `completeness_dedekind` independently and then strengthen it.** It is
  `consequence_completeness_dedekind []` after `simp` discharges `∀ ψ ∈ [], _`.
- **Do NOT restate, reorder or re-bind `consequence_completeness_dedekind_of_engine`.** Pinned by
  commit `bd9ae0ac1`; Phase 30 instantiates it and nothing else.
- **Do NOT emit a vacuous definition** (`def X := True`, `theorem X := trivial`, a hypothesis no
  structure can satisfy). If a phase cannot be completed, mark it `[BLOCKED]` with the exact goal
  state.
- **Do NOT introduce a `sorry`.** The live census outside `Boneyard/` is **exactly one** —
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` — and must remain exactly one at the
  end of every phase. `Transfer.lean:1242` is not on this route and is not to be attempted.
- **Do NOT cite task numbers in any `.lean` file.** Cite the sibling module name, the source's
  printed page, or the declaration name.
- **Do NOT touch `FormalSystem/Metalogic/Decidability/` or `FormalSystem/Automation/`.** A
  concurrent effort owns them. Neither read-for-edit nor stage any file under those paths; leave
  any of their modifications unstaged.

**Do NOT — new in v8, from Phase 10**:

- **Do NOT plan, charter or dispatch a construction phase against a module inventory that has not
  been re-checked against the tree in the same dispatch.** v7's Phases 11-13 chartered ~990 lines
  of from-scratch construction for modules that already existed, sorry-free and CI-protected, at
  3,388 lines. A `find`/`grep` costing seconds would have caught it. Every phase below that names a
  file to create MUST first confirm it does not exist.
- **Do NOT attribute a mathematical error to a source before checking that source's own definitions
  of the symbols in the disputed sentence.** Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is a
  definitional restatement, true verbatim under his own Definition (3) (`chunk_0007.md:39`). Any
  docstring in this tree asserting otherwise is a defect and Phase 10.1 corrects it.
- **Do NOT consume `HasDenseDedekindINF`'s third disjunct as though it supplied `r₀ = z₀`.** It
  supplies `TemporalTruth M atomMap z₀ P` and nothing else. `denseWindow_endpoint_disjunct_forced`
  exhibits a point where it is the only disjunct that holds, and where no infimum information is
  available. A consumer that "handles" it by assuming an infimum is unsound.
- **Do NOT duplicate the eight faithful modules to avoid weakening a hypothesis in place.** Cloning
  3,388 lines to change a binder type is a needless bridge of exactly the kind this task's
  postmortem names. The re-base is a hypothesis **weakening**: every current supplier still
  typechecks through a shim, and the canaries fire immediately if it does not.
- **Do NOT edit `kplus`, `kplusFormula`, `kplus_formula_correct`, `kminus`, `kminusFormula` or
  `kminus_formula_correct` — statements or proofs.** They are internally consistent with each other
  and the discrete pipeline depends on them (`hasDefinableINF_excludes_kplus`, `Lemma53.lean:290`;
  `prior_makes_disjunct2_unreachable`, `Lemma53Faithful.lean:382`). The source-exact `K⁺` is a
  **new sibling**, `kplusOpen`, landed beside them. Their **docstrings** are corrected in Phase
  10.1 and nothing else about them changes.
- **Do NOT substitute `Formula.kPlus` for `kplusFormula` (or `Formula.kMinus` for `kminusFormula`)
  anywhere, in either direction, without going through the bridge lemma Phase 10.1 lands.**
  `Syntax/Formula.lean:163-179` states the prohibition in the tree's own words: *"substituting one
  for the other silently transcribes a different axiom."* The two spellings differ by exactly the
  conjunct this revision is about, and the axioms (`Axioms.lean:377`, `:387`, `:390`) are stated
  with the conjunct-free one while the carrier apparatus is stated with the conjunct-carrying one.
  Any phase that needs to move between them cites the bridge by name.

**Do NOT — new in v9, from Phases 17-20 and `reports/08`**:

- **Do NOT remove a PIN-SIDE `kplusOpen_of_kplus` (D7).** The faithful carrier keeps the tree's
  `kplus` in its **RIGHT** disjunct by design, and the pin-side direction is what keeps every
  existing supplier working. A future reader who sees the two directions and assumes one is
  redundant is wrong; deleting it breaks the shim lattice v8's Phase 10.1 landed. **Zero
  removals.**
- **Do NOT swap a binder and rename in one step (D11 — the swap-binder rule).** *Swap-binder +
  land-new-name is ONE instruction*: land the new name, and keep the old one as an **unweakened
  corollary**. **Zero removals, zero renames.** Phases 18-20 already ran this three times on the
  gap-crossing family (each weaker precondition landed as a new name; all four coexist), and that
  is why nothing downstream broke. A phase that "simplifies" by folding two of them together has
  violated this rule, not tidied up.
- **Do NOT re-open D13.** Phase 17 rewrote `Kamp/Section5Correspondence.lean`'s faithful re-base
  table onto the faithful eq (5.2) carrier — correcting three independent staleness defects and
  adding a "Carrier note" recording what the old description got wrong, so the next re-base has a
  stated baseline. **CLOSED.** Do not re-derive, re-audit or "refresh" that table.
- **Do NOT quote a §6 *displayed* formula from the corpus.** Two of the two §6 displays checked so
  far are corrupt (see "The measured §6 page map" above). Every phase quoting a §6 display
  verifies it against the page image first and records the result. §6 inline prose is clean and
  may be quoted.
- **Do NOT describe anything below §6 Lemma 2 as discharged.** Every §6 lemma below Lemma 2 is
  still **conditional**: `IsContempEquivDense ε` plus Prior-U/Prior-S are hypotheses, and the only
  `ε` the tree can exhibit satisfying them is `epsTop`, for which `EndsInGapOnRight` is empty.
  **There is no live non-trivial instance until Phase 22.** This caveat is carried in every §6
  module header and must stay there; a phase summary that calls a §6 result "proved" without it is
  a defect. It is not a reason to stop — Reynolds' §6 is conditional in exactly the same way — but
  it is a reason never to overstate.
- **Do NOT use `OrderDual.toDual` to move a point across the dual structure.** Use
  `def d (x : M.carrier) : (dual M).carrier := x`. `OrderDual.toDual` reproduces the
  `.carrier`-unfolding hazard this tree already documents at `NEquivalence.lean:134` for
  `orderedSum`; `reports/08`'s probe run 2 hit exactly that mismatch and probe run 3 with `d` did
  not. The `d` trick is what removed all the `Fin.cons` friction from the binder cases. Relatedly:
  mark `dual` **not** `@[reducible]`.
- **Do NOT let the repository's `sorry` census drift on someone else's account.** The sole
  task-relevant pre-existing `sorry` is `WeakCanonical/Transfer.lean:1242` — **confirmed at this
  revision; an earlier report naming `:1225` was wrong.** Two further live sorries at
  `Decidability/Verified/Bridge/IntTruth.lean:434,444` belong to the **concurrent decidability
  effort**, not to this task; they are outside the territory this plan may touch. A concurrent
  session commits into this repository, so `lake build` job counts drift for unrelated reasons —
  **a changed job count is not by itself evidence of anything this task did.**

### The narrowed in-place constraint (v8 amendment, declared)

v7 carried an unqualified constraint: *"Dense siblings, never in-place generalization."* v8
**narrows it, deliberately, with reasons, and only for the eight `*Faithful*` modules**:

- **Still binding, unamended**, for `PriorDefs.lean`, `PriorINF.lean` (statements/proofs),
  `DedekindINF.lean`, `PriorExpressiveness.lean`, `Lemma53.lean`, `Section5Correspondence.lean`,
  `EANegationFix/**`, `KampPrior.lean`, `IntegerModel/**` and everything else on the
  discrete/attained axis. Block D adds siblings beside these; it does not generalize them.
- **Lifted, narrowly**, for `Lemma53Faithful.lean`, `Lemma53FaithfulPast.lean`, `Prop42Faithful.lean`
  and `EANegationFixFaithful/**`. Three reasons, all checkable:
  1. The change is a hypothesis **weakening** (`HasDedekindINF` → `HasFaithfulDedekindINF`), so
     every existing supplier keeps working through `HasDedekindINF.toHasFaithfulDedekindINF`. No
     conclusion is weakened anywhere.
  2. These eight modules **exist for the faithful carrier**. Re-pointing them at the source-exact
     carrier is what they are for; cloning them would leave two faithful families and no rule for
     which to consume.
  3. The discrete pipeline cannot observe the difference — `prior_makes_disjunct2_unreachable`
     (`Lemma53Faithful.lean:382`) and its mirror prove disjunct (2) never fires under
     `SemanticPriorUZ` — and the canaries (`completeness_discrete`,
     `countermodel_discrete_reynolds_v2`, `completeness_dense`) fire if that reasoning is wrong.
- **The lift does not extend to deletion.** No declaration in the eight modules may be removed,
  renamed away, or have its conclusion weakened. If a re-base cannot preserve a declaration, the
  phase is `[BLOCKED]`, not "simplified".

### The anti-vacuity gate (binding, per phase)

The `DedekindINF.lean` module docstring records the failure mode this task must not repeat:

> *"An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as a vacuous
> conclusion does — the pattern that recurred three times undetected in this development."*

Every phase that introduces a **hypothesis** (a `structure … : Prop`, an `abbrev … : Prop`, or a
new binder on a transported theorem) MUST, in the same dispatch, land one of:

1. a **witness** — a concrete structure satisfying it, ideally at a dense flow; or
2. a **derivation** of it from an already-witnessed hypothesis; or
3. an explicit **exclusion lemma** in the style of `hasDefinableINF_excludes_kplus` and
   `hasDedekindINF_admits_kplus_shape`, showing which shapes the hypothesis admits and forbids.

A phase that lands only the hypothesis and its consumers, with no witness, is `[BLOCKED]` — not
`[COMPLETED]`.

**v8 addition — the re-base corollary.** A phase that *weakens* a hypothesis must additionally
show the weakening is **strict and consumed**: land the shim from the old carrier to the new one
(so nothing regresses) **and** exhibit at least one structure satisfying the new carrier that does
**not** satisfy the old one. Without the second half, a "weakening" may be an equivalence in
disguise and the re-base buys nothing. `denseWindowFlow` (Phase 9) at `z₀ = 1/2` is the intended
witness and Phase 10 already proved the old carrier fails there
(`hasDedekindINF_fails_on_dense_window`).

### Honesty charter for docstrings (binding user directive — SCOPE INVERTED FOR THIS ROUTE)

On the completion route the construction had **no source** and every docstring had to say so. On
the Doets route the construction **has a source** — Reynolds 1992 §5-§9, Rabinovich 2014 §4-§5 and
Doets 1987 3.3.9 — and every docstring must **cite it faithfully**.

**Rule 1 — transcription is cited, faithfully and specifically.** Every declaration in Blocks D, F,
G, H and I transcribes a named result. Its docstring must carry the **source, section, theorem or
lemma number, and printed page**, e.g. `Reynolds 1992, §6 Lemma 5, printed p.178` or
`Rabinovich 2014, Lemma 5.3 eq (5.2), PDF p.8`. A bare "following Reynolds" is a defect; so is a
docstring that omits the citation.

**Rule 2 — the printed page must be verified, not copied.** Before a page number lands in a `.lean`
docstring the implementer re-checks it against the PDF and records any correction in the phase
summary. Rabinovich is cited by **PDF page only** — `DedekindINF.lean`'s docstring records that the
`.md` conversion is corrupt (it drops displayed equations and inverts `k ≠ m` to `k = m`) and is
never ground truth. **The corpus chunk files ARE usable for the plain prose sentences quoted in the
Source-to-Implementation Mapping above** — each was read verbatim at this revision — but the
*displayed equations* must be read from the PDF.

**Rule 3 — Reynolds may be cited for discharges, not only for statements.** v8 builds expressive
completeness, so Reynolds' proofs are available as proofs.

**Rule 4 — the no-source statement is reserved, and its scope is exhaustively named.** Only these
carry a plain "this construction has no source in the corpus and is original work" statement:

- the chronicle → `OrderedMonadicStructure` dense bridge (Phase 15), including any bimodal family
  encoding beyond what `mkSigFrom`/`multiFamOmega` already discharge;
- `orderIsoRealOfDedekindDenseSeparable` (Phase 28), **if and only if** no Mathlib route is found;
- **the guard/trichotomy apparatus of `DedekindINFDense.lean`** — `HasGuardedDedekindINF`,
  `HasDenseDedekindINF`, their mirrors, and the `hasDedekindINF_fails_*` exclusion family. These
  are a formalization-level repair for this tree's `kplus` deviation and have **no counterpart in
  either source**. Phase 10 already labelled them original glue; Phase 10.1 completes the label by
  recording *what they are glue for*;
- any Lean-specific scaffolding (fuel/termination arguments, decidability instances,
  `Fintype`/`DecidableEq` plumbing) with no mathematical counterpart.

**Rule 5 — ADAPTED-FROM survives, narrowed.** Where a declaration follows a source's *method* on a
different object, the form is `ADAPTED-FROM: <source>, <location>, printed p.<N>` with a one-clause
statement of what changed. Never "transcribed from" for an adaptation.

**Rule 6 — every carrier states what it excludes.** Mandatory for every new `Prop`-valued hypothesis
in Block D.

**Rule 7 — new in v8: a docstring may not assert that a source is wrong without quoting the
source's own definition of every symbol in the disputed sentence.** If, after quoting, the source
is right and the tree deviates, the docstring says *that* instead: it names the tree's definition,
names the source's, and states which is which. A tree that silently redefines a primitive and then
records the literature as mistaken is worse than one that omits the citation.

### The producer rule (new in v10, binding on every remaining phase)

**A hypothesis with no producer is a distinct failure mode from a missing theorem, and it is the
one this plan actually hit.** `ClassInteriorToRInterval` had seven repo-wide occurrences — a
definition, a field, a dual instantiation and four hypothesis positions — and **no producer**. A
`grep` for the name looks healthy; the hole is invisible unless you ask which occurrence is a
conclusion.

Three binding consequences:

1. **Before a phase consumes a structure or `Prop` as a hypothesis, it greps for a producer** — a
   declaration whose *conclusion* is that structure — and, if there is none, names that as the
   phase's own deliverable or reports `[BLOCKED]` naming it. It does not assume an earlier phase
   supplied it because a note says so.
2. **A rendering note may not carry a supply claim.** *"That is what Lemma N supplies"* is a proof
   obligation; if no phase's `Owns` list produces it, the plan has a hole. Renderings describe how
   a source's words are spelled in Lean; they do not discharge anything.
3. **A stuck agent's diagnosis is a hypothesis, not a finding.** The Phase 22 implementer named the
   consumer (`ClassInteriorToLInterval`, an `L`-side witness) as the gap; the gap was a `ρ`-side
   producer downstream of a source defect. Adopting that diagnosis unchecked would have cost a
   dispatch hand-mirroring in the wrong direction. **Grep for producers before adopting a stuck
   agent's diagnosis**; direct machine-checked evidence outranks a stuck-state account.

### MUST preserve

- **Added in v10**: `firstClassFormula` (`Lemma34.lean:785`) and `IsFirstClassPoint` (`:797`) —
  the faithful, symbol-for-symbol transcription of Reynolds' p.179 display. Phase 22.1's repaired
  variant lands **beside** them under different names. Neither is modified, renamed, reordered or
  weakened, and neither is "corrected" to the repaired form. An auditor comparing the tree against
  the printed page must still find the faithful transcription where they expect it.
- Every row of the Preserved Assets tables, byte-identical unless a phase's Tasks list names the
  file. **`PriorDefsDense.lean` and `DedekindINFDense.lean` join this list from v8 onward**; the
  only permitted change to either is Phase 10.1's comment-bytes-only correction to the latter.
- Every declaration in the eight faithful modules — present, sorry-free, and with its conclusion
  unweakened — through and after the re-base.
- Every row of the Amputated Assets table, compiling and unmodified.
- `Metalogic/Soundness.lean` at zero sorries.
- `completeness_dense`, `completeness_discrete` and `countermodel_discrete_reynolds_v2` sorryAx-free
  with axioms exactly `[propext, Classical.choice, Quot.sound]`. **The regression canary for
  Block D.**
- The live sorry count outside `Boneyard/` at exactly one (`Transfer.lean:1242`).
- The exact signature of `consequence_completeness_dedekind_of_engine` (commit `bd9ae0ac1`).
- `ChronicleTypes.lean` and `ChronicleToCountermodelBasic.lean` **byte-identical**.

### Design decisions are SETTLED (do not re-open without a concrete counterexample)

- **The Doets route, not completion-by-limits.** Settled by the user's authorization on
  `reports/07`, against a landed refutation and three exhausted axioms. **v8 does not re-open it.**
- **The terminus is the finite-context consequence form, and weak completeness is its `Γ = []`
  corollary.** Genuine (infinite-premise) strong completeness is **provably unavailable** here
  (Reynolds §2, printed p.169: compactness fails). Out of scope; do not rename any declaration back
  to a "strong" form.
- **The Doets route reaches BOTH termini with the pinned signature untouched.** Three grounds, from
  `reports/07` §1.5.
- **Expressive completeness is available in this tree and is the route's engine.** Machine-checked
  `#print axioms` outranks a plan-time prose inventory.
- **The re-base target is the faithful eq (5.2) carrier, not `HasDefinableINF` and not
  `HasAttainedINF`.** `hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`, axiom-clean) proves
  `HasDefinableINF` makes `kplus M atomMap P z₀` *impossible* whenever `P` occurs in `(z₀,z₁)` — it
  deletes Rabinovich's disjunct (2), which on a dense Prior structure is exactly the reachable case.
- **NEW, SETTLED in v8: the carrier Block D's consumers take is the source-exact dichotomy
  `HasFaithfulDedekindINF`, not the trichotomy `HasDenseDedekindINF`.** Grounds: (i) both sources
  define `K⁺` without an endpoint conjunct, verbatim (`chunk_0007.md:33,39`; Reynolds'
  abbreviations table), so the dichotomy is the *faithful* statement and the trichotomy is the
  repair; (ii) the trichotomy's third disjunct is uninformative — `P(z₀)` does not imply `r₀ = z₀`;
  (iii) the two hardest consumers (`NegFixOneFaithful.lean:422`, `NegFixListFaithful.lean:446`)
  have a case structure with no slot for it. **The trichotomy is not deleted, not deprecated, and
  not restated** — it stays landed, it stays the record of the deviation, and
  `HasFaithfulDedekindINF.toHasDenseDedekindINF` keeps it supplied.
- **NEW, SETTLED in v8: the re-base is performed in place in the eight `*Faithful*` modules**, not
  by cloning. See "The narrowed in-place constraint" for the three reasons and the limits.
- **The `.Discrete` pipeline is the template and is not the target.** Its *method* transfers; its
  *statement* does not.
- **The Stavi route is the rejected alternative.** `stavi_expressive_completeness` exists only in
  `Boneyard/StaviDiscretePath/` with a sorry-tainted chain top. Recorded as the fallback in Risks.
- **Every gap-facing obligation is discharged `fc`-conditionally.** `Axiom.prior_U_gap`,
  `prior_S_gap` and `sep` all have `minFrameClass = .Dedekind`, so every consumer carries
  `(hfc : FrameClass.Dedekind ≤ fc)`, discharged by `decide` at `fc := FrameClass.Dedekind`.
- **The chronicle layer stays at `Rat`.** On this route it is read, not lifted.
- **NEW, SETTLED in v10: the `y ≤ z` repair of Reynolds' Lemma 4 display lands BESIDE the faithful
  transcription, never in place of it.** Grounds, all machine-checked or image-verified: (i) the
  strict display is **false** at a first-class point of a maximal `R`-interval with an excluded
  left end point `r ∈ M`, the configuration Reynolds' own Lemma 3 licenses; (ii) it remains
  **sound**, which is the direction his Lemma 4 proof needs, so the transcription is not wrong
  about anything he proves; (iii) his Lemma 6 second paragraph consumes the plain-English
  statement, which only the repaired formula delivers; (iv) `reynolds_lemma4_no_first_class_closed`
  compiles green through the same `false_of_holds_throughout_class` route, byte-for-byte the shape
  of the landed strict-form proof, so **his argument is unchanged by the repair**. The defect is
  the **source's**, recorded under honesty-charter Rule 7, with the printed display quoted and the
  failing configuration named. **Residual risk, stated rather than hidden**: the attribution is a
  reading verified against the page image, not against a secondary source. The Lean does not depend
  on it — only the docstring's attribution would change if a reader disagrees, in which case the
  repair is recorded as this tree's rendering choice with Lemma 6's second paragraph cited as the
  evidence. **No code change either way.**
- **NEW, SETTLED in v10: the `λ`-side interval witness is obtained by instantiation through
  `Dual.lean`, never by a hand mirror.** `reports/09` §4.2 Attack 4: build the `ρ`-side producer
  and dualise it (6 lines, first-try green). Dualising a theorem that does not exist yields
  nothing, so `Dual.lean` is unavailable *before* the producer lands — a dispatch that reaches for
  it first will burn its budget discovering that. Hand-mirroring Lemma 4 is the exact cost Phase
  20.4's transport layer exists to avoid.
- **NEW, SETTLED in v10: no §6 result is described as discharged, and Phase 22.1 does not change
  that.** `IsContempEquivDense ε` remains a hypothesis on everything below Lemma 2; `epsTop` is
  the only exhibitable `ε`; `EndsInGapOnRight` is empty for it; there is no live non-trivial
  instance. 22.1 removes one named hypothesis and, at one named structure, the Prior-U/S half.
  **The `ε` half stands until Phase 25.** The caveat is rewritten, never deleted.

---

## Goals & Non-Goals

**Goals**:

- `consequence_completeness_dedekind (Γ : Context) (φ : Formula) :
  SemanticConsequenceDedekindDense Γ φ → Derivable FrameClass.Dedekind Γ φ`, sorry-free,
  unconditional, obtained by instantiating the pinned engine theorem.
- `completeness_dedekind (φ : Formula) : ValidDedekindDense φ → Derivable FrameClass.Dedekind [] φ`
  as its `Γ = []` corollary.
- **`kplusOpen` and `HasFaithfulDedekindINF`/`SUP`** — the source-exact `K⁺` and the eq (5.2)
  dichotomy carrier, with `prior_hasFaithfulDedekindINF_dense` derived from `SemanticPriorU` alone.
  **Reusable well beyond this task**: it repairs the tree's one deviation from the sources'
  primitive vocabulary.
- **The eight faithful modules re-based onto that carrier**, all declarations preserved, sorry-free
  and axiom-clean — closing the deferral recorded at `DedekindINF.lean:87-103`.
- `uSExpressivelyCompleteOverDensePrior` — `{U,S}` expressive completeness at the **dense** Prior
  carrier, with a non-vacuity witness.
- **A `DenseModelSurgery/Dual.lean` duality-transport layer** — `dual` / `d` / `dualize` /
  `swapUS` and the `eval`, `TemporalTruth`, Prior-U/S, `∼` and gap transports. **Reusable well
  beyond this task**: it is the first `OrderDual` machinery anywhere in `WeakCanonical/`, it
  formalizes Reynolds' *"using mirror images"* sentence directly rather than re-proving a proof he
  did not write, and it reduces every remaining §6 mirror from a module to ~25 lines.
- `no_gaps_dense_prior` (**D1**, Reynolds Theorem 4) and `dense_singletons_of_sep` (**D2**,
  Reynolds Theorem 5), both reusable.
- `doets_theorem_dense` (Reynolds Theorem 6 / Doets 3.3.9) and `doets_lemma_1_5` in live code.
- `orderIsoRealOfDedekindDenseSeparable` — an order-theoretic characterization of `ℝ` absent from
  Mathlib and of independent value.

**Non-Goals**:

- Genuine (infinite-premise) strong completeness. Provably unavailable.
- Discharging `Transfer.lean:1242`. Base/Discrete axis; not on this route.
- Removing or refactoring the amputated layer.
- Formalizing the two-sided `prior_S_gap` defeat. Moot on this route.
- Reviving `stavi_expressive_completeness` from `Boneyard/`. Fallback only.
- **Deleting, deprecating or restating `HasGuardedDedekindINF` / `HasDenseDedekindINF`.** They stay
  landed as the record of the deviation and as suppliers.
- **Editing `kplus`'s statement or proof, or unifying it with `kplusOpen`.**
- Any edit under `FormalSystem/Metalogic/Decidability/` or `FormalSystem/Automation/`.
- A uniform (single) real-flowed model.

---

## Risks & Mitigations

| # | Risk | Likelihood | Impact | Mitigation / falsification protocol |
|---|---|---|---|---|
| R1 | ~~Phase 10 fails: the dense Prior axioms do not yield the eq (5.2) carrier~~ | — | — | **DISCHARGED.** `prior_hasDenseDedekindINF_dense` / `prior_hasDenseDedekindSUP_dense` are landed, sorry-free and axiom-clean from `SemanticPriorU`/`SemanticPriorS` alone. The route's single point of failure held |
| R2 | **Block D's re-base is larger than the five phases scheduled.** Eight modules, 3,388 lines, 19 hypothesis sites | Medium | Schedule | Each of 11, 11.1, 12, 12.1, 13 is chartered against a **named module boundary in the import chain** with a stated `Done when`. A phase that on contact needs more lands whatever is green, records a named sub-phase list in its summary and handoff, and reports `[PARTIAL]` — it does **not** expand silently. The orchestrator then revises with the sub-phases spliced in at the same numeric level (flat `N.1` numbering; the scan admits at most one dot) |
| R3 | **Block F (Reynolds §6) is six phases of research-grade transcription with no discrete shortcut.** The discrete analogue cost 2215 lines *with* a shortcut | **High** | Schedule | Each phase owns one or two named lemmas of §6 whose statements are fixed verbatim by the source before any tactic is written. §6 is quoted in full in the corpus, so this is transcription, not discovery. Same `[PARTIAL]`-with-decomposition protocol as R2 |
| R4 | **Phase 27's "game argument" is not spelled out by Reynolds**, and is the only result the tree previously attempted and archived unproved | Medium-**High** | One-two phases | (i) The tree has `NEquivalence.lean`'s Karp/EF apparatus and `doets_lemma_1_4`. (ii) **Phase 27 is chartered against Doets 1987 3.1.8**, not Reynolds' one-liner. (iii) The archived draft is a *statement template* only — behind `#exit`, stale names, `sorry` body — and must be re-stated, not un-archived |
| R5 | **Phase 28's `ℝ` characterization is absent from Mathlib** | Certain | One-two phases | Standard bounded construction; chartered with a proof skeleton and a hard `Done when`; splits at the `D ≃o ℚ` / cut-extension seam |
| R6 | **Block D disturbs the landed discrete pipeline** | Medium | Regression | Hypothesis **weakening** only, never conclusion change; `HasDedekindINF.toHasFaithfulDedekindINF` keeps every current supplier working; `prior_makes_disjunct2_unreachable` proves the discrete pipeline cannot observe disjunct (2). Every Block D phase runs the three canaries and records the result |
| R7 | **The bimodal dimension does not survive the dense `≡ₖ` transfer** | Low | Blocks E/I | Attacked and defeated in `reports/07`'s adversarial pass. Phase 15's **first task** is the explicit `SuccOrder`/`PredOrder`/`IsSuccArchimedean` independence gate; `[BLOCKED]` with the exact dependency if it fails |
| R8 | **Effort overrun ends the task mid-programme** | **High** | Task state | Every phase ends green with the sorry census unchanged and the frozen files byte-identical, so every phase boundary is a clean stop. Block boundaries (14 / 16 / 22 / 23 / 29) are the reporting checkpoints |
| R9 | **A phase "succeeds" vacuously** | Medium | Silent | The anti-vacuity gate, plus v8's re-base corollary: a weakening must be shown strict by a structure satisfying the new carrier and not the old |
| R10 | **Territory collision with the concurrent decidability effort** | Low | Build | Hard prohibition on `Decidability/` and `Automation/`; staging scoped to the task directory plus the files a phase's Tasks list names. `git add -A` and `git commit -am` forbidden |
| **R11** | **The faithful dichotomy does not collapse the case split at `NegFixOneFaithful.lean:422` / `NegFixListFaithful.lean:446`.** v8's central planning bet — that the source-exact `K⁺` keeps those two consumers at two arms — is a **plan-time paper derivation**, not a machine-checked fact | **Medium** | Blocks D schedule | **Falsification is Phase 11's first deliverable, on the smallest site.** `negChainOnFaithful_iff` (`Lemma53Faithful.lean:274`) has the same two-arm shape; if the swap does not go through there, it will not go through at `:422`/`:446` either. **Chartered fallback**: Phases 12 and 12.1 fall back to consuming `HasDenseDedekindINF` with explicit endpoint branches at the two hard sites, split under the R2 protocol, and the schedule grows by the branches actually needed — **recorded honestly, not absorbed**. The fallback is strictly available because both carriers stay landed and interderivable-in-one-direction |
| **R12** | **The `¬P(z₀)` conjunct of `kplus` is load-bearing somewhere the survey did not reach**, so weakening the left disjunct breaks a proof | **Very low** | Block D | Surveyed and answered at this revision: **exactly three** sites destructure `kplus`'s `.1`, all inside `DedekindINFDense.lean`'s own refutation machinery (`:467`, `:486`, `:609`) — i.e. inside the apparatus that exists *because of* the conjunct. Every faithful-family consumer threads `kplus`/`kminus` opaquely. `orderedPointsExist_combine_kplus` (`Lemma53Faithful.lean:137`) discards it (`obtain ⟨-, hdense⟩ := hk`); `hasDefinableINF_excludes_kplus` (`Lemma53.lean:296`) and `hasDefinableSUP_excludes_kminus` (`Lemma53FaithfulPast.lean:339`) both `rintro ⟨-, h_dense⟩`. Phase 10.1 re-runs the audit as its first task and records any site the survey missed; such a site keeps the strong carrier via the shim rather than being weakened. **`kplus` itself is never edited, so no existing proof can break by construction** |
| **R14** | **`IsContempEquivDense` clause (iii) does not transport across the dual** — the one bounded attack that LANDED against Phase 20.4's cheap route. `M.subinterval` renders Reynolds' unordered `M\|[a,b]` as a Subtype over `min a b ≤ x ∧ x ≤ max a b`; the dual's predicate is the same two conjuncts in the opposite order, which is **not** definitionally equal, and no `eval`-along-carrier-iso lemma exists in the tree (`eval_rename` is variable renaming, not carrier transport) | **Confirmed — it is not a risk, it is a fact** | Bounded | **This is OUR formalization artifact, not Reynolds' — his `M\|[a,b]` is an unordered interval and the conjunct ordering is an artifact of the Lean rendering. Record it as such; do not attribute it to the source** (honesty-charter Rule 7). **Damage is bounded and measured**: clause (iii) is **never consumed** anywhere in the tree — repo-wide, `contemporary` appears at exactly two sites, its own declaration (`Defs.lean:242`) and its *construction* in the `epsTop` witness (`Defs.lean:479`). All of §6 uses clauses (i)+(ii) via `contemp_refl`/`_symm`/`_trans`/`_of_between` (`Lemma34.lean:176-199`). **Two escapes, in preference order, both chartered in Phase 20.4 Group 2**; Escape 2 is strictly additive and loses no fidelity because clause (iii) is dead weight |
| **R15** | **Phase 20.4's duality-transport layer does not reproduce green in-file**, and the phase burns its budget iterating on infrastructure instead of landing the deliverable — the classic analysis-paralysis shape this task has already paid for once | Low-Medium | Block F schedule | **A hard abort condition, written into the phase as a gate rather than a suggestion**: if **Group 1** does not reproduce green in-file on the **first** dispatch, Phase 20.4 falls back to the hand mirror **immediately** and does **not** iterate on the transport layer. Risk is front-loaded: ~150 of Group 1's lines were compiled green via `lean_run_code` in `reports/08`, with three named trivial residual errors and their fixes recorded. **Do not attempt both routes.** The fallback is chartered and sized (Phases 20.6/20.7 in Rollback/Contingency), so tripping the gate is a planned outcome, not a failure |
| **R13** | **`kplusOpen` is landed as a third `K⁺` spelling and the tree ends up with three**, deepening the collision `Formula.lean:163-179` already warns about | Medium | Maintainability | `kplusOpen` is chartered **not** as a new operator but as the **missing Prop-level reading of the existing `Formula.kPlus`** (`Syntax/Formula.lean:180`), landed together with the bridge lemma that has been absent since `Formula.kPlus` was written. Phase 10.1's `Done when` requires the bridge, and requires a single docstring paragraph — in the new module and in the two corrected docstrings — that names all three spellings, says which transcribes which source, and points at the collision warning. Net effect on the tree is **one fewer** unbridged spelling, not one more |

---

## Implementation Phases

### Dependency Analysis and wave map

Blocks D and E are **independent of each other** and may be dispatched in parallel by an
orchestrator with the budget for it: Block E consumes only the landed chronicle and the landed
`mkSigFrom` apparatus, and touches no file Block D touches. Everything from Block F on is a chain.

**New in v8**: Block D's re-base phases (11 → 11.1 → 12 → 12.1 → 13) are a **strict chain**, not a
sweep. The eight faithful modules form a linear import order and the tree cannot be left green with
a partial sweep. **No phase owns a file another phase owns in the same wave.**

| Wave | Phases | Blocked by | Territory (owned files) |
|---|---|---|---|
| — | **9**, **10** | — | `[COMPLETED]`. `WeakCanonical/PriorDefsDense.lean`; `Kamp/DedekindINFDense.lean` |
| 1 | **10.1**, **15** | 10 (for 10.1) | 10.1: `Kamp/KPlusFaithful.lean` (new) + comment-only edits to `Kamp/PriorINF.lean` and `Kamp/DedekindINFDense.lean`. 15: `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (new) |
| 2 | **11**, **16** | 10.1 (for 11); 15 (for 16) | 11: `Kamp/Lemma53Faithful.lean`, `Kamp/Lemma53FaithfulPast.lean`. 16: same bridge module |
| 3 | **11.1** | 11 | `Kamp/EANegationFixFaithful/BoundedFixFaithful.lean`, `.../BoundedFixAnchoredFaithful.lean` |
| 4 | **12** | 11.1 | `Kamp/EANegationFixFaithful/NegFixOneFaithful.lean` |
| 5 | **12.1** | 12 | `Kamp/EANegationFixFaithful/NegFixListFaithful.lean` |
| 6 | **13** | 12.1 | `Kamp/EANegationFixFaithful/VecEANegFixFaithful.lean`, `Kamp/Prop42Faithful.lean` |
| 7 | **14** | 13 | `WeakCanonical/PriorExpressivenessDense.lean` (new) |
| 8 | **17** | 14, 16 | `WeakCanonical/DenseModelSurgery/Defs.lean` (new) |
| 9 | **18** | 17 | `DenseModelSurgery/Lemma34.lean` (new) |
| 10 | **19** | 18 | `DenseModelSurgery/Lemma5.lean` (new) |
| 11 | **20** | 19 | `DenseModelSurgery/BadIntervals.lean` (new) |
| 12 | **20.4**, **21**, **20.5** | 20.4: 19 + 20's landed content. 21: **20's landed Lemma 7 only — NOT 20.4**. 20.5: — (independent) | 20.4: `DenseModelSurgery/Dual.lean` (new) + append-only extension of `Lemma5.lean` and `BadIntervals.lean`. 21: `DenseModelSurgery/TruthTransfer.lean` (new). 20.5: `WeakCanonical/PriorExpressiveness.lean` (comment bytes only) — **three-way parallel-eligible, no shared file** |
| 13 | **22** | 21 | `DenseModelSurgery/NoGaps.lean` (new) |
| 13a | **22.1** *(new in v10)* | 22's landed content, and this revision | `DenseModelSurgery/Lemma34.lean` (append-only), `DenseModelSurgery/BadIntervals.lean` (append-only), `DenseModelSurgery/NoGaps.lean` (append + the one docstring rewrite), `DenseModelSurgery/ChronicleInstance.lean` (**new**) — **no parallel opportunity is declared**: it appends to three files owned by Phases 18, 20 and 22 (all `[COMPLETED]`, so no live conflict), but Phases 23-25 are already blocked behind 22, and 28 remains the only free-floating unit |
| 14 | **23** | 22 | `DenseModelSurgery/Singletons.lean` (new) |
| 15 | **24**, **25** | 22 | 24: `RealModel/GoodDense.lean` (new). 25: `RealModel/EpsilonDense.lean` (new) — **parallel-eligible pair** |
| 16 | **26** | 24, 25 | `RealModel/Shuffle.lean` (new) |
| 17 | **27** | 26 | `RealModel/ShuffleReal.lean` (new) |
| 18 | **28** | — (independent; schedule any time after wave 1) | `RealModel/OrderIsoReal.lean` (new) — **parallel-eligible with waves 2-17** |
| 19 | **29** | 23, 27, 28 | `RealModel/DoetsTheorem.lean` (new) |
| 20 | **30** | 29 | `BXCanonical/CompletenessDedekind.lean` (extend), `Metalogic/StrongCompleteness.lean` (extend), `FormalSystem/Metalogic.lean` (tracking table) |

**Explicit parallel opportunities**: `{10.1, 15}`, `{11, 16}`, **`{20.4, 21, 20.5}`**, `{24, 25}`,
and `28` against anything from wave 2 onward. Every other edge is a genuine dependency.
**v10 adds no parallel opportunity.** Phase 22.1 is a single dispatch on the critical path; the set
above is unchanged.

**Does Phase 23 wait for 22.1? No — and this is a checked claim, not a convenience.** Phase 23
consumes Theorem 4, and Theorem 4 is **landed** (`no_gaps_dense_prior`, sorry-free and axiom-clean)
— it merely carries the extra `HasBadIntervalSurgery` binder, which a consumer can thread through
exactly as it threads `IsContempEquivDense ε` and Prior-U/S. What 22.1 buys Phase 23 is one fewer
binder to thread, not the theorem itself. The `Depends on: 22` edge for Phase 23 therefore stands
**unamended**, and 22.1 is not inserted into anyone's dependency list. **Falsification
instruction**: if Phase 23 on contact finds it cannot thread the binder, it names the exact
obligation and reports `[BLOCKED]` on 22.1 — it does not quietly wait and does not inline a
producer of its own.

**Phase 21 is NOT serialized behind Phase 20.4, and this is a checked claim rather than a
convenience.** Lemma 8's thirteen cases consume **Lemma 7**, and `reynolds_lemma7`
(`BadIntervals.lean:1230`) is complete on **both** sides — the 258-line *"Similarly at the end"*
mirror landed in Phase 20. Lemma 6's fourth half is not on Lemma 8's critical path. This was
asserted by the Phase 20 handoff and independently corroborated in `reports/08` by reading the
declaration. **Falsification instruction**: if Phase 21 on contact finds it needs
`reynolds_lemma6`'s fourth conjunct (or any `R`-from-`L` fact), it **names the exact dependency
and reports `[BLOCKED]` on 20.4** — it does not quietly wait, and it does not invent the mirror
inline.

Directory names for new modules are proposals; an implementer who places a module elsewhere records
the deviation in the phase summary.

---

### Phase 9: `SemanticPriorU` / `SemanticPriorS` and the dense-flow vacuity witness [COMPLETED]

> **Record, preserved from v7.** Landed `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean`
> (407 lines, 11 declarations, sorry-free). `SemanticPriorU` / `SemanticPriorS` are Reynolds'
> Prior-U / Prior-S in the `OrderedMonadicStructure` idiom (printed p.168, re-verified against PDF
> page 4; p.176 re-verified against PDF page 12). The anti-vacuity gate was **exceeded**:
> `semanticPriorUZ_fails_of_interval_witness` and `semanticPriorUZ_fails_on_dense` refute the
> *integer* hypothesis on a dense flow, and `semanticPriorU_of_flowGLB` / `semanticPriorS_of_flowLUB`
> give the general Dedekind-complete-flow theorem, instantiated at `denseWindowFlow` and at a
> bounded window whose Prior-U antecedent is actually satisfied
> (`densePriorU_antecedent_reachable`). All eleven declarations `[propext, Classical.choice,
> Quot.sound]`; the exclusion lemma `[propext]` only. `lake build` = "Build completed successfully
> (1909 jobs)". `PriorDefs.lean` byte-identical.
>
> **v8 note.** `SemanticPriorU` is the semantic reading of `Axiom.prior_U_gap`, which is stated with
> the **conjunct-free** `Formula.kPlus` (`Axioms.lean:377`; `Syntax/Formula.lean:180`). This is the
> upper end of the seam Phase 10.1 closes, and it is the reason the faithful dichotomy is derivable
> from `SemanticPriorU` with no guard.

- **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean` (now a Preserved Asset).
- **Timing**: 4 hours (spent).

### Phase 10: `HasDedekindINF` / `HasDedekindSUP` from the dense Prior axioms [COMPLETED]

> **OUTCOME — the route's single point of failure HELD.** The derivation from `SemanticPriorU` /
> `SemanticPriorS` is complete, sorry-free and axiom-clean, with **no discreteness, no attainment
> and no flow completeness**. The plan's proof skeleton (steps 1-6) transcribed verbatim and the
> module built green on its first compilation. Landed
> `FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINFDense.lean` (631 lines, 32 declarations).
> `DedekindINF.lean`, `PriorINF.lean` and `PriorDefsDense.lean` byte-identical. `lake build` =
> "Build completed successfully (1912 jobs)". Canaries `completeness_dense`,
> `completeness_discrete`, `countermodel_discrete_reynolds_v2` unchanged. Live sorry outside
> `Boneyard/` remains exactly `Transfer.lean:1242`.
>
> **Deviation (recorded, `kind: altered`, authorized by the Phase 9 input block).** The target was
> `prior_hasDedekindINF_dense` concluding in bare `HasDedekindINF`. Landed instead as
> `prior_hasGuardedDedekindINF_dense` (guard `¬P(z₀)`, conclusion character-for-character
> `HasDedekindINF`'s) **plus** `prior_hasDenseDedekindINF_dense` (the hypothesis-free trichotomy,
> the exported form), with the `SUP` mirrors. Both are landed and interderivable. The unguarded
> statement is refuted on disk by `hasDedekindINF_fails_of_interval_witness` (`:455`) and
> instantiated at `hasDedekindINF_fails_on_dense_window`. All three disjuncts are exhibited
> reachable: `denseWindow_kplus_at_zero`, `denseWindow_guardedINF_right_disjunct`,
> `denseWindow_endpoint_disjunct_forced`.
>
> **The three findings this phase produced are the input to v8 and are recorded in the Revision
> Rationale**: (1) the single point of failure held; (2) downstream consumes a hypothesis-free
> carrier, not the guarded one, at three by-cases-reached sites with no left-endpoint hypothesis in
> scope; (3) an `EANegationFixFaithful/` subtree plus `Lemma53Faithful.lean` and
> `Prop42Faithful.lean` already exist and already consume `HasDedekindINF`.
>
> **v8 amendment to this phase's record, not to its Lean.** Phase 10's docstring asserts that
> Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is *"false read literally"*. **That attribution is
> withdrawn.** Read against Rabinovich's own Definition (3) — *"`K+(F)` holds at a moment `t` iff
> `t = inf({t′ | t′ > t and F holds at t′})`"* — the biconditional is a definitional restatement,
> true verbatim. What is true is that **this tree's `kplus` (`PriorINF.lean:86`) is not
> Rabinovich's `K⁺`**, and the tree's own `Syntax/Formula.lean:163-179` says so independently. **No
> landed statement or proof of this phase is affected**; the guard, the trichotomy and the
> refutation remain true theorems about the tree's `kplus`. Only the docstring's attribution is
> wrong, and Phase 10.1 corrects it by comment bytes.

- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINFDense.lean` (now a Preserved
  Asset; comment-only edits permitted to Phase 10.1 alone).
- **Timing**: 6 hours (spent).

---

### Phase 10.1: The source-exact `K⁺`, its missing bridge, and the faithful dichotomy carrier [COMPLETED]

> **This phase is a probe as much as a construction, and it is chartered to be falsifiable in one
> dispatch.** v8's central bet (R11) is that the sources' conjunct-free `K⁺` turns Phase 10's
> trichotomy back into a two-arm dichotomy that the eight faithful modules can consume with a
> signature swap. That bet is settled here, by machine, before a single consumer is touched. If the
> refutation `hasDedekindINF_fails_of_interval_witness` still goes through against a conjunct-free
> antecedent, the bet is **lost**, this phase reports the fact, Phases 11-13 fall back to the
> trichotomy with explicit endpoint branches, and the schedule grows by what the branches actually
> cost. Nothing downstream assumes the bet.

- **Goal**: Land `kplusOpen` / `kminusOpen` as the **Prop-level reading of the already-existing
  `Formula.kPlus` / `Formula.kMinus`** (`Syntax/Formula.lean:180`, `:193`), together with **the
  bridge lemma the tree has never had**; land `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`
  (eq (5.2) with its left disjunct at the source's `K⁺`); derive them from `SemanticPriorU` /
  `SemanticPriorS` **with no guard and no endpoint disjunct**; and settle by machine whether the
  guard/trichotomy apparatus is needed at all.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/KPlusFaithful.lean` (**new — confirm it does
  not already exist before creating it**), plus **comment-bytes-only** corrections to
  `Kamp/PriorINF.lean` and `Kamp/DedekindINFDense.lean`.
  **`DedekindINF.lean`, `Lemma53.lean`, `Syntax/Formula.lean`, `ProofSystem/Axioms.lean` and all
  eight faithful modules are read, not edited, in this phase.**
- **Tasks**:
  - [x] **Task 0 — existence check (binding, from the v8 postmortem rule).** `find`/`grep` for
        `KPlusFaithful`, `kplusOpen`, `HasFaithfulDedekindINF` and any Prop-level conjunct-free `K⁺`
        before writing a line. If any exists, consume it and record the finding instead of building.
  - [x] **Task 1 — the `.1` audit (R12).** Repository-wide, outside `Boneyard/`: every site that
        projects the first component of a `kplus` / `kminus` hypothesis. The survey at this revision
        found **exactly three**, all inside `DedekindINFDense.lean`'s own refutation machinery
        (`:467`, `:486`, `:609`), and confirmed that
        `orderedPointsExist_combine_kplus` (`Lemma53Faithful.lean:137`, `obtain ⟨-, hdense⟩ := hk`),
        `hasDefinableINF_excludes_kplus` (`Lemma53.lean:296`) and `hasDefinableSUP_excludes_kminus`
        (`Lemma53FaithfulPast.lean:339`) all discard it. **Re-run the audit and record the result in
        the summary.** Any site the survey missed is recorded and keeps the strong carrier via a
        shim rather than being weakened.
  - [x] Define `kplusOpen M atomMap P t : Prop :=
        ∀ s, t < s → ∃ r, t < r ∧ r < s ∧ TemporalTruth M atomMap r P`, and `kminusOpen` dually.
        **State in the docstring that this is `kplus` minus its first conjunct, and that the first
        conjunct is the tree's addition, not the sources'.**
  - [x] **Land the missing bridge**: `kPlus_formula_correct :
        TemporalTruth M atomMap t (Formula.kPlus P) ↔ kplusOpen M atomMap P t`, and the `kMinus`
        mirror. **The tree has had `Formula.kPlus` and `kplusFormula` side by side with a
        name-collision warning and no bridge to either's semantics.** This lemma is the phase's
        second deliverable and is independently valuable: `Axiom.prior_U_gap`, `Axiom.prior_S_gap`
        and `Axiom.sep` are all stated with `Formula.kPlus`/`kMinus`, and nothing in the tree could
        previously read them semantically.
  - [x] Land the relating lemmas: `kplus M atomMap P t ↔ ¬TemporalTruth M atomMap t P ∧
        kplusOpen M atomMap P t`; `kplus … → kplusOpen …`; and
        `(TemporalTruth M atomMap t P ∨ kplus M atomMap P t) → kplusOpen M atomMap P t` **together
        with a machine-checked witness that the converse fails**
        *(deviation: altered — the arrow as written is **not a theorem**: `P(t)` does not imply
        `kplusOpen P t`. The plan's own parenthetical ("a point where `P` holds and `P` does not
        occur arbitrarily soon after") specifies the counterexample to exactly that direction, so
        the intended content is unambiguous and was landed in full: `truth_or_kplus_of_kplusOpen :
        kplusOpen P t → TemporalTruth t P ∨ kplus P t` (the true direction, and the one the shim
        lattice needs), plus `kplusOpen_not_implied_by_truth_at`, the machine-checked witness that
        the stated direction fails — `denseClosedRayFlow` at `t = 0`. Nothing is weakened; one
        arrow is turned around and its failure is proved.)* The pair is what makes the
        trichotomy's weakness precise rather than asserted.
  - [x] Define `HasFaithfulDedekindINF` — `HasDedekindINF`'s `first_occ` field character-for-character
        **except** that the left disjunct is `kplusOpen M atomMap P z0` in place of
        `kplus M atomMap P z0` — and `HasFaithfulDedekindSUP` dually. **Rule 6**: state what the
        carrier excludes.
  - [x] Prove `prior_hasFaithfulDedekindINF_dense : SemanticPriorU M atomMap →
        HasFaithfulDedekindINF M atomMap`, and the `SemanticPriorS` mirror.
        **Proof skeleton (paper-derived at this revision; transcribe and verify, do not treat as
        established).** Fix `P`, `z₀ < z₁`, `P` occurring in `(z₀,z₁)`. `by_cases` on whether some
        `(z₀,s)` is `P`-free.
        1. **No `P`-free initial stretch** — that *is* `kplusOpen M atomMap P z₀`; take the left
           disjunct. (Rabinovich's subcase `r₀ = z₀`, PDF p.8, at his own `K⁺`.)
        2. **Some `(z₀,s)` is `P`-free** — then `U(⊤,¬P)(z₀)` holds, and `P` occurring in `(z₀,z₁)`
           gives `F(¬¬P)(z₀)`. `SemanticPriorU` at `p := ¬P` yields `r₀ > z₀` with `¬P` throughout
           `(z₀,r₀)` and `P(r₀) ∨ K⁺(P)(r₀)`; `r₀ < z₁` because `P` occurs in `(z₀,z₁)` and `¬P`
           holds on `(z₀,r₀)`. That is eq (5.2) verbatim.
        **The case split is on the interval, never on `z₀`** — which is why no guard appears.
        Note that `P(r₀) ∨ kplusOpen P r₀` and `P(r₀) ∨ kplus P r₀` are interderivable as
        *disjunctions*, so the right disjunct is literally `HasDedekindINF`'s.
  - [x] Land the shim lattice, and state which directions are **not** available and why:
        `HasDedekindINF.toHasFaithfulDedekindINF` (weakening — keeps every current supplier,
        including the whole discrete pipeline via `HasAttainedINF.toHasDedekindINF`);
        `HasFaithfulDedekindINF.toHasDenseDedekindINF` (the faithful carrier supplies the
        trichotomy, since `kplusOpen → kplus ∨ P(z₀)`); and a recorded note that
        `HasDenseDedekindINF → HasFaithfulDedekindINF` is **not** available, because `P(z₀)` does
        not imply `r₀ = z₀`. Mirrors for `SUP`.
  - [x] **THE PROBE (R11's falsification, and this phase's most important task).** Re-run the
        interval-witness refutation against the conjunct-free antecedent: attempt
        `hasFaithfulDedekindINF_of_interval_witness` — i.e. show that at `denseWindowFlow` with
        `z₀ = 1/2`, `z₁ = 1`, the point at which `denseWindow_endpoint_disjunct_forced` forces the
        trichotomy's third disjunct, **`HasFaithfulDedekindINF`'s left disjunct holds**. Land it as
        a named lemma. **Record the outcome explicitly in the summary and handoff, in these terms**:
        either *"the guard/trichotomy apparatus is a repair for the tree's `kplus` and is not needed
        by a source-exact carrier"*, or *"the refutation survives the conjunct-free antecedent"* —
        the latter falsifies R11 and triggers the chartered fallback.
  - [x] **Anti-vacuity, positive.** Instantiate `prior_hasFaithfulDedekindINF_dense` at Phase 9's
        `denseWindowFlow` and land the resulting `HasFaithfulDedekindINF` as a named lemma.
  - [x] **Anti-vacuity, re-base corollary (v8).** Exhibit a structure satisfying
        `HasFaithfulDedekindINF` that does **not** satisfy `HasDedekindINF` — `denseWindowFlow` is
        the intended witness and `hasDedekindINF_fails_on_dense_window` already supplies the second
        half. Without this the "weakening" may be an equivalence in disguise.
  - [x] **Docstring correction 1 — `PriorINF.lean`, comment bytes only.** Record on `kplus` that it
        is **not** Reynolds' or Rabinovich's `K⁺`: quote both source definitions
        (`¬U(⊤,¬A)` / `¬((¬F)UntilTrue)`, and *"`K+(F)` holds at `t` iff
        `t = inf({t′ | t′ > t and F holds at t′})`"*), name `Formula.kPlus` (`Syntax/Formula.lean:180`)
        as the tree's source-exact spelling and `kplusOpen` as its Prop-level reading, and point at
        the collision warning at `Formula.lean:163-179`. **Resolve the unresolved doubt already in
        the file at `:75-81`** (*"Actually wait, the Rabinovich paper uses the notation
        differently"*) rather than leaving it. **No statement or proof byte changes.**
  - [x] **Docstring correction 2 — `DedekindINFDense.lean`, comment bytes only.** Withdraw the claim
        that Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is false read literally; replace it with the
        accurate statement (the biconditional is a definitional restatement under his Definition (3);
        the tree's `kplus` carries an extra conjunct neither source has). Complete the honesty-charter
        Rule 4 label already present on the guard/trichotomy apparatus by recording **what it is glue
        for**. **No statement or proof byte changes; every landed theorem stays exactly as it is.**
  - [x] **Verify both corrections are comment-only**: `git diff -U0` on the two files shows changes
        only inside `/-` … `-/` or `--` lines; re-run `#print axioms` on
        `prior_hasDenseDedekindINF_dense` and `hasDedekindINF_fails_of_interval_witness` and confirm
        unchanged.
  - [x] Docstrings on all new declarations per the honesty charter: `Rabinovich 2014, K⁺ definition
        and Lemma 5.3 eq (5.2), PDF pp.3 and 8`; `Reynolds 1992, K⁺ abbreviation and Prior-U,
        printed p.168` — **re-verify both printed pages against the PDF and record any correction**.
  - [x] `#print axioms` on every new declaration; regression canaries `completeness_dense`,
        `completeness_discrete`, `countermodel_discrete_reynolds_v2`.
  - [x] Add the aggregator import edge for CI protection, matching Phases 9 and 10's practice
        (`WeakCanonical.lean`).
  - [x] Scoped build green; full `lake build` green; sorry census unchanged.
- **Estimated output**: ~320 lines (new module), plus ~40 lines of corrected comments across two
  files.
- **Done when**: `kplusOpen`, `kminusOpen`, **the `Formula.kPlus`/`kMinus` bridge lemmas**,
  `HasFaithfulDedekindINF`/`SUP`, `prior_hasFaithfulDedekindINF_dense`/`SUP` and the shim lattice
  are sorry-free with axioms exactly `[propext, Classical.choice, Quot.sound]`; **the probe's
  outcome is recorded explicitly in the summary and handoff, either way**; the anti-vacuity witness
  and the re-base-corollary witness both land; the two docstring corrections are verified
  comment-only; the three canaries are unchanged; `DedekindINF.lean`, `Lemma53.lean`,
  `Syntax/Formula.lean`, `Axioms.lean` and all eight faithful modules are byte-identical; full
  `lake build` green; sorry census exactly `Transfer.lean:1242`.
- **Depends on**: 10.
- **Timing**: 5 hours.
- **If the probe falsifies R11**: report the phase `[COMPLETED]` anyway — the carrier, the bridge
  and the corrections are all real deliverables — but record the falsification prominently in the
  handoff's `route_critical_findings`, and flag that Phases 12 and 12.1 must take the trichotomy
  fallback. Do **not** dispatch Phase 11 without the orchestrator having read that finding.

### Phase 11: Faithful-carrier re-base, base layer — `Lemma53Faithful` + `Lemma53FaithfulPast` [COMPLETED]

> **R11's consumer-level verdict: the two-arm shape HELD, machine-checked.** At
> `negChainOnFaithful_iff` the `rcases h_INF.first_occ … with hk | ⟨r0, …⟩` split is unchanged;
> only `hk`'s type moved, `kplus P z₀` → `kplusOpen P z₀`. No new branch, no endpoint case, no
> `by_cases` added. The mirror at `HasFaithfulDedekindSUP.last_occ_tp` is likewise two-arm. Both
> scoped builds were green on the **first** attempt with zero failed proof attempts. The chartered
> R11 fallback is **not** triggered.
>
> **One survey gap found, and it is the material input to Phase 11.1.** Re-basing
> `negChainOnFaithful_iff`'s binder reddens **eight** call sites in Phase 11.1's territory, which
> this phase may not edit. Machine-measured by disabling the shim and rebuilding: exactly four
> `Application type mismatch` errors at `BoundedFixFaithful.lean:215,227,281,290` and four at
> `BoundedFixAnchoredFaithful.lean:181,193,257,266`, and **no other errors anywhere**. A labelled
> `Coe` shim (`Lemma53Faithful.lean:596`) closes the window; Phase 11.1 swaps the four binders and
> **must delete the shim in the same change**.

> **v7's charter for this phase is withdrawn as factually wrong about the tree.** v7 chartered the
> construction of a new `EANegationFix/OnBuilderFaithful.lean`, ~350 lines. `Lemma53Faithful.lean`
> (391 lines) **already exists**, sorry-free and CI-protected, and already contains the printed
> three-disjunct `Oₙ₊₁` over `HasDedekindINF` — including the `Subcase r₀ = z₀` branch that the
> attained carrier deletes. Its Since mirror `Lemma53FaithfulPast.lean` (364 lines) exists too and
> **was absent from the Phase 10 handoff's list**. This phase re-bases them; it builds nothing from
> scratch.

- **Goal**: `Lemma53Faithful.lean` and `Lemma53FaithfulPast.lean` re-based from `HasDedekindINF` /
  `HasDedekindSUP` onto `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`, every declaration
  preserved with its conclusion unweakened, and the `K⁺` primitives in `Lemma53Faithful.lean`
  re-pointed at the source-exact spelling.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53Faithful.lean`,
  `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53FaithfulPast.lean`.
  **`Lemma53.lean`, `DedekindINF.lean`, `PriorINF.lean`, `EANegationFix/**` and
  `EANegationFixFaithful/**` are read, not edited.**
- **Tasks**:
  - [x] Re-point the `K⁺` primitives in `Lemma53Faithful.lean`: land `kplusOpenPred` beside
        `kplusPred` (`:81`) as `⟨Formula.kPlus P.formula⟩` — **the object-language spelling already
        exists and needs no new formula** — with `kplusOpenPred_eval` from Phase 10.1's bridge;
        `kplusOpenLeftBlock` beside `kplusLeftBlock`; and
        `orderedPointsExist_combine_kplusOpen` beside `orderedPointsExist_combine_kplus` (`:137`).
        **The last is expected to be nearly free**: the landed proof opens its hypothesis as
        `obtain ⟨-, hdense⟩ := hk`, discarding exactly the conjunct being dropped. Prove the landed
        `kplus` versions **from** the `kplusOpen` ones so nothing is duplicated in substance.
        *(All five landed at `:140`, `:145`, `:304`, `:309`, `:208`. The prediction was exact: the
        only proof-body change in `orderedPointsExist_combine_kplusOpen` is line 1,
        `obtain ⟨-, hdense⟩ := hk` → `have hdense := hk`; the remaining 21 lines are the landed
        proof byte-identical. `orderedPointsExist_combine_kplus` (`:245`) is now a one-line
        derivation via `kplusOpen_of_kplus`.)*
  - [x] Re-base `negChainOnFaithful` and `negChainOnFaithful_iff` (`:230` binder, `:274` destructure)
        onto `HasFaithfulDedekindINF`, keeping the printed three-disjunct `Oₙ₊₁` — disjunct (2) now
        gated on the **source-exact** `K⁺`, which is Rabinovich's own *"`K⁺(P₁)(z₀) ∧
        Oₙ(P₂,…,Pₙ,z₀,z₁)`"* (PDF p.9, corpus `chunk_0016.md:3`) rather than a strictly stronger
        proxy. **The two-arm `rcases … with hk | ⟨r0, …⟩` shape is expected to survive unchanged**;
        only `hk`'s type moves.
        *(**R11 consumer-level verdict: HELD.** `negChainOnFaithful` `:340` changed by one
        identifier; `negChainOnFaithful_iff` `:365` changed by its binder plus two tactic-line
        renames. The `rcases` at the old `:274` is structurally unchanged. Disjunct (3)'s point
        type deliberately stays at `kplusPred`: the faithful carrier's right disjunct is literally
        `HasDedekindINF`'s, so nothing at `r₀` needed to move.)*
  - [x] Re-base `lemma53Faithful` (the `∃ O, ∀ M …` form) onto the faithful carrier.
        *(`:460`; binder-type only, proof byte-identical.)*
  - [x] Re-base `HasDedekindSUP.last_occ_tp` (`Lemma53FaithfulPast.lean:181`, an unconditional
        wrapper) and the `kminus` primitives (`kminusFormula`, `kminus_formula_correct`,
        `kminusPred`, `kminusPred_eval`, `orderedPointsExist_combine_kminus`) onto the mirror.
        *(deviation: altered — additive at `last_occ_tp` rather than in place.
        `HasFaithfulDedekindSUP.last_occ_tp` landed at `:254`, and `HasDedekindSUP.last_occ_tp`
        `:221` is **kept unchanged**. Reason, machine-forced: the faithful carrier can only supply
        `kminusOpen P z₁` in the left disjunct, and `kminusOpen ↛ kminus`, so re-basing that
        wrapper in place would strictly **weaken a landed conclusion** — which "every declaration
        preserved with its conclusion unweakened" forbids. The two are incomparable (weaker
        hypothesis **and** weaker conclusion); neither has a live consumer, so keeping both costs
        nothing. `kminusOpenPred`/`_eval` landed at `:199`/`:203`;
        `orderedPointsExist_combine_kminusOpen` at `:343` with `_kminus` `:380` derived from it.
        `kminusFormula`/`kminus_formula_correct`/`kminusPred`/`kminusPred_eval` needed no change
        and are byte-identical.)*
  - [x] **Preserve `prior_makes_disjunct2_unreachable` (`Lemma53Faithful.lean:382`) and
        `prior_makes_kminus_disjunct_unreachable` (`Lemma53FaithfulPast.lean:355`)**, and land their
        faithful-carrier analogues or record why the analogue does not hold. These two are the
        tree's machine-checked statement that the discrete pipeline cannot observe disjunct (2); if
        the faithful carrier changes that, **say so** — it is exactly the observability the dense
        route needs.
        *(Both preserved verbatim in statement, at `:556` and `:482`, and both now **derived** from
        their new faithful analogues `prior_makes_faithful_disjunct2_unreachable` `:537` and
        `prior_makes_faithful_kminus_disjunct_unreachable` `:464`. **The analogues hold**: the
        faithful carrier does **not** make disjunct (2) observable on Prior structures. This was
        the live risk — `kplus → kplusOpen`, so a weaker gate could have fired where the stronger
        one cannot — and it is resolved against observability. Attainment kills `kplusOpen P z₀`
        outright: an attained first occurrence `r₀ > z₀` with `¬P` on `(z₀,r₀)` contradicts `P`
        occurring in every `(z₀,s)`. Observability still requires a genuinely non-attained
        Dedekind-complete frame class, which the tree does not construct.)*
  - [x] **THE MEASUREMENT (binding, and the input to Phases 11.1-13).** Record in the summary, per
        remaining module and per declaration, whether the re-base was (a) binder-type only,
        (b) binder + a projection/name fix, or (c) genuinely new proof. Give counts and file:line.
        **Phases 11.1, 12, 12.1 and 13 are scheduled against this measurement, not against this
        plan's estimate.** In particular state plainly whether the two-arm shape survived — that is
        R11's verdict at the smallest site.
        *(Recorded in the summary and in `.orchestrator-handoff.json`'s `binding_measurement`.
        Headline: **0 declarations in class (c) attributable to the re-base**; 2 class-(a),
        4 class-(b), 6 mechanical new spelling-level primitives, 4 retained-and-derived, 2 new
        exclusion theorems (class (c), but new content the honesty charter demanded, not re-base
        cost), 1 original-glue shim. Zero failed proof attempts; both scoped builds green first
        try.)*
  - [x] Docstrings: `Rabinovich 2014, Lemma 5.3 and eq (5.2), PDF pp.8-9`, with an `ADAPTED-FROM`
        note naming the previous `HasDedekindINF` pin and one clause on what changed (the left
        disjunct moved from the tree's `kplus` to the source's `K⁺`). Cite Rabinovich's printed
        `Oₙ₊₁` disjunct list verbatim so a reader can check the transcription disjunct by disjunct.
        *(Module-level `ADAPTED-FROM` sections in both files; per-declaration `ADAPTED-FROM`
        clauses on every moved declaration; the printed `Oₙ₊₁` disjunct list and the printed
        subcase split quoted verbatim on `negChainOnFaithful_iff`.)*
  - [x] `#print axioms` on every re-based declaration; regression canaries.
        *(24 declarations checked; all `[propext, Classical.choice, Quot.sound]` or a subset, no
        `sorryAx`. `completeness_dense`, `completeness_discrete`,
        `countermodel_discrete_reynolds_v2` all unchanged at
        `[propext, Classical.choice, Quot.sound]`.)*
  - [x] Scoped build green; full `lake build` green; sorry census unchanged.
        *(Both scoped builds green first attempt; full `lake build` green, 1919 jobs; sole live
        sorry outside `Boneyard/` remains `Transfer.lean:1242`.)*
  - [x] **Unplanned, and the material input to Phase 11.1 — the compatibility shim.** Not
        anticipated by the Faithful-Subtree Survey: re-basing `negChainOnFaithful_iff`'s binder
        reddens eight call sites in Phase 11.1's territory, which this phase may not edit. Closed
        with `coeHasDedekindINFToFaithful` (`Lemma53Faithful.lean:596`), a labelled `Coe` wrapper
        around the landed `HasDedekindINF.toHasFaithfulDedekindINF`. **Phase 11.1 must delete it**
        in the same change that swaps the four binders.
- **Estimated output**: ~280 lines changed/added across the two modules.
- **Done when**: both modules compile with every pre-existing declaration present, sorry-free,
  axiom-clean and with its conclusion unweakened; `negChainOnFaithful_iff` and `last_occ_tp` are
  stated at the faithful carriers; **the measurement is recorded**; the three canaries are
  unchanged; `Lemma53.lean`, `DedekindINF.lean`, `PriorINF.lean` and `EANegationFix/**`
  byte-identical.
- **Depends on**: 10.1.
- **Timing**: 6 hours.
- **Decomposition protocol (R2)**: if the re-base needs more than one agent run, land whatever is
  green (the INF side is the natural first half; the `Past`/SUP mirror is the second), record a
  named sub-phase list in the summary and handoff, and report `[PARTIAL]`. Do **not** expand
  silently and do **not** stub with `sorry`.
- **Fallback (R11)**: if Phase 10.1's probe falsified the bet, or if the two-arm shape does not
  survive here, re-base onto `HasDenseDedekindINF` instead and handle the `P(z₀)` disjunct
  explicitly at `:274` — recording the branch's actual content, since `P(z₀)` supplies no infimum
  information and the branch must derive what it needs from the ambient hypotheses. Report the
  extra cost honestly rather than absorbing it.

### Phase 11.1: Faithful-carrier re-base — `BoundedFixFaithful` + `BoundedFixAnchoredFaithful` [COMPLETED]

> **The four-binder swap was exactly as measured; the blast radius was not.** Phase 11's
> shim-disabled probe found eight red sites and "no other error anywhere", and that measurement
> held: both target modules are pure signature swaps, neither opens the carrier, and both scoped
> builds went green on the first attempt with zero proof-search tool calls. But the probe was taken
> with the four binders *unchanged*, so it could not see one module further down. Swapping them
> reddened **five transitive call sites** in Phase 12's and Phase 12.1's territory —
> `NegFixOneFaithful.lean:253` and `NegFixListFaithful.lean:368`, `:421`, `:437`, `:500` — all
> consumers of `negBoundedLeftFixAnchoredFaithful_iff`. Resolved by deviation D3 below: an explicit
> `.toHasFaithfulDedekindINF` at each of the five argument positions, **no binder or statement
> touched in either downstream module**. See D3 for why this was chosen over keeping the shim.

- **Goal**: Rabinovich Corollary 5.4, unanchored and anchored, re-based onto the faithful carrier.
  Surveyed as **pure signature swap**: four hypothesis sites, **no destructure sites** — both
  modules delegate to `Lemma53Faithful`'s primitives without opening the carrier.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixFaithful.lean`
  (371 lines, sites `:188`, `:258`),
  `.../EANegationFixFaithful/BoundedFixAnchoredFaithful.lean` (355 lines, sites `:150`, `:230`).
  **`EANegationFix/BoundedFix.lean` and `EANegationFix/BoundedFixAnchored.lean` — the attained
  originals — are read, not edited.**
- **Tasks**:
  - [x] Swap the four hypothesis binders to `HasFaithfulDedekindINF` and re-point every downstream
        application at Phase 11's re-based primitives.
        *(Done at `BoundedFixFaithful.lean:204`, `:277` and `BoundedFixAnchoredFaithful.lean:165`,
        `:248` — the four binders as measured, at their post-docstring line numbers. The eight predicted call sites needed no edit at
        all: they pass `h_INF` straight through, so the binder change alone fixed them. Nine
        argument positions did need an explicit coercion — the four in-territory `_of_attained`
        wrappers, plus the five out-of-territory sites recorded under D3.)*
        **Phase 11 measured the exact work**: with the compatibility shim disabled, the only errors
        anywhere in the tree are eight `Application type mismatch` on the carrier argument, at
        `BoundedFixFaithful.lean:215`, `:227`, `:281`, `:290` and
        `BoundedFixAnchoredFaithful.lean:181`, `:193`, `:257`, `:266`. No other error surfaced, and
        neither module has a destructure site. This is a **four-token binder swap**, confirmed by
        machine rather than by inspection.
  - [x] **DELETE `coeHasDedekindINFToFaithful` (`Lemma53Faithful.lean:596`) in the same change.**
        *(Done. The whole "Re-base compatibility shim" section — the instance and its 33-line
        section note — is gone; `Lemma53Faithful.lean` is 601 → 565 lines. Declaration-inventory
        diff against the prior commit shows exactly one removal and no other. `grep` over
        `FormalSystem/` finds no remaining reference to the identifier, and the full build is green
        without it, so nothing was silently depending on it.)*
        Phase 11 landed it as declared, scheduled-for-removal original glue solely to keep the tree
        green across the module boundary. Leaving it would let a later reader pass a needlessly
        strong carrier without seeing that they had. **This makes `Lemma53Faithful.lean` a
        one-declaration exception to this phase's "read, not edited" territory**, and the deletion
        is the only edit permitted to it.
  - [x] Confirm by inspection — and record — that neither module opens the carrier. If either does,
        that is a survey miss: record it with file:line and treat it under the Phase 11 fallback.
        **CONFIRMED, neither module opens the carrier.** In all four `_iff` proofs `h_INF` occurs
        only as an argument to `negChainOnFaithful_iff` — never as `h_INF.first_occ`, never
        `rcases`d, never projected. Recorded in both module docstrings. The Phase 11 fallback is
        not triggered.
  - [x] Verify every pre-existing declaration is present with its conclusion unweakened.
        *(Declaration-inventory diff across all five touched files: zero removals except the
        chartered shim, zero additions, zero renames. No conclusion changed — the entire
        code-bearing delta is 4 binder types, 9 coercion insertions at argument positions, and the
        deletion. Hypothesis weakening only, which strengthens each theorem.)*
  - [x] Docstrings: `Rabinovich 2014, Corollary 5.4(1)/(2), PDF p.9`, with `ADAPTED-FROM` naming the
        previous pin and the one-clause change.
        *(Added at module level and on each of the four `_iff` theorems. Also corrected two
        now-stale in-file claims Phase 11 invalidated: the carrier tables, and the non-vacuity
        note's `hk : kplus` / `orderedPointsExist_combine_kplus`, which are `kplusOpen` /
        `orderedPointsExist_combine_kplusOpen` since Phase 11. Stale `Lemma53Faithful.lean:NNN`
        line pins in that prose were dropped rather than re-guessed.)*
  - [x] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
- **Estimated output**: ~120 lines changed.
- **Actual output**: 144 lines changed across two modules plus a 36-line deletion; 5 tokens in two
  further modules (D3). Well under one agent run, as Phase 11 predicted.
- **Done when**: both modules compile with all declarations preserved, sorry-free and axiom-clean at
  the faithful carrier; canaries unchanged; the attained originals byte-identical. **MET.**
- **Depends on**: 11.
- **Timing**: 4 hours.
- **Decomposition protocol**: as Phase 11 — split at the module boundary. *(Not needed; single
  dispatch.)*

#### Deviation D3 — chartered-scope expansion into Phase 12 / 12.1 territory, 5 tokens

**What.** Five call sites outside this phase's declared territory were edited:
`NegFixOneFaithful.lean:253` (Phase 12) and `NegFixListFaithful.lean:368`, `:421`, `:437`, `:500`
(Phase 12.1). At each, the argument `h_INF` became `h_INF.toHasFaithfulDedekindINF`. **Nothing
else in those two modules changed** — not one binder, statement, docstring, or proof step. Their
`h_INF` binders remain `HasDedekindINF`, so Phases 12 and 12.1 re-base them exactly as planned and
delete these five coercions when they do.

**Why it was forced.** All five consume `negBoundedLeftFixAnchoredFaithful_iff`, whose binder this
phase swaps. Once swapped, they are red. Phase 11's eight-error measurement could not have caught
this: it disabled the shim while leaving the four binders in place, so it measured the consumers of
`negChainOnFaithful_iff`, not the *transitive* consumers of the four Cor 5.4 `_iff`s. That is a
real survey miss in the v8 Faithful-Subtree Survey's blast-radius count, recorded here rather than
absorbed.

**Why not keep the shim instead.** Retaining `coeHasDedekindINFToFaithful` would have made the tree
green with zero out-of-territory edits — and would have violated this phase's own binding checklist
item. The charter's stated reason for deletion is that the shim *"would let a later reader pass a
needlessly strong carrier without seeing that they had."* An explicit, greppable
`.toHasFaithfulDedekindINF` at each site delivers exactly the visibility the charter wants; a
silent `Coe` is what it forbids. Between violating the deliverable and a five-token expansion that
changes no statement, the expansion is the smaller and more honest cost.

**Why not `[BLOCKED]`.** There was no ambiguity to escalate and no design question reopened: the
fix is forced, mechanical, and verified green. Escalating a five-token coercion would have stalled
the route for no decision.

**Standing consequence for Phases 12 and 12.1.** When those phases swap their own `h_INF` binders
to `HasFaithfulDedekindINF`, they must *remove* these five `.toHasFaithfulDedekindINF` suffixes —
leaving them in place would be a type error, so the build enforces this and no tracking is needed.
More important: **assume the same one-module-further cascade will recur.** Before declaring either
phase done, grep the tree for transitive consumers of every re-based `_iff`, not just the sites a
shim-disabled probe reddens.

### Phase 12: Rabinovich Lemma 5.1 re-based — `NegFixOneFaithful` [COMPLETED]

> **HARD-SITE VERDICT: two-arm shape held. R11's bet is settled at the first of the two hard
> sites.** `negFixOneFaithful_cover`'s `Case1 / Case2 / Case3a/b/c` split survived the re-base
> with **no case introduced, merged, or removed**, and with its branch structure textually
> unchanged: a carrier-free `by_cases h_occ` (the paper's Case 2 against the rest) wrapping a
> two-arm `rcases` on the carrier (Case 1 against Case 3), with Case 3's three arms unchanged.
> The chartered R11 fallback — fall back to the trichotomy and add endpoint branches — is **NOT
> triggered**. The whole code-bearing delta in the cover is four tokens: the binder type, two
> `kplusLeftBlock_holds → kplusOpenLeftBlock_holds` renames, and one `kplusOpen_of_kplus`
> insertion where the carrier's right disjunct (still `kplus`, being literally `HasDedekindINF`'s)
> meets the re-spelled pin type. Corroborating effort datum, matching Phases 11 and 11.1: **zero
> failed proof attempts, scoped build green on the FIRST attempt, and no proof-search tool
> (`lean_multi_attempt`, `lean_state_search`, `lean_hammer_premise`) invoked at any point.**
>
> **Why it held, stated as the transcription rather than as luck.** Rabinovich's enumeration is
> exhaustive *because* his `K⁺` is conjunct-free. He prints the implication twice on PDF p.10 —
> as the guard on `r₀`'s existence and as Case 3's closed form — and both printings say
> `¬K⁺(¬β₁)(z₀)` plus an occurrence yields the pin, i.e. contrapositively a **dichotomy**. A
> carrier at the tree's `kplus` would need a third endpoint disjunct `¬β₁(z₀)` — literally
> `HasDenseDedekindINF`'s shape — for which the paper has no case. That argument is now
> transcribed and cited in the module docstring, not merely asserted here.

> **The first of the two genuinely hard sites.** `negFixOneFaithful_cover`
> (`NegFixOneFaithful.lean:422`) is by-cases-reached with no left-endpoint hypothesis in scope, and
> its `Case1 / Case2 / Case3a/b/c` structure — Rabinovich's own, transcribed — has **no slot** for a
> "`P` holds at `z₀`" case. Under the trichotomy this needs new proof branches. Under the faithful
> dichotomy it should not, because Rabinovich's Case 1 is *"`¬α₀(z₀)` or `K⁺(¬β₁)(z₀)`"* and his
> Case 3 is *"`α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀)`, and there is `x ∈ (z₀,z₁)` with `¬β₁(x)`"* (PDF p.9, corpus
> `chunk_0017.md:9`) — **an exhaustive split precisely because `K⁺` is the source's conjunct-free
> one**. That is the negation-chain discipline this phase must transcribe, not assume.

- **Goal**: `NegFixOneFaithful.lean` re-based onto `HasFaithfulDedekindINF`, with the eq (5.3)
  machinery (`infPinPoint`, `allSeg`, `somePointBlock`) and `HasDedekindINF.first_occ_tp` (`:164`)
  re-pointed, and `negFixOneFaithful_cover` (`:422`) re-proved at the faithful carrier.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixOneFaithful.lean`
  (726 lines; hypothesis sites `:156`, `:247`, `:339`, `:403`, `:488`; destructure sites `:164`,
  `:422`). **`EANegationFix/NegFixOne.lean` is read, not edited.**
- **Tasks**:
  - [x] **First task — transcribe the negation-chain discipline, from the source, before touching a
        tactic.** Record in the module docstring, verbatim and cited, Rabinovich's Lemma 5.1 case
        enumeration (PDF p.9): *"Case 1: `¬α₀(z₀)` or `K⁺(¬β₁)(z₀)`. Case 2: `α₀(z₀)`, and `β₁`
        holds along `(z₀,z₁)`. Case 3: (1) `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀)`, and (2) there is `x ∈ (z₀,z₁)`
        such that `¬β₁(x)`."*, together with the eq (5.3) use-site guard, printed twice (PDF p.10):
        *"(If `¬K⁺(¬β₁)` holds at `z₀` and there is `x ∈ (z₀,z₁)` such that `¬β₁(x)`, then such
        `r₀` exists …)"* and *"Case 3 is described by `α₀(z₀) ∧ ¬K⁺(¬β₁)(z₀) ∧ (∃z)^{<z₁}_{>z₀}
        INF_{¬β₁}(z₀,z,z₁)`"*. **State explicitly which `K⁺` makes the split exhaustive** — the
        source's conjunct-free one — and that the tree's `kplus` would not.
        *(Done, and done first: it is the first edit of the dispatch, landed before any tactic was
        touched. Both p.10 guard printings were re-read from the corpus and confirmed verbatim
        against `chunk_0018.md` before transcription; the p.9 enumeration was already present and
        was confirmed against `chunk_0017.md`. New module-docstring section "The negation-chain
        discipline: which `K⁺` makes the split exhaustive" carries both printings, the
        contrapositive reading that makes the split a dichotomy, the `kplusOpen`-vs-`kplus`
        difference with its source citations (Rabinovich Definition (3), PDF p.3; Reynolds'
        abbreviation table, printed p.168), and the concrete failure of the `kplus` reading —
        grounded on three landed declarations rather than asserted:
        `kplusOpen_not_implied_by_truth_at`, `HasDenseDedekindINF`'s literal trichotomy shape, and
        `hasFaithfulDedekindINF_survives_interval_witness`.)*
  - [x] Re-point `HasDedekindINF.first_occ_tp` (`:164`, unconditional wrapper) onto the faithful
        carrier.
        *(Done **additively**, following Phase 11's D1 precedent rather than by rename:
        `HasFaithfulDedekindINF.first_occ_tp` is added and `HasDedekindINF.first_occ_tp` is
        retained unweakened. The two are **incomparable** — the old assumes the stronger carrier
        and concludes the stronger `kplus` at `z₀`; the new assumes the weaker and concludes the
        weaker `kplusOpen` — so neither is derivable from the other and a rename would have
        deleted a statement. A rename was also unnecessary: dot notation on the re-based `h_INF`
        resolves to the faithful one automatically at the cover's call site. Recorded in
        non-vacuity note 3.)*
  - [x] Re-point the eq (5.3) pieces (`infPinPoint`, `allSeg`, `somePointBlock`) at
        `Formula.kPlus` / `kplusOpenPred` via Phase 10.1's bridge and Phase 11's primitives.
        *(Done for `infPinPoint` — `kplusPred β.neg → kplusOpenPred β.neg`, with
        `infPinPoint_holds` re-stated at `kplusOpen`. **For `allSeg` and `somePointBlock` the item
        is vacuous and this is recorded rather than absorbed**: neither definition contains any
        `K⁺` occurrence at all (`allSeg s = trivialTrue.conjEverywhere s`; `somePointBlock` is a
        bare `BracketFormula.prepend` block), so there was nothing to re-point. The v8 survey's
        three-piece grouping was one piece too wide.)*
  - [x] Re-prove `negFixOneFaithful_cover` (`:422`) and `negFixOneFaithful_iff` at the faithful
        carrier, preserving Rabinovich's case numbering in the proof structure and in the docstring
        so the transcription is checkable case by case. **Do not merge a case without a stated
        reason; do not close a case by hand-waving.**
        *(Done. **No case was introduced, merged, or removed, and no branch was restructured.** The
        cover's delta is: the binder type; `kplusLeftBlock_holds → kplusOpenLeftBlock_holds` in
        Case 1's arm; and `Or.inr h → Or.inr (kplusOpen_of_kplus h)` in the pin construction, where
        the carrier's right disjunct still prints the tree's `kplus` — it is literally
        `HasDedekindINF`'s — while eq (5.3)'s pin type is now at the source's `K⁺`. That last
        insertion is a **weakening**, so nothing is assumed there that the carrier did not already
        supply; it carries an inline comment saying so. Every per-case comment and citation is
        preserved. `negFixOneFaithful_sound`'s Case 1 arm took the mirror-image change
        (`obtain ⟨-, hdense⟩ := h1` → `h1` applied directly, `kplusOpen` having no first conjunct
        to discard) — the same class-b pattern Phase 11 measured at
        `orderedPointsExist_combine_kplusOpen`.)*
  - [x] Swap the remaining hypothesis binders (`:156`, `:247`, `:339`, `:403`, `:488`).
        *(Done at all five as measured — `:156` becoming the new faithful wrapper's binder with the
        original retained beside it. Deviation D3's `.toHasFaithfulDedekindINF` at `:253` is
        **removed** as the charter required; the build enforced it, exactly as 11.1 predicted.
        `negFixOneFaithful_iff_of_attained`'s `h_INF.toHasDedekindINF` became
        `h_INF.toHasFaithfulDedekindINF` — one further argument position the site list did not
        count.)*
  - [x] Verify every pre-existing declaration is present with its conclusion unweakened.
        *(Declaration-inventory diff vs the prior commit: **exactly one addition**
        (`HasFaithfulDedekindINF.first_occ_tp`), zero removals, zero renames; `NegFixListFaithful`
        inventory byte-identical. No hypothesis was strengthened anywhere. Two **definitions**
        moved to the source's operator as this phase's charter directs — `negFixOneCase1` and
        `infPinPoint` — which makes `negFixOneFaithful` a formally weaker `VVecEA2`; this
        strengthens `_sound` (weaker hypothesis) and weakens `_cover` (weaker conclusion) taken
        singly, while `_iff` is preserved **as an `iff`, with its right-hand side
        `¬(bracketOne s0 p s1).holds` textually unchanged**, now proved from a strictly weaker
        carrier. The deliverable — a `∨∃⃗∀` formula equivalent to `¬bracketOne` — is therefore
        strictly stronger than before, and the phase's stated goal was precisely to move those two
        definitions. Recorded here rather than glossed as "no conclusion changed".)*
  - [x] Docstrings: `Rabinovich 2014, Lemma 5.1 and eq (5.3), PDF pp.9-10`, cited by **PDF page
        only** (the `.md` conversion is corrupt for displayed equations); `ADAPTED-FROM` naming the
        previous pin.
        *(Done at module level and on `negFixOneTail_iff`, `negFixOneCase1`, `infPinPoint`,
        `negFixOneFaithful_sound`, `negFixOneFaithful_cover`, `negFixOneFaithful_iff` and the new
        wrapper. Every Rabinovich citation is by PDF page; the corpus `chunk_NNNN.md` files were
        used to confirm wording and are not cited as ground truth. Three now-stale in-file claims
        this phase invalidated were corrected: the carrier tables, non-vacuity notes 1-3 and 5, and
        the gate probe's shape docstring.)*
  - [x] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
- **Estimated output**: ~330 lines changed/added.
- **Actual output**: 155 lines added to `NegFixOneFaithful.lean` (726 → 881), of which the large
  majority is the mandated transcription and the ADAPTED-FROM/non-vacuity prose; the code-bearing
  delta is 1 added theorem, 2 definition bodies, 5 binder types, and 6 tactic-line tokens. Plus 6
  lines in `NegFixListFaithful.lean` (D4 below). Well under one agent run, as Phases 11 and 11.1
  predicted for this class of work.
- **Done when**: `NegFixOneFaithful.lean` compiles with every declaration preserved, sorry-free and
  axiom-clean at the faithful carrier; the negation-chain discipline is transcribed and cited in the
  docstring; the case numbering is preserved; canaries unchanged; `EANegationFix/NegFixOne.lean`
  byte-identical. **MET.**
- **Depends on**: 11.1.
- **Timing**: 7 hours.
- **Decomposition protocol**: as Phase 11 — the `first_occ_tp` + eq (5.3) primitives and the
  `_cover`/`_iff` pair are a clean seam, and splitting there is the expected outcome if the cover
  resists.
- **Fallback (R11)**: if the faithful dichotomy does not collapse the split here, fall back to the
  trichotomy and add the endpoint branches Rabinovich's enumeration has no slot for. **That is a
  genuinely new sub-argument, not a transcription**: record it as such, label it original glue under
  honesty-charter Rule 4, and split under R2 rather than absorbing the cost. **NOT TRIGGERED** — the
  faithful dichotomy did collapse the split, with zero new branches.

#### Deviation D4 — the one-module-further cascade recurred, as 11.1 warned, 6 lines

**What.** One call site outside this phase's declared territory was edited:
`NegFixListFaithful.lean:463` pre-edit, now `:468` (Phase 12.1 territory). `Or.inr hkr` became
`Or.inr (kplusOpen_of_kplus hkr)`, plus a five-line comment marking it scheduled for removal.
**Nothing else in that module changed** — not one binder, statement, docstring or proof step, and
its declaration inventory is byte-identical. Its `h_INF` binder remains `HasDedekindINF`, so
Phase 12.1 re-bases it exactly as planned.

**Why it was forced.** `infPinPoint` now carries the source's conjunct-free `K⁺`, while the
`HasDedekindINF` carrier that module still binds supplies the tree's `kplus` at the pin. The
`hpin` construction there therefore needs the one-token weakening `kplusOpen_of_kplus`.

**How 11.1's standing warning performed.** It was correct that the cascade recurs, and its
prescribed check found the site — but the *shape* it predicted (an argument-position
`.toHasFaithfulDedekindINF` coercion, as in D3) was not the shape that fired. What fired came
from the **definition** move, not the binder move: the `.toHasFaithfulDedekindINF` sites D3 left
at `NegFixListFaithful.lean:368`, `:421`, `:437`, `:500` stayed green and untouched, because this
phase did not re-base `negBoundedLeftFixAnchoredFaithful_iff`. Generalized warning for Phase 12.1
and Phase 13: **a re-base cascades along two independent edges — moved binders and moved
definitions — and a probe or grep aimed at one will not reveal the other.** Here the binder edge
cost nothing downstream and the definition edge cost one site.

**Why not `[BLOCKED]`.** Same reasoning as D3: no ambiguity to escalate, no settled design
reopened, the fix is forced and mechanical and verified green.

**Standing consequence for Phase 12.1.** When it swaps its own `h_INF` binder, it removes D3's
four `.toHasFaithfulDedekindINF` suffixes (the build enforces this) and should collapse this
`kplusOpen_of_kplus` too — though note the build will **not** enforce that one, since the
weakening stays type-correct under any carrier. It is marked in-file with an explicit
SCHEDULED FOR REMOVAL comment for exactly that reason.

### Phase 12.1: Rabinovich Lemma 5.1, list form — `NegFixListFaithful` [COMPLETED]

> **The second hard site.** `negFixListFaithful_iff` (`NegFixListFaithful.lean:446`) is
> by-cases-reached with the same case structure and the same absence of a slot for an endpoint case.

- **Goal**: `NegFixListFaithful.lean` re-based onto `HasFaithfulDedekindINF`, with
  `negFixListFaithful_iff` (`:446`) re-proved at the faithful carrier.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixListFaithful.lean`
  (584 lines; hypothesis site `:335`; destructure site `:446`). **`EANegationFix/NegFixList.lean`
  is read, not edited.**
- **Tasks**:
  - [x] Swap the hypothesis binder at `:335` and re-prove `negFixListFaithful_iff` (`:446`) at the
        faithful carrier, consuming Phase 12's re-based `negFixOneFaithful_cover`.
  - [x] Preserve the case numbering and the per-case citations, as in Phase 12.
  - [x] Re-point this module's own Case 1 block: `kplusLeftBlock s.neg` (`:279`) and its
        `kplusLeftBlock_holds` uses (`:360`, `:452`) — the same move Phase 12 made at
        `negFixOneCase1`. Note `witness_absurd_of_kplusLeft` (`:236`) and
        `negFixList_gate_probe`-adjacent statements bind `kplus` directly; decide per declaration
        whether to re-point or retain-and-derive, and record which, as Phase 11 did.
        *(per-declaration decisions recorded: `witness_absurd_of_kplusLeft` **re-pointed** to
        `kplusOpen` — the two are comparable, not incomparable, so retaining would duplicate;
        `negFixListFaithful_case1_is_indispensable` **re-pointed**, since an indispensability
        artifact must be stated at the gate the definition actually carries. Those two are the
        ONLY `kplus`-binding statements this module had. Deviation D8: no `negFixList_gate_probe`
        declaration exists anywhere in the tree, and this module contains no gate probe at all —
        the two that exist are `NegFixGateProbe` (`EANegationFix/NegFixOne.lean:402`, a frozen
        read-only module) and `NegFixOneFaithfulGateProbe` (`NegFixOneFaithful.lean:695`, Phase
        12's territory, already handled there). The item is vacuous for this phase, recorded
        rather than silently skipped.)*
  - [ ] **Remove D4's `kplusOpen_of_kplus` at `:468`.** Unlike D3's four coercions the build will
        NOT enforce this one — the weakening stays type-correct under either carrier — so it is
        marked with an in-file `SCHEDULED FOR REMOVAL` comment. Grep for that comment.
        *(deviation D7: **not executable as written — the item's premise is false.** The coercion
        is not a mixed-carrier artifact; it is structurally required under EITHER carrier, because
        `HasFaithfulDedekindINF.first_occ` (`KPlusFaithful.lean:325`) weakens only its LEFT
        disjunct and deliberately keeps the tree's `kplus` in its RIGHT disjunct — its own
        docstring at `:302` records this as intentional, so the two carriers' right disjuncts stay
        syntactically identical. Removing the coercion makes the build RED. Phase 12 kept the
        identical coercion at `NegFixOneFaithful.lean:583` for the identical reason. Action taken:
        coercion retained; the `SCHEDULED FOR REMOVAL` comment replaced by one explaining why it
        is permanent.)*
  - [x] Verify every pre-existing declaration is present with its conclusion unweakened.
        *(mechanically diffed: inventory byte-identical, 0 additions / 0 removals / 0 renames.)*
  - [x] Docstring: `Rabinovich 2014, Lemma 5.1, PDF pp.9-10`; `ADAPTED-FROM` naming the previous pin.
  - [x] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
- **Estimated output**: ~220 lines changed.
- **Done when**: the module compiles with all declarations preserved, sorry-free and axiom-clean at
  the faithful carrier; canaries unchanged; `EANegationFix/NegFixList.lean` byte-identical.
  **MET**, with the one exception recorded as D7 above.
- **Depends on**: 12.
- **Timing**: 6 hours.
- **Decomposition protocol** and **Fallback (R11)**: as Phase 12. **R11 not triggered.**

**Outcome: the second hard site held, and it held more cheaply than the first.** The banner above
predicted `negFixListFaithful_iff` would be "by-cases-reached with the same case structure and the
same absence of a slot for an endpoint case." Correct on both counts, and the consequence was that
**no proof step changed at all**. The entire code-bearing delta inside the theorem is the binder
type, four dropped `.toHasFaithfulDedekindINF` suffixes, and two `kplusLeftBlock_holds` →
`kplusOpenLeftBlock_holds` rewrites. The `rcases … with hk | ⟨r0, …⟩` remains a two-arm split; the
`by_cases hsev` wrapping it is carrier-free and untouched; the `Aᵢ`/`Bᵢ` recursion, its
`vecPinnedConjAll` DNF, and the `x ≤ r` / `x = r` / `x < r` peel are all textually unchanged.
Scoped build green on the FIRST attempt, zero failed proof attempts, no proof-search tool invoked.

**Standing consequence for Phase 13 — the two-edge cascade fired again, one site per edge.**
Phase 12's generalized warning ("a re-base cascades along two independent edges — moved binders and
moved definitions — and a probe or grep aimed at one will not reveal the other") is now confirmed
by a second, independent instance, and this time **both** edges fired, in Phase 13's own territory:
- *Binder edge*: `VecEANegFixFaithful.lean:109` needed `.toHasFaithfulDedekindINF`. Marked
  `SCHEDULED FOR REMOVAL`; the build WILL delete it when `:105`'s binder is swapped.
- *Definition edge*: `VecEANegFixFaithful.lean:295` read `kplusLeftBlock_holds` off
  `negFixListFaithful`'s Case 1 disjunct and needed `kplusOpenLeftBlock_holds` plus a one-token
  weakening. The build DID enforce this one — unlike D4's, because the block identifier changed
  rather than merely the argument type.

Phase 13 should also re-point `VecEA2.negFixFaithful_carries_limit_gate`'s `hk : kplus` hypothesis
to `kplusOpen`. Deliberately left alone here as out-of-territory (a statement change is more than a
cascade repair); the statement is still true and still load-bearing, but it now certifies the limit
gate at a hypothesis one conjunct stronger than the gate the definition carries. An in-file note
records this.

### Phase 13: Rabinovich Prop 4.2 re-based — `VecEANegFixFaithful` + `Prop42Faithful` [COMPLETED]

- **Goal**: The top of the faithful chain re-based: `VVecEA2.negFixFaithful_iff` and the Prop 4.2
  per-disjunct lemmas, plus `Prop42Faithful.lean`'s contentfulness guard, all at the faithful
  carrier. Surveyed as **pure signature swap** on both modules — six hypothesis sites, **no
  destructure sites**.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/VecEANegFixFaithful.lean`
  (314 lines; sites `:105`, `:138`, `:207`, `:234`, shim use `:312`),
  `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Faithful.lean` (283 lines; sites `:142`, `:167`).
  **`EANegationFix/VecEANegFix.lean` and `Kamp/Section5Correspondence.lean` are read, not edited.**
- **Tasks**:
  - [x] Swap the six hypothesis binders and re-point the shim use at `VecEANegFixFaithful.lean:312`
        from `HasAttainedINF.toHasDedekindINF` to the composed
        `HasAttainedINF.toHasDedekindINF |> HasDedekindINF.toHasFaithfulDedekindINF` (or the direct
        composite, landed by name in Phase 10.1 if cleaner) — **so the attained/discrete pipeline
        keeps supplying the faithful carrier unchanged**. Record which composite is used.
        *(**Composite used: the direct `HasAttainedINF.toHasFaithfulDedekindINF`**,
        `KPlusFaithful.lean:382`, landed by name in Phase 10.1 — cleaner, so taken. Used at both
        shim sites: `VVecEA2.negFixFaithful_iff_of_attained` and
        `prop42_contentful_of_attained_inf_only`.)*
        *(deviation D11: **five of the six binders swapped in place; the sixth handled
        differently, because swapping it in place is jointly unsatisfiable with two other items in
        this same phase.** Site `Prop42Faithful.lean:167` is `prop42_contentful_of_dedekind`, whose
        NAME asserts its carrier. Swapping its binder would (a) leave the name asserting something
        false in a tree whose vocabulary separates `HasDedekindINF` from `HasFaithfulDedekindINF`
        as two distinct structures with two distinct shims, and (b) leave the next item — "land
        `prop42_contentful_of_faithful`" — with nothing to be except a duplicate alias. Action
        taken: `prop42_contentful_of_faithful` landed at `HasFaithfulDedekindINF` as the honest
        re-based headline, and `prop42_contentful_of_dedekind` retained at `HasDedekindINF`,
        unweakened, as its one-line corollary via `HasDedekindINF.toHasFaithfulDedekindINF`. Every
        pre-existing declaration is preserved (0 removals, 0 renames), every consumer keeps
        working, and no name asserts a carrier it does not bind. Flagged for orchestrator review
        rather than silently annotated.)*
  - [x] Land `prop42_contentful_of_faithful` — the contentfulness guard at the faithful carrier.
        `Section5Correspondence.lean`'s existing `prop42_contentful_of_attained` exists precisely to
        stop this correspondence rotting; the faithful sibling must carry the same guard or the
        re-base is unprotected. **The guard must be non-vacuous**: state what it excludes (Rule 6)
        and exhibit the exclusion.
        *(landed at `Prop42Faithful.lean`, axiom-clean. Rule 6 exclusion **stated** in its
        docstring and **exhibited** by the companion
        `prop42_faithful_covers_what_dedekind_excludes`, which produces `denseWindowFlow` — a
        dense Prior structure satisfying `HasFaithfulDedekindINF`
        (`hasFaithfulDedekindINF_of_dense_window`) and **refuting** `HasDedekindINF`
        (`hasDedekindINF_fails_on_dense_window`) — together with `∀ v, Prop42Contentful` at that
        structure. So Prop 4.2 is available there from the new carrier and unavailable from the
        old: the weakening is strict, and the guard names `Prop42Contentful` itself, so a future
        weakening of the negation chain breaks this declaration and not merely the carrier
        lemmas.)*
  - [x] Verify every pre-existing declaration is present with its conclusion unweakened.
        *(mechanically diffed against the phase base `9dc3466f9`: `VecEANegFixFaithful.lean` and
        `NfMultiAnchorBridge.lean` byte-identical inventories, 0/0/0; `Prop42Faithful.lean` 2
        additions, 0 removals, 0 renames. No conclusion weakened anywhere. Four hypotheses
        weakened by design (the binder swaps) and two indispensability artifacts re-pointed
        `kplus → kplusOpen`, which weakens their hypotheses and therefore strengthens them.)*
  - [x] **CI-edge audit (chain closure).** Confirm `NfMultiAnchorBridge.lean`'s import edges
        (`:7-18`, `:238`, `:252`, `:275`, `:297`, `:320`, `:345`) still reach every re-based module,
        and that `WeakCanonical.lean:20-21` still reaches `PriorDefsDense`/`DedekindINFDense`. Add an
        edge for `KPlusFaithful.lean` if Phase 10.1 did not. **Record the audit** — a faithful module
        that falls out of CI rots invisibly, which is the failure `DedekindINF.lean:98-103` names.
        *(**AUDIT RECORDED — PASSES, no edge needed.** Method: the transitive `import` closure of
        the default target's root `FormalSystem.lean` was computed mechanically (306 modules; the
        `lean_lib FormalSystem` target declares `roots := #[FormalSystem]` and no `globs`, so this
        closure IS what `lake build` builds). All thirteen probed modules are inside it:
        `NfMultiAnchorBridge`, `Prop42Faithful`, `EANegationFixFaithful/{VecEANegFixFaithful,
        NegFixListFaithful, NegFixOneFaithful, BoundedFixFaithful, BoundedFixAnchoredFaithful}`,
        `Lemma53Faithful`, `Lemma53FaithfulPast`, `KPlusFaithful`, `PriorDefsDense`,
        `DedekindINFDense`, `Section5Correspondence`. The six deep aggregator edges named by the
        plan (`:238`, `:252`, `:275`, `:297`, `:320`, `:345`) are real `import` lines — each
        preceded by its long `--` NOTE block — not comments, and all still resolve. The
        `KPlusFaithful` edge was already landed by Phase 10.1 at `WeakCanonical.lean:22`, so
        nothing had to be added. `WeakCanonical.lean:20-21` still reaches `PriorDefsDense` and
        `DedekindINFDense`.)*
  - [x] Update `NfMultiAnchorBridge.lean`'s `NOTE` comment blocks where they describe the carrier as
        `HasDedekindINF`, so the aggregator's own prose stays true. **Comment bytes only.**
        *(twelve NOTE passages corrected across six edges. Verified comment-bytes-only: a `-U0`
        diff filtered to non-`--` lines is empty, and the declaration inventory is byte-identical.
        The largest correction is the `DedekindINF` edge's **DEFERRED note**, which asserted
        "Lemma 5.1 / Prop 4.2 remain DEFERRED, not done" — false as of this phase. It now records
        that the deferral is closed, that the chain landed one step BELOW `HasDedekindINF` at
        `HasFaithfulDedekindINF`, and that exactly one step remains open (deriving the carrier
        from order completeness alone).)*
  - [x] Docstrings: `Rabinovich 2014, Prop 4.2, PDF p.6` (*"Proposition 4.2. (Closure under
        negation) The negation of ∃⃗∀-formulas with at most two free variables is equivalent over
        Dedekind complete chains to a disjunction of ∃⃗∀-formulas."*); `ADAPTED-FROM` naming the
        previous pin.
        *(source read VERBATIM from the PDF, p.6, before transcription — the Prop 4.2 statement
        and the Prop 4.3 **Negation:** case both quoted. The Prop 4.2 sentence is now quoted
        verbatim in `prop42_contentful_of_faithful`'s docstring and in
        `VVecEA2.negFixFaithful_iff`'s. `ADAPTED-FROM` blocks naming the previous pin
        `HasDedekindINF` (`DedekindINF.lean:136`) added to `VecEANegFixFaithful.lean`'s module
        docstring and to `prop42_contentful_of_faithful`.)*
  - [x] `#print axioms`; regression canaries; scoped build green; full `lake build` green.
        *(all twelve touched/added declarations axiom-clean at `[propext, Classical.choice,
        Quot.sound]`. Both canaries unchanged at the same three axioms: `completeness_discrete`
        and `countermodel_discrete_reynolds_v2`. Both scoped builds green on the FIRST attempt,
        zero failed proof attempts, no proof-search tool invoked. Full `lake build` green, 1920
        jobs — the same count as Phase 12.1. Sorry census unchanged at 163, none in this phase's
        territory; vacuous-definition count 1 and axiom-grep count 2, both pre-existing, both
        outside this territory and untouched.)*
- **Estimated output**: ~200 lines changed/added.
- **Done when**: both modules compile with all declarations preserved, sorry-free and axiom-clean at
  the faithful carrier; `prop42_contentful_of_faithful` is landed and non-vacuous; the CI-edge audit
  is recorded; canaries unchanged; `EANegationFix/VecEANegFix.lean` and
  `Section5Correspondence.lean` byte-identical. **MET in full**, with the one method choice
  recorded as D11 above. `EANegationFix/`, `Section5Correspondence.lean`, `KPlusFaithful.lean` and
  `NegFixListFaithful.lean` all verified byte-identical against the phase base `9dc3466f9`.

**Outcome: the surveyed "pure signature swap" verdict held exactly, and the cascade did not fire
a third time.** Phase 12.1 predicted both of this phase's cascade sites in advance and both
behaved as predicted: swapping `VecEANegFixFaithful.lean:105`'s binder deleted the
`SCHEDULED FOR REMOVAL` coercion automatically, and the definition-edge repair at `:295` had
already been applied. Beyond those, **no proof step in either module changed**. The entire
code-bearing delta is six binder/shim tokens, two `kplus → kplusOpen` hypothesis re-points with
their one retired coercion, and two new declarations. Both scoped builds were green on the first
attempt with no proof-search tool invoked at any point in the dispatch.

**Standing note for Phase 14 — one frozen asset is now stale prose, deliberately not edited.**
`Section5Correspondence.lean`'s "faithful re-base table" (`:48-82`) still describes the mirror
chain as "re-based onto `HasDedekindINF`", cites `VVecEA2.negFixFaithful_iff` at a line number
that has moved, and names `prop42_contentful_of_dedekind` as the chain's terminus rather than
`prop42_contentful_of_faithful`. Every row is still TRUE as a statement about a landed
declaration — `prop42_contentful_of_dedekind` is retained and still discharges the target from
`HasDedekindINF` — but the table now understates the chain by one carrier step. This phase's
`Done when` requires that file byte-identical, so it was left untouched rather than silently
edited. Whichever phase next owns `Section5Correspondence.lean` should refresh the table.

- **Depends on**: 12.1.
- **Timing**: 5 hours.
- **Decomposition protocol**: as Phase 11 — split at the module boundary.
- **BLOCK D RE-BASE CHECKPOINT**: at this point the whole faithful chain — 3,388 lines across eight
  modules, plus `KPlusFaithful.lean` — runs on a carrier that dense Prior structures actually
  inhabit, and `prior_hasFaithfulDedekindINF_dense` connects it to `SemanticPriorU`. The deferral
  recorded at `DedekindINF.lean:87-103` is closed. This is a reusable result of independent value
  and a clean stopping point.

### Phase 14: `uSExpressivelyCompleteOverDensePrior` [COMPLETED]

> **RECONCILED 2026-07-28 (was `[PARTIAL]`).** This phase was `[PARTIAL]` for exactly one
> reason: `uSExpressivelyCompleteOverDensePrior` carried the tracked strategic sorry
> `kampFaithfulExpressiveCompleteness_open`. Phase 14.3 discharged it. Re-verified against
> this phase's own `Done when`, clause by clause, rather than flipped on the strength of the
> sorry alone:
> - *"both declarations sorry-free with axioms exactly `[propext, Classical.choice,
>   Quot.sound]`"* — **met in substance, under a different name.**
>   `uSExpressivelyCompleteOverDensePrior` verified axiom-clean by `#print axioms`. The second
>   declaration never landed under the plan's name `kampDedekindExpressiveCompleteness`: task 2
>   above deliberately deferred it and landed the content as the stated obligation
>   `KampFaithfulExpressiveCompleteness` (`PriorExpressivenessDense.lean:170`) plus its proof
>   `kampFaithfulExpressiveCompleteness_open` (`:277`), also verified axiom-clean. The
>   mathematical bar is met; **the plan's identifier `kampDedekindExpressiveCompleteness` does
>   not exist in the tree and no later phase should expect it.** Task 2's checkbox is left
>   unchecked to keep that visible.
> - *"the carrier measurement of task 1 is recorded"* — met (task 1, and the module header).
> - *"the non-vacuity instantiation lands at a dense flow"* — met at `denseWindowFlow`.
> - *"`#print axioms completeness_discrete` unchanged"* — re-verified `[propext,
>   Classical.choice, Quot.sound]`.

> **Re-scoped by v8, same goal.** v7 chartered this phase to compose three from-scratch modules.
> It now composes the **re-based faithful chain** (Phases 11-13) with
> `prior_hasFaithfulDedekindINF_dense` (Phase 10.1). The target, the owned module, the anti-vacuity
> requirement and the `Done when` are otherwise unchanged.

- **Goal**: The composed theorem — `{U,S}` expressive completeness over structures satisfying the
  **dense** Prior axioms — plus its non-vacuity witness. Reynolds' Theorem 3 (§5, printed p.176) at
  the carrier the Dedekind route actually needs.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` (new — **confirm it
  does not already exist**). **`PriorExpressiveness.lean` and `Kamp/KampPrior.lean` are read, not
  edited.**
- **Tasks**:
  - [x] **First task — measure, do not assume.** Determine and record which carrier
        `kampPriorExpressiveCompleteness` (`KampPrior.lean:672`) and `nfCharacterizableTemporalPrior`
        (`:589`) actually consume, and whether they route through the faithful chain or through the
        attained originals in `EANegationFix/`. v7 assumed the former; the tree must be checked. If
        they route through the attained originals, the composition needs a faithful sibling of
        `kampPriorExpressiveCompleteness` and **that** is this phase's real content.
        *(**GATE EXECUTED — v7's premise REFUTED.** Both declarations consume `SemanticPriorUZ` /
        `SemanticPriorSZ` and **no completeness carrier at all**: `KampPrior.lean` has ZERO
        occurrences of `HasDedekindINF/SUP`, `HasFaithfulDedekindINF/SUP`, `HasAttainedINF/SUP`,
        `kplus`, `negFix*`, `prop42*`, `VVecEA2`. Its only edge into the Rabinovich machinery is
        `kampArm_zeta`. One level down, `ZetaUniformExtract.lean` (821 lines) carries the carrier
        and it is **the attained originals** — `HasAttainedINF` ×7, `HasAttainedSUP` ×7, plus
        `VVecEA2` ×11 and `negFix` ×3 — with **zero** `HasFaithful*`. The faithful chain reaches
        `NfMultiAnchorBridge.lean` (`HasFaithfulDedekindINF` ×15) but the zeta wire does not reach
        it. **So the "faithful sibling" branch of this task fires**, and per the Decomposition
        protocol it is a NAMED sub-phase reported `[PARTIAL]`, not a silent expansion — see
        Phase 14.1 below.)*
  - [ ] Land `kampDedekindExpressiveCompleteness` — the `HasFaithfulDedekindINF`/`SUP`-based
        analogue, composing Phases 11-13.
        *(deviation: **DEFERRED to Phase 14.1 — not composable, as the gate above established.**
        Landed as a NAMED, STATED obligation `KampFaithfulExpressiveCompleteness` (the type) rather
        than a proof, because the measurement shows it is a re-base of `ZetaUniformExtract.lean`'s
        zeta wire from `HasAttainedINF`/`SUP` onto the faithful carrier — on the model of the
        `EANegationFixFaithful/` re-base — and not a composition of landed parts. The plan's name
        is recorded in the obligation's docstring.)*
  - [x] Land `uSExpressivelyCompleteOverDensePrior atomMap h_surj psi :
        { A : Formula // ∀ M, SemanticPriorU M atomMap → SemanticPriorS M atomMap →
        ∀ t, eval M (fun _ => t) psi ↔ TemporalTruth M atomMap t A }`, composing
        `prior_hasFaithfulDedekindINF_dense` / `SUP` with the above. Mirror the landed
        `uSExpressivelyCompleteOverPrior`'s shape exactly, including the `h_surj` binder.
        *(**landed at the exact charted signature, `h_surj` binder included.** The composition
        itself — `uSExpressivelyCompleteOverDensePrior_of_faithful` — is **sorry-free and
        axiom-clean**: it feeds `prior_hasFaithfulDedekindINF_dense` (`KPlusFaithful.lean:474`) and
        `prior_hasFaithfulDedekindSUP_dense` (`:524`) to the obligation, same witness formula `A`.
        `uSExpressivelyCompleteOverDensePrior` is that conditional discharged by the single
        strategic sorry `kampFaithfulExpressiveCompleteness_open`. Every step of the chartered
        composition that the tree supports is taken; the sorry is the obligation and nothing
        else.)*
  - [x] **Inherit, do not silently widen, the domain restriction.** `nf_nvar_exist_all_depths`
        (`KampPrior.lean:363`) carries `hn : n ≤ 1` (the arity-`n ≥ 2` arm is excluded). Record
        whether the composition inherits it and state the restriction in the docstring.
        *(**inherited, not widened; stated in the module docstring and in the obligation's.**
        `nfCharacterizableTemporalPrior` consumes `nf_nvar_exist_all_depths` at `n = 1` only, so
        `hn : n ≤ 1` is invisible in `kampPriorExpressiveCompleteness`' statement. The obligation
        `KampFaithfulExpressiveCompleteness` is stated at `MonadicFormula sig 1` — exactly the
        arity at which the existing chain closes — so any discharge inherits `hn : n ≤ 1`
        verbatim. Nothing in the module reaches arity ≥ 2.)*
  - [x] Docstring: `Reynolds 1992, §5 Theorem 3, printed p.176`, quoting the theorem statement, and
        recording that this tree obtains it by Rabinovich's method relativized to the faithful eq
        (5.2) carrier rather than by Reynolds' own reduction to `{U,S,U',S'}` (which would require
        the Boneyard'd, sorry-tainted `stavi_expressive_completeness`).
        *(**source read VERBATIM before transcription** — the corpus PDF is an OCR'd scan, so the
        theorem was located and read on PDF page 12, whose printed page number is **176**,
        CONFIRMING the plan's figure. Quoted verbatim: "The language with U and S is expressively
        complete for the class of Prior structures." Reynolds' own route is quoted too — "By the
        expressive completeness of {U, S, U', S'} over all linear structures, it suffices to
        prove..." — so the departure is recorded against his printed words, not asserted. Also
        recorded: he attributes the result onward ("see [8], proposition 4.2"), so p.176 is a
        statement-plus-sketch site, not a transcribable proof.
        **UNCHARTERED FIDELITY FINDING**: p.176 DEFINES "Prior structure" as satisfying Prior-U and
        Prior-S, and p.168 gives those verbatim as `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p),p)` and its
        mirror — i.e. `SemanticPriorU`/`SemanticPriorS`. **So Reynolds' Theorem 3 is a statement
        about the DENSE axioms, and the landed `uSExpressivelyCompleteOverPrior`, pinned at the
        strictly stronger `SemanticPriorUZ`/`SZ`, is NOT Reynolds' Theorem 3** — this module's
        target is. Recorded in the module header; no existing declaration was renamed.)*
  - [x] **Anti-vacuity, and this is the phase's most important task.** Instantiate at Phase 9's
        positive dense witness and land the resulting `{A : Formula // …}` as a named example for at
        least one non-trivial `psi`. A sorry-free `uSExpressivelyCompleteOverDensePrior` whose
        hypothesis no dense structure satisfies would reproduce the exact defect Block D exists to
        repair.
        *(**done, and the whole anti-vacuity block is sorry-free AND axiom-clean** — verified by
        `#print axioms`, it does NOT inherit the strategic sorry.
        `densePrior_target_hypotheses_inhabited` exhibits `denseWindowFlow` satisfying BOTH target
        hypotheses AND both faithful carriers, so neither the premise nor the composition's
        internal step is empty. `uSExpressivelyCompleteOverDensePrior_at_denseWindow` lands the
        actual `{A : Formula // …}` at `denseTestPsi := ∃x, t < x ∧ P(x)` (`F P`; quantifier depth
        1, uses both order and predicate, so not quantifier-free-equivalent), with hypotheses
        DISCHARGED rather than assumed; `denseTestPsi_eval` machine-checks by `Iff.rfl` that the
        de Bruijn indices mean what the docstring says. It consumes the sorry-free CONDITIONAL, so
        it is honest about the one open obligation instead of laundering it.
        Negative half: `uSExpressivelyCompleteOverDensePrior_not_by_reuse` records that the target
        is not obtainable by re-exporting the landed integer theorem.)*
  - [x] `#print axioms`; regression canaries `completeness_discrete` and
        `countermodel_discrete_reynolds_v2`.
        *(all six non-obligation declarations axiom-clean: five at `[propext, Classical.choice,
        Quot.sound]`, `densePriorAtomMap_surj` depends on NO axioms.
        `uSExpressivelyCompleteOverDensePrior` carries `sorryAx` — the single tracked strategic
        sorry — and it is the ONLY declaration that does. Both canaries UNCHANGED at `[propext,
        Classical.choice, Quot.sound]`.)*
  - [x] Scoped build green; full `lake build` green; sorry census unchanged.
        *(scoped build green; full `lake build` green, **1921 jobs** — one more than Phase 13's
        1920, the new module. Census `sorry_count` 161 -> 162: delta **exactly +1**, the tracked
        strategic sorry, zero other new sorries. NOTE: this script reports 162 on `FormalSystem/`
        where Phase 13's handoff reported 163; the baseline was re-measured at HEAD as 161 and the
        DELTA is what is asserted here, not the absolute against a differently-rooted figure.
        Vacuous-definition count 1 and axiom-grep count 2, both pre-existing and unchanged.
        CI edge added at `WeakCanonical.lean:22` so the new module cannot rot out of the build
        closure — the ONLY edit outside the owned module, one import line.)*
- **Estimated output**: ~250 lines. *(actual: 320 lines, one new module plus one import line.)*
- **Done when**: both declarations sorry-free with axioms exactly `[propext, Classical.choice,
  Quot.sound]`; the carrier measurement of task 1 is recorded; the non-vacuity instantiation lands
  at a dense flow; `#print axioms completeness_discrete` unchanged.
  *(**MET EXCEPT the first clause, and that clause was falsified by the phase's own gate.** Met:
  the carrier measurement is recorded (in the module header AND task 1 above); the non-vacuity
  instantiation lands at `denseWindowFlow` and is itself sorry-free and axiom-clean;
  `#print axioms completeness_discrete` unchanged. NOT met: `uSExpressivelyCompleteOverDensePrior`
  is not sorry-free, because task 1's gate established that the second declaration
  (`kampDedekindExpressiveCompleteness`) is not a composition of landed parts but a re-base of
  `ZetaUniformExtract.lean`. The `Done when` was written under v7's premise that the chain already
  ran on the faithful carrier; the tree says otherwise. Reported `[PARTIAL]` with the remainder
  chartered as Phase 14.1 rather than silently redefining the bar.)*
- **Depends on**: 13.
- **Timing**: 5 hours.
- **Decomposition protocol**: as Phase 11 — if task 1 shows a faithful sibling of
  `kampPriorExpressiveCompleteness` is needed, that is a named sub-phase, reported `[PARTIAL]`, not
  a silent expansion. *(**FIRED.** Sub-phase named below as Phase 14.1.)*

**Outcome: the gate was the phase.** v7 assumed the Kamp chain already ran on the faithful
carrier and chartered Phase 14 as a composition. The measurement refuted that assumption twice
over — the chain consumes neither carrier at the top (only `SemanticPriorUZ`/`SZ`) and consumes
the *attained originals* one level down — and separately the tree already machine-checks
(`semanticPriorU_not_implies_semanticPriorUZ`) that the dense hypotheses cannot supply the
integer ones, so no re-export could have closed the gap either. Everything the charter asked for
that the tree actually supports is landed and sorry-free: the composition, the domain-restriction
inheritance, the verbatim Reynolds grounding, and the full anti-vacuity block. The single
remaining gap is isolated in one named obligation.

### Phase 14.1: `KampFaithfulExpressiveCompleteness` — re-base the zeta wire [COMPLETED]

> **RECONCILED 2026-07-28 (was `[PARTIAL]`).** Checked against this phase's own `Done when`,
> all four clauses re-verified at HEAD rather than inferred from Phase 14.3's report:
> `kampFaithfulExpressiveCompleteness_open` sorry-free and axiom-clean; hence
> `uSExpressivelyCompleteOverDensePrior` axiom-clean at `[propext, Classical.choice,
> Quot.sound]`; census delta back to zero (live-tree `sorry_count` 161, the Phase 14 baseline,
> with `Transfer.lean:1242` the sole live sorry); canaries `completeness_discrete` and
> `countermodel_discrete_reynolds_v2` both unchanged. The "Why `[PARTIAL]`, not `[COMPLETED]`"
> note at the end of this phase's outcome refers to the **Content** clause (the spine above the
> wire), not to the `Done when` — that spine was chartered out as Phases 14.2/14.3 and both are
> now closed, so the note is spent and the `Done when` is met in full.

- **Goal**: Discharge `kampFaithfulExpressiveCompleteness_open`
  (`PriorExpressivenessDense.lean`), the sole open obligation of Phase 14 and the last gap
  between the tree and Reynolds' Theorem 3 at the dense Prior axioms. On discharge,
  `uSExpressivelyCompleteOverDensePrior` becomes unconditional **with no further edits**.
- **Content, as measured by Phase 14's gate**: re-base `Kamp/ZetaUniformExtract.lean` (821 lines;
  `HasAttainedINF` ×7, `HasAttainedSUP` ×7, `VVecEA2` ×11, `negFix` ×3, zero `HasFaithful*`) from
  the attained originals onto `HasFaithfulDedekindINF`/`SUP`, together with whatever below it the
  wire consumes, then a faithful sibling of `kampPriorExpressiveCompleteness` at that carrier.
  Model: the `Kamp/EANegationFixFaithful/` re-base of Phases 11-13.
- **First task, and it is a gate**: survey `ZetaUniformExtract.lean`'s `HasAttained*` sites for
  destructure vs. hypothesis use, as Phase 12.1 did for `VecEANegFix`. Phases 11-13 found "pure
  signature swap" three times running; if that holds a fourth time this is far cheaper than its
  line count suggests. **Verify rather than assume** — `HasAttainedINF` is a *stronger* carrier
  than `HasFaithfulDedekindINF`, so unlike the Phase 11-13 swaps this one weakens a hypothesis
  the proofs may genuinely lean on, and `HasAttainedINF.toHasFaithfulDedekindINF`
  (`KPlusFaithful.lean:382`) runs the wrong way to help.
- **Owns**: `Kamp/ZetaUniformExtract.lean` and a new faithful sibling module.
  **`PriorExpressivenessDense.lean` is read, not edited, except to replace
  `kampFaithfulExpressiveCompleteness_open`'s body.**
- **Done when**: `kampFaithfulExpressiveCompleteness_open` is sorry-free, hence
  `uSExpressivelyCompleteOverDensePrior` axiom-clean at `[propext, Classical.choice, Quot.sound]`;
  census delta back to zero; canaries unchanged.
- **Depends on**: 14.
- **Verification Tier**: full.
- **BLOCK D CHECKPOINT**: the tree contains expressive completeness of `{U,S}` at a carrier that
  dense Prior structures actually inhabit. A reusable result of independent value and a clean
  stopping point.

**Outcome: the gate answered, the wire landed, the spine measured.**

The gate did *not* come back "pure signature swap" a fourth time, and it did not come back
"the swap fails" either. Measured across `ZetaUniformExtract.lean`'s fourteen `HasAttained*`
occurrences: `h_INF`/`h_SUP` are **consumed at exactly one site** (`:162`,
`VVecEA2.negFix_iff` inside `prop42_efSat_negation_general_uniformFin`) and **constructed at
two** (`:800`, `:802`). The other eleven are pure threading. So the re-base of the wire itself
was one genuine content change plus mechanical restatement.

**Landed, sorry-free, full build green at 1921 jobs** —
`Kamp/ZetaUniformExtractFaithful.lean` (595 lines, new; zero edits to `ZetaUniformExtract.lean`):

- `canonExpand_hasFaithfulDedekindINF` / `canonExpand_hasFaithfulDedekindSUP` — the faithful
  carrier transfers to the canonical expansion. **No source**; original work modelled on
  `canonExpand_hasAttainedINF`, and the docstring says so.
- `prop42_efSat_negation_general_uniformFin_faithful` — the one substantive change: witness
  `VVecEA2.negFixFaithful`, correctness `VVecEA2.negFixFaithful_iff`.
- `efSat_negation_pair_uniformFin_faithful`, `efSat_negation_general_uniformFin_faithful`,
  `veeSat_negation_uniformFin_faithful`, `translate_uniformFin_faithful` — proof bodies verbatim.
- `kampArm_zeta_faithful` — the ζ wire at `HasFaithfulDedekindINF`/`SUP`.
- `kampArm_zeta_faithful_covers_attained` — machine-checks the re-base is a weakening, not a
  sideways move: every consumer of the attained wire is re-suppliable from the faithful one.

**Two findings worth carrying forward.**

1. **At the faithful carrier the `SUP` half is not consumed at all.** `VVecEA2.negFix_iff` needs
   `HasAttainedINF` *and* `HasAttainedSUP`; `VVecEA2.negFixFaithful_iff` needs
   `HasFaithfulDedekindINF` alone. `HasFaithfulDedekindSUP` is threaded through every new
   statement (kept for shape-parallelism with the attained originals and with the consuming
   obligation) but bound to `_h_SUP` and never used. Deleting it would strengthen the results;
   that decision was deliberately not taken here.
2. **One site genuinely needs the stronger carrier, exactly as warned.**
   `Lemma53Faithful.lean:545` (`prior_makes_faithful_disjunct2_unreachable`) uses
   `HasAttainedINF.first_occ`'s attained conclusion — `¬P` throughout `(z₀,r₀)` with no `kplus`
   escape hatch — to derive `¬kplusOpen`. The faithful `first_occ` carries that escape hatch, so
   this lemma is **not re-basable and must not be swapped**. It is an exclusion/anti-vacuity
   result about Prior structures, not a step on the correctness path, so it does not block the
   re-base — it simply does not carry over. Recorded so a later dispatch does not try.

**Why [PARTIAL], not [COMPLETED]**: the charter's second clause — "then a faithful sibling of
`kampPriorExpressiveCompleteness` at that carrier" — is the spine *above* the wire, and it was
measured at **110 hypothesis-binder sites across 22 live modules**: `Kamp/KampPrior.lean` (26)
and fifteen `Kamp/NfMultiAnchorBridge/` modules (~50 between them) being the bulk. That is the
scale of the `Kamp/EANegationFixFaithful/` re-base, not of one dispatch.
`kampFaithfulExpressiveCompleteness_open` therefore remains the single strategic sorry, with its
docstring updated to record what the wire closed and what the inventory above leaves open.

### Phase 14.2: the `kampPriorExpressiveCompleteness` spine at the faithful carrier [COMPLETED]

> **RECONCILED 2026-07-28 (was `[PARTIAL]`).** This record entry carries no `Done when` of its
> own, so it was judged against the **original charter** reproduced further below ("Phase 14.2
> (original charter)"), whose `Done when` has five clauses. All five re-verified at HEAD:
> `kampFaithfulExpressiveCompleteness_open` sorry-free; `uSExpressivelyCompleteOverDensePrior`
> axiom-clean at `[propext, Classical.choice, Quot.sound]`; census delta zero; canaries
> unchanged; and **every attained original byte-identical** — checked mechanically over the
> whole 14.1→14.3 commit range, which modifies exactly two pre-existing files:
> `PriorExpressivenessDense.lean` (which the charter's `Owns` explicitly permits, "except to
> replace `kampFaithfulExpressiveCompleteness_open`'s body") and one import line in
> `WeakCanonical.lean` added by Phase 14 and recorded there. No `Kamp/` or
> `NfMultiAnchorBridge/` original was touched. The 72-line remainder this entry handed forward
> was closed by Phase 14.3, already `[COMPLETED]`.

**GATE ANSWERED — the phase's first task, and it was a gate.** The question was whether
`aggOdPopFold_iff` bottoms out at `VVecEA2.negFix_iff` (mechanical) or at some other attained-only
consumer (`[BLOCKED]`). **It bottoms out at `VVecEA2.negFix_iff`**, verified by reading the proof
rather than assumed: `aggOdPopFold_iff` (`AggregateOffDiagK1.lean:1226`) touches `h_INF`/`h_SUP` at
exactly one step, the bit-false branch of its cons case (`:1253`), and that step is
`VVecEA2.negFix_iff`. Its nil case, its `VVecEA2.conjFull_iff` cons rewrite and its bit-true branch
are carrier-free. `VVecEA2.negFixFaithful_iff`
(`EANegationFixFaithful/VecEANegFixFaithful.lean:244`) therefore supplies it directly, and needs
`HasFaithfulDedekindINF` **alone** — the `SUP` half is not consumed at all, exactly as at the ζ
wire. **The obligation is not merely answered but discharged**:
`aggOdPopFold_iff_faithful` is landed and sorry-free
(`NfMultiAnchorBridge/AggregateOffDiagK1Faithful.lean`). The spine re-base has **no remaining proof
content** — everything left is restatement.

**Landed this dispatch** (622 lines across three new modules, zero edits to any existing file,
zero removals, zero renames, all eleven declarations axiom-clean at
`[propext, Classical.choice, Quot.sound]`):

| Module | Contents |
|---|---|
| `NfMultiAnchorBridge/PriorInterfaceFaithful.lean` | `ExistProvidersFaithful`, `.toExistProviders`, `BracketCarrierCorrectVPriorFaithful`, `.toBracketCarrierCorrectVPrior`, the two `k ≤ 1` lifts |
| `NfMultiAnchorBridge/OuterGateFaithful.lean` | `bracketEndChar_kvE2_hck_faithful`, `_complete_two_prior_faithful`, `_correct_two_prior_frag_faithful`, `…_covers_prior` |
| `NfMultiAnchorBridge/AggregateOffDiagK1Faithful.lean` | `aggOdPopFold_iff_faithful`, `…_covers_attained`, `…_on_prior` |

`PriorInterface.lean` and `OuterGate.lean` were chosen because they are the **only two roots** of
the bridge's UZ/SZ subgraph: `PriorInterface` imports only `CarrierKv` and `OuterGate` only
`SharedWitness`, neither of which mentions a completeness carrier, while every other UZ/SZ-carrying
bridge module sits above one of them.

**Two findings worth recording.**

1. **`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:297`) is already carrier-free.**
   Despite its `_prior` name it binds no `SemanticPriorUZ` at all — `hfrag` plus the four provider
   obligations carry the whole ⇒ direction. It needs **no** faithful sibling and is reused verbatim
   at `P.toExistProviders`. So this rung's re-base cost one lemma, not three.
2. **`private` is the real obstruction to the new-modules-only strategy, and it is
   module-specific.** `ExteriorBracket.lean`'s carrier-consuming path runs through
   `kvE2_extGate_anyBit_iff` (`:837`), which is `private` — its faithful sibling therefore *cannot*
   live in a new module and must be added inside `ExteriorBracket.lean` itself, duplicating roughly
   265 lines of body. Measured across the remaining scope, `private` declarations exist in 7 of the
   15 remaining modules (`ExteriorBracket` 10, `ExteriorPinnedConversePastK` 6,
   `ExteriorPinnedConverseK` 5, `AggregateHookDischarge` 5, `ExteriorNegationPastK` 2,
   `AggregateOffDiagK1` 2, `ExteriorGateAssembleK` 1) and are **absent** from the other 8 —
   including **`KampPrior.lean`, the single biggest chunk at 26 UZ binder lines, which has zero
   `private` declarations** and is therefore re-basable entirely by new modules.

**Scope, re-measured with the plan's own grep** (`grep -cE '(_?h_UZ|hUZ) *: *SemanticPriorUZ'`,
live tree, Boneyard excluded): the baseline is **85 binder lines**, not the 110 this plan recorded
— the 110 figure is not reproducible by the grep the plan cites and should be treated as
superseded. Of those 85: **5 re-based this dispatch** (PriorInterface 2, OuterGate 3), **8 are not
re-base targets at all** (`PriorINF` 2 and `DedekindINF` 1 are the *suppliers*
`prior_hasAttained*`/`prior_hasDedekind*`; `ZetaPriorTransfer` 2 already has faithful siblings in
`ZetaUniformExtractFaithful.lean`; `Lemma53Faithful` 2, `Lemma53FaithfulPast` 1 and `Prop42Faithful`
1 are the exclusion results that provably do **not** carry over), leaving **72 lines across 15
modules** as the genuine remainder. That is the number Phase 14.3 inherits.

### Phase 14.3: the remaining 72 binder lines of the spine re-base [COMPLETED]

> **OUTCOME (2026-07-28).** The phase's "Done when" is fully met:
> `kampFaithfulExpressiveCompleteness_open` is sorry-free, and
> `uSExpressivelyCompleteOverDensePrior` is axiom-clean at
> `[propext, Classical.choice, Quot.sound]` — verified by `#print axioms`, not asserted. The
> live tree now carries exactly ONE `sorry`, the pre-existing unrelated `Transfer.lean:1242`;
> the strategic sorry is gone, so the census delta is **−1**. Full `lake build` green at 1926
> jobs. Zero edits to any existing Lean declaration; the only edit outside the two new modules
> is the sanctioned replacement of `kampFaithfulExpressiveCompleteness_open`'s body, and even
> there nothing was removed or renamed — the name is retained as an unweakened alias of the new
> `kampFaithfulExpressiveCompleteness` (D11).
>
> **Landed**: 952 lines across two new modules, 25 declarations, all axiom-clean.
>
> | Module | Contents |
> |---|---|
> | `NfMultiAnchorBridge/ArmLemmasFaithful.lean` (455 lines, 17 decls) | the three `k = 0` arms, `aggPosDiagK1_correct_faithful`, `kampArm_diag_k1_correct_faithful`, `CAggInt`/`CAggOd`/`CAggOdSwap` clause iffs, the `negFixFaithful` population folds `aggPop1Faithful` / `aggPop1FFaithful` and their correctness, and the two off-diagonal `k = 1` arms |
> | `Kamp/KampPriorFaithful.lean` (497 lines, 8 decls) | `nf_succ_char_formula_correct_faithful`, both per-depth arm closures, `nf_nvar_exist_all_depths_faithful`, its wrapper + correctness, `nfCharacterizableTemporalPriorFaithful`, `kampPriorExpressiveCompletenessFaithful` |
>
> **14.2's load-bearing finding is CONFIRMED, not corrected.** No site on the live path needed
> `HasAttainedINF`'s extra strength. Everything above the ζ wire was restatement, exactly as
> 14.2 reported.
>
> **Three corrections to this phase's own scope model, however.**
>
> 1. **The "72 binder lines across 15 modules" figure over-scoped the obligation.** Only
>    **seven** declarations in `KampPrior.lean` and **nine** in the bridge lie on the live
>    dependency path from `kampPriorExpressiveCompleteness` (`:672`). In particular
>    `KampPrior.lean`'s own site/coverage-probe block — `kampPrior_site_*`,
>    `kampPriorExistProviders*`, `kampPrior_fChain_*`, all of it *below* `:672` — is consumed by
>    nothing on that path, and neither are `ExteriorPinnedConverseK` (10 lines),
>    `ExteriorPinnedConversePastK`, `ExteriorBracketAssembleK`, `ExteriorFiberK`,
>    `EndIntervalConsumerK`, `ExteriorNegation{K,PastK}`, `ExteriorConverter{K,PastK}`,
>    `ExteriorGateAssembleK` or `InteriorGateGeneralK`'s further sites. Re-basing them is not
>    required to discharge the obligation and was **not** done.
> 2. **The plan's grep metric never was a complete inventory.**
>    `grep -cE '(_?h_UZ|hUZ) *: *SemanticPriorUZ'` counts only the *named-binder* form and misses
>    the arrow form `SemanticPriorUZ M atomMap →` entirely. There are 6 arrow-form sites in the
>    live tree, and **5 of the 6 are on the live path** (the `k = 0` / `k = 1` arm lemmas in
>    `AggregateHookDischarge.lean` and `AggregateOffDiagK1.lean`). The "72" therefore both
>    over-counted (off-path sites) and under-counted (arrow form) at the same time.
> 3. **Under D11 the UZ/SZ binder count can never decrease.** D11 forbids editing the attained
>    originals, so a faithful re-base *adds* faithful binders beside the UZ/SZ ones rather than
>    replacing them. The UZ/SZ count is now 115, up from 85, purely for that reason. It measures
>    remaining restatement work, not progress, and should not be used as a completion metric —
>    the sorry census is the metric that moved, and it moved the right way.
>
> **The `private` obstruction was largely a non-issue on the live path.** Exactly one private
> helper mattered: `AggregateHookDischarge.lean`'s `agg2_cons_diag_env` (`:1447`), a four-line
> arity-2 env identity, restated visibly as `aggDiagEnv2_const_faithful` (an addition; the
> original keeps its `private`). `ExteriorBracket.lean`'s `kvE2_extGate_anyBit_iff` (`:837`) —
> the case 14.2 diagnosed as forcing a ~265-line in-file duplication — is **not on the live
> path**, so it never had to be touched.
>
> **What is left, and it is optional.** The off-path UZ/SZ sites above are unreached restatement.
> They cost nothing to leave: they are pinned at the strictly stronger carrier, they are
> sorry-free, and no live result depends on them at the faithful carrier. Any future phase that
> wants them re-based should be chartered on its own merits, not as a completion obligation of
> this route.

<details>
<summary>Original Phase 14.3 charter (retained verbatim)</summary>


- **Goal**: finish what 14.2 began — re-base the remaining 72 `SemanticPriorUZ`/`SemanticPriorSZ`
  binder lines across 15 modules onto `HasFaithfulDedekindINF`/`SUP`, then discharge
  `kampFaithfulExpressiveCompleteness_open`. **There is no remaining proof content**: 14.2's gate
  discharged the only substantive obligation (`aggOdPopFold_iff_faithful`). Everything here is
  restatement.
- **Suggested order, by the `private` finding**: take the 8 `private`-free modules first, all as
  new modules with zero edits to originals — `ExteriorFiberK` (3), `InteriorGateGeneralK` (5),
  `ExteriorConverterK` (1), `ExteriorConverterPastK` (1), `ExteriorNegationK` (2),
  `EndIntervalConsumerK` (2), `ExteriorBracketAssembleK` (4), and **`KampPrior.lean` (26)**. Note
  that `ExteriorFiberK` / `InteriorGateGeneralK` sit on `ExteriorBracketK`, which sits on
  `ExteriorBracket` — check per module whether the *carrier-consuming* path actually reaches
  `ExteriorBracket`'s private lemma, or only its public rungs.
- **The 7 `private`-bearing modules** (`ExteriorBracket` 2, `ExteriorPinnedConverseK` 10,
  `ExteriorPinnedConversePastK` 4, `AggregateHookDischarge` 4, `AggregateOffDiagK1` 6,
  `ExteriorNegationPastK` 1, `ExteriorGateAssembleK` 1) each need a decision recorded before any
  edit: either add the faithful sibling **inside** the original module (duplicating the private
  body — D11-compatible, since it is a new declaration and removes/renames nothing) or promote
  nothing and route around it. `ExteriorBracket`'s case is already diagnosed above; the other six
  are unexamined.
- **Owns**: new `*Faithful.lean` modules beside each original; in-file additions only where a
  `private` dependency forces it. D11 throughout: zero removals, zero renames, every attained/UZ
  original byte-identical unless a private dependency forces an in-file addition, and then only an
  addition.
- **Do NOT**: swap `Lemma53Faithful.lean:545` or `Lemma53FaithfulPast.lean:472` — these consume
  `HasAttainedINF.first_occ`'s attained conclusion and provably do not carry over. Do not touch
  `PriorINF.lean`, `DedekindINF.lean` or `ZetaPriorTransfer.lean` — they are suppliers, not spine.
  Do not touch `Section5Correspondence.lean` (D13) or `PriorExpressiveness.lean` (D16). Do not
  attempt `Transfer.lean:1242`.
- **Verification Tier**: full.
- **Done when**: `kampFaithfulExpressiveCompleteness_open` is sorry-free, hence
  `uSExpressivelyCompleteOverDensePrior` axiom-clean; census delta zero; every attained original
  unmodified except for sanctioned in-file additions.
- **Depends on**: 14.2.
- **Note**: likely three or four dispatches. A natural seam is the 8 `private`-free bridge modules
  first, then `KampPrior.lean`, then the 7 `private`-bearing modules last.
  *(Outcome: one dispatch, because the live path was far narrower than the inventory suggested.)*

</details>

<!-- superseded 14.2 heading retained below for the original charter text -->

### Phase 14.2 (original charter): the `kampPriorExpressiveCompleteness` spine at the faithful carrier

- **Goal**: Discharge `kampFaithfulExpressiveCompleteness_open` by re-basing the spine above the
  ζ wire onto `HasFaithfulDedekindINF`/`SUP`, consuming Phase 14.1's `kampArm_zeta_faithful`.
  On discharge `uSExpressivelyCompleteOverDensePrior` becomes unconditional with no further
  edits — that composition is already landed and sorry-free.
- **Content, as measured by Phase 14.1's gate**: 110 hypothesis-binder sites across 22 live
  modules. Only **four** consume the carrier rather than thread it —
  `Lemma53Faithful.lean:545`, `Lemma53FaithfulPast.lean:472`,
  `NfMultiAnchorBridge/AggregateOffDiagK1.lean:1288` and `:1381`. The first two are the
  exclusion results identified above and do **not** carry over; the remaining real proof
  obligation is `aggOdPopFold_iff` (and whatever it bottoms out on) at the faithful carrier.
  Everything else is mechanical restatement.
- **First task, and it is a gate**: determine whether `aggOdPopFold_iff` bottoms out at
  `VVecEA2.negFix_iff` — in which case `VVecEA2.negFixFaithful_iff` already supplies it and the
  whole phase is mechanical — or at some other attained-only consumer. **Verify rather than
  assume, and record the answer.** If it bottoms out on genuine attainment, report `[BLOCKED]`
  with the exact dependency rather than forcing a swap.
- **Owns**: `Kamp/KampPrior.lean`'s faithful siblings and the `Kamp/NfMultiAnchorBridge/`
  faithful siblings (new declarations only — D11: zero removals, zero renames, every attained
  original left byte-identical). **`PriorExpressivenessDense.lean` is read, not edited, except
  to replace `kampFaithfulExpressiveCompleteness_open`'s body.**
- **Scope Hypothesis**: 110 binder sites / 22 modules / 4 consuming sites, measured by
  `grep -cE '(_?h_UZ|hUZ) *: *SemanticPriorUZ'` over the live tree at Phase 14.1's end.
  Re-measure before starting; if the count has moved, the spine changed underneath.
- **Verification Tier**: full.
- **Done when**: `kampFaithfulExpressiveCompleteness_open` is sorry-free, hence
  `uSExpressivelyCompleteOverDensePrior` axiom-clean at `[propext, Classical.choice, Quot.sound]`;
  census delta back to zero; canaries unchanged; every attained original byte-identical.
- **Depends on**: 14.1.
- **Note**: likely needs splitting across dispatches — a natural seam is
  `NfMultiAnchorBridge/` first (it is below `KampPrior.lean` and self-contained), then
  `KampPrior.lean`.

---

> **Blocks E-I (Phases 15-30) are carried forward from v7 unchanged in goal, territory, tasks,
> estimates, timings and dependencies.** The only v8 edits are dependency-arrow updates where a
> Block D phase number moved. Nothing Phase 10 found touches them.

### Phase 15: The dense monadic bridge — chronicle to `OrderedMonadicStructure` over `ℚ` [COMPLETED]

> **OUTCOME (2026-07-28).** The R7 gate came back **independent**, and it was *discharged*
> rather than merely answered: the generic frame typechecks over an arbitrary ordered abelian
> group and the `ℤ` originals are recovered by `rfl`. `ChronicleMonadicBridge.lean` (581 lines,
> new) landed sorry-free; all declarations axiom-clean at `[propext, Classical.choice,
> Quot.sound]`; full `lake build` green at 1926 jobs; both frozen chronicle files verified
> byte-identical by SHA-256.

- **Goal**: Reynolds §9 steps 1-2 (printed p.189): turn the landed rational chronicle into a
  temporal structure *in a finite monadic language* over a countable dense endpointless flow, with
  the bimodal dimension encoded as `ReynoldsBridge.lean` already encodes it at `.Discrete`.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (new).
  **`ChronicleToCountermodelBasic.lean` and `ChronicleConstruction.lean` are read, not edited, and
  must be byte-identical at phase end.**
- **Tasks**:
  - [x] **First task, and it is a gate (R7).** Determine whether `mkSigFrom` (**`Transfer.lean:134`**,
        not `ReynoldsBridge.lean`), `Formula.predFormulas` (**`Syntax/Formula.lean:778`**),
        `multiFamTaskFrame` (`ReynoldsBridge.lean:671`), `multiFamOmega` (`:694`) and
        `multiFamOmega_shiftClosed` (`:708`) are independent of `SuccOrder` / `PredOrder` /
        `IsSuccArchimedean`, or whether discreteness is baked into the encoding rather than only into
        `countermodel_discrete_reynolds_v2`'s statement (`:739`). **Preliminary reading says they are
        independent**: `multiFamTaskFrame FamIdx : TaskFrame ℤ` is `WorldState := FamIdx × ℤ` with
        `TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d`, in which `ℤ` occurs only as the carrier and `+`
        only as its group operation. **Verify rather than assume, and record the answer.** If
        discreteness *is* baked in, report `[BLOCKED]` with the exact dependency; do not attempt a
        workaround in this phase.
        *(**GATE EXECUTED — preliminary reading CONFIRMED, and discharged rather than asserted.**
        `TaskFrame` (`Semantics/TaskFrame.lean:99`) is parameterized by
        `(D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` and nothing else;
        `WorldHistory`, `WorldHistory.timeShift` and `ShiftClosed` carry the same three instances
        and no successor structure. `Formula.predFormulas` is a purely syntactic recursion with no
        temporal parameter, and `mkSigFrom φ` is `Finset.cons Formula.bot φ.predFormulas _`. The
        proof is not the reading but `multiFamTaskFrameGen` and siblings, which **typecheck** over
        an arbitrary such `D`, together with `multiFamTaskFrameGen_int` /
        `multiFamHistoryGen_int` / `multiFamOmegaGen_int`, which recover the landed `ℤ`
        definitions **by `rfl`**. Discreteness lives only in `countermodel_discrete_reynolds_v2`'s
        statement.
        **One correction to the plan's premise, and it is load-bearing:** `TaskFrame.WorldState`
        has type `Type` (universe 0), not `Type*`, so `WorldState := FamIdx × D` forces
        `D : Type`. The generic definitions are therefore stated at `D : Type`, not `Type*`. `ℤ`,
        `ℚ` and `ℝ` are all `Type`, so Phase 30's `D := ℝ` is unaffected.)*
  - [x] Land `multiFamTaskFrameGen (D) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
        (FamIdx) : TaskFrame D` and its `Omega`/shift-closure siblings, **beside** the `ℤ` versions
        (which `countermodel_discrete_reynolds_v2` consumes and which must stay byte-identical), and
        prove the `ℤ` instances are definitionally the specializations — or record why not. Phase 30
        consumes these at `D := ℝ`.
        *(landed: `multiFamTaskFrameGen`, `multiFamHistoryGen`, `multiFamOmegaGen`,
        `multiFamHistoryGen_shift_eq`, `multiFamOmegaGen_shiftClosed`,
        `multiFamHistoryGen_mem_omega`, plus the three `_int` specialization lemmas, all three of
        which are `rfl` — so the definitional claim is machine-checked, not recorded as a
        near-miss. **Placement deviation, stated not silent:** the plan says "beside the `ℤ`
        versions", which reads as *inside* `ReynoldsBridge.lean`, but this phase's `Owns` lists
        only the new file. `Owns` was followed: the generic definitions live in
        `ChronicleMonadicBridge.lean` and `ReynoldsBridge.lean` has **zero** edits. This keeps the
        four-dispatch streak of zero edits to existing declarations intact and costs nothing —
        the `_int` lemmas supply the "beside" relation explicitly.)*
  - [x] Note for the record: `mkSigFrom` lives in `Transfer.lean`, which carries the repository's
        single live sorry at `:1242` in an **unrelated** declaration. Importing it is normal and
        already universal. `Transfer.lean:1242` is not to be attempted.
  - [x] Build `chronicleMonadicStructure fc A h_mcs h_box_dense root : OrderedMonadicStructure
        (mkSigFrom root)` with carrier `Rat`, interpreting each predicate of `mkSigFrom root` as
        membership of the corresponding `predFormula` in the chronicle family's MCS at that rational.
        Reuse `cantorBfmcsDense`'s `evalFamily` for the root family and its `families` set for the
        modal dimension.
        *(landed as two declarations rather than one, and the split is deliberate:
        `chronicleMonadicStructureOf root fam` takes an arbitrary family — because the
        truth-correspondence statement the plan specifies quantifies over `fam` — and
        `chronicleMonadicStructure fc A h_mcs h_box_dense root` is its specialization at
        `(cantorBfmcsDense …).evalFamily`, exactly the signature the plan names.)*
  - [x] Prove the **truth-correspondence** lemma: for every `φ ∈ subformulaClosure root`,
        `TemporalTruth (chronicleMonadicStructure …) atomMap q φ ↔ φ ∈ (fam.mcs q)`. This is the
        bridge's whole content and the only thing later phases consume.
        *(`chronicleMonadic_truth_correspondence`, plus `chronicleMonadic_truth_correspondence_eval`
        with the coherence hypotheses discharged by `cantor_bfmcs_dense_restricted_fuc`/`_buc`.
        The atom and box cases needed two new syntactic lemmas —
        `atom_mem_predFormulas_of_mem_closure` and `box_mem_predFormulas_of_mem_closure` — because
        `mkAtomMapFwd` is the identity only on `root.predFormulas`, and nothing in the tree
        connected `subformulaClosure` to `predFormulas`. **The box case needs no inductive
        hypothesis**, which is precisely the `.Discrete` encoding being reused: the monadic
        language never unfolds the modal dimension.)*
  - [x] Prove the carrier is countable, densely ordered and without endpoints (immediate at `Rat`).
        *(`chronicleMonadic_carrier_countable` / `_denselyOrdered` / `_noMaxOrder` / `_noMinOrder`.)*
  - [x] Docstring: the construction has **no source in the corpus** and is original work (honesty
        charter Rule 4), with `ADAPTED-FROM: ReynoldsBridge.lean`'s `.Discrete` encoding named, and
        `Reynolds 1992, §9, printed p.189` cited for the *statement* of what step 2 delivers.
        *(**§9 IS in the local corpus** — `reynolds_1992/sec07_9-completeness.md`, titled
        "## 9 Completeness" — so the citation is grounded verbatim rather than asserted. The module
        docstring block-quotes the passage character-for-character, including the sentence this
        phase implements: *"By ignoring all the atoms which don't appear in `A₀` we have a temporal
        structure `M` from a finite language"*, and *"The flow of time of `M` is countable, dense
        and without end points"*. The printed page number p.189 is carried from this plan; the
        corpus markdown does not record page numbers, so it is cited as the plan's reference rather
        than as an independently verified one. The honesty note and the `ADAPTED-FROM:
        ReynoldsBridge.lean` attribution are both in the module docstring.)*
  - [x] `#print axioms`; verify the two frozen chronicle files byte-identical.
        *(all checked declarations at `[propext, Classical.choice, Quot.sound]`;
        `multiFamTaskFrameGen_int` and `multiFamOmegaGen_shiftClosed` at `[propext, Quot.sound]`
        only. `ChronicleToCountermodelBasic.lean` and `ChronicleConstruction.lean` verified
        byte-identical by SHA-256 taken before the first edit and re-checked at phase end; `git
        status` shows the new file as the only change under `Chronicle/` and `WeakCanonical/`.)*
  - [x] Scoped build green; full `lake build` green.
        *(scoped green; full `lake build` green at **1927 jobs**, one more than Phase 14.3's 1926 —
        the new module. **Caught and fixed, not glossed:** the first full build still reported 1926,
        because `lake`'s `FormalSystem` lib has `roots := #[`FormalSystem]` and therefore builds
        only what the root module's import graph reaches — the new file was compiling under the
        scoped target but was NOT in CI's closure. A one-line CI edge was added at
        `WeakCanonical.lean`, exactly as Phase 14 did for `PriorExpressivenessDense.lean`, and the
        count then moved to 1927. **This is the only edit outside the owned module.** It is placed
        in `WeakCanonical.lean` rather than a Chronicle aggregator because the new module imports
        `Transfer.lean` and so sits ABOVE `WeakCanonical/` in the import graph despite living in
        the `BXCanonical/Chronicle/` directory — a directory-vs-import-graph mismatch the plan's
        `Owns` path creates and which later phases should expect. Live-tree `sorry_count` **161**,
        unchanged: the sole live sorry remains `Transfer.lean:1242`, untouched. Zero warnings from
        the new module.)*
- **Estimated output**: ~400 lines.
- **Done when**: the structure and its truth-correspondence lemma are sorry-free and axiom-clean; the
  R7 gate answer is recorded; frozen files byte-identical.
- **Depends on**: — (may run in parallel with Phase 10.1).
- **Timing**: 7 hours.

### Phase 16: The chronicle structure is a dense Prior structure satisfying Sep [COMPLETED]

- **Goal**: Reynolds §4 Corollary 1 clause 3 (printed p.174), in the monadic idiom: *"all
  substitution instances of the axioms Prior-U, Prior-S and Sep are valid in `M`"* — for the
  structure Phase 15 built.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (extends
  Phase 15).
- **Tasks**:
  - [x] Prove `chronicleMonadic_semanticPriorU`: the structure satisfies `SemanticPriorU`. Route:
        `Axiom.prior_U_gap` has `minFrameClass = .Dedekind`, so at `fc := FrameClass.Dedekind` every
        substitution instance is a theorem, hence in every MCS (`theorem_in_mcs`,
        `MaximalConsistent.lean:491`), hence true at every point by Phase 15's truth correspondence.
        Carry `(hfc : FrameClass.Dedekind ≤ fc)`. **Note (v8): `Axiom.prior_U_gap` is stated with
        `Formula.kPlus` (`Axioms.lean:377`; `Syntax/Formula.lean:180`), and Phase 10.1's bridge
        lemma is what reads it semantically. Cite the bridge by name; do not substitute
        `kplusFormula`.**
        *(deviation: altered — the plan's route ends "hence true at every point by Phase 15's truth
        correspondence", but `chronicleMonadic_truth_correspondence` is bounded by
        `subformulaClosure root` while `SemanticPriorU` quantifies over ALL formulas, so it cannot
        close the step. The plan's three-move route — axiom at `.Dedekind` → `theorem_in_mcs` →
        semantics — is executed unchanged; what was added is the machinery the last move needed:
        `cantor_bfmcs_dense_fuc`/`_buc` (unrestricted Until/Since coherence, by self-root
        instantiation of the existing restricted theorems, which discard their closure argument)
        and `chronicleMonadic_truth_effective` (the same correspondence at `effectiveFormula`,
        `Transfer.lean:1004`, with no closure bound). No named declaration was skipped, renamed or
        substituted; Phase 15's closure-bounded correspondence is retained unweakened.)*
  - [x] Prove `chronicleMonadic_semanticPriorS` from `Axiom.prior_S_gap`, dually.
  - [x] Define `SemanticSep` (the semantic reading of `Axiom.sep`, `Axioms.lean:390`) and prove
        `chronicleMonadic_semanticSep` the same way. **This is `Axiom.sep`'s first consumer on any
        completeness route in this repository.** Its soundness is already landed; Reynolds' Lemma 10
        (printed p.184) is **not** re-derived.
  - [x] Land the packaged `chronicleIsDensePriorSepStructure` bundling all three plus countability,
        density and endpointlessness — the exact input Blocks F, G and H consume.
  - [x] Docstrings cite `Reynolds 1992, §4 Corollary 1, printed p.174` and `Sep, printed p.168`
        (character-for-character, as the landed `Axiom.sep` docstring already does). Corollary 1
        clauses 1-3 are block-quoted verbatim from the local corpus
        (`reynolds_1992/sec02_3-irr.md`) in the Part 7 section docstring.
  - [x] **Anti-vacuity**: this phase's output *is* the witness Phase 14's hypothesis wanted. Record
        the cross-reference explicitly; if Phase 14 has landed, land the application as a named lemma
        here. *(landed as `chronicleMonadic_expressiveCompleteness`; note the plan's
        `kampDedekindExpressiveCompleteness` does not exist in the tree — the landed names are
        `KampFaithfulExpressiveCompleteness` / `kampFaithfulExpressiveCompleteness_open`, composed
        into `uSExpressivelyCompleteOverDensePrior`, which is what the application uses)*
  - [x] `#print axioms`; frozen files byte-identical; full `lake build` green. *(all eight new
        top-level declarations at `[propext, Classical.choice, Quot.sound]`; `sorryAx` absent
        despite the `Transfer.lean` import. Only `ChronicleMonadicBridge.lean` modified. Full
        `lake build` green at 1927 jobs.)*
- **Estimated output**: ~350 lines.
- **Done when**: all four declarations sorry-free and axiom-clean; the cross-reference to Phase 14's
  hypothesis is landed or explicitly deferred with a reason; frozen files byte-identical.
- **Depends on**: 15.
- **Timing**: 6 hours.
- **BLOCK E CHECKPOINT**: Reynolds' step 1 is now available in the form Doets' theorem consumes.

### Phase 17: Contemporaneous equivalence, `ρ`/`λ`, and Reynolds §6 Lemma 2 [COMPLETED]

- **Goal**: The vocabulary of Reynolds §6 at the dense instance, and Lemma 2 — the temporal formula
  `R` that holds exactly where a class ends in a gap on the right.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean` (new).
- **Tasks**:
  - [x] Define `ContempEquivDense`: a binary relation defined by a monadic `ε(x,y)` such that (i) it
        is an equivalence relation, (ii) it partitions the carrier into intervals, and (iii)
        `M ⊨ ε(a,b) ↔ M|[a,b] ⊨ ε(a,b)`. Reynolds §6, printed p.176, states all three clauses
        verbatim; transcribe them. Compare with the landed `ContempEquiv`
        (`IntegerModel/GoodStructures.lean:729`) and **record** whether it can be reused as-is or
        needs a dense sibling — do not silently generalize the landed one.
  - [x] Define `rhoFormula ε` as the monadic
        `∃y>x ¬ε(x,y) ∧ ¬∃z(x<z ∧ ε(x,z) ∧ ∀y(x<y<z → ε(x,y)))`, verbatim from printed p.177, and
        `lambdaFormula ε` dually. *(deviation: altered — the formula quoted in this task is the
        LOCAL CORPUS' rendering, and the corpus is corrupted at this display formula. The printed
        `ρ` has THREE conjuncts, not two: the middle conjunct `¬∃z(ε(x,z) ∧ ∀y>z ¬ε(x,y))` is
        missing from the corpus, and the negation on `ε(x,z)` in the final conjunct was dropped.
        Read off the page image of the source PDF, printed p.177 = PDF page index 12. `rhoFormula`
        transcribes the printed three-conjunct form; see the module header's "CORRECTION TO THE
        LOCAL CORPUS" section. `lambdaFormula` is landed and labelled as this tree's mirror, since
        Reynolds prints no `λ`.)*
  - [x] Prove **Lemma 2**: *"there is a `US`-formula `R` which holds in any Prior structure `N`
        exactly at those points whose `∼_N`-class ends in a gap on the right"*, by applying
        `uSExpressivelyCompleteOverDensePrior` (Phase 14) to `rhoFormula ε`. Dually `L`.
  - [x] Record, in the docstring, the uniformity Reynolds relies on: the same `R` works in *any*
        Prior structure, because expressive completeness is uniform over the class (§5, printed
        p.176: *"Note the uniformity of the translation over the whole of `S`"*). Lemma 9 uses
        exactly this.
  - [x] Docstrings: `Reynolds 1992, §6, printed pp.176-177` and `§6 Lemma 2, printed p.177`.
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~300 lines.
- **Done when**: `ContempEquivDense`, `rhoFormula`, `lambdaFormula` and Lemma 2 (both directions) are
  sorry-free and axiom-clean; the `ContempEquiv`-reuse question is answered in the summary.
- **Depends on**: 14, 16.
- **Timing**: 6 hours.

#### Phase 17 addendum — chartered territory extension (D13, D16)

**Authorized by**: the orchestrator, in the Phase 17 dispatch brief, on the basis of Phase 16's
mechanical scan of the `Owns` list of every phase from 16 through 30, which established that no
remaining phase owns either file. This addendum exists so a later reader does not read the two
edits below as an unexplained territory violation.

**Supersedes, for these two files only**: the instruction in the Phase 14.3 block above — *"Do not
touch `Section5Correspondence.lean` (D13) or `PriorExpressiveness.lean` (D16)"*. That instruction
was correct for Phases 14.3, 15 and 16, whose charters did not cover the two files. It is
superseded here by explicit orchestrator authorization, and by nothing else.

**Scope**: documentation only. No proof, statement, signature or declaration in either file was
changed. The zero-edits-to-pre-existing-*declarations* streak is intact.

- **D13 — RESOLVED.** `Kamp/Section5Correspondence.lean` (the file is at `Kamp/`, not
  `Separation/`; the dispatch brief's path was approximate). The faithful re-base table was stale
  in three ways, all corrected: (a) it described the chain as re-based onto `HasDedekindINF`
  (`DedekindINF.lean:136`) when every chain member is in fact stated at the strictly weaker
  `HasFaithfulDedekindINF` (`KPlusFaithful.lean:320`) / `HasFaithfulDedekindSUP` (`:339`) —
  verified declaration by declaration; (b) it named `prop42_contentful_of_dedekind` as the chain's
  terminus when the terminus is `prop42_contentful_of_faithful` (`Prop42Faithful.lean:192`) and
  `prop42_contentful_of_dedekind` (`:208`) is the retained previous pin, derived *from* it via
  `HasDedekindINF.toHasFaithfulDedekindINF`; (c) nine of the eleven cited line numbers had moved.
  Every cited name was re-located by grep before editing; the two that had not moved
  (`VecEACombinators.lean:116` / `:201`) were left as they were. A new row was added for the
  retained previous pin, and a "Carrier note" paragraph records what the old description got wrong,
  so the next re-base has a stated baseline instead of a silently-refreshed table.

- **D16 — CLOSED AS ALREADY CORRECT. No change made.** The ticket recorded (from Phase 14) that
  *"`uSExpressivelyCompleteOverPrior`'s Reynolds Theorem 3 citation in `PriorExpressiveness.lean`
  may need correcting"*. On inspection the premise is false: **there is no "Theorem 3" citation in
  that file.** `uSExpressivelyCompleteOverPrior`'s References block cites *"Reynolds 1994, Theorem
  5, pp.123-124"*, and that citation is correct. Reynolds 1994, printed p.123, reads verbatim:
  *"**Theorem 5.** The language with `U` and `S` is expressively complete for the class of Prior
  structures."* — which is exactly what the declaration states. The declaration's pinning at the
  stronger `SemanticPriorUZ` / `SemanticPriorSZ` is also sanctioned on that same page: *"Note that
  this result also holds for our stronger Prior axioms Prior-UZ and Prior-SZ (the weaker axioms are
  useful in non-discrete structures)."* Verified against the page image, not the corpus text layer.
  Per the dispatch's explicit instruction not to manufacture a correction in order to close a
  ticket, `PriorExpressiveness.lean` was left byte-identical.

  One residual imprecision, reported and deliberately **not** edited: Theorem 5's statement and
  proof sit wholly on printed p.123, so the range *"pp.123-124"* is one page wide. This is a
  page-range nicety, not a mis-citation, and correcting it was outside what the charter authorized.

  Note there is no conflict with `PriorExpressivenessDense.lean`'s header, which says
  `uSExpressivelyCompleteOverPrior` is *not* Reynolds' Theorem 3. That refers to Reynolds **1992**
  §5 Theorem 3; `PriorExpressiveness.lean` cites Reynolds **1994** Theorem 5. Two papers, two
  numberings, both citations correct.

**Territory addition outside the `Owns` list, recorded**: one import line was added to
`FormalSystem/Metalogic/WeakCanonical.lean` registering `DenseModelSurgery/Defs.lean`, with a
comment following the precedent already set there for `ChronicleMonadicBridge`. Without it the new
module is outside the `lake build` closure and would compile only when named explicitly. No other
content in that file was touched.

### Phase 18: Reynolds §6 Lemmas 3 and 4 — maximal `R`-intervals [COMPLETED]

- **Goal**: *"The maximal intervals in which `R` holds are open intervals which, if bounded, have
  elements of `M` as their (excluded) end points"* (Lemma 3) and *"There is no last class and no
  first class in any maximal interval of `R`"* (Lemma 4).
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean` (new).
- **Tasks**:
  - [x] Prove Lemma 3, transcribing Reynolds' three-case argument (printed p.177): `ρ` at `t` gives
        `R` for a while after `t`; if `R` does not hold forever after `t` then Prior-U applied to `R`
        gives either a last point of the `R`-stretch (impossible given `ρ`) or a first point of `¬R`;
        looking left, Prior-S gives three cases of which the third — a first point `s` of `R` with
        `R ∧ K⁻(¬R)` at `s` — is ruled out by the auxiliary formula `B` ("the class we are now in
        begins with a point satisfying `R ∧ K⁻(¬R)`"), which exists by expressive completeness and
        contradicts Prior-U. *(deviation: altered — page reference is p.178, not p.177; see the
        deviation record below)*
  - [x] Prove Lemma 4, transcribing printed p.177: the last class in a maximal `R`-interval would not
        end in a gap; and the temporal equivalent of `ρ(x) ∧ ∀y<x (y<z<x ∧ ε(y,z))` is true only in
        first classes, so a first class would give a formula true up to a gap and false arbitrarily
        soon after, contradicting Prior-U. *(deviation: altered — the quoted formula is the corrupted
        corpus rendering; the printed formula is `ρ(x) ∧ ∀y < x(¬ε(x,y) → ∃z(y < z < x ∧ ¬ρ(z)))`,
        and that is what was transcribed. See the deviation record below)*
  - [x] Each auxiliary formula obtained by expressive completeness is landed as a **named**
        definition with its defining monadic formula, not as an inline `obtain` — Phases 19-21 reuse
        the pattern and a named family is what makes them cheap.
  - [x] Docstrings: `Reynolds 1992, §6 Lemma 3 / Lemma 4, printed p.177`. *(deviation: altered —
        docstrings say pp.178-179, the pages the lemmas are actually printed on)*
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: Lemmas 3 and 4 sorry-free and axiom-clean; the auxiliary-formula helpers are named
  and reusable.
- **Depends on**: 17.
- **Timing**: 7 hours.
- **Decomposition protocol (R3)**: as Phase 11 — split at the Lemma 3 / Lemma 4 boundary if needed.

**Deviation record (Phase 18)**

*Deviation 1 — Lemma 4's displayed formula (literature-fidelity, plan premise wrong).* The plan's
task list quotes Lemma 4's formula as `ρ(x) ∧ ∀y<x (y<z<x ∧ ε(y,z))`. That is the pre-segmented
corpus chunk's rendering
(`~/Projects/Literature/sources/reynolds_1992/sec03_6-no-gaps-between-equivalence-classes.md`) and
it is corrupted in four independent places. The printed formula, read off the page image
(PDF page index 15 = printed p.179), is

```
ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))
```

The corpus version drops the implication's antecedent entirely, drops the `∃z` binder (leaving `z`
free, so the corpus text is not even a well-formed formula of one free variable), replaces the
one-place `¬ρ(z)` with the two-place `ε(y,z)`, and consequently flattens the quantifier nesting.
`pdftotext` is no help — that page's text layer renders the display as `p(x) A vy <    z(y < z < x
A`, so the image is the only reliable witness. Only the printed formula *means* what Reynolds says
it means (*"true only in the first classes of maximal intervals of `R`"*). Per the standing
literature-fidelity directive the printed formula was transcribed and the plan premise is reported
here rather than silently followed. This is the **second** corpus defect found in §6; the first,
`ρ`'s missing middle conjunct, is recorded under Phase 17.

*Deviation 2 — page references.* The plan says *"printed p.177"* for both lemmas. Lemma 3 and its
proof are on printed p.178; Lemma 4's statement is on p.178 and its proof on p.179. Docstrings use
the correct pages. Printed p.177 is where `ρ` and Lemma 2 sit — i.e. Phase 17's material.

*Deviation 3 — renderings that are this tree's, not Reynolds' words.* Lemma 3's one printed
sentence is landed as four named theorems plus an assembled `reynolds_lemma3`, with a table in the
module header mapping each to the proof step it transcribes. "Open interval" is rendered as `R`
holding on a two-sided neighbourhood; the left-hand half carries the proviso that `t` has some
point below it at all, which is not a weakening but the case Reynolds flags with *"the end of the
whole structure is not a gap"*. "If bounded, have elements of `M` as their (excluded) end points"
is rendered as the pair `reynolds_lemma3_right` / `reynolds_lemma3_left`.

*Addition beyond the task list.* `false_of_holds_throughout_class` isolates the *"holds up to a gap
and is false arbitrarily soon after the gap, contradicting Prior-U"* step, which Reynolds runs
verbatim at Lemma 3, Lemma 4 and again at Lemmas 5 and 7. Both Phase 18 uses go through it, so it
is exercised twice already; Phases 20-21 should consume it rather than re-deriving it.

*Territory addition outside the `Owns` list, recorded.* One import line was added to
`FormalSystem/Metalogic/WeakCanonical.lean` registering `DenseModelSurgery/Lemma34.lean`, following
the precedent set there by `Defs.lean` in Phase 17. The `Defs.lean` import line was **kept**
alongside it rather than dropped as now-transitive, so that removing `Lemma34.lean` from the list
could not silently drop the §6 vocabulary out of the build closure too. No other content in that
file was touched.

### Phase 19: Reynolds §6 Lemma 5 — formula and elementary transfer across classes [COMPLETED]

- **Goal**: *"If a temporal formula holds somewhere in one `∼`-class in a maximal interval of `R`,
  then it holds somewhere in each `∼`-class in the interval. Furthermore, each pair of the
  `∼`-classes in a maximal interval of `R` are elementarily equivalent (taken as substructures of
  `M`)."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean` (new).
- **Tasks**:
  - [x] Prove the first statement, transcribing printed p.178: find `B` true at points only if `A`
        occurs somewhere in their class (expressive completeness + `ε`); use `¬B` if necessary; the
        `B`-to-`¬B` transition point `s` is a left endpoint; Prior-U forbids `B` arbitrarily soon
        after the gap; then `C` ("we are now in a class whose left hand end point is also in the
        class and at that point `K⁻(B)` holds") is true in `s`'s class and false afterwards,
        contradicting Prior-U. *(deviation: altered — the page is p.179, not p.178; and two named
        assets the task list did not anticipate were required, `temporalToMonadic` and
        `false_of_holds_throughout_class_bounded`. See the deviation record below)*
  - [x] Prove the second statement: relativize a monadic sentence `φ` to `ε(x,−)`, obtain `φ'` of one
        free variable, apply expressive completeness, and conclude by the first statement.
        *(deviation: altered — the printed formula name is `φ(x)`, not the corpus' `φ'`; and
        "substructures of `M`" is rendered as relativized satisfaction. See below)*
  - [x] Land the **relativization operator** `relativizeToClass ε φ` as a named, reusable definition
        — Phase 25 (Lemma 12) needs exactly the same operator for `γ(z,t)`. *(landed at arbitrary
        arity as `relativizeAt`, with `relativizeToClass` its sentence case, so Lemma 12's
        two-variable `γ(z,t)` is already covered)*
  - [x] Docstring: `Reynolds 1992, §6 Lemma 5, printed p.178`. *(deviation: altered — docstrings say
        p.179, the page the lemma is actually printed on)*
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~380 lines.
- **Done when**: both statements sorry-free and axiom-clean; `relativizeToClass` is named and
  reusable.
- **Depends on**: 18.
- **Timing**: 7 hours.
- **Decomposition protocol**: as Phase 18.

**Deviation record (Phase 19)**

*Deviation 1 — page reference.* The plan says *"printed p.178"* for Lemma 5. Lemma 5's statement
**and its whole proof** are on printed p.179 (PDF page index 15); printed p.180 opens with Lemma 6.
Docstrings use p.179. This is the same drift Phase 18 recorded for Lemmas 3-4.

*Deviation 2 — `φ'` vs `φ(x)`, and the corpus is clean here.* Lemma 5 contains **no displayed
formula**, which is where both earlier §6 corpus defects sat, and its inline text checks out
against the page image. The single difference: the corpus (and the plan, which follows it) writes
*"We get a formula `φ'` of one free variable"* where the page prints *"a formula `φ(x)`"*. Nothing
turns on it; the module quotes the printed form.

*Addition 1 — the temporal-to-monadic direction of expressive completeness.* Reynolds' *"using
expressive completeness and `ε`, find `B` which is true at points only if `A` occurs somewhere in
their `∼`-class"* builds `B` from `A`'s **monadic** form. The tree lands only the hard direction of
§5 Theorem 3 (`uSExpressivelyCompleteOverDensePrior`, monadic → temporal). The easy converse is
landed here as `temporalAt` / `temporalToMonadic` with a checked soundness theorem
`eval_temporalAt`. It is available at all only because `TemporalTruth` (`Table.lean:188`) reads
`.box φ` off `M.interp (atomMap (.box φ))`, i.e. as a monadic atom.

*Addition 2 — `false_of_holds_throughout_class` could not be reused as it stands.* Phase 18's
theorem requires the auxiliary formula to fail at **every** point outside the class reachable with
`R` throughout in between. Lemma 5's `C` does not satisfy that and cannot: with classes
`C₀ ⊨ ¬B`, `C₁ ⊨ B`, `C₂ ⊨ ¬B` in a row, `C₂`'s left end point does carry `K⁻(B)`, so `C` is true
again at `C₂`. Reynolds claims only *"false **afterwards**"*, licensed by the preceding paragraph
(*"for a while after this class `B` stays false"*, landed as `exists_bound_notHolds`).
`false_of_holds_throughout_class_bounded` is that weaker hypothesis, and is a genuine
strengthening: the unbounded form does not imply it. Phase 18's theorem is left in place,
unweakened and unrenamed, and its two Phase 18 consumers are untouched.

*Addition 3 — two reusable auxiliary-formula families.* `classBeginsWithFormula` (*"we are now in a
class whose left hand end point is also in the class and at that point … holds"*) and
`kMinusFormula` (`K⁻`), each with a named semantic reading and a checked `..._eval`, following the
Phase 18 pattern. `Lemma34.lean`'s `classBeginsAtGapStartFormula` is the same family with
`R ∧ K⁻(¬R)` in the payload slot; it was **not** refactored to route through them — zero removals,
zero renames — and the relationship is recorded in the new docstring instead.

*Rendering 1 — "in the same maximal interval of `R`".* Rendered as `R` holding throughout the
closed segment between the two points, which is what lying in one maximal (hence convex)
`R`-interval amounts to for two of its points. This is this tree's rendering, not Reynolds' words.

*Rendering 2 — "elementarily equivalent (taken as substructures of `M`)".* A `∼`-class is convex
but need not be an interval with end points in `M` — by `ρ` the classes inside a maximal
`R`-interval end in gaps — so `M.subinterval` cannot name one. The induced substructure is named
the standard equivalent way, by relativized satisfaction (`evalOn`), and `eval_relativizeAt` is the
theorem that Reynolds' syntactic relativization agrees with it.

*Honest caveat, unchanged.* Every §6 lemma below Lemma 2 is still **conditional**. The only `ε`
this tree can exhibit satisfying `IsContempEquivDense` is `epsTop`, for which `EndsInGapOnRight` is
empty, so Lemma 5 has no live non-trivial instance yet. It is recorded in the module header and
carried forward.

*Correction to a carry-forward.* The dispatch brief said the repository's sole live `sorry` sits at
`Transfer.lean:1225`. It is at **`Transfer.lean:1242`** — the plan's original figure was right and
the correction was not. Re-measured, not assumed.

#### Phase 19 scope-gap annotation (added in v9 — an annotation, NOT a reopening)

**Phase 19 remains `[COMPLETED]` and is not reopened.** Its charter was discharged in full, its
output is landed, green, sorry-free and axiom-clean, and it delivered two named assets beyond
charter. What follows records a gap in the **charter Phase 19 was given**, so that a later reader
does not conclude the implementation under-delivered.

**The gap.** Phase 19's task 1 charters only the `ρ` side: *"the whole of a class … left hand end
point … `K⁻(B)`"*, yielding `reynolds_lemma5_first` over `EndsInGapOnRight`. **No `λ`-side
statement was chartered**, and none was landed.

**Why the charter looked complete, and was not.** Reynolds states §6 Lemma 5 over maximal
intervals of `R` **only** — verified verbatim off the printed p.179 page image (quoted in full in
the Revision Rationale (v8 → v9) above). There is no *"dually"* on that page. The charter
faithfully transcribed the printed statement. **The `λ`-side Lemma 5 is Reynolds' own omission**,
licensed by the duality convention he sets up at printed p.178 (*"Dually we can define λ(x) about
left ends."*, and Lemma 2's closing *"Dually L."*) and discharged all at once by the sentence that
closes Lemma 6 at p.180: *"Using mirror images of the above and previous results we get our
proof."* Reading *"previous results"* precisely, **Lemma 5 over maximal `λ`-intervals is a real
mathematical dependency of Lemma 6 that Reynolds never writes down** — it is the only result in §6
that gets *"all classes include their left hand end points"* out of one class doing so.

**Why it was insufficient.** Phase 20's Lemma 6 needs both sides. **Phase 20 could not have
succeeded as written**, and its `[PARTIAL]` is a consequence of this charter gap rather than of
anything the Phase 20 dispatch did or failed to do.

**Where the discharge lives.** **Phase 20.4**, which lands `reynolds_lemma5_first_left` (over
`EndsInGapOnLeft`) together with the fourth half of Lemma 6 that consumes it. Phase 19's landed
declarations are Preserved Assets: Phase 20.4 **adds beside them** and may not restate, rename or
weaken any of them.

**The generalization every later Block F phase must carry.** *When a source states a family of
results on one side and discharges the duals with a single "dually" or "by mirror images", the
duals are still proof obligations — and they must be scheduled as such at plan time, not left to
be discovered by the phase that first consumes one.* Reynolds does this at Lemmas 3, 4 and 5 and
again inside Lemma 6. Phases 21-30 must check, before dispatch, whether the §6 results they
consume exist on the side they need.

### Phase 20: Reynolds §6 Lemmas 6 and 7 — bad points and bad intervals [COMPLETED]

> **DISPATCH REDIRECT (v9).** This heading is the first match for the orchestrator's phase scan,
> but **there is no work left inside Phase 20's own territory**. Everything Phase 20 can land in
> `BadIntervals.lean` alone is landed, green and committed. Its one remaining task — Lemma 6's
> fourth half, *"`R` wherever `L`"* — is blocked on a dependency outside this phase's `Owns` list
> and is **chartered in full as Phase 20.4 below**.
>
> **A dispatch landing here executes Phase 20.4's charter, not this one.** Phase 20 closes as
> `[COMPLETED]` when and only when Phase 20.4 closes; mark both in the same postflight. Phase 20
> stays `[PARTIAL]` rather than `[COMPLETED WITH EXCLUSIONS]` because residual work genuinely
> remains and is handed off — condition 5 of the exclusion admission test fails, correctly.

- **Goal**: *"Bad points only occur in non-singleton bad intervals. In any bad interval both `R` and
  `L` hold throughout. Any bad interval, if bounded, has excluded end points in `M`"* (Lemma 6);
  *"If a formula `B` is true for a while at the start of a `∼`-class in a bad interval then it holds
  throughout the bad interval. Similarly at the end. If a formula is true anywhere in a bad interval
  it is true arbitrarily close to each end of each class in the interval"* (Lemma 7).
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/BadIntervals.lean` (new).
- **Tasks**:
  - [x] Define *bad point* (`R ∨ L` holds) and *bad interval* (non-empty maximal interval in which
        `R ∨ L` holds throughout), verbatim from printed p.178. *(deviation: altered — the
        definition is on printed p.179, not p.178; see the deviation record)*
  - **Lemma 6 — split in v9 into the four halves Reynolds' one sentence actually contains.** v8
    carried this as a single checkbox ending *"Then mirror images"*, which is what made a
    module-sized dependency look like a step. The split is the correction:
    - [x] **(a) Non-singleton.** *"Bad points only occur in non-singleton bad intervals."*
          `reynolds_lemma6_nonsingleton` (`BadIntervals.lean:677`).
    - [x] **(b) `L` wherever `R`.** Reynolds' *"We first show that `L` holds wherever `R` does"*
          (printed **p.180**), by the case analysis on whether a class includes its left endpoint
          or begins just after a point of `M`, closed by the formula `B` true at times which are
          not left endpoints of their classes, against Prior-U.
          `endsInGapOnLeft_of_endsInGapOnRight` (`:615-670`).
    - [x] **(c) Excluded end points.** *"Any bad interval, if bounded, has excluded end points in
          `M`."* `reynolds_lemma6_right_endpoint` (`:1275`). Assembled with (a) and (b) as the
          three-conjunct `reynolds_lemma6` (`:1322`) over `ClassInteriorToRInterval`.
    - [ ] **(d) `R` wherever `L` — Reynolds' *"Using mirror images of the above and previous
          results we get our proof"* (printed p.180). OWNED BY PHASE 20.4, NOT BY THIS PHASE.**
          **Explicit dependency**: Lemma 5 over maximal intervals of `λ`
          (`reynolds_lemma5_first_left`, over `EndsInGapOnLeft`), which does not exist — Phase 19's
          charter covered the `ρ` side only (see the Phase 19 scope-gap annotation). Also required:
          `ClassInteriorToLInterval`, which does not exist either (`grep`-confirmed at this
          revision: `BadIntervals.lean` defines `ClassInteriorToRInterval` at `:416` and
          `ClassInteriorToBadInterval` at `:1017`, and no `L` counterpart). **This is not a tactic
          failure and not a step inside this phase.**
          *(deviation from v8's charter: page is p.180, not pp.178-179)*
  - [x] Prove Lemma 7, transcribing printed p.179: for `γ < δ` gaps with `(γ,δ)` a class in a bad
        interval, the formula `C` true only at points within a class after some `¬B` in that class is
        false at the start and true at the end of each class, hence true up to the gap and false
        arbitrarily soon after — contradicting Prior-U. Second part by applying the first to `¬B`.
        *(deviation: altered — pages pp.180-181, not p.179; and Reynolds' *"Similarly at the end"*
        needed a full Prior-S mirror, plus a THIRD gap-crossing form that neither Phase 18's nor
        Phase 19's theorem supplies. See the deviation record)*
  - [x] Docstrings: `Reynolds 1992, §6 Lemma 6 / Lemma 7, printed pp.178-179`. *(deviation:
        altered — docstrings say pp.179-181, the pages the material is actually printed on)*
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines. *(actual: `BadIntervals.lean` is 1343 lines — a ~3× overrun,
  driven by Lemma 7's *"Similarly at the end"* turning out to be a full 258-line Prior-S mirror
  rather than a one-liner. Recorded, not absorbed.)*
- **Done when**: Lemma 7 sorry-free and axiom-clean **both sides** (met); Lemma 6's halves (a),
  (b), (c) sorry-free and axiom-clean (met); **half (d) closed by Phase 20.4** (outstanding).
  Phase 20 and Phase 20.4 close together.
- **Depends on**: 19.
- **Timing**: 7 hours (spent).
- **Verification Tier**: full.
- **Decomposition protocol**: as Phase 18 — split at the Lemma 6 / Lemma 7 boundary if needed.
  **Exercised**: half (d) was split out as Phase 20.4 under the R3 protocol at this revision.

**BLOCKER** (Phase 20, Lemma 6's half (d) only — everything else landed and green). **Updated in
v9 against `reports/08`; the original Phase 20 text is preserved in the diff and its one wrong
figure is corrected here rather than silently overwritten.**

- **What is missing**: `R` holds wherever `L` does — Reynolds' *"Using mirror images of the above
  and previous results we get our proof"* (printed **p.180**).
- **What was tried**: the forward direction (`endsInGapOnLeft_of_endsInGapOnRight`) was landed in
  full and its shape inspected for mirroring. It routes through `reynolds_lemma5_first`
  (`Lemma5.lean:591`), whose interval hypothesis is
  `hIcc : ∀ q, min t t' ≤ q → q ≤ max t t' → EndsInGapOnRight M ε q`.
- **Why stuck**: mirroring the argument requires Lemma 5 stated over maximal intervals of `λ`
  (`EndsInGapOnLeft`), which is what Reynolds means by *"previous results"* read in the mirror.
  Phase 19's **charter** covered the `ρ` side only. This is not a tactic failure and not an
  implementation defect — **the mirrored statement does not exist in the tree because the plan
  never scheduled it.** See the Phase 19 scope-gap annotation.
- **ROOT CAUSE (v9)**: a **plan deviation**, not an implementation failure. Verified verbatim off
  the printed p.179 page image that Reynolds states Lemma 5 over maximal intervals of `R` only,
  and that this is his own omission licensed by the p.178 duality convention.
- **CORRECTED SIZING (v9) — v8's figure was a ~3× under-count.** The original text said *"~180
  lines mirroring `not_endsInGapOnRight_of_immediatePredecessor`, `false_of_allClassesHaveLeftEnd`
  and `exists_leftEnd_throughout`"*. That sized only `reynolds_lemma5_first_left` and **omitted
  the fourth half's own mirror chain, which is the actual deliverable**. Measured R-side spans:
  ~273 lines (Chain 1, `Lemma5.lean`) + ~271 lines (Chain 2, `BadIntervals.lean`) ≈ **540-590
  lines** for the hand-mirrored route. In-file precedent corroborates: this phase's own Lemma 7
  mirror (`BadIntervals.lean:968-1225`) is **258 lines for a half-size chain**. Both figures are
  right about different scopes; the ~180 figure's scope is not the deliverable's.
- **What is needed**: chartered in full as **Phase 20.4** below — preferentially as the
  duality-transport route (~350 lines, ~150 of them already compiled green), with the ~540-590
  line hand mirror as the gated fallback.
- **Not needed by Phase 21**: Lemma 8's thirteen cases consume **Lemma 7**, which is complete on
  both sides. Lemma 6's half (d) is not on Lemma 8's critical path. Corroborated independently in
  `reports/08` by reading `reynolds_lemma7` (`:1230`).
- **Prohibited, and observed**: no `sorry`, no `def X := True`, no vacuous placeholder was used.
  The gap is recorded in the module header and here, and the tree is green.

**Deviation record (Phase 20)**

*Deviation 1 — page references, again, and a measured page map.* The plan puts the *bad point* /
*bad interval* definition and Lemma 6 at pp.178-179 and Lemma 7 at p.179. Measured against the page
images, printed page = PDF page (1-based) + 164 throughout §6:

| Material | PDF page | Printed page | Plan says |
| --- | --- | --- | --- |
| `ρ`, Lemma 2 | 13 | 177 | 177 ✓ |
| Lemma 3, Lemma 4 statement | 14 | 178 | 177 ✗ |
| Lemma 4 proof, Lemma 5, *bad point* / *bad interval* | 15 | 179 | 178 ✗ |
| Lemma 6, Lemma 7 statement + proof opening | 16 | 180 | 178-179 ✗ |
| Lemma 7 proof close, surgery set-up, Lemma 8 | 17 | 181 | 179 ✗ |

Docstrings use the measured pages. Reported, not silently followed. This extends the Phase 18 and
Phase 19 drift records; Phase 21's Lemma 8 is on **pp.181-182**, not pp.179-180.

*Deviation 2 — corpus is clean here; the §6 defect count stands at two.* Lemmas 6 and 7 and the
*bad point* / *bad interval* definition contain **no displayed formula at all**. Both recorded §6
corpus defects sat at displays, so neither has an analogue. Every sentence block-quoted in the
module header was read off the page image and agrees with the corpus chunk word for word, with one
printer's typo preserved in the module (*"Its not hard"* on the page; the corpus normalises it to
*"It's not hard"*). The standing display warning is unchanged.

*Deviation 3 — Lemma 7 licenses NEITHER landed gap-crossing form.* The standing instruction was to
determine which of `false_of_holds_throughout_class` (Phase 18) and
`false_of_holds_throughout_class_bounded` (Phase 19) Lemma 7 consumes before using either. The
answer is neither, and Reynolds' own sentence says why: *"`C` will be false for a while at the
beginning of each class and then true for a while at the end."* Phase 18's form needs the auxiliary
formula true **throughout** the class and false at **every** later point outside it; `C` fails both.
Phase 19's form weakens only the second. `false_of_holds_throughout_class_from_bounded` weakens
both — `hin` only from `s` onwards inside the class, `hout` only *"false arbitrarily soon after the
gap"* (a failure point at or below each given point beyond the class, not failure everywhere).
Both earlier forms are left in place unweakened and unrenamed; every existing consumer is untouched.

*Deviation 4 — *"Similarly at the end"* is a full mirror, not a one-liner.* Lemma 7's second half
needed Prior-S rather than Prior-U, and pulled in four assets the task list did not anticipate:
`endsInGapOnLeft_congr` (`λ` is a class property — `Lemma34.lean` had only the `ρ` side),
`exists_contemp_lt`, `false_of_holds_throughout_class_upto_bounded`, and the mirror auxiliary
formula family `beforeNotHoldsInClass*`. It does **not** hit the Lemma-5-mirror obstruction that
blocks Lemma 6's fourth half, because a bad interval carries both `R` and `L` throughout
(`ClassInteriorToBadInterval`), so the past-directed argument can still appeal to the `R`-side
Lemma 5.

*Rendering 1 — *"a maximal interval of `R`"*.* Rendered as `ClassInteriorToRInterval M ε a t b`:
two points `a < t < b` outside `t`'s class with `R` throughout `[a,b]`. This is this tree's
rendering, not Reynolds' words.

**CORRECTED IN v10 — the supply claim this note carried is measured FALSE, and it was the root
deviation of the whole Block F stall.** The sentence v9 printed here was:

> *That is what Lemma 4 ("no last class and no first class") plus convexity of a maximal interval
> supply.*

**Superseded. It is kept visible so the correction is auditable, and it must not be re-asserted.**
The measured facts (`reports/09` §1.3, §6.2):

- `reynolds_lemma4_no_last_class` **does** supply the **upper** witness, as-is — that half of the
  claim holds.
- `reynolds_lemma4_no_first_class` **does not** supply the lower one. It yields `R` on the **open**
  `(y, t)`, and `ClassInteriorToRInterval.rThroughout` demands the **closed** `[a, t]`. Shrinking
  `a` into `(y, t)` is unavailable in exactly the residual case where `t`'s class begins
  immediately after `y ∈ M` — the boundary configuration Reynolds' Lemma 3 licenses and his own
  Lemma 4 display fails to cover.
- **Nothing in the tree produces a `ClassInteriorToRInterval` at all**, on either side.
  Repo-wide the identifier occurs at `BadIntervals.lean:{422, 626, 868, 954, 1026, 1353, 1392}` —
  one definition, one field, one dual instantiation, four hypothesis positions. **Zero
  conclusions.**

**This was a proof obligation asserted in a rendering note and never chartered as a task**, and no
phase in v9 — not 19, not 20, not 20.4, not 22 — had a producer as a deliverable. The producer is
now chartered as **Phase 22.1 Step B**, downstream of the repaired Lemma 4 (Step A). See the
producer rule in Postmortem Constraints. **Phase 20 is not reopened**: everything it landed is
green and committed, and this is an annotation to its deviation record.

*Rendering 2 — *"non-empty and maximal one in which `R ∨ L` holds throughout"*.* Rendered as
`IsBadInterval`, whose maximality clause is in **saturation** form. `IsBadInterval.maximal_among`
derives the maximal-among-bad-intervals reading from it, so the rendering is checked rather than
asserted.

*Territory addition outside the `Owns` list, recorded.* One import line was added to
`FormalSystem/Metalogic/WeakCanonical.lean` registering `DenseModelSurgery/BadIntervals.lean`,
following the precedent of `Defs.lean` (Phase 17), `Lemma34.lean` (Phase 18) and `Lemma5.lean`
(Phase 19). The three earlier import lines were **kept** rather than dropped as now-transitive. No
other content in that file was touched.

*Honest caveat, unchanged and carried forward.* Every §6 lemma below Lemma 2 remains **conditional**:
`IsContempEquivDense ε` plus Prior-U/Prior-S are hypotheses, and the only `ε` the tree can exhibit
satisfying them is `epsTop`, for which `EndsInGapOnRight` is empty. Nothing in this phase is
discharged at a non-trivial instance. These results are not to be described as discharged.

### Phase 20.4: The §6 duality-transport layer and Lemma 6's fourth half [COMPLETED]

- **Goal**: Land `reynolds_lemma5_first_left` (Lemma 5 over maximal intervals of `λ`) and
  `endsInGapOnRight_of_endsInGapOnLeft` (Reynolds' *"using mirror images of the above and previous
  results"*, printed **p.180**), and extend `reynolds_lemma6` to its fourth conjunct — **via a
  reusable duality-transport layer rather than a hand mirror**, so that every remaining §6
  *"mirror image"* costs ~25 lines instead of a module.
- **Owns**:
  - `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean` (**new**);
  - `.../DenseModelSurgery/Lemma5.lean` (**append-only**: new declarations at the end; no existing
    declaration restated, renamed or weakened);
  - `.../DenseModelSurgery/BadIntervals.lean` (**append-only**, plus the one permitted in-place
    edit named in task G3.3);
  - one import line in `FormalSystem/Metalogic/WeakCanonical.lean`, following the precedent set by
    `Defs.lean` (Phase 17), `Lemma34.lean` (18), `Lemma5.lean` (19) and `BadIntervals.lean` (20).
    **Keep the four earlier import lines** rather than dropping them as now-transitive.
- **Route (a) — the chartered route. Three groups, dispatched in order.**

  **Group 1 — the dualization core (~150 lines; ~150 already compiled green via `lean_run_code`
  in `reports/08`).** New file `Dual.lean`. Land, with full proofs:

  | Declaration | Content |
  |---|---|
  | `dual`, `d`, `dual_carrier`, `d_lt` | the dual structure over `OrderDual`; `d_lt : d x < d y ↔ y < x` is `Iff.rfl` |
  | `dualize` | flip every `.lt i j ↦ .lt j i` in a `MonadicFormula` |
  | `eval_dualize` | `eval (dual M) (d ∘ env) (dualize φ) ↔ eval M env φ` — **the `lt` case is `Iff.rfl`; order reversal is definitional** |
  | `swapUS` | swap `untl`/`snce`; **leaves `.box` opaque** |
  | `temporalTruth_dual` | `TemporalTruth (dual M) atomMap (d t) A ↔ TemporalTruth M atomMap t (swapUS A)` |
  | `swapUS_involutive` | |
  | `semanticPriorU_dual` | `SemanticPriorS M → SemanticPriorU (dual M)` |
  | `contempEquivDense_dual` | `∼` is the same relation on the dual |
  | `endsInGapOnRight_dual` | `EndsInGapOnRight (dual M) (dualize ε) (d t) ↔ EndsInGapOnLeft M ε t` |

  Three fixes to apply to the probe as `reports/08` ran it: (1) drop the redundant
  `generalizing env` on `eval_dualize` (Lean 4.33 generalizes it automatically); (2) in
  `contempEquivDense_dual`, `congr 1` closes the goal — delete the trailing `funext`/`fin_cases`;
  (3) in `endsInGapOnRight_dual`'s third conjunct the two inner implications appear in swapped
  order (`y < z → y < t` vs `z < y → y < t`) — reorder the `imp_congr` chain or close with
  `tauto`.

  **Two discipline constraints, binding and non-negotiable** (see also the v9 Postmortem
  Constraints):
  - **Use `def d (x : M.carrier) : (dual M).carrier := x`, NOT `OrderDual.toDual`.** The latter
    reproduces the `.carrier`-unfolding hazard already documented at `NEquivalence.lean:134` for
    `orderedSum`. `reports/08`'s probe run 2 hit exactly that mismatch; run 3 with `d` did not.
    **This is the trick that removed all the `Fin.cons` friction** — with `d` in place the binder
    cases of the `eval` transport collapse to one-liners.
  - **Mark `dual` NOT `@[reducible]`**, for the same reason (instance-diamond avoidance).

  **Group 2 — hypothesis transport (~145 lines).** `semanticPriorS_dual` (~20, symmetric to a
  green proof), `endsInGapOnLeft_dual` (~25, symmetric to a green proof), and
  `isContempEquivDense_dualize` clauses (i)+(ii) (~30, routine, via `contempEquivDense_dual`),
  then **clause (iii) (~70) — the one piece with no verified path (R14)**. Take the escapes in
  this order and stop at the first that works:
  - **Escape 1 (~70 lines, reusable).** Prove `eval` invariant along an `Equiv` of carriers
    preserving order and `interp`, then apply at `Equiv.subtypeEquivRight (fun _ => and_comm)`.
    One structural induction over `MonadicFormula`, six cases, the same shape as the
    already-green `eval_dualize`. Reusable indefinitely.
  - **Escape 2 (~40 lines, strictly additive) — take it the MOMENT Escape 1 resists.** Add
    `structure ContempFacts (M) (ε) : Prop` carrying only `equiv` and `convex`, plus
    `ContempFacts.of_isContempEquivDense`, plus `_of_facts` variants of the four helpers
    (`contemp_refl`/`_symm`/`_trans`/`_of_between`) and of the Lemma 5 chain's entry points.
    Clause (iii) then never has to transport at all. **Add new variants; do not rewrite existing
    signatures** (D11). **No fidelity is lost either way**, because clause (iii) is dead weight —
    see R14 and task V4 below.

  **Group 3 — the deliverables (~55 lines).**
  - **G3.1** `reynolds_lemma5_first_left` — `reynolds_lemma5_first` instantiated at
    `(dual M, dualize ε)`, rewritten through Group 1's transport lemmas (~25 lines), appended to
    `Lemma5.lean`.
  - **G3.2** `ClassInteriorToLInterval` (**it does not exist — define it**, as the `λ`-side mirror
    of `ClassInteriorToRInterval`, `BadIntervals.lean:416`) and
    `endsInGapOnRight_of_endsInGapOnLeft : ClassInteriorToLInterval M ε a t b →
    EndsInGapOnRight M ε t`, likewise by instantiation (~30 lines).
  - **G3.3** Extend `reynolds_lemma6` (`BadIntervals.lean:1322`) with its fourth conjunct.
    **This is the ONE permitted in-place edit in this phase**: the three landed conjuncts are
    Preserved Assets and may not be restated, reordered or weakened — the edit **adds** a
    conjunct and adds the corresponding component to the assembling `exact`. Then delete the gap
    note in `BadIntervals.lean`'s module header and in `reynolds_lemma6`'s docstring, replacing
    them with the completed four-half account.
- **Route (b) — the gated fallback.** The ~540-590 line hand mirror, split at the `Lemma5.lean` /
  `BadIntervals.lean` boundary. **Not chartered as headings here** — see Rollback/Contingency,
  which sizes it as Phases 20.6 (~273 lines) and 20.7 (~271 lines) to be spliced in under the R2
  protocol only if the gate below trips.
- **THE HARD GATE (binding abort condition, not a suggestion — R15)**: **if Group 1 does not
  reproduce green in-file on the first dispatch, abandon route (a) immediately and fall back to
  route (b).** Do **not** iterate on the transport layer. Do **not** attempt both routes. On
  abort: land whatever of Group 1 is green (or revert it cleanly if none is), report `[PARTIAL]`
  with the exact failing goal state, and name Phases 20.6/20.7 as the successor units. **Tripping
  this gate is a chartered outcome, not a failure**; burning the dispatch on transport-layer
  repair is the failure.
- **Verification tasks (all mandatory):**
  - [x] **V1 — declaration census.** Every declaration present in `Lemma5.lean` and
        `BadIntervals.lean` before the dispatch is still present after it, with its conclusion
        unweakened. Record before/after counts. `reynolds_lemma6` is the one declaration whose
        conclusion changes, and it may only be **strengthened** (a fourth conjunct added).
  - [x] **V2 — sorry census unchanged.** Exactly one live `sorry` outside `Boneyard/`, at
        `WeakCanonical/Transfer.lean:1242`. **The two live sorries at
        `Decidability/Verified/Bridge/IntTruth.lean:434,444` belong to the concurrent decidability
        effort and are outside this task's territory — do not count them, do not touch them, do
        not stage them.**
  - [x] **V3 — `#print axioms`** on `reynolds_lemma5_first_left`,
        `endsInGapOnRight_of_endsInGapOnLeft`, `reynolds_lemma6` and every `Dual.lean` declaration
        = exactly `[propext, Classical.choice, Quot.sound]`. Group 1 is axiom-free by construction
        (structural inductions and `Iff.rfl`); if it is not, something has gone wrong.
  - [x] **V4 — record R14 honestly.** `Dual.lean`'s module header states, in this tree's own
        words, that `IsContempEquivDense` clause (iii) does not transport definitionally, that
        this is **our formalization artifact and not Reynolds'** (his `M|[a,b]` is an *unordered*
        interval; the `min ≤ x ∧ x ≤ max` conjunct ordering is an artifact of the Lean rendering),
        and which escape was taken. **Honesty-charter Rule 7 applies**: do not record this as a
        defect in the source.
  - [x] **V5 — record the retrospective subsumption.** `Dual.lean`'s header notes that the layer
        subsumes the two hand-written mirrors already paid for — `BadIntervals.lean:968-1225` (258
        lines) and `Kamp/Lemma53FaithfulPast.lean` (364 lines) — **neither of which is deleted or
        refactored**. The point is that no future phase derives a third by hand.
  - [x] **V6 — carry the conditionality caveat.** `Dual.lean` and the extended `reynolds_lemma6`
        docstring repeat the standing §6 caveat: every §6 lemma below Lemma 2 is **conditional**,
        with no live non-trivial instance until Phase 22. Nothing here is discharged.
  - [x] **V7 — regression canaries**: `#print axioms completeness_dense`,
        `completeness_discrete`, `countermodel_discrete_reynolds_v2` unchanged. Frozen files
        byte-identical. No file under `Decidability/` or `Automation/` read for edit or staged.
  - [x] **V8 — docstring pages.** Every §6 page number cited is taken from the measured map
        (printed = PDF + 164): Lemma 5 → **p.179**, Lemma 6 → **p.180**. Reynolds' duality
        convention is cited at **p.178** (*"Dually we can define λ(x) about left ends."*).
        Quote only inline prose from the corpus; verify any display against the page image.
  - [x] No task-number citations in any `.lean` file.
- **Estimated output**: **~350 lines** on route (a) (Group 1 ~150 + Group 2 ~145 + Group 3 ~55).
  Within the H8 one-run bound. Route (b) at 540-590 lines is **not** within it, which is why it is
  chartered as two sub-phases rather than as an in-phase alternative.
- **Scope Hypothesis**: the ~350-line route-(a) total, the ~150-line green Group 1, and the
  ~540-590-line route-(b) figure are **hypotheses from `reports/08`'s measurement, not facts about
  this dispatch**. Confirm at implementation time by: (i) recording actual `wc -l` of `Dual.lean`
  and of the appended blocks; (ii) recording whether Group 1 reproduced green in-file on the first
  attempt (the gate); (iii) recording which clause-(iii) escape was taken. A material divergence
  is reported in the summary, never absorbed into an unchanged estimate.
- **Done when**: `reynolds_lemma5_first_left` and `endsInGapOnRight_of_endsInGapOnLeft` are
  sorry-free and axiom-clean; `reynolds_lemma6` carries its **fourth** conjunct; the gap notes in
  `BadIntervals.lean` are removed; V1-V8 recorded. **Phase 20 is marked `[COMPLETED]` in the same
  postflight.**
- **EXECUTION RECORD (Phase 20.4, as run).**
  - **R15 hard gate: NOT tripped.** Route (a) taken and completed; route (b) never opened.
    Group 1 reproduced green in-file after ONE repair pass of six explicit-implicit-argument
    annotations (`(M := M)` on `.mp`/`.mpr` applications where Lean unified the implicit `{M}`
    as `dual M`). `reports/08` had pre-authorised three residual fixes of exactly this species;
    six were found, all trivial, none a design defect. Of the three fixes `reports/08` named,
    (1) `generalizing env` and (2) the `contempEquivDense_dual` `congr` were pre-empted by
    writing those declarations differently; (3) the swapped-conjunct order in
    `endsInGapOnRight_dual` was real and was repaired as recorded.
  - **Clause (iii) escape taken: ESCAPE 1**, the chartered first choice. `StructIso` /
    `cons_comp_equiv` / `eval_iso` supply the eval-along-carrier-isomorphism lemma R14 named as
    absent; `subintervalDualEquiv` / `subintervalDualIso` instantiate it at the conjunct
    exchange. **Escape 2 (`ContempFacts`) was NOT needed**, so no existing signature was
    rewritten and `IsContempEquivDense` is unweakened and unrenamed.
  - **R14 refined by measurement, and narrower than stated.** The endpoint exchange in the dual
    IS definitional — `dual_min` and `dual_max` are both `rfl`. Only the ORDER of the two
    conjuncts in the `Subtype` predicate fails to be definitional. R14's diagnosis stands; its
    scope is smaller than the risk row claims. Recorded in `Dual.lean`'s header as this tree's
    formalization artifact, not as a defect in Reynolds (honesty-charter Rule 7).
  - **SCOPE HYPOTHESIS FALSIFIED — reported, not absorbed.** Estimate ~350 lines; **actual 618**
    (1.77x): `Dual.lean` 492 (of which ~98 are module-header docstring), `Lemma5.lean` +58,
    `BadIntervals.lean` +68. The overrun is concentrated in Group 1+2 (~394 lines of code vs
    ~295 estimated) and in documentation density, not in unplanned proof work. Group 3 came in
    at ~126 lines against ~55 estimated, because `ClassInteriorToLInterval` and the retired gap
    notes were not counted in the estimate. **Every group still landed within the one dispatch.**
  - **V1 census**: `Lemma5.lean` 38 -> 39 declarations, `BadIntervals.lean` 48 -> 50. **Zero
    removals, zero renames.** `reynolds_lemma6` is the only declaration whose conclusion
    changed, and it was strengthened by one conjunct; its three landed conjuncts are byte-identical.
  - **V2 sorry census**: this dispatch's delta is **ZERO**. Live non-`Boneyard` sorries before
    and after: `WeakCanonical/Transfer.lean:1242` (pre-existing, unrelated) plus two in
    `Decidability/Verified/Bridge/IntTruth.lean` belonging to the concurrent decidability
    effort — not counted, not touched, not staged. Their line numbers drift under that session.
  - **V3/V7 axioms**: every new declaration is within `[propext, Classical.choice, Quot.sound]`
    (several are strictly smaller; `dualize`, `swapUS` and their involutivity lemmas depend on
    no axioms at all). Canaries `completeness_dense`, `completeness_discrete`,
    `countermodel_discrete_reynolds_v2` unchanged.
  - **Phase 20.5 (D16) was NOT batched into this dispatch** — it remains `[NOT STARTED]` with
    its own owner, as chartered.
  - **Build**: full `lake build` green (1937 jobs) with the complete change set in place. A
    later full build failed on `Decidability/Verified/Bridge/TemporalGate.lean`, a file the
    concurrent session was live-editing; scoped `lake build FormalSystem.Metalogic.WeakCanonical`
    (1842 jobs) green. No `Decidability/` or `Automation/` file was staged by this phase.
  - **Incident, disclosed.** A `git stash`/`git checkout` used to compare the sorry census
    against the baseline left the tree detached and briefly swept the concurrent session's
    in-flight `TemporalGate.lean` into a stash, which was then popped by mistake. All work was
    recovered by content extraction (`git show <stash>:<path>`); the concurrent session's WIP is
    preserved and labelled in a stash entry. Census comparisons afterwards used `git show
    <rev>:<path>` only, never a checkout.
- **Depends on**: 19, and Phase 20's landed content. **Blocks nothing currently scheduled** —
  Phase 21 is explicitly not serialized behind it.
- **Timing**: 5 hours on route (a). *(Route (b), if the gate trips, is 5 + 5 hours across Phases
  20.6 and 20.7 — recorded there, not silently absorbed here.)*
- **Verification Tier**: full. *(`Dual.lean` introduces a new order-dual structure and instances
  that can affect elaboration anywhere downstream; the tie-break-upward rule applies.)*
- **Commit Mode**: `per-substep`. Group 1, Group 2 and each of G3.1/G3.2/G3.3 are independently
  green-able and are committed as they go — this is also what makes the gate cheap to honour, since
  a green Group 1 is already banked when Group 2 is attempted.
- **Decomposition protocol**: as Phase 18. If Group 2's clause (iii) resists **both** escapes,
  land Groups 1 and 3 (G3.1/G3.2 do not consume clause (iii)) and report `[PARTIAL]` naming clause
  (iii) as the residual — do not sorry it and do not weaken `IsContempEquivDense`.

### Phase 20.5: D16 closure — the `PriorExpressiveness.lean` page-range correction [COMPLETED]

- **Goal**: Give **D16** an owner. It is the last open documentation ticket from Block D/F and it
  currently appears in **no** `Owns` list for any phase from 20 through 30, so the existing
  sequence would never have picked it up. This phase exists so that a real, small, named residual
  is closed rather than quietly outliving the plan.
- **What D16 is, precisely** (it is smaller than its history suggests). Phase 17's addendum closed
  D16 as **already correct**: `uSExpressivelyCompleteOverPrior`'s citation of *"Reynolds 1994,
  Theorem 5"* is right, verified against the page image, and the file was correctly left
  byte-identical rather than having a correction manufactured to close a ticket. **One residual
  imprecision was reported and deliberately not edited**: Theorem 5's statement and proof sit
  wholly on printed **p.123**, so the cited range *"pp.123-124"* is one page wide. That, and
  nothing else, is what remains.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorExpressiveness.lean` — **comment bytes
  only**.
- **Tasks**:
  - [x] Re-verify against the page image that Reynolds 1994 Theorem 5 (*"The language with `U` and
        `S` is expressively complete for the class of Prior structures."*) sits wholly on printed
        p.123. **If it does not, change nothing** and record the finding — the standing instruction
        not to manufacture a correction in order to close a ticket applies here as it did in
        Phase 17. **CONFIRMED against the page image** (`pdftoppm -f 7` of
        `Reynolds_1994_Axiomatising_U_and_S_over_integer_time.pdf`, read as an image, not from
        another docstring): PDF page 7 carries the printed running header **123**, and Theorem 5's
        statement *and* its complete proof (down to *"The case of `S'` is similar."*) both sit on
        that page, followed immediately by the §7 heading *"No gaps between equivalence classes"*.
        Nothing of Theorem 5 spills onto p.124. **Offset re-measured for this section rather than
        inherited**: printed = PDF page **+ 116** here (123 = 7 + 116) — §6's measured `+164` does
        NOT carry over, exactly as the standing directive warned.
  - [x] If confirmed, narrow the References range from `pp.123-124` to `p.123`. No proof,
        statement, signature or declaration changes. **Done at all three citation sites in the
        owned file** (module-header References `:39`, `flatten_stavi_correct_prior`'s docstring
        `:209`, `uSExpressivelyCompleteOverPrior`'s References `:355`) — the estimate said ~1 line
        because only the third was on the D16 ticket, but all three carried the identical wrong
        range and all three are comment bytes in the owned file. *(deviation: widened — 3 changed
        lines, not 1, same correction each time.)*
  - [x] Record that there is **no** conflict with `PriorExpressivenessDense.lean`'s header: that
        header refers to Reynolds **1992** §5 Theorem 3, while this file cites Reynolds **1994**
        Theorem 5. Two papers, two numberings, both citations correct. **Re-confirmed by
        inspection**: `PriorExpressivenessDense.lean:15,125,190,284` cite *Reynolds 1992,
        "Continuous Temporal Models", §5 Theorem 3, printed p.176*; nothing there mentions p.123
        or Reynolds 1994. The two files were not made to agree, because they are not about the
        same theorem.
  - [x] `git diff -U0` shows changes confined to `/-` … `-/` or `--` lines; `#print axioms
        uSExpressivelyCompleteOverPrior` unchanged. **Both gates pass**: `git diff -U0` is exactly
        three single-line `-`/`+` pairs, every one inside a `/-! … -/` or `/-- … -/` block; the
        axiom set is `[propext, Classical.choice, Quot.sound]` with no `sorryAx`, unchanged.
        Scoped `lake build FormalSystem.Metalogic.WeakCanonical.PriorExpressiveness` green
        (1234 jobs).
  - **Out-of-territory finding, reported not fixed**: two `Boneyard/` files still carry the old
    range — `BXPipelineDeadCode/ReynoldsModelSurgery.lean:41` and
    `BXPipelineGapAnalysis/ChronicleNoGaps.lean:72`. Both are outside this phase's `Owns` list and
    were deliberately left untouched. They are dead code; if anyone wants them consistent it is a
    separate, trivially small ticket, not a silent territory extension here.
- **Estimated output**: ~1 changed line.
- **Batching permission (explicit, to avoid a wasted dispatch)**: this phase **may** be executed as
  a chartered territory extension inside any dispatch from Phase 20.4 onward. If it is, the
  executing phase records the extension in its summary — following the precedent of the Phase 17
  addendum — and this phase is marked `[COMPLETED]` in the same postflight. It is chartered as its
  own heading so that it has an owner if it is *not* batched.
- **Done when**: either the range is narrowed to `p.123`, or the re-verification found otherwise
  and that finding is recorded. Either outcome closes D16.
- **Depends on**: none. Parallel-eligible with everything.
- **Timing**: 0.5 hours.
- **Verification Tier**: prose. *(Comment bytes only, in a file whose declarations are Preserved
  Assets. The tier's blind spot — an edit crossing out of the comment region — is covered by the
  `git diff -U0` check and the `#print axioms` check above.)*

### Phase 21: Reynolds §6 Lemma 8 — truth preservation under bad-interval surgery [COMPLETED]

- **Goal**: *"For all temporal formulas `A`, for all `t ∈ N`, `M ⊨ A(t)` iff `N ⊨ A(t)"`*, where `N`
  is `M` with a whole bad interval `Q₀` replaced by one of its `∼`-classes `I`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/TruthTransfer.lean` (new).
- **Tasks**:
  - [x] **Dependency check, first task (v9).** Confirm that this phase's Lemma 8 argument consumes
        only `reynolds_lemma7` (`BadIntervals.lean:1230`, **complete on both sides**) and Phase
        20's landed vocabulary — `IsBadInterval`, `ClassInteriorToBadInterval` (`:1017`),
        `reynolds_lemma6_nonsingleton` (`:677`), `reynolds_lemma6_right_endpoint` (`:1275`). **If
        any step needs `reynolds_lemma6`'s fourth conjunct or any other `R`-from-`L` fact, name the
        exact dependency and report `[BLOCKED]` on Phase 20.4** — do not wait silently, and do not
        manufacture the mirror inline. **CONFIRMED, and the de-serialization held**: the landed
        consumers are exactly `reynolds_lemma7_start`, `reynolds_lemma7_end`,
        `reynolds_lemma7_close_to_left`, `reynolds_lemma7_close_to_right`, `IsBadInterval` and
        `ClassInteriorToBadInterval`. `reynolds_lemma6`'s fourth conjunct was **not** needed and
        neither were `reynolds_lemma6_nonsingleton` or `reynolds_lemma6_right_endpoint` — the two
        Lemma 6 facts Lemma 8 does use (*"a bad interval has no first point"*, *"no last point"*)
        are re-derived inside the owned file as `exists_mem_lt` / `exists_mem_gt` from the
        interiority witnesses plus `IsBadInterval.saturated`, in four lines each. No `[BLOCKED]`
        report was required.
  - [x] Define the surgered structure `N` with domain `Q⁻ ∪ I ∪ Q⁺` (printed **p.181**).
        `restrictStructure` (the general form of `MonadicFO.lean:215`'s `subinterval`),
        `SurgeryDomain` and `surgeredStructure`. `Q⁻ ∪ Q⁺` is rendered as the single clause
        `¬ Q x` — justified by convexity of a bad interval, and proved as `lt_of_before` /
        `lt_of_after` rather than assumed.
  - [x] Prove Lemma 8 by induction on `A`, transcribing all thirteen cases from printed
        **pp.181-182**: seven forward `U(A,B)` cases and six backward, with `S(A,B)` by the mirror.
        Each case's justification is written out in the source; Lemma 7 is what closes cases 2, 3,
        5 and 6 in both directions. **Case count confirmed by measurement off the page images**
        (PDF pp.17-18): seven forward, six backward, thirteen in all. *(deviation: altered —
        Reynolds' seven forward cases are jointly exhaustive but **not pairwise disjoint**, his
        case 4 overlapping his case 2 when `t ∈ Q⁻` and `s ∈ I`. Lean needs a disjoint split, so
        the transcription fixes the position of `t` first and of `s` second, giving `3+3+1`
        forward and `3+2+1` backward — exactly his counts, with his case 4 read as the `t ∈ I`
        reading. The correspondence is recorded case by case in the module header and in inline
        case comments.)* Second measured divergence: Reynolds names Lemma 7 in **forward case 3**,
        where in this rendering his remark that *"`B` holds throughout `I`"* is just the
        observation that `I ⊆ (t, s)`, so the `U`-hypothesis already covers it and no appeal is
        needed. Lemma 7 is genuinely consumed in forward cases 2 and 5 and backward cases 2, 3
        and 5 — five of the thirteen.
  - [x] **Pick the gap-crossing lemma deliberately.** Three (four with the past mirror) coexist and
        differ only in their preconditions — see the family table in Preserved Assets. Phase 20
        found by measurement that Lemma 7 licenses **neither** of the first two. **Do not assume
        the unbounded form.** State in the summary which was used and why. **Resolved by not
        touching the family at all**: this module consumes `reynolds_lemma7`'s four landed halves
        and nothing below them, so the choice among `false_of_holds_throughout_class`,
        `..._bounded`, `..._from_bounded` and `..._upto_bounded` was already made *inside* Lemma 7
        and re-making it here would have been re-deriving Lemma 7. No Prior axiom is applied
        anywhere in the owned file outside the four `reynolds_lemma7_*` calls. Recorded explicitly
        in the module header under *"The gap-crossing family: which form this module uses"*.
  - [x] **If a `λ`-side mirror is needed anywhere in this phase and Phase 20.4 has landed**, obtain
        it by instantiation at `(dual M, dualize ε)` through `Dual.lean` at ~25 lines. **Do not
        hand-write a third mirror.** **Done — no hand-written mirror.** `S(A,B)` is
        `reynolds_lemma8_untl_forward` / `_backward` instantiated at `(dual M, dualize ε)`.
        *(deviation: widened — ~110 lines, not ~25. Two bridges were missing and had to be built:
        `temporalTruth_iso`, the `TemporalTruth` lift of `Dual.lean`'s `eval_iso` via
        `table_correctness`, which `Dual.lean` stopped one step short of; and `surgeredDualIso`,
        the commutation of `surgeredStructure` with `dual`, on the exact model of
        `subintervalDualIso`. Both are new declarations in the owned file; nothing in `Dual.lean`
        or `BadIntervals.lean` was edited, renamed or weakened. `temporalTruth_iso` is stated for
        an arbitrary `StructIso` and is reusable.)*
  - [x] Compare against the landed `truth_transfer` (`Transfer.lean:361`) and reuse whatever
        transfers; record what does and does not. **Nothing transfers, and the reason is
        recorded in the module header.** `truth_transfer` is an Ehrenfeucht-Fraïssé argument: it
        moves an *existentially closed* formula between two `k`-equivalent structures via
        `table_correctness`, concluding *"`ψ` holds at **some** point of `N`"*. Lemma 8 needs
        point-by-point agreement at a designated `t` between structures not assumed
        `k`-equivalent. Only `TemporalTruth` itself is shared. `table_correctness`, which
        `truth_transfer` uses, **is** reused — inside `temporalTruth_iso`.
  - [x] Docstring: `Reynolds 1992, §6 Lemma 8, printed pp.181-182` (**corrected in v9** from
        v8's pp.179-180 — see the measured §6 page map), with the case numbering preserved so a
        reader can check the transcription case by case. Verify any **displayed** formula against
        the page image before transcribing. **Both pages read as images at 200 dpi**
        (`pdftoppm -f 17 -l 18`): PDF p.17 carries the printed running header **181** and PDF
        p.18 carries **182**, confirming the `+164` §6 offset and v9's corrected range. The one
        displayed formula in Lemma 8 (`M ⊨ A(t) iff N ⊨ A(t)`) was checked against the image and
        is **clean** in the corpus markdown; the thirteen case bodies were compared line by line
        against both images and agree with the corpus prose (only *"Straight forward"* /
        *"Straightforward"* differs, which is typesetting).
  - [x] Carry the standing conditionality caveat: §6 below Lemma 2 is conditional, with no live
        non-trivial instance until Phase 22. Carried verbatim in the module header under
        *"Honest caveat on conditionality"* and repeated in `reynolds_lemma8`'s own docstring.
  - [x] `#print axioms`; scoped build green; full `lake build` green. `reynolds_lemma8` axioms:
        `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. Scoped build green (1246 jobs);
        full `lake build` green (1939 jobs).
- **Estimated output**: ~500 lines. **Actual: 806 lines** — 1.6x, the same direction as Phase 20's
  overrun though a much smaller factor. The excess is the module header's verbatim transcription
  of both printed pages plus the `S`-mirror bridge that came in at ~110 lines rather than ~25.
- **Scope Hypothesis**: *"thirteen cases"* and *"~500 lines"* are hypotheses taken from the source
  and from the discrete precedent. Confirm at implementation time by enumerating the cases actually
  printed on pp.181-182 off the page image, and by recording the actual line count. Phase 20's
  ~400-line estimate came in at 1343 lines; treat this one with the same suspicion.
- **Done when**: Lemma 8 is sorry-free and axiom-clean with all thirteen cases discharged (no case
  closed by hand-waving, no case merged without a stated reason).
- **Depends on**: **Phase 20's landed content only** — specifically `reynolds_lemma7` (both sides)
  and the bad-interval vocabulary. **NOT on Phase 20.4**, and not on Phase 20's `[PARTIAL]` marker
  clearing. This is a checked claim: `reports/08` read `reynolds_lemma7` and confirmed it, and the
  first task above is the falsification hook if it is wrong.
- **Timing**: 9 hours.
- **Verification Tier**: full.
- **Decomposition protocol**: as Phase 18 — the `U`/`S` and forward/backward boundaries are both
  clean seams.

### Phase 22: Reynolds §6 Lemma 9 and Theorem 4 — D1 [COMPLETED]

> **DISPATCH REDIRECT (v10).** This heading is the first match for the orchestrator's phase scan,
> but **there is no work left inside Phase 22's own territory**. Lemma 9 and both halves of Theorem
> 4 are landed, sorry-free, axiom-clean and committed; the full `lake build` was green at 1940
> jobs. Its two residuals — **F1** (the `HasBadIntervalSurgery` discharge) and **F2** (the chronicle
> anti-vacuity instantiation) — are both blocked on work outside this phase's `Owns` list and are
> **chartered in full as Phase 22.1 below**.
>
> **A dispatch landing here executes Phase 22.1's charter, not this one.** Phase 22 closes as
> `[COMPLETED]` when and only when Phase 22.1 closes; mark both in the same postflight. Phase 22
> stays `[PARTIAL]` rather than `[COMPLETED WITH EXCLUSIONS]` because residual work genuinely
> remains and is handed off — condition 5 of the exclusion admission test fails, correctly. This
> reuses the mechanism v9 established at Phase 20 → Phase 20.4.

- **Goal**: **D1.** *"In fact there can't have been any bad points anyway"* (Lemma 9), hence
  *"Suppose that `∼` is a contemporaneous equivalence relation on a Prior structure `M`. Then the
  `∼`-classes do not end at gaps"* (Theorem 4).
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/NoGaps.lean` (new).
- **Tasks**:
  - [x] **MEASURED: pp.182-183.** Both pages read as 200 dpi images
        (`pdftoppm -f 18 -l 19 -r 200`). PDF p.18 carries the printed running header **182** and
        holds the whole of Lemma 9, statement and proof; PDF p.19 carries **183** and opens with
        the statement of Theorem 4, immediately followed by §7 *"Separability"*. The `+164` offset
        and the extrapolation both hold; v8's `pp.180-181` was wrong. One measured corpus
        divergence recorded: the image spells *"appropraite"*, which the corpus markdown silently
        normalizes to *"appropriate"*. No **displayed** formula occurs anywhere in Lemma 9 or
        Theorem 4 — the whole of both is inline prose. Original task text:
        **Measure Lemma 9 / Theorem 4's printed page, first task (v9).** This is the one §6 row
        whose page the measured map (printed = PDF page + 164) only lets us **extrapolate**:
        `≈pp.182-183`, flagged UNVERIFIED in the Source-to-Implementation Mapping. Read it off the
        page image at 200 dpi, not from `pdftotext`, and record the result — exactly as Phases 18,
        19 and 20 each had to. **Do not copy `p.180` or `pp.180-181` out of the task text below**;
        those are v8's unmeasured figures, retained only so the correction is visible.
  - [ ] **NOT ACHIEVED — reported, not annotated away.** §6 remains conditional and the caveat
        stays verbatim everywhere it is carried. Two of the three conditions are now precisely
        located: (a) the **structure** half is blocked by module direction, not by mathematics —
        `chronicleIsDensePriorSepStructure` exists but `ChronicleMonadicBridge` imports
        `WeakCanonical`, so the instantiation cannot live in this phase's `Owns` file and needs a
        new module downstream of both; (b) the **ε** half is unchanged, `epsTop` is still the only
        exhibitable `ε`; (c) a **third** condition was discovered — Theorem 4 additionally needs
        Lemma 6's first clause, see below. Original task text:
        **THIS PHASE IS WHERE §6 STOPS BEING CONDITIONAL.** Every §6 lemma below Lemma 2 is
        conditional on `IsContempEquivDense ε` plus Prior-U/Prior-S, and the only `ε` the tree can
        currently exhibit is `epsTop`, for which `EndsInGapOnRight` is empty — **so nothing in
        Phases 17-21 has a live non-trivial instance**. The anti-vacuity task below is what
        finally supplies one. Treat it as load-bearing, not as a formality.
  - [x] **DONE, sorry-free and axiom-clean.** `reynolds_lemma9`, transcribed from the measured
        printed **p.182** (not p.180). *"`N` is a Prior structure"* was stated as its own named
        lemma exactly as this task required — in fact as six: `priorUFormula` / `priorSFormula`
        render Reynolds' two schemes (printed p.168) as `Formula`s,
        `temporalTruth_priorUFormula` / `temporalTruth_priorSFormula` check the rendering against
        `SemanticPriorU` / `SemanticPriorS`'s bodies, and `surgeredSemanticPriorU` /
        `surgeredSemanticPriorS` transport them by Lemma 8. The formula-level route is forced: a
        direct semantic transfer would have to produce, from *"p holds at every point of N in
        (t,s)"*, the same about every point of **M**, and the points of `Q₀ ∖ I` are exactly the
        ones that fail. Original task text: Prove Lemma 9, transcribing printed p.180: by Lemma 8, `R` holds in `I` in `N`; by Lemma 2,
        `R` holds in *any* Prior structure exactly at points whose class ends in a gap, and `N` **is**
        a Prior structure (*"we still have all the instances of Prior-U/S continuing to hold as any
        counterexample point in `N` is also one in `M`"*); by contemporaneity of `ε`, `I` is in one
        `∼_N`-class; `R` true of that class makes it bounded above, so `Q⁺` is non-empty and by
        Lemma 6 begins with a point `q` at which `¬R` holds — so the class ends just before `q` and
        `R` cannot have been true. The step "`N` is a Prior structure" needs care in Lean: state it
        as its own named lemma.
  - [x] **LANDED BUT CONDITIONAL.** `no_gaps_dense_prior` (right end) and
        `no_gaps_dense_prior_left` (left end, by instantiation at `(dual M, dualize ε)` through
        `Dual.lean` — no hand-written mirror), both sorry-free and axiom-clean. *(deviation:
        altered — both carry a new named hypothesis `HasBadIntervalSurgery`, so Phase 29 can NOT
        yet consume them directly.)*
        **BLOCKER DIAGNOSIS CORRECTED IN v10 — the original is preserved below, verbatim and
        struck, because it would send the next dispatch to the wrong file.** The measured account
        (`reports/09` §1.2, §1.3, §4.3):
        - **Reynolds does NOT merely state the clause.** He gives a **five-paragraph proof** on
          printed p.180, with an explicit three-case analysis (a class unbounded below / beginning
          just after some `r ∈ M` / including its left end point) and an explicit Prior-U
          contradiction on a formula `B` true at times which are not left hand end points of their
          classes. The claim recorded in `NoGaps.lean:730-731` — *"his Lemma 6 states the clause
          and treats it as established"* — is **refuted against the page image**.
        - **Both halves of the clause are already LANDED in this tree.** *"`L` wherever `R`"* is
          `endsInGapOnLeft_of_endsInGapOnRight` (`BadIntervals.lean:615`, Phase 20); *"using mirror
          images"* is `endsInGapOnRight_of_endsInGapOnLeft` (`:1346`, Phase 20.4, by instantiation
          through `Dual.lean`).
        - **What is missing is the HYPOTHESIS DISCHARGE, not a theorem.** Both landed halves take
          an interval witness as an assumption and **nothing in the tree produces one**, on either
          side. The gap is therefore located at **Lemma 4's boundary case**, not at Lemma 6, and it
          is downstream of a one-symbol defect in Reynolds' own p.179 display — see the corrected
          "Rendering 1" note under Phase 20 and the charter of Phase 22.1.
        - **The fix is on the `ρ` side, not the `λ` side.** Build `exists_classInteriorToRInterval`
          from the repaired Lemma 4 and take the `λ` side by instantiation through `Dual.lean`.
          **Do not hand-mirror.**
        - **Superseded original text, kept visible**: *"The missing input is Reynolds' Lemma 6
          first clause, 'in any bad interval both `R` and `L` hold throughout' (printed p.180), and
          the obstruction was measured rather than guessed: `IsBadInterval.saturated` is stated
          over `IsBadPoint` (= `R ∨ L`), so the bad-connected component of a point is the only
          candidate satisfying it; but `IsBadIntervalSurgery.interior` demands
          `ClassInteriorToBadInterval`, which carries `R` **and** `L` throughout its segment;
          closing that gap is `L → R` at a point where only `L` is known.
          `endsInGapOnRight_of_endsInGapOnLeft` (`BadIntervals.lean:1346`) proves that implication
          but only from a `ClassInteriorToLInterval` witness, and producing that witness at a
          merely-`L` point is the missing clause. It is the same clause
          `reynolds_lemma6_right_endpoint` already carries as its `hbadR` hypothesis — one gap, in
          one place, in all three declarations. Everything else assembles from landed material
          (`reynolds_lemma4_no_last_class` gives the upper interiority witness,
          `reynolds_lemma4_no_first_class` the lower)."* **Two sentences of that are false**: the
          `ClassInteriorToLInterval` witness is not the thing to build, and
          `reynolds_lemma4_no_first_class` does not give the lower witness (it gives `R` on the
          **open** `(y,t)`; the structure demands the **closed** `[a,t]`). The rest — the
          `saturated` / `interior` analysis and the one-gap-three-declarations accounting — stands
          and is consumed by Phase 22.1 Step D.
  - [ ] **Anti-vacuity: NOT LANDED — blocked on module direction, reported not worked around.**
        `chronicleIsDensePriorSepStructure` lives in
        `BXCanonical/Chronicle/ChronicleMonadicBridge.lean:1053`, which **imports**
        `WeakCanonical`. This phase's `Owns` file is under `WeakCanonical/DenseModelSurgery/` and
        therefore cannot import it back without a cycle. The instantiation needs a **new module
        downstream of both**, which is outside this phase's territory; extending territory
        silently was declined. Even once landed it would discharge only the Prior-U/S hypotheses,
        leaving `HasBadIntervalSurgery` and the `ε` half — so it would not by itself retire the
        caveat.
        **CYCLE CLAIM CORRECTED IN v10; the CONCLUSION stands.** `reports/09` §5.1 computed the
        transitive closure over every `import` line in `FormalSystem/` outside `Boneyard/`:
        `ChronicleMonadicBridge` imports **specific** `WeakCanonical.*` modules
        (`Transfer`, `Table`, `IntegerModel.ReynoldsBridge`, `Bundle.TemporalCoherence`,
        `PriorDefsDense`, `Kamp.KPlusFaithful`, `PriorExpressivenessDense`) and the
        `BXCanonical.Chronicle.ChronicleToCountermodelBasic` module — **not** the `WeakCanonical`
        umbrella, and **zero** `DenseModelSurgery` modules. `NoGaps`'s closure contains **zero**
        `BXCanonical` modules. The two subtrees are import-disjoint; only the leaf aggregator
        `WeakCanonical.lean` sees both. So `NoGaps.lean` *could* legally import the bridge today —
        **and it still should not.** The real objection is **layering, not cyclicity**: the
        bridge's transitive closure is **280 modules**, and pulling that cone into the parametric
        §6 surgery layer would make a low-level module depend on the entire canonical-model
        construction. **The implementer reached the right conclusion through the wrong argument,
        and declining to extend territory silently was correct behaviour.** The new module is
        chartered as Phase 22.1's `ChronicleInstance.lean`.
  - [x] Docstrings carry `Reynolds 1992, §6 Lemma 9 and Theorem 4, printed pp.182-183` — the
        measured range, with both printed pages block-quoted verbatim in the module header and a
        proof-step → name map, as Phases 19-21 did.
  - [x] `#print axioms` on `reynolds_lemma9`, `no_gaps_dense_prior`, `no_gaps_dense_prior_left`,
        `surgeredSemanticPriorU/S`, `temporalTruth_priorUFormula/SFormula` and
        `surgeredContempEquiv_of_base`: all `[propext, Classical.choice, Quot.sound]`, no
        `sorryAx`. Scoped build green; full `lake build` green (**1940 jobs**, +1 over Phase 21's
        1939 — the new module).
- **Estimated output**: ~300 lines. **Actual: 742 lines** — 2.5x. The excess is the module header's
  verbatim transcription of both printed pages, the Prior-U/S scheme bridge (~230 lines, which the
  plan assumed rather than budgeted), and the closing conditionality section.
- **Done when**: Lemma 9 and `no_gaps_dense_prior` are sorry-free and axiom-clean, the chronicle
  instance is landed, **and the §6 conditionality caveat is retired from the module headers of
  `DenseModelSurgery/*` that it can now be retired from — with an explicit statement of which
  results are thereby discharged and which are not.**
- **OUTCOME (measured, not asserted)**: Lemma 9 and both halves of Theorem 4 are sorry-free and
  axiom-clean. The chronicle instance is **not** landed (module direction, above) and the §6
  conditionality caveat is **NOT retired** — it stays verbatim in every module header that carries
  it, and the new module's closing section `## Conditionality after Theorem 4` states exactly what
  is and is not established. Phase 22 is therefore `[PARTIAL]`. Two follow-ups, named precisely:
  **(F1)** Reynolds' Lemma 6 first clause, to discharge `HasBadIntervalSurgery` and `hbadR`;
  **(F2)** a new module downstream of both `BXCanonical/Chronicle` and
  `WeakCanonical/DenseModelSurgery` carrying the chronicle anti-vacuity instantiation.
  **v10: both are chartered together as Phase 22.1**, whose §3 pre-compiled route relocates F1's
  content from Lemma 6 to Lemma 4's boundary case.
- **Depends on**: 21.
- **Timing**: 6 hours (spent).
- **Verification Tier**: full.
- **BLOCK F CHECKPOINT**: D1 is the harder of Doets' two hypotheses and it is now available at the
  dense instance. Clean stopping point.

### Phase 22.1: Reynolds §6 Lemma 4's boundary case, and the discharge of `HasBadIntervalSurgery` [COMPLETED]

> **TRANSCRIBE, DO NOT RE-DERIVE.** `reports/09` §3 contains **239 lines of this phase's content
> already compiled green, sorry-free and axiom-clean** against the tree at this commit
> (`lake env lean`, Lean v4.33.0-rc1), with `#print axioms` returning exactly
> `[propext, Classical.choice, Quot.sound]` on `StepD.hasBadIntervalSurgery` and on a derived
> `no_gaps_dense_prior_unconditional`. **Read `reports/09` §3 in full before writing a line.** The
> five residual errors that route hit, and their fixes, are recorded in its §3.6 and reproduced
> below so this dispatch does not rediscover them. A dispatch that re-derives instead of
> transcribing is not following this charter.

- **Goal**: retire the `HasBadIntervalSurgery` hypothesis from `no_gaps_dense_prior` and
  `no_gaps_dense_prior_left`, and land the chronicle anti-vacuity instantiation. This closes both
  of Phase 22's named follow-ups, **F1** and **F2**, in one dispatch.
- **Owns**:
  - `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean` (**append-only**: new
    declarations beside the landed ones; nothing restated, renamed, reordered or weakened);
  - `.../DenseModelSurgery/BadIntervals.lean` (**append-only**);
  - `.../DenseModelSurgery/NoGaps.lean` (append-only, **plus the one permitted in-place edit**:
    the rewrite of the closing `## Conditionality after Theorem 4` section, task 6);
  - `.../DenseModelSurgery/ChronicleInstance.lean` (**new**);
  - one import line in `FormalSystem/Metalogic/WeakCanonical.lean`, following the precedent of
    `Defs.lean` (17), `Lemma34.lean` (18), `Lemma5.lean` (19), `BadIntervals.lean` (20),
    `Dual.lean` (20.4) and `NoGaps.lean` (22). **Keep the earlier import lines.**

**The source finding this phase rests on** (`reports/09` §1.3, verified against the 200 dpi page
image of printed **p.179**; the corpus display of this formula is corrupt and the image is
authoritative):

> ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))

With `y < z` **strict**, this is **false** at a point `x` of the first class of a maximal
`R`-interval bounded below by an excluded end point `r ∈ M`: the universal clause at `y := r`
demands `∃z` with `r < z < x` and `¬ρ(z)`, but `(r, x)` lies inside `x`'s own class where `ρ` holds
throughout, so no witness exists. The formula stays **sound** (true only in first classes) — the
direction Reynolds' own Lemma 4 proof needs — but its **conclusion** is then weaker than the
plain-English statement that Lemma 6's second paragraph goes on to consume. Reading the inner bound
as **`y ≤ z`** repairs it (at `y := r`, take `z := r`), and **Reynolds' proof goes through unchanged
for the repaired formula**.

**Two honesty constraints, binding on this phase and non-negotiable:**

1. **The defect is the SOURCE's, recorded as the source's under honesty-charter Rule 7.** The
   tree's transcription was **faithful and was the right thing to do**. `firstClassFormula`
   (`Lemma34.lean:785`) and `IsFirstClassPoint` (`:797`) are **Preserved Assets and are NOT
   modified** — the repaired variant lands **beside** them under different names. Rule 7 requires
   the docstring to quote the printed display verbatim before asserting anything about it, name
   the boundary configuration it fails on, and say which reading is the source's and which is this
   tree's. **Record this as a flagged deviation in the phase's deviation record** — it is not
   absorbed silently. **Fallback if the attribution is disputed** (`reports/09` §4.2 Attack 5):
   state the repair as this tree's rendering choice and cite Reynolds' Lemma 6 second paragraph as
   the evidence that the plain-English reading is the one he uses. **No code change either way** —
   the route depends only on the repaired lemma being *provable*, which is machine-checked.
2. **Do NOT repeat the claim that Reynolds asserts Lemma 6's first clause without argument.**
   `NoGaps.lean:730-731` says *"his Lemma 6 states the clause and treats it as established"*; that
   is **refuted** against printed p.180, where he gives a five-paragraph proof with an explicit
   three-case analysis and a Prior-U contradiction. **Both halves of the clause are already landed
   in this tree** (`endsInGapOnLeft_of_endsInGapOnRight` `:615`; `endsInGapOnRight_of_endsInGapOnLeft`
   `:1346`). What was missing is the **hypothesis discharge** — no producer of
   `ClassInteriorToRInterval` exists on either side. **That sentence in `NoGaps.lean` is corrected
   by this phase** as part of task 6.

- **Tasks**:
  1. [x] **Step A — the repaired Lemma 4**, in `Lemma34.lean`, **beside** the landed faithful
        transcription, which is not modified. Land `firstClassFormulaClosed`,
        `IsFirstClassPointClosed`, `firstClassFormulaClosed_eval`, `firstClassTemporalClosed`,
        `firstClassTemporalClosed_spec`, `isFirstClassPointClosed_congr`,
        `not_isFirstClassPointClosed`, `reynolds_lemma4_no_first_class_closed`. The docstring
        quotes printed p.179's display verbatim, states the boundary configuration it fails on, and
        attributes the defect to the source per constraint 1 above. **Note for the transcriber**:
        the scratch module re-declared `c2_one`/`c3_one`/`c3_two` as primed copies because they are
        `private` at `Lemma34.lean:375-381`; **the real edit does not need that** — Step A belongs
        in `Lemma34.lean`, where they are in scope.
        **`reynolds_lemma4_no_first_class_closed`'s proof is byte-for-byte the shape of the landed
        `reynolds_lemma4_no_first_class`** — that is the evidence that the repair is faithful to
        Reynolds' *prose* even though it deviates from his *display*, and it is why the same
        `false_of_holds_throughout_class` route closes it.
  2. [x] **Step B — `exists_classInteriorToRInterval`**, the producer this plan assumed and never
        chartered: `EndsInGapOnRight M ε t → ∃ a b, ClassInteriorToRInterval M ε a t b`. ~22 lines.
        **This is where the `≤` repair pays**: with the landed strict form, the lower witness gives
        `R` only on the **open** `(y, t)` while `ClassInteriorToRInterval.rThroughout` demands the
        **closed** `[a, b]`, and shrinking `a` into `(y, t)` fails in exactly the boundary case.
        Home file: `Lemma34.lean` or `BadIntervals.lean` — either is inside this phase's territory;
        record which was chosen.
  3. [x] **Step C — Lemma 6's first clause, hypothesis-free, both directions**, in
        `BadIntervals.lean` after `endsInGapOnRight_of_endsInGapOnLeft`:
        `endsInGapOnLeft_of_endsInGapOnRight'` (from Step B plus the landed Phase 20 theorem) and
        `endsInGapOnRight_of_endsInGapOnLeft'` **by instantiation at `(dual M, dualize ε)` through
        `Dual.lean`** — 6 lines, no hand mirror, the third successful use of the transport layer.
        ~22 lines total.
        **`Dual.lean` applies HERE and nowhere earlier in this phase.** Steps A and B have no
        `ρ`-side theorem to dualise; dualising a theorem that does not exist yields nothing.
  4. [x] **Step D — the discharge**, in `NoGaps.lean`: the `Btw` / `badComp` family
        (`btw_of_minmax`, `minmax_of_btw`, `btw_self`, `badComp`, `badComp_isBadInterval`,
        `badComp_right`) and `hasBadIntervalSurgery`. `Q` is the bad-connected component of `t`.
        ~110 lines. Then restate `no_gaps_dense_prior` / `no_gaps_dense_prior_left` **without** the
        hypothesis, **keeping the hypothesised forms as `_of_hasBadIntervalSurgery` variants** if
        any caller wants them (D11: land the new name beside an unweakened original; do not swap a
        binder and rename in one step).
        **The `interior` field is the hard part** and is where a re-derivation falls over
        (`reports/09` §4.2 Attack 3): it needs a **single** segment `[a,b]` that both straddles
        `p`'s class **and** contains a second arbitrary point `u` of the component. Extend the Step
        B witness by `min`/`max` against `u`, then pull the extension back into the component by
        convexity. The `left_out` and `right_out` branches need **different argument shapes** — see
        residual error 5 below. **If this is re-derived rather than transcribed, budget an extra
        hour.**
  5. [x] **F2 — `ChronicleInstance.lean`** (new), importing `…DenseModelSurgery.NoGaps` and
        `FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleMonadicBridge`; instantiate at
        `chronicleIsDensePriorSepStructure` (`ChronicleMonadicBridge.lean:1053`), whose `priorU`
        and `priorS` fields plug straight into the Step D conclusion.
        **There is no import cycle** — the two closures are disjoint (`reports/09` §5.1); the
        reason this is a *new* module rather than an import into `NoGaps.lean` is **layering**: the
        bridge's cone is 280 modules and the §6 surgery layer must not depend on the whole
        canonical-model construction. **Recommended home is `DenseModelSurgery/`** because the
        content is §6 material and Block F already owns that directory, so no territory boundary is
        crossed; the alternative `BXCanonical/Chronicle/ChronicleNoGaps.lean` has an identical
        import set and only the directory differs — record the choice either way. ~30 lines.
        **What this instantiation does and does not buy**: it retires the **structure** half of the
        standing caveat **at one named structure**. It does **not** supply `IsContempEquivDense ε`
        — that is Phase 25's deliverable (§8 Lemma 12) and `epsTop` remains the only exhibitable
        `ε`.
  6. [x] **Rewrite `NoGaps.lean`'s `## Conditionality after Theorem 4`** to the three-condition
        accounting: **one of three conditions fully gone** (`HasBadIntervalSurgery`), **one gone at
        a live structure** (Prior-U/S, via `ChronicleInstance.lean`), **one standing until Phase
        25** (`ε`). **DO NOT DELETE THE CAVEAT.** Halves one and two of the standing §6 caveat stay
        **verbatim** in every module header that carries them — `Lemma5.lean`, `BadIntervals.lean`,
        `Dual.lean`, `TruthTransfer.lean`, `NoGaps.lean`. In the same edit, correct the sentence at
        `NoGaps.lean:730-731` per constraint 2 above.
  7. [x] **`#print axioms`** on `reynolds_lemma4_no_first_class_closed`,
        `exists_classInteriorToRInterval`, `endsInGapOnLeft_of_endsInGapOnRight'`,
        `endsInGapOnRight_of_endsInGapOnLeft'`, `hasBadIntervalSurgery`, the restated
        `no_gaps_dense_prior` / `no_gaps_dense_prior_left`, and the `ChronicleInstance.lean`
        instantiation = exactly `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. Scoped
        build green; full `lake build` green.
  8. [x] **Declaration census (V1 pattern).** Every declaration present in `Lemma34.lean`,
        `BadIntervals.lean` and `NoGaps.lean` before the dispatch is still present after it with
        its conclusion unweakened. Record before/after counts. `no_gaps_dense_prior` and
        `no_gaps_dense_prior_left` are the only declarations whose signatures change, and they may
        only be **strengthened** (one hypothesis removed), with the hypothesised forms retained
        under the `_of_hasBadIntervalSurgery` names.
  9. [x] **Sorry census unchanged.** Exactly one live `sorry` outside `Boneyard/`, at
        `WeakCanonical/Transfer.lean:1242` — pre-existing, unrelated, **never to be attempted**.
        Locate it by name, not by trusting a line number carried in a brief. **Any sorries under
        `Decidability/Verified/Bridge/` belong to the concurrent effort: do not count them, do not
        touch them, do not stage them.**
  10. [x] **Regression canaries**: `#print axioms completeness_dense`, `completeness_discrete`,
        `countermodel_discrete_reynolds_v2` unchanged. No file under `Decidability/` or
        `Automation/` read for edit or staged. No task-number citations in any `.lean` file.

- **DEVIATION RECORD (Phase 22.1, as executed).**

  | # | Kind | What | Why |
  |---|---|---|---|
  | 1 | **Flagged deviation from the source** (mandated by constraint 1) | `firstClassFormulaClosed` reads Reynolds' Lemma 4 inner bound as `y ≤ z` where printed p.179 displays `y < z`. Recorded in the `Lemma34.lean` section docstring *"Lemma 4 at the boundary"*, which quotes the printed display verbatim, names the boundary configuration on which it is false, attributes the defect to the **source**, and states the fallback framing if the attribution is disputed | The strict display is false at points of a first class bounded below by an excluded end point `r ∈ M`. `firstClassFormula` / `IsFirstClassPoint` are **not modified**; the repaired variant lands beside them |
  | 2 | Placement, resolved | **Step B landed in `BadIntervals.lean`**, not `Lemma34.lean` | The charter allowed either. `ClassInteriorToRInterval` is defined at `BadIntervals.lean:422`, which is **downstream** of `Lemma34.lean` in the import DAG (`Defs → Lemma34 → Dual → Lemma5 → BadIntervals`), so `Lemma34.lean` was not actually available |
  | 3 | Placement, as recommended | **F2 landed at `DenseModelSurgery/ChronicleInstance.lean`** | §6 material, inside Block F's existing territory; no boundary crossed. `reports/09` §5.2's recommended home |
  | 4 | **In-place edit beyond the one permitted** | Two further docstring corrections in `NoGaps.lean`: the module header's *"adds a third condition"* paragraph, and the `## Theorem 4` section header's *"the input this tree cannot yet supply"* / *"the clause that is missing"* | Both became **actively false** the moment `StepD.hasBadIntervalSurgery` landed. Leaving them would have left the file asserting a standing gap that no longer exists. Prose only — no declaration touched |
  | 5 | Signature change, chartered | `no_gaps_dense_prior` / `no_gaps_dense_prior_left` lose the `HasBadIntervalSurgery` hypothesis; the hypothesised forms are retained under `_of_hasBadIntervalSurgery` | Task 4 and task 8 charter exactly this. Strengthening only; zero declarations removed; no external callers existed (verified repo-wide) |

- **SCOPE HYPOTHESIS, CONFIRMED AT IMPLEMENTATION TIME** (per the Scope Hypothesis bullet below):

  | Measure | Hypothesis | Actual |
  |---|---|---|
  | Total | ~415 across 4 files | **+628 / −48 across 4 files + 1 import line** (`git diff --stat` against `5bf191e9e`, scoped to `DenseModelSurgery/` and `WeakCanonical.lean`). Docstrings ran materially longer than estimated: the honesty-charter Rule 7 quotation block in `Lemma34.lean` and the three-condition rewrite in `NoGaps.lean` account for most of the excess. **The proof content itself matched the 239-line pre-compiled figure almost exactly** |
  | `Lemma34.lean` (Step A) | ~135 | +153, −0 (purely additive) |
  | `BadIntervals.lean` (Steps B+C) | ~85 | +76, −0 (purely additive) |
  | `NoGaps.lean` (Step D + rewrite) | ~195 | +335, −48 (the 48 deletions are the two rewritten prose sections plus the two renamed declaration lines) |
  | `ChronicleInstance.lean` (F2) | ~30 | 111 (whole new file) |
  | **Step A green in-file on first attempt (THE HARD GATE)** | gate may trip | **NOT TRIPPED — green first attempt, zero repairs.** Steps B+C and Step D were likewise green on the first attempt; F2 needed one repair (a missing `open` for `FrameClass` / `SetMaximalConsistent`, not a proof failure) |
  | Residual errors from §3.6 re-encountered | 5 recorded | **0** — all five were pre-applied from the charter's table, exactly as intended |

- **Residual errors already encountered on this route, with their fixes** (`reports/09` §3.6 —
  reproduced so this dispatch does not rediscover them; all five are mechanical):

  | # | Error | Fix |
  |---|---|---|
  | 1 | `Unknown identifier c2_one/c3_one/c3_two` | They are `private` at `Lemma34.lean:375-381`. **Not an issue for the real edit** — Step A lands in that file, where they are in scope. |
  | 2 | `firstClassFormulaClosed_eval` unsolved goal (`¬(z < y)` vs `y ≤ z`) | Add `not_lt` to the `simp only` set |
  | 3 | `unexpected identifier; expected '}'` on a multi-line structure instance inside `exact ⟨a, b, {…}⟩` | Use the anonymous constructor `exact ⟨a, b, ⟨hat, htb, hna, hnb, hR⟩⟩`; hoist `rThroughout` into a preceding `have` |
  | 4 | `le_refl` mismatch on `Btw t x x` | Needs `le_total t x`; factored out as `btw_self` |
  | 5 | `contemp_of_between` argument mismatch in the `right_out` branch | `hint.right_out (contemp_of_between hε M hint.lt_right.le (le_max_left b₀ u) hc)` — direct, **no** `contemp_trans`/`contemp_symm` wrapper. The `left_out` branch **does** need the wrapper; the two are not symmetric in this rendering |

- **Preserved Assets (this phase).** All work here is **additive**. None of the following may be
  restated, renamed, reordered or weakened:

  | Declaration | Why it is preserved |
  |---|---|
  | `firstClassFormula` (`Lemma34.lean:785`) | The faithful, symbol-for-symbol transcription of Reynolds' p.179 display. The repair lands beside it |
  | `IsFirstClassPoint` (`:797`) | Its correct semantic reading |
  | `reynolds_lemma4_no_first_class` | The landed strict-form result; the `_closed` variant is added, not substituted |
  | `reynolds_lemma4_no_last_class` | Supplies the **upper** interiority witness as-is, and Step B consumes it unchanged |
  | `reynolds_lemma4` | The assembled statement |
  | `endsInGapOnLeft_of_endsInGapOnRight` (`BadIntervals.lean:615`) | Lemma 6's *"`L` wherever `R`"*, landed in Phase 20; Step C consumes it |
  | `endsInGapOnRight_of_endsInGapOnLeft` (`:1346`) | Lemma 6's *"using mirror images"*, landed in Phase 20.4; Step C consumes it |
  | `reynolds_lemma6` (`:1322`) | The four-conjunct assembly. Its `hbadR` hypothesis becomes dischargeable; the declaration itself is untouched |
  | `reynolds_lemma9` (`NoGaps.lean`) | Landed in Phase 22, consumed unchanged |

- **THE HARD GATE (binding abort condition, not a suggestion — borrowed from Phase 20.4's R15
  pattern)**: **if Step A does not reproduce green in-file on the FIRST dispatch, stop and
  report.** Do **not** iterate on alternatives. Do **not** attempt the `L`-side hand mirror —
  `reports/09` §4.2 Attack 4 shows it is the wrong direction: there is no `ρ`-side theorem to
  dualise until Step B lands, and building the `L` side directly means hand-mirroring Lemma 4, the
  exact cost Phase 20.4's transport layer exists to avoid. On abort: land whatever of Step A is
  green (or revert it cleanly if none is), report `[PARTIAL]` with the exact failing goal state,
  and name the residual. **Tripping this gate is a chartered outcome, not a failure**; burning the
  dispatch on alternatives is the failure.
- **Estimated output**: **~415 lines across 4 files** — Step A ~135 with docstrings, Step B ~40,
  Step C ~45, Step D ~165, plus ~30 for the conditionality rewrite, plus ~30 for
  `ChronicleInstance.lean`. **239 of those lines are already compiled green in `reports/09` §3.**
- **Scope Hypothesis**: the ~415-line total, the 239-line pre-compiled figure, the four-file
  territory and the ~30-line F2 estimate are **hypotheses from `reports/09`'s measurement, not
  facts about this dispatch**. Confirm at implementation time by (i) recording actual `wc -l` /
  diff sizes per file; (ii) recording whether Step A reproduced green in-file on the first attempt
  (the gate); (iii) recording where Step B was placed and which home was chosen for
  `ChronicleInstance.lean`. A material divergence is reported in the summary, **never absorbed into
  an unchanged estimate**.
- **Done when**: `hasBadIntervalSurgery` is sorry-free and axiom-clean; `no_gaps_dense_prior` and
  `no_gaps_dense_prior_left` no longer carry the `HasBadIntervalSurgery` hypothesis, with the
  hypothesised forms retained; `ChronicleInstance.lean` instantiates at
  `chronicleIsDensePriorSepStructure`; `NoGaps.lean`'s conditionality section states the
  three-condition accounting **without deleting the caveat**; the `NoGaps.lean:730-731` sentence
  about Reynolds is corrected; tasks 7-10 recorded. **Phase 22 is marked `[COMPLETED]` in the same
  postflight.**
- **Depends on**: **22** (closed `[PARTIAL]`; its landed content is consumed unchanged), and on
  **this revision**. Blocks nothing currently scheduled — Phase 23 is explicitly not serialized
  behind it (see the wave map).
- **Timing**: 3 hours.
- **Verification Tier**: full. *(Step D changes the signature of a theorem Blocks G-I consume, and
  `ChronicleInstance.lean` introduces a new join point between two previously disjoint import
  cones; the tie-break-upward rule applies.)*
- **Commit Mode**: `per-substep`. Steps A, B, C, D, F2 and the conditionality rewrite are each
  independently green-able and are committed as they go — which is also what makes the hard gate
  cheap to honour, since a green Step A is banked before Step B is attempted.
- **Decomposition protocol**: as Phase 18. If Step D's `interior` field resists after the
  transcription, land Steps A-C (which are independently useful — the producer and the
  hypothesis-free Lemma 6 clause are consumed by nothing else that is blocked) and report
  `[PARTIAL]` naming `interior` as the residual. **Do not `sorry` it, do not weaken
  `HasBadIntervalSurgery`, and do not weaken `ClassInteriorToRInterval`.**

- **WHAT THIS PHASE DOES NOT CLAIM — binding, and stated here so no summary overstates it.** The
  standing §6 conditionality caveat is **NOT retired by this work**. Every §6 result below Lemma 2
  remains conditional on `IsContempEquivDense ε`; **`epsTop` is still the only `ε` this tree can
  exhibit**; `EndsInGapOnRight` is still **empty** for it; there is still **no live non-trivial
  instance**. What 22.1 removes is **one named hypothesis** — `HasBadIntervalSurgery`, the third
  condition, introduced by Phase 22 — and, **at one named structure**, the Prior-U/S half. **The
  `ε` half stands until Phase 25.** No §6 result may be described as discharged in any docstring,
  summary or handoff produced by this phase.

### Phase 23: Reynolds §7 Theorem 5 — D2 from `Axiom.sep` [COMPLETED]

- **Goal**: **D2.** *"Suppose that `M` is a Prior structure which also satisfies every substitution
  instance of axiom Sep. Then for every contemporaneous equivalence relation `∼` such that `M/∼` is
  densely ordered, `M/∼` has a dense set of singletons."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Singletons.lean` (new).
- **Tasks**:
  - [x] Prove that the classes are **closed intervals**, from Theorem 4 plus density: *"if a class has
        an excluded end point then this point is in the next class and this contradicts density"*
        (printed p.184). *(landed as `exists_rightEndPoint` and `exists_leftEndPoint`; the left half
        by order-duality transport through `Dual.lean`, not a hand mirror, which additionally
        required the new `quotientDenselyOrdered_dual`)*
  - [x] Prove Theorem 5, transcribing printed pp.184-185: with `c < d`, `c ≁ d`, `c` the right
        endpoint of its class, let `C` be true exactly at left endpoints of classes (**expressive
        completeness**, Phase 14); `C ∧ U(C,¬C)` never holds, so `¬K⁺(C ∧ U(C,¬C))` holds at `c`;
        `K⁺(C)` holds at `c`; Sep gives `K⁺(K⁺C ∧ K⁻C)` at `c`; some `e` between `c` and `d` has
        `K⁺C ∧ K⁻C` and must be in a class of its own. **Note (v8): `Axiom.sep` is stated with
        `Formula.kPlus`/`kMinus`; read it through Phase 10.1's bridge, cited by name.**
        *(deviation: altered — the page range is `p.184` alone, not `pp.184-185`; measured off the
        200 dpi images, see deviation #1 below. The "without loss of generality" was **discharged**
        rather than assumed, via `exists_rightEndPoint` applied to `c` itself.)*
  - [x] Land `dense_singletons_of_sep` — the D2 hypothesis of Doets' theorem.
  - [x] **Anti-vacuity**: instantiate at `chronicleIsDensePriorSepStructure` (Phase 16).
        *(deviation: altered — landed in the existing `ChronicleInstance.lean` rather than in a new
        module; purely additive, see deviation #3 below)*
  - [x] Docstrings: `Reynolds 1992, §7 Theorem 5, printed pp.184-185`, quoting *"We use expressive
        completeness here"* at the point where Phase 14 is consumed — that sentence is the reason
        Block D exists and the docstring should say so. **Reynolds' Lemma 10 (Sep's validity over
        real flows, printed p.184) is NOT re-derived**: `sep_valid` (`Soundness.lean:1601`) is landed
        and already stated at `ValidDedekindDense`. Phase 23 consumes `Axiom.sep`'s *derivability*
        side, exactly as Phase 16 does for Prior-U/Prior-S. *(deviation: altered — docstrings cite
        `printed p.184`; Lemma 10 is on `p.183`, not `p.184`. Both measured, see deviation #1.)*
  - [x] `#print axioms`; scoped build green; full `lake build` green.

**Phase 23 deviation record:**

1. **Page range corrected (source measurement).** The charter says Theorem 5 runs *"printed
   pp.184-185"* and puts Lemma 10 on p.184. Measured off the 200 dpi page images: §7 *Separability*
   **opens on p.183** directly beneath Theorem 4's statement, Lemma 10 and its whole proof are on
   **p.183**, and Theorem 5's statement **and entire proof fit on p.184 alone** — §8 *Doets'
   Theorem* also opens on p.184, so p.185 is already inside §8's preliminaries. The §6 offset
   (`printed = PDF 1-based + 164`) does carry over to §7 and was re-verified page by page across
   PDF indices 18-20; it was the charter's *content* attribution that did not carry. This is a
   plan error, **not** a source defect: no defect is claimed or repaired in §7. The §7 corpus chunk
   (`sec04_7-separability.md`) was compared sentence-by-sentence against both page images and is
   **clean** — Theorem 5 carries no displayed formulas at all, which is consistent with §6's
   finding that inline prose is reliable where displays are not.
2. **`SemanticSepOpen` restated rather than imported.** `SemanticSep` lives in
   `ChronicleMonadicBridge.lean`, whose transitive closure is ~280 modules; importing it would
   contradict the layering rule `ChronicleInstance.lean` records. The body is restated
   character-for-character in `Singletons.lean` as `SemanticSepOpen`. Nothing is removed or renamed
   (D11 respected). The definitional identity is **machine-checked, not asserted**:
   `chronicleMonadic_dense_singletons` passes `hpack.sep` (a `SemanticSep`) directly into a
   `SemanticSepOpen` argument, which elaborates only if the two are defeq.
3. **Anti-vacuity landed in `ChronicleInstance.lean`, not a new module.** The charter's `Owns` names
   only `Singletons.lean`. The chronicle instantiation went into the existing
   `ChronicleInstance.lean`, which is exactly the §6/§7-to-bridge join point Phase 22.1 created.
   The edit is **purely additive** (two new theorems plus header text; zero removals, zero
   signature changes to existing declarations).
4. **Second, independent vacuity recorded.** Beyond the standing `EndsInGapOnRight`-is-empty reason,
   Theorem 5's `epsTop` instantiation is vacuous because `QuotientDenselyOrdered M (epsTop sig)` is
   itself *unsatisfiable* on any structure with two distinct points. Stated in-file as
   `quotientDenselyOrdered_epsTop_vacuous` / `chronicleMonadic_dense_singletons_epsTop_vacuous`
   rather than left to be rediscovered.
5. **The §6 caveat is carried forward unweakened.** `Singletons.lean`'s header reproduces
   *"Honest caveat, carried forward"* verbatim and adds that Theorem 5 inherits every condition
   Theorem 4 stands on, plus Sep and plus density. **No §6 or §7 result is described as
   discharged.**
- **Estimated output**: ~300 lines.
- **Done when**: `dense_singletons_of_sep` and the closed-interval lemma are sorry-free and
  axiom-clean; the chronicle instance is landed.
- **Depends on**: 22.
- **Timing**: 6 hours.
- **Verification Tier**: full.
- **BLOCK G CHECKPOINT**: both of Doets' hypotheses, D1 and D2, are now available.

### Phase 24: Reynolds §8 Lemma 11 — countable + very good ⇒ good, at `ℝ`-intervals [COMPLETED]

- **Goal**: `goodDense`, `veryGoodDense` and *"If `N` is countable and very good then it is good"*.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/GoodDense.lean` (new).
  **`IntegerModel/GoodStructures.lean` is read, not edited.**
- **Tasks**:
  - [x] Define `RIntervalStructure sig` (the `ℝ`-interval analogue of `ZIntervalStructure`),
        `goodDense M` (`∃ R : RIntervalStructure sig, KEquiv sig k M (R.toOrdered sig)`) and
        `veryGoodDense M` (`∀ t < u`, `M|(t,u)` non-empty and good). **Genuinely new definitions, not
        instantiations.** The landed `good` (`:78`) is `∃ Z : ZIntervalStructure sig, …` and the
        landed `VeryGood` (`:86`) quantifies over **closed** `a ≤ b`; Reynolds' dense forms (printed
        p.186) use **open** intervals and strict `t < u`. Record the difference in the docstring; it
        is not cosmetic — the open/closed choice is what makes Lemma 11's `Σ_{i∈ℤ}(N|{aᵢ} + Rᵢ)` have
        flow isomorphic to `ℝ`.
  - [x] Prove Lemma 11, transcribing printed p.186: for `N` with no endpoints choose `aᵢ` (`i ∈ ℤ`)
        increasing and cofinal both ways; `N|(aᵢ,aᵢ₊₁)` is good, so take `Rᵢ ≡ₖ N|(aᵢ,aᵢ₊₁)` with an
        open real interval as flow; then `N ≡ₖ Σ_{i∈ℤ}(N|{aᵢ} + Rᵢ)`, whose flow is isomorphic to
        `ℝ`. Consume `doets_lemma_1_4` (`OrderedSum.lean:41`). Then the one- and two-endpoint cases
        by adding singleton structures.
  - [x] Docstring: `Reynolds 1992, §8 Lemma 11, printed p.186` (attributed there to `[8] lemma 6.4`),
        plus `ADAPTED-FROM: IntegerModel/GoodStructures.lean` naming the `ℤ` analogue (Reynolds Lemma
        14, printed p.190) and what changed. *(citation corrected to `pp.185-186`: re-measured off
        the 200 dpi page images, correction and its evidence recorded in the module header's
        "Corpus and page-measurement notes". Landed in sub-objective 24.1, not this dispatch.)*
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~380 lines.
- **Done when**: `goodDense`, `veryGoodDense` and Lemma 11 sorry-free and axiom-clean.
- **Depends on**: 22.
- **Timing**: 7 hours.
- **Verification Tier**: full.

### Phase 25: Reynolds §8 Lemma 12 — `ε(x,y)` defines `∼_M`, and the finite `γ`-set [COMPLETED]

- **Goal**: *"There is a monadic formula `ε(x,y)` which defines `∼_M` as a contemporaneous
  equivalence relation on the domain of any `M`. Furthermore, there is a finite set `{γᵢ}` of
  sentences such that `M` is good if and only if `M ⊨ γᵢ` for some `i`."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/EpsilonDense.lean` (new).
- **Tasks**:
  - [x] Define `∼_M` by Reynolds' three clauses (printed p.186): `a = b`, or `a < b` and `M|(a,b)`
        very good, or `b < a` and `M|(b,a)` very good. *(landed as `SimDense`)*
  - [x] Land the finite `γ`-set: *"There are only finitely many logically inequivalent maximal
        consistent conjunctions `γ` of sentences of quantifier depth `≤ k`"* — consume the tree's
        `NormalForm` / `nf_nvar_exist_all_depths` layer rather than rebuilding it, and record which
        declarations discharge finiteness. **Note the `hn : n ≤ 1` restriction inherited from
        Phase 14.**
  - [x] Define `ε(x,y)` verbatim from printed p.187, via `γ(z,t)` = relativization of `⋁γᵢ` to
        `(z,t)` and `γ'(z,t) = γ(z,t) ∧ ∃u(z<u<t)`. **This is already prepaid — instantiate, do not
        build.** Phase 19 landed relativization at **arbitrary arity** as `relativizeAt` / `evalOn`
        with the soundness theorem `eval_relativizeAt` (`Lemma5.lean`), of which
        `relativizeToClass` is only the sentence case. The two-variable `γ(z,t)` this task needs is
        covered by `relativizeAt` as it stands. Note the **open**-interval relativization, versus
        the closed `[z,t]` of the discrete Lemma 15.
  - [x] Prove `ε` defines `∼_M` and that `∼_M` is a contemporaneous equivalence relation, with the
        transitivity argument transcribed (the `a < t < b < u < c` case via `R₁ + R₂ + R₃`).
        *(deviation: altered — the three clauses are landed as the standalone theorems
        `simDense_equivalence` / `simDense_convex` / `simDense_contemporary` and bundled by
        `epsDense_isContempEquiv` at `[Countable M.carrier] [DenselyOrdered M.carrier]`, not as the
        `∀ M`-quantified `IsContempEquivDense (epsDense sig k)` structure. Reynolds' "any `M`" is
        not supportable: transitivity needs Lemma 11 (countability) and, at the boundary case, is
        outright **false** without density — a counterexample is recorded in the module header. Both
        hypotheses hold at Doets' theorem's `M`, so Phase 29's consumption is unaffected; see the
        handoff note for the one adapter Phase 29 must supply.)*
  - [x] Docstring: `Reynolds 1992, §8 Lemma 12, printed pp.186-187`, plus `ADAPTED-FROM` naming
        Lemma 15 (printed p.191) and the closed/open difference.
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~400 lines.
- **Done when**: `ε`, the `γ`-set, and both properties are sorry-free and axiom-clean.
- **Depends on**: 22. **Parallel-eligible with Phase 24** (disjoint files).
- **Timing**: 7 hours.
- **Verification Tier**: full.

### Phase 26: Reynolds §8 Lemma 13 and the `ℚ`-shuffle [COMPLETED]

- **Goal**: *"For any structure `M`, if there are no `∼_M` classes ending at gaps then they are all
  closed intervals"* (Lemma 13), and the shuffle `Σ_{t∈ℚ} π(t)` with its `≡ₖ` property.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/Shuffle.lean` (new).
- **Tasks**:
  - [x] Prove Lemma 13, transcribing printed p.187: classes are intervals; a class ending at an
        excluded point `b` would make `M|(c,b)` very good, which is the contradiction.
        *(deviation: altered — landed as `reynolds_lemma13_right`/`_left`/`reynolds_lemma13` with
        two hypotheses beyond the printed statement, `[Countable M.carrier]` and
        `[DenselyOrdered M.carrier]`. Reynolds' "for any structure `M`" does not survive the
        non-emptiness clause of his own `veryGoodDense`, and the very-good⇒good step is Lemma 11,
        which is stated for countable structures. Both are standing hypotheses of the theorem this
        feeds (printed p.185), so nothing downstream weakens; documented in the module's honesty
        charter notes.)*
  - [x] Define `Shuffle S π` for a finite set `S` of structures and `π : ℚ → S` dense in every
        interval (printed p.186), and prove it well defined up to isomorphism.
        *(deviation: altered — `shuffle` and `IsShuffleMap` landed as specified; "well defined up
        to isomorphism" landed only in its **reindexing** form, `kEquiv_shuffle_congr_orderIso`
        (invariance under any colour-preserving order isomorphism of `ℚ`) plus
        `kEquiv_shuffle_congr`. The full claim — that **any** two dense `π, π'` over the same `S`
        are related by such an isomorphism — is the colour-preserving Cantor back-and-forth, which
        Mathlib does not carry (`Order.iso_of_countable_dense` is uncoloured) and which no
        downstream phase consumes. Deferred as a named follow-up; see the module header's
        `FOLLOW-UP` note.)*
  - [x] Prove `M|(⋃I) ≡ₖ Σ_{q∈ℚ} σ(q)` for the density-of-`γᵢ` situation of the main proof, using
        `doets_lemma_1_4`. *(landed in two halves: `kEquiv_orderedSum_blocks` for the left-hand
        identity `M|(⋃I) = Σ_{E∈I} M|E`, and `kEquiv_shuffle_of_classIso` for the `≡ₖ`; assembled
        as `kEquiv_blocks_shuffle`. `kEquiv_orderedSum_reindex` /
        `kEquiv_orderedSum_of_orderIso` supply the `I ≃o ℚ` bridge `doets_lemma_1_4` lacks.)*
  - [x] Docstrings: `Reynolds 1992, §8 Lemma 13, printed p.187` and `§8 (the shuffle), printed p.186`.
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~350 lines.
- **Done when**: Lemma 13 and the shuffle's `≡ₖ` property are sorry-free and axiom-clean.
- **Depends on**: 24, 25.
- **Timing**: 7 hours.
- **Verification Tier**: full.

### Phase 27: The `ℝ`-extension of the shuffle, its Dedekind completeness and its countable dense subflow [COMPLETED]

- **Goal**: `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)` where `σ*` is `σ` extended by singletons at the
  irrationals; plus the flow `R` of `Σ_{r∈ℝ} σ*(r)` is dense, endpointless, **Dedekind complete**,
  and has a countable dense subflow.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` (new),
  `FormalSystem/Metalogic/WeakCanonical/BackAndForth.lean` (new, continuation dispatch),
  `FormalSystem/Metalogic/WeakCanonical/ColourOrders.lean` (new, continuation dispatch).
- **Tasks**:
  - [x] Define `σ*` (printed p.188): `σ*(i) = N_{γ₁}` for `i ∈ ℝ − ℚ`, where `γ₁` is a `γ` in `G`
        satisfied only by one-point structures. *(landed as `shuffleColourReal` with
        `shuffleColourReal_rat` / `shuffleColourReal_irrational`, plus `shuffleReal` for the sum
        and `isShuffleMapReal_shuffleColourReal` transferring Reynolds' density condition from
        `ℚ`-intervals to `ℝ`-intervals.)*
  - [x] **Land `doets_lemma_1_5` in live code** — the phase's centre of gravity. **Do not attempt
        Reynolds' one-line "another simple game argument" directly**; charter it against **Doets 1987,
        3.1.8**: *"if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then
        `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`"*, which reduces the claim to a `≡ⁿ` fact about the
        `Z`-coloured orders `(ℚ,…)` and `(ℝ,…)`. Consume `NEquivalence.lean`'s `KEquiv`/`kTypeOf`/
        `KType` apparatus for that fact, and `doets_lemma_1_4` (`OrderedSum.lean:41`) for the
        same-index-set case.
        **A statement template exists and must be re-stated, not un-archived**: the drafted
        `doets_lemma_1_5` at `Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean:58` sits behind
        `#exit` (line 41), uses the stale names `k_type_of`/`k_equiv`, and its body is `sorry`. Copy
        the *shape* into a live module under the live names `kTypeOf`/`KEquiv`, and **prove it**. Do
        not import `Boneyard`, and do not reintroduce the `sorry`.
        *(deviation: altered — the **statement** landed in live code as
        `ShuffleReal.lean`'s `doets_lemma_1_5`, under the live names `kTypeOf`/`KEquiv`, in
        Doets 3.1.8's coloured-index form (`colourSig`, `colourStructure`, `kTypeColouring`
        render `(I, {i | m(i) ⊨ σ})_{σ∈Z}` with `Z := KType sig k`), with no `Boneyard` import.
        The archived draft's own hypothesis was **not** copied: matching *sets* of realized
        k-types does not imply `≡ₖ` sums, since it ignores the order the types occur in; that is
        recorded at both `OrderedSum.lean`'s status block and the archive note. The **proof** is
        now landed too, as `MixedSum.lean`'s `kEquiv_orderedSum_of_kEquiv_colour`, of which
        `ShuffleReal.lean`'s `doets_lemma_1_5` is a one-line consequence. Sorry-free and
        axiom-clean; the former BLOCKER note below is retained as a record and marked resolved.)*
  - [x] Update the forward pointer at `OrderedSum.lean:20-22` and the archive note at
        `SingletonSorriedDecls.lean:19-24` — or, if editing them is out of territory, record in the
        summary that they are now stale. *(both edited in place; each now points at the live
        re-statement and records that the archived draft is superseded and unsound as stated.)*
  - [x] Apply `doets_lemma_1_5` to obtain `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`.
        *(deviation: altered — landed as `kEquiv_shuffle_shuffleReal`, sorry-free **given**
        `doets_lemma_1_5`, but carrying the `≡ₖ` fact about the two coloured index orders as an
        **explicit hypothesis** rather than discharging it. That fact — `(ℚ, σ)` and `(ℝ, σ*)`,
        densely coloured by the same finite palette, are `≡ₖ` — is the colour-preserving
        back-and-forth and is not in the tree. Carrying it as a visible hypothesis rather than a
        second `sorry` keeps what remains open readable from the statement.)*
  - [x] Prove Dedekind completeness of `R`, transcribing printed p.188: *"any subset bounded above
        intersects a last summand. Because the `γᵢ`'s say so the summands themselves are closed
        intervals of the reals so the supremum of the set exists in this class."*
        *(landed as `exists_isLUB_orderedSumReal` / `exists_isLUB_shuffleReal`, sorry-free and
        axiom-clean. The transcription adds the case Reynolds' sentence passes over — the
        supremum of the index set need not be met by the subset — and handles it with the
        summand's least element.)*
  - [x] Prove `R` has a countable dense subflow, transcribing printed p.188.
        *(landed as `exists_countableDense_orderedSumReal` / `exists_countableDense_shuffleReal`;
        density and endpointlessness landed alongside as `denselyOrdered_orderedSumReal`,
        `noMax_orderedSumReal`, `noMin_orderedSumReal` and their `shuffleReal` instances. All
        sorry-free and axiom-clean. Reynolds' choice of `γ₁` as a one-point colour is consumed
        exactly here, as the hypothesis that the irrational summands are subsingletons.)*
  - [x] Docstrings: `Reynolds 1992, §8, printed p.188` for each part, plus
        `ADAPTED-FROM: Doets 1987, 3.1.8` for the mixing argument, with a one-clause note that
        Reynolds asserts it without proof.
  - [x] `#print axioms`; scoped build green; full `lake build` green.
        *(all 13 sorry-free declarations depend only on `propext`, `Classical.choice`,
        `Quot.sound`. Scoped and full builds green. Census outside `Boneyard/` is
        `Transfer.lean:1242` plus the one tracked strategic sorry at `ShuffleReal.lean:201`.)*
  - [x] **Not in the original checklist, added**: anti-vacuity witness for the order facts —
        `pointStructure` / `pointFam` / `pointFam_hyps` / `pointFam_orderedSum_facts` exhibit one
        family satisfying every hypothesis of all five order lemmas simultaneously, so none of
        them is only vacuously instantiable.

**PROGRESS UPDATE** (Phase 27, continuation dispatch — second of the two open halves now closed):

The blocker below named two independent halves. **The second half is discharged.**
`kEquiv_shuffle_shuffleReal` no longer carries the `hcol` hypothesis; it takes the shuffle data
`hγ : γ₁ ∈ S` and `hσ : IsShuffleMap S σ` instead, and the coloured-order `≡ₖ` fact is proved.
Two new sorry-free, axiom-clean modules landed:

- `FormalSystem/Metalogic/WeakCanonical/BackAndForth.lean` — `BackForth`, the depth-indexed
  back-and-forth relation for an **arbitrary pair** of structures, with both bridge directions
  (`nfAgree_of_backForth`, `backForth_of_nfAgree`) and the characterization
  `kEquiv_iff_backForth`, plus `backForth_mono`. This generalizes machinery that existed only
  inside the ordered-sum proof and only for a shared index set: `BiCompat` / `sum_nf_lift_gen`
  (whose `_h_comp` argument is threaded but never consumed — the content is the generic EF
  lemma) and `component_extend_fwd` / `component_extend_bwd`.
- `FormalSystem/Metalogic/WeakCanonical/ColourOrders.lean` — now owns `colourSig`,
  `colourStructure` and `kTypeColouring` (moved out of `ShuffleReal.lean`), and adds
  `IsShuffleColouring` (Reynolds' density condition for an arbitrary index order) and
  `kEquiv_colourStructure`: **any two shuffle colourings over a common palette give `≡ₖ`
  coloured index orders, at every depth.** Proved by a colour-preserving back-and-forth whose
  matching step answers a new point by the density of its colour in the gap of the finite
  matched configuration. Nothing in it is specific to `ℚ` or `ℝ`.

Both halves are now closed. The first half is `MixedSum.lean` (this phase's final dispatch); the
record of how it was blocked, and of what the blocking analysis got right, is kept below.

**BLOCKER — RESOLVED** (Phase 27, first half; kept as a record):
- **Resolution**: `MixedSum.lean` builds the two-index invariant `Mixed` and discharges
  `doets_lemma_1_5`. The diagnosis below was correct about *what* was missing (the assembly
  bookkeeping, not the engine) and about the two refuted routes (shared-index `sum_nf_agree`,
  re-association). Two design choices made the bookkeeping tractable: the position-to-summand
  **link is a `Sigma` equality in the sum carrier**, never a transport of a summand element along
  an index equality; and every slot's environment carries the **same arity** as the position
  count, so a move extends every slot by exactly one entry — the touched slot by the real witness,
  the others by a junk move answered by their own strategy. Together these remove `CompData`'s
  `Fin (sz t)` reindexing and hence all of `build_bicompat`'s `NormalForm`-type `HEq` casts. The
  depth budget `d + n ≤ k` is what a freshly created slot needs: matched indices carry the same
  `k`-type, so their summands are `≡ₖ`, and `backForth_pad` spends `n` moves reaching arity `n`
  plus one for the real witness, leaving depth `d`.
- **What failed**: `doets_lemma_1_5` (`ShuffleReal.lean:226`) — the statement is landed under the
  live names, the proof is not.
- **What was tried**: routing it through the existing apparatus. `doets_lemma_1_4`
  (`OrderedSum.lean:41`) delegates to `KEquivalenceFramework.sum_preservation`, whose engine is
  `NEquivalence.lean`'s `sum_nf_agree` / `sum_lift_one_var` normal-form induction. That induction
  is written for a **shared** index set: at each quantifier step it matches a witness `⟨i, a⟩` in
  one sum with `⟨i, b⟩` in the other at the *same* `i`. Doets 3.1.8 needs the witness matched at a
  *different* index supplied by a coloured back-and-forth between two index orders. Re-association
  was also checked and does not avoid the argument: `Σ_{r∈ℝ} σ*(r)` is not a re-bracketing of
  `Σ_{q∈ℚ} σ(q)`, because a convex partition of `ℝ` into countably many blocks cannot have
  quotient order `ℚ` (`ℝ` is Dedekind complete and `ℚ` is not), so the index-relabelling bridge
  `kEquiv_orderedSum_of_orderIso` from Phase 26 does not apply.
- **Why stuck**: the *engine* is no longer missing — `BackAndForth.lean` supplies it. Applied to
  the hypothesis, `kEquiv_iff_backForth` turns `_hcol` into a depth-`k` strategy on the coloured
  index orders; applied to `kTypeOf`-equality of matched summands it supplies a depth-`k`
  strategy inside each matched pair; applied to the conclusion it reduces the goal to exhibiting
  a strategy on the sums. What remains is the *bookkeeping that assembles them*: the invariant
  carried down the induction must record, for each already-matched pair of indices `(i, j)`, the
  sub-tuple of environment positions lying in that pair of summands together with a strategy
  relating them — the two-index analogue of `NEquivalence.lean`'s `CompData` (`:333`) and
  `build_bicompat` (`:512`). Phrased through `BackForth` rather than through normal-form
  agreement it avoids `CompData`'s dependent `NormalForm`-type casts (the `convert … using 2`
  `HEq` blocks), which is a real simplification, but it is still phase-sized formalization in its
  own right rather than a gap in an otherwise complete proof.
- **What is needed**: a follow-up task, *"build the two-index analogue of `CompData` /
  `build_bicompat` over `BackAndForth.lean`'s `BackForth`, and discharge `doets_lemma_1_5`"*.
  The former second half (`hcol`) is **done** and no longer part of this.
- **Downstream**: Phase 29 consumes `kEquiv_shuffle_shuffleReal`, which is now **unconditional**
  (`#print axioms` reports `propext, Classical.choice, Quot.sound` and no `sorryAx`). **Phase 28**
  was never affected — it consumes only the four order facts.
- **Prohibited**: Do NOT resolve this with `def X := True`, a vacuous placeholder, or a new axiom.

- **Estimated output**: ~500 lines.
- **Done when**: **`doets_lemma_1_5` is landed in live code, sorry-free and axiom-clean, under the
  live names**; the mixing `≡ₖ`, Dedekind completeness, density, endpointlessness and separability of
  `R` are all sorry-free and axiom-clean; the sorry census outside `Boneyard/` is still exactly
  `Transfer.lean:1242`.
- **Depends on**: 26.
- **Timing**: 10 hours.
- **Verification Tier**: full.
- **Decomposition protocol**: as Phase 18 — `doets_lemma_1_5` and the three order-theoretic facts are
  a clean seam, and splitting there is the expected outcome if the `≡ⁿ` colouring fact resists.

### Phase 28: `orderIsoRealOfDedekindDenseSeparable` — the order characterization of `ℝ` [COMPLETED]

> **Confirmed absent from Mathlib.** `Order.iso_of_countable_dense`
> (`Mathlib.Order.CountableDenseLinearOrder`) gives Cantor's theorem for countable dense endpointless
> orders; for `ℝ` only *field*-theoretic uniqueness exists (`ConditionallyCompleteLinearOrderedField`,
> `Mathlib.Algebra.Order.CompleteField`). Reynolds asserts the order-theoretic form in one sentence
> (printed p.188): *"But then `R` being Dedekind complete, dense, without end points and with a
> countable dense subset must be isomorphic to the reals."*

- **Goal**: For a linear order `R` that is densely ordered, without endpoints, Dedekind complete
  (every non-empty bounded-above subset has a lub), and has a countable dense subset:
  `Nonempty (R ≃o ℝ)`.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/OrderIsoReal.lean` (new).
- **Proof skeleton (transcribe, do not re-derive)**:
  1. The countable dense subset `D ⊆ R` is itself densely ordered and without endpoints, and
     non-empty; so `Order.iso_of_countable_dense` gives `e : D ≃o ℚ`.
  2. Define `f : R → ℝ` by `f x = sSup (Rat.cast '' (e '' {d : D | (d:R) < x}))`.
  3. Monotone and injective by density of `D`; surjective by Dedekind completeness of `R` against
     completeness of `ℝ`; conclude `R ≃o ℝ`.
- **Tasks**:
  - [x] Land the hypothesis bundle as a named `structure` (dense, no endpoints, lub property,
        separable) with **Rule 6**'s "what this excludes" docstring paragraph.
        *(`IsRealLike`, six fields: `nonempty'`, `dense`, `noMax`, `noMin`, `lub`, `sep`. The
        Rule 6 paragraph names a separating witness for every clause — `ℤ` for `dense`, `[0,1]`
        for the endpoint clauses, `ℚ` and `(0,1) \ {1/2}` for `lub`, the long line for `sep` —
        and records that no field/topological/metric structure is assumed.)*
  - [x] Prove step 1 and land it as a named lemma.
        *(`nonempty_orderIso_rat_of_countableDense`: `↥D` inherits `Countable`, `DenselyOrdered`,
        `NoMinOrder`, `NoMaxOrder`, `Nonempty`, then Mathlib's `Order.iso_of_countable_dense`.)*
  - [x] Prove steps 2-3 and land `orderIsoRealOfDedekindDenseSeparable`.
        *(`cutSet` / `cutMap`, well-definedness via `cutSet_nonempty` + `cutSet_bddAbove`, the
        two one-sided bounds `cutMap_le_of` / `le_cutMap_of`, then `strictMono_cutMap` and
        `cutMap_surjective`, closed by `StrictMono.orderIsoOfSurjective`.)*
  - [x] **Anti-vacuity**: instantiate at `ℝ` itself and at one non-trivial example; if the only
        instance is `ℝ`, say so.
        *(Base case `isRealLike_real` + `nonempty_orderIso_real_real` in `OrderIsoReal.lean`.
        **Non-trivial example**: `nonempty_orderIso_real_shuffleReal` in `ShuffleReal.lean` — the
        flow of `Σ_{r∈ℝ} σ*(r)`, a lexicographic `Sigma` over `ℝ` with arbitrary summands, is
        `≃o ℝ`; and `nonempty_orderIso_real_shuffleReal_point` exhibits a concrete palette
        satisfying all six hypotheses, so that theorem is not vacuous either. This is the last
        sentence of Reynolds' printed p.188 paragraph, landed.)*
  - [x] Docstring per honesty charter Rule 4: the *statement* is `Reynolds 1992, §8, printed p.188`;
        the *proof* has **no source in the corpus** and is original work.
  - [x] Search Mathlib once more before writing (`loogle`, `leansearch`) and record the negative
        result in the docstring so a future reader does not repeat the search.
        *(`loogle "Nonempty (?a ≃o ℝ)"` → **zero results**; `loogle "?a ≃o ℝ"` → only
        `Real.tanOrderIso`, `Real.sinhOrderIso`, `CircleDeg1Lift.toOrderIso`, i.e. specific
        isomorphisms, never a characterization. `leansearch` returned HTTP 502 and was not
        retried; the two `loogle` queries are decisive on their own. Recorded verbatim in the
        module docstring.)*
  - [x] `#print axioms`; scoped build green; full `lake build` green.
- **Estimated output**: ~350 lines. **Actual**: 335 lines (`OrderIsoReal.lean`, new) + 83
  appended to `ShuffleReal.lean`.
- **Done when**: `orderIsoRealOfDedekindDenseSeparable` is sorry-free and axiom-clean and the
  anti-vacuity instantiation lands.

**CLOSED.** `orderIsoRealOfDedekindDenseSeparable` and every helper is sorry-free, and
`#print axioms` reports exactly `[propext, Classical.choice, Quot.sound]` for it,
`isRealLike_real`, `nonempty_orderIso_real_real`, `strictMono_cutMap`, `cutMap_surjective`,
`isRealLike_shuffleReal`, `nonempty_orderIso_real_shuffleReal` and
`nonempty_orderIso_real_shuffleReal_point`. Sorry census outside `Boneyard/` unchanged at
exactly one (`Transfer.lean:1242`). The three regression canaries
(`BXCanonical.completeness_dense`, `BXCanonical.completeness_discrete`,
`WeakCanonical.countermodel_discrete_reynolds_v2`) are unchanged and sorryAx-free.

**Deviation from the `Owns` line, recorded rather than absorbed.** The phase owns
`RealModel/OrderIsoReal.lean` only. The non-trivial anti-vacuity instantiation was landed
**append-only in `RealModel/ShuffleReal.lean`** (Phase 27's file, `[COMPLETED]`, so no live
conflict) plus one added `import`. The alternative — importing `ShuffleReal` *into*
`OrderIsoReal` — would have inverted the layering and made the characterization module depend on
the whole Doets chain. `OrderIsoReal.lean` therefore imports **only Mathlib** and remains the
free-floating unit the wave map describes.

**FINDING for Phases 29-30, verified not assumed: `RealModel/**` is unreachable from the default
build target.** `lakefile.lean` sets `roots := #[FormalSystem]`, and nothing in the
`FormalSystem.lean → FormalSystem/FormalSystem.lean → Metalogic.lean →
Metalogic/WeakCanonical.lean` chain imports any `RealModel/*` module — `grep -rn '^import.*RealModel'`
matches only inside `RealModel/` itself. Measured consequence: full `lake build` runs **1983
jobs**, while `lake build FormalSystem.Metalogic.WeakCanonical.RealModel.ShuffleReal` runs
**2207**. So "full `lake build` green" does **not** cover Blocks G-H; the scoped builds are the
real verification, and both are green. This is a pre-existing condition from Phases 24-27, not
introduced here. **No aggregator was edited** — `Metalogic/WeakCanonical.lean` is in no phase's
`Owns` list and `FormalSystem/Metalogic.lean` belongs to Phase 30, which should add the
`RealModel` reachability edge when it updates the tracking table.
- **Depends on**: — (independent of Blocks D-G; **parallel-eligible from wave 2 onward**).
- **Timing**: 7 hours.
- **Verification Tier**: full.

### Phase 29: Doets' Theorem — Reynolds §8 Theorem 6 [PARTIAL]

**PARTIAL RECORD (Phase 29)**: `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean`
is landed, scoped build green (2234 jobs, `DenseModelSurgery.ChronicleInstance` as canary), full
build green (1983 jobs), and the file now contains **no `sorry` at all**. `doets_theorem_dense` is
landed with its final signature — `DoetsD1` / `DoetsD2` only, no extra hypothesis — and is
**sorry-free and axiom-clean**: `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. Phase 30
can consume it exactly as chartered.

**The phase remains `[PARTIAL]` for exactly one reason, and it is not the proof**: the anti-vacuity
checkbox (the chronicle instantiation) is still unmet, on the measured `surgeredStructure`
obstruction recorded below. That obstruction is outside this phase's territory. Nothing else is
outstanding.

- **What is proved, sorry-free**: `exists_realFlow_witness` (goodness normalized to flow `= ℝ`),
  `goodDense_of_orderIso_real` / `exists_realFlow_of_orderIso_real`, the whole Layer-3 `ℝ`-model
  transfer (`goodDense_shuffleReal`, `exists_realFlow_shuffleReal`, `goodDense_shuffle`,
  `exists_realFlow_of_kEquiv_shuffle`), the anti-vacuity witness
  `exists_realFlow_shuffleReal_point`, and `exists_not_simDense_of_not_goodDense` — printed
  p.187's *"`M` is not very good and so there are `a < b` with `a ≁ b`"*, both implications by
  Lemma 11 in contrapositive form.
- **The proof is complete, and there is no tracked sorry left in this phase.** All **five** sub-gaps
  the residual's docstring named across this phase's sub-dispatches are discharged, the fifth (the
  shuffle step) in sub-phase 29.6:
  - ~~(1) the `ε`-adapter~~ — **DONE (sub-phase 29.1)**. `IsContempEquivDenseCD` (`Defs.lean`) is
    the countable-dense bundle, `epsDense_isContempEquivDenseCD` (`EpsilonDense.lean`) discharges
    it sorry-free, `DoetsD1`/`DoetsD2` now take it, and `doetsD1_epsDense` / `doetsD2_epsDense`
    apply Reynolds' hypotheses at `∼_M` outright. All axiom-clean; `IsContempEquivDense.toCD`
    reports `[propext]` alone.
  - ~~(2) the minimization over the finite `γ`-palette~~ — **DONE (sub-phase 29.2)**, Layer 5 of
    `DoetsTheorem.lean`: `ClassStrictlyBetween`, `contempClassStructure`, `gammaBetween`
    (Reynolds' `G` at a pair), `mem_gammaBetween`, `gammaBetween_subset`,
    `exists_minimal_gammaBetween` (*"the following choice makes sense"*),
    `gammaBetween_eq_of_minimal` (*"by minimality of `G`"*) and `gammaBetween_dense_of_minimal`
    (*"all the `γᵢ`'s in `G` are satisfied densely in `I`"*). All sorry-free and axiom-clean.
    Rendering note recorded in the file: `G` is a `Finset (NormalForm sig k 0)` rather than a set
    of sentences, because `Finset.card` is the size measure and `nfToSentence`-injectivity is not
    part of what the argument uses.
  - ~~(3) the *"classes strictly between have order type `ℚ`"* step~~ — **DONE (sub-phases 29.3,
    29.4)**, Layers 6-7. The quotient is built: `IsConvexEquiv` (clauses (i)+(ii) at one
    structure), `ltPt_congr` (the well-definedness fact — two distinct classes are *totally*
    separated, the one essential use of convexity), `ClassQuot` with
    `instLinearOrderClassQuot` via `linearOrderOfSTO`, `ClassBetween` (Reynolds' `I` as an
    ordered type), the four order properties from `QuotientDenselyOrdered`, and
    `nonempty_orderIso_rat_classBetween` by `Order.iso_of_countable_dense`. Layer 7 then
    discharges that hypothesis *from D1*: `quotientDenselyOrdered_epsDense` is printed p.187's
    *"By lemma 13 and D1 … thus we have density of `M/∼`"*, and
    `nonempty_orderIso_rat_classBetween_epsDense` states the order-type-`ℚ` result at Reynolds'
    own `∼_M` with no abstract hypothesis left. All sorry-free and axiom-clean.
  - ~~(4) the assembly~~ — **DONE (sub-phase 29.5)**, Layers 8-10. `reynolds_theorem6_contradiction`
    now carries **no `sorry` in its own body**: it makes Reynolds' minimal choice, derives
    very-goodness of `M|(a,b)` as `SimDense` and so contradicts `a ≁ b` outright, reduces via
    `veryGoodDense_openSubinterval_iff` to goodness of each `M|(c,d)`, takes the `c ∼ d` branch by
    Lemma 11, and takes the `c ≁ d` branch through Layers 8-10. Sorry-free and axiom-clean in this
    dispatch: `goodDense_openSub_of_mid`, `goodDense_openSub_of_mid_le`,
    `exists_right_endpoint_class`, `exists_left_endpoint_class`, `endpoint_lt_endpoint`,
    `mem_openSub_endpoints_iff`, `classStrictlyBetween_epsDense_iff`.
    - **The prior record's step (3) was mis-sized, and the correction is recorded rather than
      quietly absorbed.** The three-summand decomposition was named *"the one genuinely missing
      ingredient"*; it is in fact **two nested applications of assets already in the tree** —
      `kEquiv_openSub_split` (`EpsilonDense.lean:858`) plus `goodDense_binSum_pointSum`
      (`EpsilonDense.lean:832`), the same `R₁+R₂+R₃` step §8 already used for transitivity of `∼`.
      It cost ~40 lines. `goodDense_openSub_of_mid_le` additionally discharges all four
      singleton/non-singleton combinations of `c'=c` / `d'=d`, which Reynolds' sentence passes over
      and which D2 makes the *generic* case rather than a corner case.
    - Step (2), the `ℝ`-extension and the flow, was correctly sized: it is application only, and it
      is reached through `goodDense_shuffle`, which is landed.
  - ~~(5) the shuffle step at `⋃I`~~ — **DONE (sub-phase 29.6)**, Layers 11-14.
    `goodDense_unionClasses` is sorry-free, so the whole chain up to `doets_theorem_dense` is.
    Twenty-eight new sorry-free, axiom-clean declarations, in four layers:
    - **Layer 11, the two-sided closed normalization** (`exists_max_of_kEquiv`,
      `exists_min_of_kEquiv`, `nfEvalNf_of_kEquiv`, `ordConnected_eq_Icc`, `IsIccLike`,
      `isIccLike_of_carrierSet_eq_Icc`, `exists_iccLike_witness`,
      `exists_icc_witness_of_subsingleton`, `subsingleton_of_carrierSet_eq_Icc_self`). The prior
      record's sketch for this item was **correct and was followed**, with one simplification: the
      `DenselyOrdered` transfer it called for is **not needed and could not have been used** —
      *"densely ordered"* is a depth-3 sentence and so does **not** travel across `≡ₖ` at `hk : 2 ≤ k`.
      Density comes for free instead, from `OrdConnected` in `ℝ`. Only the two end-point transfers
      are real, and both reuse the existing depth-2 `hasMaxSent`/`hasMinSent` machinery.
    - **Layer 12, the summands are the classes** (`kEquiv_restrictSet_openSub`,
      `kEquiv_openSub_restrictSet`, `veryGoodDense_contempClassStructure`,
      `goodDense_contempClassStructure`, `exists_max_contempClass`, `exists_min_contempClass`,
      `exists_iccLike_contempClass`). Two facts the prior record's sketch assumed without naming:
      that `M|E` is **good** (it is *very* good, because `x ∼ y` *is* very-goodness of `M|(x,y)` and
      convexity puts `(x,y)` inside `E`; Lemma 11 finishes), and that Layer 9's end-point
      construction applies at an **interior** class — run at `(e,d)` and at `(c,e)` rather than at
      `(c,d)`, which is what makes each summand closed on both sides.
    - **Layer 13, Reynolds' `σ`** (`trivialIccStructure`, `isIccLike_trivialIccStructure`,
      `classNF`, `classNF_spec`, `classNF_eq_of_nfEvalNf`, `contempClassStructure_congr`,
      `classNF_congr`, `classColour`, `classColour_cls`, `classNF_mem_gammaBetween`,
      `isShuffleMap_classColour`). The prior record was right that `σ` is forced, and right that
      `IsShuffleMap` is `gammaBetween_dense_of_minimal` along `e` — but it called this half
      *"bookkeeping"*, and one step is not. Minimality produces a class realizing `γ` inside *some*
      `≁`-pair; the shuffle needs it inside the pair **the two rationals name**. The bridge is
      Layer 9's end points run a second time, at the two classes `e.symm r` and `e.symm s`. That is
      why the class end points are needed twice over: once to close each summand and once to locate
      it. Recorded because the prior sizing understated it.
    - **Layer 14, the composition** (`exists_singleton_class_between`, `exists_iccLike_family`,
      `kEquiv_classBlock`, `goodDense_unionClasses`). `kEquiv_classBlock` is the one step of the
      composition Reynolds does not write at all: on paper `M | E` is one object, but the block map
      cuts the class out of `M | (c',d')` while the `γ`-palette cuts it out of `M`, and in Lean
      those are different types.
    - **Stale documentation corrected rather than left standing**: the module header's *"honesty
      charter"* claimed the `G`-minimality argument was carried as a hypothesis of a
      `doets_theorem_dense_core` that no longer exists, and
      `reynolds_theorem6_contradiction`'s docstring still asserted that `#print axioms` reports
      `sorryAx`. Both were false as of this sub-phase; both are fixed, and four source-map rows
      were added for Layers 11-14.
- **NEW OBLIGATION SURFACED, and deliberately not hidden.** Weakening D1/D2's antecedent is what
  made (1) closable, and it makes D1/D2 correspondingly *harder to discharge* — Phase 30's
  suppliers (`no_gaps_dense_prior`, `no_gaps_dense_prior_left`, `dense_singletons_of_sep`) all
  take the unrestricted `IsContempEquivDense`, and `toCD` runs the wrong way. Making §6 run on
  the countable-dense bundle was attempted and abandoned in that dispatch, with the abandonment
  recorded as a *measured irreducible failure*. **Both halves of that record were wrong, and the
  corrections are stated here rather than smoothed over.**
  - **The claim was false.** The record said `reynolds_lemma9` demands
    `DenselyOrdered (surgeredStructure M ε Q t).carrier`, that the surgered structure collapses a
    bad interval to a single class, and that by Lemma 4 (*"no first class in any maximal
    interval"*) it therefore has adjacent points and is not densely ordered. The premise is right
    and the conclusion does not follow: removing what lies below the surviving class `I` produces
    adjacency only if `I` has a **least element**, and Lemma 4 quantifies over **classes**, saying
    nothing about the points inside one. Lemma 6's first clause — supplied at every point of `Q₀`
    by `IsBadIntervalSurgery.interior` (`TruthTransfer.lean:218`) via
    `ClassInteriorToBadInterval` (`BadIntervals.lean:1023`), whose `.toR.rThroughout` (`:433`) and
    `.lThroughout` (`:1028`) are both halves — makes every point of `Q₀` an `R`-point and an
    `L`-point, and `exists_contemp_gt` (`Lemma34.lean:265`) / `exists_contemp_lt`
    (`BadIntervals.lean:1011`) then give class-mates strictly above and below every point of `I`.
    So `I` has no first and no last point, and no adjacency appears. **Both instances are
    provable and are now landed sorry-free** (sub-phase 29.7: `denselyOrdered_surgeredStructure`,
    `countable_surgeredStructure`, `NoGaps.lean`), so the vacuity fear the record cited is avoided
    by *deriving* the instances rather than hypothesizing them.
  - **The extent of the attempt was overstated.** The record says the instances were "propagated
    through Lemma34/Lemma5/BadIntervals/TruthTransfer/NoGaps". The reverted commit `3be9b82d8`
    touched **three** files — `Defs.lean`, `Dual.lean`, `Lemma34.lean` (113 insertions, 43
    deletions) — and its own message claims green for exactly those three: *"Defs, Lemma34 and
    Dual scoped-build green."* `Lemma5`, `BadIntervals`, `TruthTransfer` and `NoGaps` were never
    touched. The `reynolds_lemma9` failure was therefore **predicted from reading, never observed
    from a build**. That does not make the *localization* wrong — an independent audit confirms
    `NoGaps.lean:608` is the only site projecting clauses (i)/(ii) at a non-`M`, non-`dual M`
    structure — but the remaining propagation is real work still to do, chartered as sub-phase
    29.7's successor.
  - The design of the reverted commit is worth recovering: it split clause (i) into
    `refl`/`symm`/`trans` with the instances riding on `trans` alone, keeping
    `IsContempEquivDense.equiv` as a reassembling accessor so call sites read unchanged.
- **Anti-vacuity checkbox STILL NOT met**, and not faked. The chronicle instantiation is not
  landed. It is **no longer** gated on the `ε`-adapter — that is discharged — but it is now
  gated on the newly surfaced obligation above: instantiating the chronicle requires *discharging*
  D1/D2 at the chronicle structure, which needs §6 to run on the countable-dense bundle, which is
  exactly what was measured to fail at `surgeredStructure`. Closing it at `epsTop` would be
  vacuous by the plan's own caveat. `exists_realFlow_shuffleReal_point` is landed instead as an honest but
  *weaker* anti-vacuity witness: it exhibits the `ℝ`-flow conclusion shape at the constant
  one-point palette, so Layer 3 is demonstrably non-vacuous. It does **not** discharge the
  chronicle checkbox and is not presented as doing so.

- **Goal**: `doets_theorem_dense`: *"Suppose that `M` is a temporal structure in a finite language
  whose flow of time is countable, dense and without end points. Suppose further that for any
  contemporaneous equivalence relation `∼` on `M`, D1) the `∼` classes do not end in gaps and D2) if
  `M/∼` is densely ordered, then `M/∼` has a dense set of singletons. Then for all `k < ω`, there is a
  temporal structure with flow of time the real numbers satisfying the same monadic first-order
  sentences of quantifier depth at most `k` as `M` does."*
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` (new).
- **Tasks**:
  - [x] Assemble the proof, transcribing printed pp.187-188: if `M` is good, done. Otherwise by
        *(complete — sorry-free and axiom-clean as of sub-phase 29.6. The "if `M` is good, done"
        half is `exists_realFlow_witness`; "`M` not very good ⇒ `a ≁ b`" is
        `exists_not_simDense_of_not_goodDense`; the `ℝ`-passage is `goodDense_shuffle` /
        `exists_realFlow_of_kEquiv_shuffle`; the `G`-minimality contradiction that consumes them is
        `reynolds_theorem6_contradiction`; and the shuffle step it routes through is
        `goodDense_unionClasses` over Layers 11-14.)*
        Lemma 11 there are ≥ 2 `∼`-classes; by Lemma 13 and D1 there is a third between any two, so
        `M/∼` is dense and D2 gives density of singletons. Choose `a < b` with `a ≁ b` and `G`
        minimal; show `M|(a,b)` is very good, contradiction. For `a < c < d < b` with `c ≁ d`: the
        classes strictly between have order type `ℚ` and by minimality all `γᵢ ∈ G` are dense in `I`,
        so `M|(⋃I) ≡ₖ` a shuffle (Phase 26); extend to `ℝ` (Phase 27); the flow is `≅o ℝ` (Phase 28);
        and `M|(c,d) ≡ₖ X + R + Y` (Phase 24 + `doets_lemma_1_4`).
  - [x] Land the statement so Phase 30 can consume it with `D1 := no_gaps_dense_prior` and
        `D2 := dense_singletons_of_sep` at the chronicle structure. **No change of substance in
        v10**: once Phase 22.1 lands, `no_gaps_dense_prior` carries one fewer hypothesis
        (`HasBadIntervalSurgery` is discharged) and this consumption is direct, exactly as
        originally written.
  - [ ] **Anti-vacuity**: instantiate at `chronicleIsDensePriorSepStructure` (Phase 16) with the D1
        and D2 instances from Phases 22-23, and land the resulting `ℝ`-flowed structure as a named
        definition. This is the phase's real deliverable.
        **CAVEAT ADDED IN v10 — this checkbox still needs a live `ε`, and that is Phase 25's
        deliverable, not this phase's and not Phase 22.1's.** Phase 22.1's `ChronicleInstance.lean`
        discharges the **Prior-U/S** half at this very structure, but `IsContempEquivDense ε`
        remains a hypothesis: `epsTop` is the only `ε` this tree can exhibit and
        `EndsInGapOnRight` is empty for it, so an instantiation at `epsTop` is **vacuous** and does
        **not** satisfy the anti-vacuity gate. Reynolds' actual `ε` — the one that defines `∼_M` —
        is §8 Lemma 12, chartered as **Phase 25**. **This checkbox is therefore blocked on Phase 25
        as well as on 22-23**, and a dispatch that closes it at `epsTop` has not met the gate. The
        `Depends on` line below is unchanged (27 already depends on 26 → 25), so this is a citation
        of an existing edge, not a new one.
        *(deviation: NOT met — see the PARTIAL RECORD above, and note that this is now the phase's
        **only** outstanding item: the proof itself is sorry-free, so the checkbox is no longer
        coupled to any tracked sorry. It is gated on discharging `DoetsD1`/`DoetsD2` at the
        chronicle structure, which needs §6 to run on the countable-dense bundle.
        **The earlier record that this was blocked by an irreducible failure is retracted**: it
        claimed `DenselyOrdered (surgeredStructure M ε Q t).carrier` is false because the structure
        collapses a bad interval to one class and so has adjacent points by Lemma 4. That inference
        does not go through — Lemma 4 is about **classes**, and adjacency additionally needs the
        surviving class to have a least element, which Lemma 6's first clause rules out. The
        instance is **provable and landed sorry-free** (sub-phase 29.7). What is genuinely
        outstanding is the mechanical restatement of the §6 chain, chartered as sub-phase 29.7's
        successor and **outside this phase's territory** either way.
        `exists_realFlow_shuffleReal_point` remains landed as a weaker, honest substitute and is
        not claimed to discharge this checkbox.)*
  - [x] Docstrings: `Reynolds 1992, §8 Theorem 6, printed pp.185-188` and `Doets 1987, 3.3.9`, with
        Reynolds' own note that his statement is slightly stronger and his proof a little different
        because of the contemporaneity notion. *(landed verbatim on `doets_theorem_dense`, plus a
        source-to-implementation map in the module header.)*
  - [x] `#print axioms`; scoped build green; full `lake build` green. *(scoped
        `lake build …RealModel.DoetsTheorem …DenseModelSurgery.ChronicleInstance` green, 2234 jobs;
        full `lake build` green, 1983 jobs — the full build does **not** reach `RealModel/**`, per
        the Phase 28 reachability finding, so the scoped build is the load-bearing channel.
        **Every** declaration in the module, `doets_goodDense` and `doets_theorem_dense` included,
        now reports exactly `[propext, Classical.choice, Quot.sound]`. No `sorryAx` anywhere in the
        chain.)*
- **Estimated output**: ~400 lines.
- **Done when**: `doets_theorem_dense` and the chronicle instantiation are sorry-free and axiom-clean.
- **Depends on**: 23, 27, 28.
- **Timing**: 8 hours.
- **Verification Tier**: full.
- **BLOCK H CHECKPOINT**: an `ℝ`-flowed structure `≡ₖ`-equivalent to the chronicle model now exists.

### Phase 29.7: `Countable` and `DenselyOrdered` at the surgered structure [COMPLETED]

> **Numbering note.** The report that chartered this work suggested `22.2`, and the dispatch brief
> suggested `29.1`. Both collide: `### Phase 22.1` already exists as a real heading, and the
> Phase 29 body already uses *"sub-phase 29.1"* through *"sub-phase 29.6"* as informal labels for
> six prior dispatches within Phase 29 (`:4671` is the `ε`-adapter, `:4714` the shuffle step).
> Reusing either number would make those six provenance annotations ambiguous. `29.7` is the next
> free label in the same series, and it keeps this work filed where it belongs — with Phase 29's
> anti-vacuity checkbox, which it unblocks.

**Why this phase exists.** Phase 29's anti-vacuity checkbox was recorded as blocked by a *measured
irreducible failure*: that `DenselyOrdered (surgeredStructure M ε Q t).carrier` is **false**. That
record was wrong on both counts — the claim, and the extent of the attempt behind it. Both
corrections are written into the Phase 29 record above, into `DoetsTheorem.lean`'s D1/D2 section
header, and into `Defs.lean`'s countable-dense-bundle note. This phase's job is to **machine-check
the replacement claim before any wide mechanical edit depends on it**, because the five-case
density argument was the one load-bearing step in the escalation's route that was hand-verified and
explicitly not machine-checked (Medium-High implementation risk).

- **Goal**: land `DenselyOrdered (surgeredStructure M ε Q t).carrier` and
  `Countable (surgeredStructure M ε Q t).carrier` as **derived** results — never hypotheses — so
  that the one §6 site projecting clauses (i)/(ii) at a non-`M` structure (`reynolds_lemma9`) can
  be supplied its instances without making §6 Theorem 4 vacuous.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/NoGaps.lean` (additions only),
  plus the record-correction docstrings in
  `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean` and
  `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean`. The `DoetsTheorem.lean` edit
  is inside Phase 29's `Owns` and is **prose only** — it is the site that carries the retracted
  claim, so correcting it there is the whole point rather than a territory violation.
- **Tasks**:
  - [x] `endsInGapOnLeft_of_mem` — Lemma 6's first clause, `L` half, immediately after
        `endsInGapOnRight_of_mem`. The mirror three lines through
        `ClassInteriorToBadInterval.lThroughout` instead of `.toR.rThroughout`.
  - [x] `exists_contemp_gt_of_mem` / `exists_contemp_lt_of_mem` — the **point**-level statements
        that `I` has no last and no first point. This is the premise Lemma 4 does not supply,
        because Lemma 4 quantifies over **classes**; it is the exact gap in the retracted argument.
  - [x] `countable_surgeredStructure` — `Subtype.countable`.
  - [x] `denselyOrdered_surgeredStructure` — the five-case analysis on the two `SurgeryDomain`
        disjuncts of each endpoint: both in `I` (convexity); `x ∈ I` / `y ∉ Q₀` (no last point);
        `x ∉ Q₀` / `y ∈ I` (no first point); both outside straddling `t` (reflexivity at `t`); both
        outside on one side (an `M`-dense point is outside `Q₀` by convexity). The clauses of `hε`
        are projected **only at `M`**, so there is no circularity in using this to license the
        projection at `N`.
  - [x] `#print axioms`; scoped build green. *(All five declarations sorry-free;
        `denselyOrdered_surgeredStructure` reports exactly `[propext, Classical.choice, Quot.sound]`,
        no `sorryAx`. Scoped `lake build …DenseModelSurgery.NoGaps` green, 1247 jobs. Green on the
        first attempt — no goal-state failure to record.)*
  - [ ] `isContempEquivDenseCD_dualize` + the `Countable`/`DenselyOrdered` transfer at `dual M`.
        *(deviation: skipped — the dispatch brief authorized this only "if and only if it is needed
        to state or prove the above", and it is not: the density proof never touches `dual M`.
        Deferred to the successor phase, where it is genuinely needed. The finding it rests on is
        preserved: `Countable αᵒᵈ` has **no** named Mathlib instance, so it needs
        `inferInstanceAs (Countable M.carrier)`, the idiom already used at
        `ChronicleMonadicBridge.lean:375`; `OrderDual.denselyOrdered` does exist.)*

**Chartered design for the successor — Decision 1, settled and not to be relitigated.** The
successor phase restates the §6 chain so the instances above can be supplied. A straight in-place
CD restatement would narrow `no_gaps_dense_prior` and `dense_singletons_of_sep` from *"any Prior
structure"* to *"any countable densely-ordered Prior structure"*, tripping the Block D gate
(`:4944-4946`, "conclusion unweakened") and the Block F gate (`:4980`, "additions and
strengthenings only"). The user rejected both a gate waiver and a duplicated chain. The chosen
design is to **parameterize over a structure class**:

```
IsContempEquivDenseOn ε (C : OrderedMonadicStructure sig → Prop)
  with closure hypotheses:  C M → C (dual M)
                            C M → IsBadIntervalSurgery M ε Q t → C (surgeredStructure M ε Q t)

C := fun _ => True       recovers today's unrestricted results VERBATIM
C := countable ∧ dense   gives the CD results, closure discharged by this phase's declarations
```

Nothing landed is weakened and both gates pass by construction.

**Deliberately NOT in this phase.** The ~90-binder propagation across `Defs`, `Dual`, `Lemma34`,
`Lemma5`, `BadIntervals`, `TruthTransfer`, `NoGaps`, `Singletons` (plus `ChronicleInstance`) is
**not** chartered here and was not attempted — that is the whole point of proving the risky claim
first. It needs its own heading. **Landed since**: that heading is Phase 29.8 below, and the
propagation is complete; 29.8's measurement 1 also corrects this phase's guess about *which*
clauses need restricting. Likewise out of scope and untouched:
Phase 29's anti-vacuity checkbox, any part of Phase 30, and `StrongCompleteness.lean` (its four
signatures are pinned and the §6 repair is upstream of all of them).

**Consequence for the helpers' eventual reuse, stated rather than left implicit.** The five
declarations take today's unrestricted `hε : IsContempEquivDense ε`. Under `IsContempEquivDenseOn`
the successor will project the clauses at `M` and re-bind these signatures; the **proof bodies are
unaffected**, which is exactly what this phase was for. **Confirmed by 29.8**: all five were
re-bound with no proof-body edit, and `denselyOrdered_surgeredStructure` /
`countable_surgeredStructure` are exactly what `instIsSurgeryClosedCountableDense` is built from.

- **Estimated output**: ~120 lines (actual: 118 added to `NoGaps.lean`, plus ~35 lines of
  record-correction prose across two files).
- **Scope Hypothesis**: the density demand arises at exactly **one** site,
  `NoGaps.lean:608` in `reynolds_lemma9`; `NoGaps.lean:467`
  (`surgeredContempEquiv_of_base`) uses clause (iii), which is unrestricted in the CD bundle and so
  survives untouched. Every other `hε` projection in §6 is at `M` or at `dual M`. Confirmed by the
  escalation report's exhaustive audit of all 97 `hε : IsContempEquivDense` binders; **not**
  re-measured in this phase, since this phase changes no binder.
- **Done when**: both instances are landed sorry-free and axiom-clean as derived results, and the
  retracted claim is corrected everywhere it was recorded.
- **Depends on**: 20 (Lemma 6), 21 (Lemma 8's surgery set-up), 22.1 (the unconditional discharge of
  `HasBadIntervalSurgery`, which is what keeps `interior` from being an open assumption).
- **Timing**: 2 hours.
- **Verification Tier**: full.

### Phase 29.8: §6 on a parameterized structure class [COMPLETED]

> **Numbering note.** Successor to 29.7 in the same series; 29.7's record chartered this work as
> "Decision 1" and deliberately left the binder propagation out of scope.

- **Goal**: state the whole of §6 against an arbitrary structure class `C` rather than against
  either Reynolds' unrestricted reading or the countable-dense one, so that both instantiate from
  one chain. `C := UnrestrictedClass sig` recovers every pre-existing conclusion **verbatim**;
  `C := CountableDense sig` gives the CD forms Doets' theorem consumes, with the two closure
  obligations discharged by 29.7's `countable_surgeredStructure` /
  `denselyOrdered_surgeredStructure` and by the `dual` transfer.
- **Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/`{`Defs`, `Dual`, `Lemma34`,
  `Lemma5`, `BadIntervals`, `TruthTransfer`, `NoGaps`, `Singletons`, `ChronicleInstance`}`.lean`.
  Nothing outside that directory is touched — in particular not `StrongCompleteness.lean`, whose
  four pinned signatures are downstream of all of it, and not `RealModel/EpsilonDense.lean` or
  `RealModel/DoetsTheorem.lean`, which keep `IsContempEquivDenseCD` unchanged.
- **Tasks**:
  - [x] **Task 29.8.1**: `IsContempEquivDenseOn ε C` in `Defs.lean`, with clause (i) split into
        `refl` / `symm` / `trans` and `IsContempEquivDenseOn.equiv` as the reassembling accessor, so
        call sites read unchanged. Membership carried by a class, `InStructureClass C M`, so the
        quantifier lives on binder lines and no call site mentions it.
  - [x] **Task 29.8.2**: `UnrestrictedClass` and `CountableDense` as named classes with their
        membership instances, plus `countable_of_countableDense` /
        `denselyOrdered_of_countableDense` for the reverse translation.
        `abbrev IsContempEquivDense ε := IsContempEquivDenseOn ε (UnrestrictedClass sig)`, so the
        unrestricted name survives as a specialization rather than a separate structure.
  - [x] **Task 29.8.3**: `isContempEquivDenseCD_of_countableDense` (free) and
        `IsContempEquivDenseCD.toOn` (needs the two unrestricted halves, which `simDense_refl` /
        `simDense_symm` supply for the only `ε` §8 produces).
  - [x] **Task 29.8.4**: `IsDualClosed C` + `instInStructureClassDual` in `Dual.lean`;
        `isContempEquivDense_dualize` generalized to **preserve** `C` rather than change it.
  - [x] **Task 29.8.5**: `IsSurgeryClosed C` in `TruthTransfer.lean`, with the bundle quantified
        *inside* the field so one binder serves both `ε` and `dualize ε`.
        `instIsSurgeryClosedCountableDense` in `NoGaps.lean` derives it from 29.7's two theorems.
  - [x] **Task 29.8.6**: propagate the binders across the eight §6 files plus
        `ChronicleInstance.lean`, and supply the membership at `N` at the one site that projects the
        gated clauses there (`reynolds_lemma9`).
  - [x] **Task 29.8.7**: `section NoWeakening` in `ChronicleInstance.lean` — seven
        pre-parameterization signatures restated verbatim and discharged by direct application.

- **The gate question, and how it is answered.** Report 11 §2.2 records that a straight in-place CD
  restatement narrows `no_gaps_dense_prior` and `dense_singletons_of_sep` from "any Prior structure"
  to "any countable densely-ordered Prior structure", tripping the Block D gate ("conclusion
  unweakened") and the Block F gate ("additions and strengthenings only"). The user rejected both
  the gate waiver and the duplicate-chain alternative. The parameterization answers the gate by
  **strengthening**: each §6 theorem now quantifies over `C`, and the pre-existing statement is the
  `C := UnrestrictedClass sig` instance of it. The three class obligations
  (`InStructureClass`, `IsDualClosed`, `IsSurgeryClosed`) are all typeclasses with global instances
  at `UnrestrictedClass`, so recovery costs **no extra explicit argument** — which is what makes it
  verbatim rather than merely equivalent, and is checked by Task 29.8.7 rather than asserted.

- **Two measurements that came out better than the route predicted.**
  1. Report 11 §2.1 proposed restricting clauses (i) and (ii). Reading `EpsilonDense.lean` showed
     `simDense_refl` (`:136`), `simDense_symm` (`:140`), `simDense_convex` (`:199`) and
     `simDense_contemporary` (`:673`) carry **no** instance hypotheses and `simDense_trans` (`:988`)
     is the only one that does. So `refl` and `symm` are left class-free — which is what lets
     `contemp_refl` / `contemp_symm` stay class-free and what keeps the dual transport's own
     `refl`/`symm` branches from needing any closure hypothesis. Clause (ii) **is** gated, but not
     for `epsDense`'s sake: `isContempEquivDense_dualize` reconstructs clause (ii) at `N` out of
     clause (ii) *and transitivity* at `dual N`, so an ungated field there would have demanded
     `C (dual N)` at every `N`. Recorded at the field itself.
  2. Report 11's High-confidence claim that `reynolds_lemma9` is the **only** site projecting the
     gated clauses at `surgeredStructure` is **confirmed by the compiler**, not by a second audit:
     after the mechanical rename the build reported exactly one unsatisfied
     `InStructureClass C (surgeredStructure …)` obligation, at that site. No second site exists.

- **Cost, measured against the estimate**: the route estimated ~100-140 new lines plus ~90 binder
  edits across 8 files. Actual: 9 files, 569 insertions / 192 deletions, of which the binder
  propagation was ~60 declaration signatures reached by one scripted pass (declarations that do not
  bind the bundle are left alone — there `C` is undetermined and instance search is stuck, which is
  how the over-broad first pass was caught and narrowed).
- **Scope Hypothesis, retired**: the "one site" hypothesis 29.7 recorded is no longer a hypothesis;
  see measurement 2 above.
- **Done when**: full `lake build` green, the scoped build over `DenseModelSurgery.ChronicleInstance`
  + `RealModel.DoetsTheorem` green at its baseline job count, non-Boneyard sorry census unchanged,
  and the no-weakening block elaborating.
  **Met**: full build green (1983 jobs), scoped build green (2234 jobs, the same count 29.7 cites),
  non-Boneyard sorry census 1 at entry and 1 at exit (`Transfer.lean:1242`, pre-existing and
  unrelated), no new axiom, no vacuous definition, `StrongCompleteness.lean` byte-identical.
- **Depends on**: 29.7 (the two derived instances, which are what make the `CountableDense` surgery
  closure a *derived* result rather than a hypothesis — without them the parameterization would
  compile but §6 at the CD reading would be vacuous).
- **Timing**: 3 hours.
- **Verification Tier**: full.

- **Deliberately NOT in this phase**: Phase 29's anti-vacuity checkbox, any part of Phase 30, and
  `epsDense`'s own `IsContempEquivDenseOn (epsDense sig k) (CountableDense sig)` witness. The last
  is a one-liner over `simDense_refl` / `simDense_symm` / `epsDense_isContempEquivDenseCD`, but it
  belongs in `RealModel/EpsilonDense.lean`, outside this phase's `Owns`; `IsContempEquivDenseCD.toOn`
  names it as the remaining step and states its two inputs.

### Phase 30: Reynolds §9 Theorem 7 — the engine and the unconditional terminus [IN PROGRESS]

> **This phase absorbs v6's Phase 8.** Its precondition is the availability of `doets_theorem_dense`
> at the chronicle structure. **The `consequence_completeness_dedekind_of_engine` pinned signature
> and commit `bd9ae0ac1` carry over unchanged. There is no conditional terminus.**

- **Goal**: `countermodel_dedekind_dense`, `completeness_dedekind_engine`, and then — by instantiating
  the **pinned, unmodified** Phase 2 theorem — `consequence_completeness_dedekind` and
  `completeness_dedekind`.
- **Owns**: `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`,
  `FormalSystem/Metalogic/StrongCompleteness.lean`, `FormalSystem/Metalogic.lean` (tracking table).
- **Tasks**:
  - [ ] Define the **table** `α(t)` of a `Formula` and its quantifier depth, or verify that the tree's
        existing `tableMu` / `staviFoDepth` layer (`EFGames/StaviCompleteness.lean:237,462`) already
        supplies it; record which. Set `k` to one greater than the depth, per printed p.189.
  - [ ] Prove the transfer: `R ⊨ ∃t α(t)` from `M ⊨ ∃t α(t)` via `≡ₖ`, obtain `b ∈ R` with
        `R ⊨ α(b)`, hence `R ⊨ A₀(b)`.
  - [ ] Convert the `ℝ`-flowed monadic structure back to a `TaskFrame ℝ` + `TaskModel` + shift-closed
        `Omega`, using Phase 15's `multiFamTaskFrameGen` and siblings at `D := ℝ` (the `ℤ` originals
        at `ReynoldsBridge.lean:671,694,708` stay byte-identical), and land `countermodel_dedekind_dense
        {fc} (hfc : FrameClass.Dedekind ≤ fc) (A) (h_mcs) (φ) (h_neg_in) (h_box_dense) :
        ∃ (F : TaskFrame ℝ) (TM : TaskModel F) (Omega) (_ : ShiftClosed Omega) (τ) (_ : τ ∈ Omega)
        (t : ℝ), ¬TruthAt TM Omega τ t φ`. Follow `countermodel_dense_enriched`
        (`Completeness.lean:133`) statement-for-statement with `Rat → ℝ`. **Do not add any hypothesis
        beyond `hfc`.**
  - [ ] Prove `completeness_dedekind_engine (ψ : Formula) : ValidDedekindDense ψ →
        Derivable FrameClass.Dedekind [] ψ`: contrapositive, `neg_consistent_of_not_derivable`
        (`Completeness.lean:72`), `set_lindenbaum`, `dedekind_box_dense_mem`
        (`CompletenessDedekind.lean:149`), then `countermodel_dedekind_dense` at `ℝ` with
        `real_lub_of_bddAbove` (`:127`) discharging the lub binder and `by decide` discharging `hfc`.
  - [ ] Instantiate `consequence_completeness_dedekind_of_engine` (`StrongCompleteness.lean:274`) with
        this engine to obtain the unconditional `consequence_completeness_dedekind`. **Do not restate
        or re-bind that signature** — pinned by commit `bd9ae0ac1`.
  - [ ] Derive `completeness_dedekind (φ : Formula) : ValidDedekindDense φ →
        Derivable FrameClass.Dedekind [] φ` as `consequence_completeness_dedekind []`, with `simp`
        discharging `∀ ψ ∈ [], _`. **It must be a corollary, not an independent proof.**
  - [ ] Verify the root placement: the evaluation family's value at `t = 0` is the root MCS `A`,
        composing with `rooted_cantor_fmcs_dense_at_s` (`ChronicleToCountermodelBasic.lean:513`). A
        mismatch here is silent. Land it as a named lemma, not an inline `have`.
  - [ ] `#print axioms consequence_completeness_dedekind` and `#print axioms completeness_dedekind`;
        record. Regression: `completeness_dense`, `completeness_discrete`,
        `countermodel_discrete_reynolds_v2`.
  - [ ] Update the tracking table in `FormalSystem/Metalogic.lean` with the Dedekind rows, matching
        the existing `Completeness (dense)` / `(discrete)` row format at `:37`,`:39`.
  - [ ] Docstrings: `Reynolds 1992, §9 Theorem 7, printed p.189`, quoting the five proof steps, and
        `Reynolds 1992, §2, printed p.169` for the definition of weak completeness that makes the
        finite-context form fall out.
  - [ ] Full `lake build` green.
- **Estimated output**: ~450 lines.
- **Done when**: `consequence_completeness_dedekind` and `completeness_dedekind` are sorry-free; full
  `lake build` green; `#print axioms` on both shows exactly `[propext, Classical.choice, Quot.sound]`;
  the three regression axiom sets are unchanged; the tracking table is updated; the two frozen
  chronicle files are byte-identical.
- **Depends on**: 29 (and, through it, all of Blocks D-H).
- **Timing**: 8 hours.
- **Verification Tier**: full.

---

## Testing & Validation

Run at the end of **every** phase, not only at the end of a block:

- [ ] Scoped build green: `lake build <the phase's owned module>`.
- [ ] Full `lake build` green. If a full build is not achievable within the dispatch, the sanctioned
      fallback is a scoped build of the aggregator that transitively covers the phase's module — and
      **the fallback must be recorded honestly in the summary and handoff**, naming which build ran
      and which did not. A scoped build reported as a full build is a defect.
- [ ] Sorry census unchanged: `grep -rnE "^\s*sorry\s*$|:= sorry|by sorry|exact sorry" FormalSystem/
      --include=*.lean | grep -v Boneyard` returns exactly
      `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` **for this task's territory**.
      **v9 clarification — the census is territory-scoped, and a concurrent session shares this
      repository.** Two further live sorries at
      `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean:434,444` belong to the
      **concurrent decidability effort**, which owns `Decidability/` and `Automation/` under this
      plan's hard territory prohibition. They are not this task's to count, fix, or stage. Report
      them as out-of-territory if the grep surfaces them; **do not** treat their presence as a
      census regression, and **do not** silently widen the census to include them. Relatedly,
      `lake build` job counts drift between dispatches for reasons unrelated to this task — a
      changed job count is not by itself evidence of anything this task did.
- [ ] `#print axioms` on every load-bearing declaration the phase introduces = exactly
      `[propext, Classical.choice, Quot.sound]`. Record the results in the summary.
- [ ] **Regression canaries**: `#print axioms completeness_dense`,
      `#print axioms completeness_discrete`, `#print axioms countermodel_discrete_reynolds_v2` —
      unchanged. **Mandatory for every Block D phase**; recommended for all.
- [ ] **Frozen files byte-identical**: `git diff --stat` shows no change to
      `BXCanonical/Chronicle/ChronicleTypes.lean` or `.../ChronicleToCountermodelBasic.lean`. Also
      `ChronicleConstruction.lean`, `CounterexampleElimination.lean` and `cantorIsoDense`.
- [ ] **Amputated layer intact**: every module in the Amputated Assets table still compiles and is
      unmodified.
- [ ] **Territory respected**: no file under `FormalSystem/Metalogic/Decidability/` or
      `FormalSystem/Automation/` read for edit, modified, or staged.
- [ ] **No vacuous definitions**: every `Prop`-valued hypothesis the phase introduces has a witness,
      a derivation, or an exclusion lemma (the anti-vacuity gate). Record which.
- [ ] **Docstring audit**: every new declaration carries a source citation with a printed page (or,
      for the exhaustively named originals, the no-source statement). Any printed page landed in a
      docstring was re-verified against the PDF in this dispatch, or is flagged as carried.
- [ ] No task-number citations in any file outside `specs/`.

**Additional gates for every Block D phase (new in v8):**

- [ ] **Declaration census**: every declaration present in the phase's owned module(s) *before* the
      dispatch is still present *after* it, with its conclusion unweakened. A re-base that loses,
      renames away, or weakens a declaration has failed, not deviated. Record the before/after count.
- [ ] **Re-base strictness (anti-vacuity corollary)**: the shim from the old carrier to the new one is
      landed, **and** a structure is exhibited satisfying the new carrier and not the old.
- [ ] **CI-edge intactness**: every re-based module is still reachable from `FormalSystem.lean`
      through `NfMultiAnchorBridge.lean` (`:7-18`, `:238`, `:252`, `:275`, `:297`, `:320`, `:345`) or
      `WeakCanonical.lean`. A faithful module that falls out of CI rots invisibly.
- [ ] **`K⁺` spelling discipline**: no substitution between `Formula.kPlus` and `kplusFormula` (or
      their `kMinus` mirrors) except through Phase 10.1's bridge lemma, cited by name.
- [ ] **Comment-only edits verified**: where a phase's Tasks list says "comment bytes only",
      `git diff -U0` shows changes confined to `/-` … `-/` or `--` lines, and `#print axioms` on the
      affected declarations is unchanged.

**Additional gates for every Block F phase (new in v9):**

- [ ] **§6 page discipline**: every printed page cited in a docstring is taken from the measured
      map (printed = PDF page (1-based) + 164) or re-measured against the page image in this
      dispatch. Which one, per citation, is recorded.
- [ ] **§6 display verification**: any *displayed* formula transcribed from §6 was read off the
      page image, not from the corpus chunk and not from `pdftotext`. The standing §6 corpus
      defect count is **two, both displays** — if a phase finds a third, it records it and the
      count moves.
- [ ] **Gap-lemma family discipline**: any use of the `false_of_holds_throughout_class*` family
      names **which** of the four forms was used and why its preconditions are met. Assuming the
      unbounded form is a defect — Phase 20 established by measurement that Lemma 7 licenses
      neither of the first two.
- [ ] **Mirror discipline**: no new hand-written past/future mirror. Once `Dual.lean` exists
      (Phase 20.4), a §6 *"mirror image"* is obtained by instantiation at `(dual M, dualize ε)`.
      A phase that hand-writes a third mirror must state why the transport layer could not be
      used. The two existing hand mirrors (`BadIntervals.lean:968-1225`,
      `Kamp/Lemma53FaithfulPast.lean`) are Preserved Assets and are **not** refactored onto it.
- [ ] **Conditionality caveat carried**: until Phase 22 lands the chronicle instance, every §6
      module header and every phase summary states that the results are **conditional** with no
      live non-trivial instance. A summary calling a §6 result "discharged" before Phase 22 is a
      defect.
- [ ] **Zero removals, zero renames (D7, D11)**: no PIN-SIDE shim removed; no binder swapped and
      renamed in one step. `git diff` shows additions and strengthenings only, never a deleted or
      renamed declaration.

At Phase 30 additionally:

- [ ] `#print axioms consequence_completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms completeness_dedekind` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `FormalSystem/Metalogic.lean` tracking table updated.

---

## Artifacts & Outputs

| Artifact | Path | Produced by |
|---|---|---|
| This plan | `specs/408_.../plans/10_strong-completeness-dedekind-v10.md` | this revision |
| Superseded predecessor (retained) | `specs/408_.../plans/09_strong-completeness-dedekind-v9.md` | v9; carries the Revision Rationale (v8 → v9) and the Block F duality charter, both reproduced here unamended |
| Superseded predecessor (retained) | `specs/408_.../plans/08_strong-completeness-dedekind-v8.md` | v8; carries the Revision Rationale (v7 → v8) and the Block D charter, both reproduced here unamended |
| Superseded predecessor (retained) | `specs/408_.../plans/07_strong-completeness-dedekind-v7.md` | v7; carries the Revision Rationale (v6 → v7) and the Phases 9-10 execution record |
| **Blocker research grounding this revision** | `specs/408_.../reports/09_lemma6-first-clause-blocker.md` | `lean-research-hard-agent`, Tier 1 — **carries 239 lines of Phase 22.1 pre-compiled green in its §3** |
| Blocker research grounding the v8 → v9 revision | `specs/408_.../reports/08_lemma5-mirror-blocker.md` | `lean-research-hard-agent`, Tier 1 |
| Per-phase summary | `specs/408_.../summaries/08_phase-{N}-{slug}-summary.md` | each phase |
| Per-phase handoff | `specs/408_.../handoffs/phase-{N}-handoff-{DATE}.json` | each phase |
| Orchestrator handoff | `specs/408_.../.orchestrator-handoff.json` | this revision, then each phase |
| Dense Prior hypotheses | `WeakCanonical/PriorDefsDense.lean` | Phase 9 — **landed** |
| Guarded/trichotomy carriers + the refutation family | `WeakCanonical/Kamp/DedekindINFDense.lean` | Phase 10 — **landed** |
| Source-exact `K⁺`, the `Formula.kPlus` bridge, and the faithful dichotomy carrier | `WeakCanonical/Kamp/KPlusFaithful.lean` | Phase 10.1 |
| Faithful-carrier re-base | `WeakCanonical/Kamp/Lemma53Faithful.lean`, `Lemma53FaithfulPast.lean`, `Prop42Faithful.lean`, `Kamp/EANegationFixFaithful/*.lean` (in place) | Phases 11, 11.1, 12, 12.1, 13 |
| Dense expressive completeness | `WeakCanonical/PriorExpressivenessDense.lean` | Phase 14 |
| Dense monadic bridge | `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` | Phases 15-16 |
| Reynolds §6 (D1) | `WeakCanonical/DenseModelSurgery/*.lean` | Phases 17-22 |
| **The §6 duality-transport layer** (shared infrastructure; subsumes every remaining §6 *"mirror image"* at ~25 lines each) | `WeakCanonical/DenseModelSurgery/Dual.lean` | **Phase 20.4** |
| D16 closure (comment bytes only) | `WeakCanonical/PriorExpressiveness.lean` | **Phase 20.5** |
| **The repaired Lemma 4, the `ClassInteriorToRInterval` producer, and the `HasBadIntervalSurgery` discharge** (append-only into three files Block F already owns) | `WeakCanonical/DenseModelSurgery/Lemma34.lean`, `BadIntervals.lean`, `NoGaps.lean` | **Phase 22.1** |
| **The chronicle anti-vacuity join point** (the only module importing both `DenseModelSurgery` and `BXCanonical/Chronicle`) | `WeakCanonical/DenseModelSurgery/ChronicleInstance.lean` | **Phase 22.1** |
| Reynolds §7 (D2) | `WeakCanonical/DenseModelSurgery/Singletons.lean` | Phase 23 |
| Doets' theorem | `WeakCanonical/RealModel/*.lean` | Phases 24-29 |
| Terminus | `BXCanonical/CompletenessDedekind.lean`, `StrongCompleteness.lean`, `FormalSystem/Metalogic.lean` | Phase 30 |

Commit convention: `task 408 phase {N}: {objective}`, with a `Session:` line in the body, staging
only the task directory plus the files the phase's Tasks list names. `git add -A` and
`git commit -am` are forbidden.

---

## Rollback/Contingency

**Per-phase rollback.** Phases 10.1 and 14-30 each own a new module (Phase 30 extends two existing
ones); rolling one back is deleting its module and its aggregator import line, and no landed
mathematics is touched.

**Block D re-base rollback (new in v8, and the one place rollback is not a deletion).** Phases 11,
11.1, 12, 12.1 and 13 edit landed modules in place. Rollback is `git revert` of that phase's commit,
which is clean because (i) each phase owns a disjoint set of files, (ii) each ends with the tree
green and the canaries unchanged, and (iii) the change is a hypothesis weakening, so reverting
restores a state every supplier already satisfied. **This is why the phases follow the import chain
one boundary at a time rather than sweeping**: a partial sweep cannot be left green, and a sweep
that fails halfway cannot be reverted phase-wise.

**R1 is discharged.** v7's contingency for a Phase 10 failure is spent: the dense Prior axioms *do*
yield the eq (5.2) carrier, sorry-free and axiom-clean. That branch of the plan is closed.

**R11 contingency — the faithful-carrier bet.** v8's central planning bet is that the source-exact
`K⁺` collapses the trichotomy back to a dichotomy the existing consumers can take with a signature
swap. It is **falsifiable in Phase 10.1's probe** and again at the smallest consumer in Phase 11.
If falsified:

1. Phase 10.1 still `[COMPLETED]` — `kplusOpen`, the `Formula.kPlus` bridge and the two docstring
   corrections are real deliverables regardless.
2. Phases 11-13 re-base onto `HasDenseDedekindINF` instead, adding explicit endpoint branches at
   `Lemma53Faithful.lean:274`, `NegFixOneFaithful.lean:422` and `NegFixListFaithful.lean:446`.
3. **Those branches are new mathematics, not transcription**: `P(z₀)` supplies no infimum
   information, so each branch must derive what it needs from the ambient hypotheses. Each is
   labelled original glue under honesty-charter Rule 4, and each is split out under the R2
   decomposition protocol with its own `[PARTIAL]` report — **the cost is recorded, never absorbed
   into an unchanged estimate**.
4. Both carriers stay landed and the shims stay in place throughout, so the fallback is always
   available and never requires undoing work.

**R15 contingency — Phase 20.4's hard gate and the chartered hand mirror (new in v9).** Phase
20.4's route (a) bets that a duality-transport layer reproduces green in-file. **The bet is gated,
not assumed**, and the fallback is sized in advance so that tripping the gate costs a dispatch, not
a re-plan:

1. **The gate.** If **Group 1** does not reproduce green in-file on the **first** dispatch, route
   (a) is abandoned immediately. **Do not iterate on the transport layer; do not attempt both
   routes.** Land whatever of Group 1 is green (or revert cleanly if none is), report `[PARTIAL]`
   with the exact failing goal state, and name the two successor units below.
2. **The fallback, sized.** Route (b) is the hand mirror at a **measured** ~540-590 lines — v8's
   ~180-line figure sized only Chain 1 and omitted the deliverable. At that size it **exceeds the
   H8 one-agent-run bound and must be split**, at the natural file boundary:

   | Unit | Territory | Content | Measured residual | Timing |
   |---|---|---|---:|---:|
   | **Phase 20.6** | `DenseModelSurgery/Lemma5.lean` (append-only) | Chain 1 — `reynolds_lemma5_first_left` and its supports: `kPlusFormula`/`KPlusAt`/`_eval` (mirroring `:243-268`), `classRightEndKPlus…` + specs (mirroring `:271-378`), `exists_bound_notHolds` mirror (`:451-479`), `false_of_classInvariant_changes` mirror (`:510-582`), `reynolds_lemma5_first` mirror (`:591-627`). **`holdsSomewhereInClassFormula` (`:300-353`) is order-free and reusable verbatim on both sides**; `exists_contemp_lt` (`BadIntervals.lean:1005`), `endsInGapOnLeft_congr` (`:975`) and `false_of_holds_throughout_class_upto_bounded` (`:1027`) are **already landed** — do not re-derive any of the four | ~273 lines | 5 h |
   | **Phase 20.7** | `DenseModelSurgery/BadIntervals.lean` (append-only + the one `reynolds_lemma6` extension) | Chain 2 — the fourth half's own mirror chain: `NotRightEnd`/`notRightEndFormula`/`notRightEndTemporal` (mirroring `:332-375`), `not_endsInGapOnLeft_of_immediateSuccessor` (`:390-414`), `ClassInteriorToLInterval` (`:416-443`), `rightEnd_iff_exists_not_notRightEnd` (`:444-458`), `exists_rightEnd_throughout` (`:466-486`), `false_of_allClassesHaveRightEnd` (`:514-595`), `endsInGapOnRight_of_endsInGapOnLeft` (`:615-670`), then `reynolds_lemma6`'s fourth conjunct | ~271 lines | 5 h |

3. **Splicing.** These two are **not** chartered as `### Phase` headings, deliberately: if route
   (a) succeeds they must never be dispatched, and a `[NOT STARTED]` heading would eventually be
   picked up by the orchestrator's scan regardless. They are spliced in as headings **only** when
   the gate trips, under the R2/R3 decomposition protocol — the same mechanism by which v6's
   Phase 7.5 became 7.5-7.9 and v8's Phases 11-13 became 11, 11.1, 12, 12.1, 13.
4. **The cost is recorded, never absorbed.** Route (b) costs +5 hours over route (a) and produces
   no reusable duality layer, so Lemma 3's dual, Lemma 4's dual and every future §6 mirror stay at
   hand-mirror prices. That trade-off is stated so that a dispatch which trips the gate reports an
   honest schedule change rather than an unchanged estimate.
5. **Neither route needs a `sorry`, a vacuous definition, or a new axiom.** Route (a)'s Group 1 is
   sorry-free and axiom-free by construction (structural inductions and `Iff.rfl`). Nothing in this
   contingency licenses deferral.

**Phase 20.4 rollback.** `Dual.lean` is a new file; the `Lemma5.lean` and `BadIntervals.lean`
changes are append-only apart from the single `reynolds_lemma6` conjunct extension. Rollback is
`git revert` of the phase's commits: deleting the new file and its import line, and restoring
`reynolds_lemma6` to its three-conjunct form. **No landed mathematics is touched** — which is
exactly why the phase is chartered append-only rather than as a refactor of the existing mirrors.

**Phase 22.1 rollback and its gate (new in v10).** `ChronicleInstance.lean` is a new file; the
`Lemma34.lean`, `BadIntervals.lean` and `NoGaps.lean` changes are append-only apart from the single
rewrite of `NoGaps.lean`'s `## Conditionality after Theorem 4` section and the correction to its
`:730-731` sentence. Rollback is `git revert` of the phase's commits: deleting the new file and its
import line, dropping the appended declarations, and restoring `no_gaps_dense_prior` /
`no_gaps_dense_prior_left` to their `HasBadIntervalSurgery`-hypothesised forms — which the phase
retains under `_of_hasBadIntervalSurgery` names anyway, so no consumer breaks either way. **No
landed mathematics is touched**, which is why the phase is chartered append-only.

- **The gate.** If **Step A** (the repaired Lemma 4) does not reproduce green in-file on the
  **first** dispatch, stop and report `[PARTIAL]` with the exact failing goal state. **Do not
  iterate on alternatives, and do not attempt the `L`-side hand mirror** — `reports/09` §4.2 Attack
  4 establishes it is the wrong direction, and Phase 20.4 already paid for the transport layer that
  makes the `λ` side a 6-line instantiation *once the `ρ` side exists*.
- **There is no chartered fallback route, and that is deliberate.** Unlike Phase 20.4, this phase
  has no route (b): the 239 pre-compiled green lines in `reports/09` §3 *are* the verified route,
  and the only alternative anyone has proposed (hand-mirroring Lemma 4 on the `λ` side) is
  refuted. If Step A fails, the correct response is a new blocker report against the failing goal,
  not a second route improvised in-dispatch.
- **Nothing here licenses a `sorry`, a vacuous definition, or a new axiom.** The whole route is
  machine-checked at `[propext, Classical.choice, Quot.sound]`.

**Block-level contingency (R2, R3).** Any phase in Blocks D or F that on contact needs more than one
agent run lands whatever is green, records a named sub-phase list, and reports `[PARTIAL]`. The
orchestrator revises with the sub-phases spliced in at the same numeric level (flat numbering `N.1`,
`N.2`, … — the scan admits **at most one** dot segment, so three-level numbering would be invisible
to dispatch). This is the chartered outcome, not a failure, and it is how v6's Phase 7.5 correctly
became 7.5-7.9 and how v8's Phases 11-13 became 11, 11.1, 12, 12.1, 13.

**Budget contingency (R8).** Every phase ends with the tree green, the sorry census unchanged and the
frozen files byte-identical, so every phase boundary is a clean stop. Running out of budget yields
`[PARTIAL]` with a named next phase. The checkpoints — after Phases 13, 14, 16, 22, 23 and 29 — are
the natural reporting points, and each leaves a reusable result of independent value in the tree.

**Fallback route (recorded, not planned).** If Block D proves intractable, Reynolds' own proof of
Theorem 3 is available in principle: reduce to `{U,S,U',S'}` expressive completeness (Theorem 2 /
GHR93 Theorem 9.3.1) and show `U'(A,B) ↔ ⊥` in every Prior structure by applying Prior-U to `B`. The
tree's `stavi_U_false_on_prior_UZ` (`PriorExpressiveness.lean:90`) is exactly that argument at the
*integer* axioms and would mirror cheaply, and the whole Stavi layer (`StaviConnectives.lean`, 583
lines) is present and sorry-free. **The blocker is the other half**: `stavi_expressive_completeness`
**does not exist as a declaration anywhere in live code** — it survives only at
`Boneyard/StaviDiscretePath/StaviExpressiveCompletenessTail.lean:1674`, its chain top is
sorry-tainted, `EFGames/StaviCompleteness.lean:16` records it as "the dead expressive-completeness
tail", and `PriorExpressiveness.lean:30,350` records that the tree deliberately moved off it onto
`kampPriorExpressiveCompleteness`. Reviving a Boneyard module and discharging its sorry is strictly
more work and strictly less certain than the re-base. Recorded so a future dispatch does not
rediscover it as a novelty.

**What is never a contingency.** Re-opening completion-by-limits; stripping the amputated layer;
generalizing a landed discrete declaration in place; deleting or weakening a declaration in the
faithful subtree; cloning the faithful subtree to avoid a hypothesis weakening; a conditional
terminus; a strategic sorry on the terminus chain; an over-strong hypothesis that makes a theorem
pass vacuously; or substituting one `K⁺` spelling for the other without the bridge. **Added in
v9**: removing a PIN-SIDE shim (D7); swapping a binder and renaming in one step instead of landing
the new name beside an unweakened corollary (D11); re-opening D13; weakening `IsContempEquivDense`
to make clause (iii) transport; sorrying clause (iii); attempting routes (a) and (b) together;
iterating on the transport layer past the Group 1 gate; or hand-writing a third past/future mirror
once `Dual.lean` exists. **Added in v10**: modifying, renaming or "correcting" `firstClassFormula`
or `IsFirstClassPoint` in place instead of landing the repaired variant beside them;
hand-mirroring Lemma 4 on the `λ` side; deleting the standing §6 conditionality caveat rather than
rewriting it; describing any §6 result as discharged while `IsContempEquivDense ε` is still a
hypothesis; closing Phase 29's anti-vacuity checkbox at `epsTop`; or carrying a supply claim
(*"that is what Lemma N supplies"*) in a rendering note instead of chartering it as a task.
