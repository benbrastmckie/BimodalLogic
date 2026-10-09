# Research Report: Task #748

**Task**: 748 - Revise existing tasks and create new ones to move the L+ decidability programme forward
**Started**: 2026-10-09T15:56:47Z
**Completed**: 2026-10-09T16:40:00Z
**Effort**: ~0.8 hours (verification-dominated; no Lean elaboration, one sorry census, one gate run)
**Dependencies**: 747 (completed)
**Sources/Inputs**:
- In-tree Lean and documentation (primary authority): `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `.../RaySummary/Trace.lean`, `.../RaySummary/Compose.lean`, `.../RaySummary/AnchorLayer.lean`, `.../PlusSlicedCertificate/Limits/`, `FormalSystem/PlusLanguage/PlusTruth.lean`, `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/{Basic,Saturation}.lean`, `docs/theorem-index.md`
- Wired evidence probes: `specs/evidence/seam-gluing-ray-product/{hit-presented-model-a,w-soundness-shape-refuted,backward-dual-mirror-fixture,backward-dual-asymmetric-fixture,mosaic-stab-saturated,mosaic-germ-amalgamation}.lean`
- Task-closure artifacts: 745's summary and `.return-meta.json`, 747's summary, 733's summary, 734's summary and report
- Machine state and gates: `specs/state.json`, `specs/ROADMAP.md`, `scripts/check-evidence-probes.sh`, `.claude/scripts/{validate-state,roadmap-integration,lean-sorry-census}.sh`
- Literature (via 734's report, not re-read here): Caleiro-Vigano-Volpe 2013 sections 3.1-3.2, 4.3
**Artifacts**:
- `specs/748_revise_and_create_tasks_lplus_decidability/reports/01_ranked-route-analysis-dispositions.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **(C)'s computable bound was DESCOPED at closure and is now UNOWNED.** 745 delivered only the satisfiability half. The bound half is recorded BLOCKED with one named obligation, `kTypeOf_listSeg_replicate_eventually_periodic`, which has no declaration body anywhere in the repository -- its only declaration-position occurrence sits inside a module comment that opens at line 1 and closes at line 131 -- and is carried by no `sorry`: the sorry census cross-checks against `lake build` at `compiler_sorry_count: 0`, `cross_check: MATCH`. So the build is green, the gates pass, the axiom pins hold, and the obligation is outstanding with nothing in the build surface able to surface it. **This is the highest-value filing on the front.**
- **That same obligation IS (W)'s obligation (iii).** The task description treats item 1 and item 2's third bullet as two things; `RaySummary/README.md:376-377` shows they are one. (W)'s own README states that without it a landed lift reads `¬ PlusValidZTime φ ↔ ∃ object, …` and is "at best semi-decidable". One obligation therefore gates the whole programme aim, and it is the cheapest unowned item on the front.
- **The roadmap's R2 contingency is void, and nothing replaces it: there is no fallback route.** Neither trigger fired (745 did not refute; 733 came back POSITIVE), and independently the contingency's mechanism is unusable -- 734's `stabSaturated_univ` makes the literal R2 falsifier unsatisfiable. 734 additionally rests externally blocked by a recorded user decision. Stage 1 proceeds on R1 alone, with named risks. No fallback is invented here.
- **Two task descriptions dissolve on inspection and two defects are larger than filed.** Item 4 (747's missing dependency edge) is moot -- 747 is `completed`. 725 is fully subsumed by two wired probes and should close. Conversely 720 is not a citation tidy-up but a gate-integrity repair: two `WIRED_REPO` entries point at files git does not track.
- **Two unowned tooling gaps surfaced.** `roadmap-integration.sh --regenerate` is silently inoperative on this roadmap (exit 1, no output, no write), and the task said to own that ("task 371") does not exist.
- **Dispositions: 2 creations, 4 revisions, 1 roadmap edit, 2 low-priority filings.** Every one is justified below against a file:line, a wired probe, or a named theorem.

## Context & Scope

This is the review that owns ranking. Every probe record on this front forbids the probe from re-ranking; this task does it. The scope is the task graph and the roadmap, not the mathematics: the deliverable is tasks created and revised, with this report existing to make those auditable.

Constraints honoured throughout, each checked against this report's own text before writing: no complexity bound is asserted or implied -- and the tree states that constraint in its own words, quoted at F12 rather than paraphrased here; the ARGUED CTL-star 2EXPTIME ceiling is not cited as an upper-bound source and appears nowhere below; no fourth certificate class is proposed; no settled ruling is reopened; no unqualified decidability claim for the L-plus language appears anywhere, and every decidability statement cited below carries its frame class, language fragment, premise set and hypothesis; no `sorry`-deferral or axiom-introduction is recommended for any filed work.

**Evidence tier.** All Lean claims below were verified by `grep`/`sed` reads of the source files, not by LSP lookup and not by `lake build` (no module was elaborated). `lean_local_search` was not consulted, so no absence claim rests on an LSP index state; the one absence claim that matters was established by an unfiltered repo-wide `grep` whose invocation is given verbatim. One sorry census and one state validation were run and their output read.

## Findings

### Codebase Patterns

**F1. (C)'s bound: descoped, named, and unowned. [VERIFIED]**

745 is `completed` (`specs/state.json`). Its own closure artifacts state the bound half was not delivered, in three mutually independent in-tree places:

- `FormalSystem/Metalogic/Decidability/RaySummary/README.md:154` -- the (C) requirements-table row reads "**Half-settled, and only the easier half.** … that discharge is **non-constructive** (an `∃ L` from `Set.Finite.bddAbove`, never exhibited) and it is **one fixture**, so no computable bound and no general regular `ℤ`-model statement follows."
- `README.md:264-293`, the section "The bound: blocked, with the obligation named", which states the obligation verbatim in a blockquote at lines 285-290 and says it is "deliberately not landed as a `sorry` anywhere".
- `docs/theorem-index.md:206` -- "the run layer is not bounded by anything in the tree (obligation (iii), `kTypeOf_listSeg_replicate_eventually_periodic`, unproved)".
- The wired probe's own header, `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean:88-99`, states the same obligation and names its proof route.

**The mechanism of failure, verified at source.** `hitCl_eq_truncated` at `hit-presented-model-a.lean:593` is an `∃ L : ℕ` statement. Its proof obtains `L` at line 603 from `((hitCl_finite MA stayA t Fp k).image off).bddAbove`, after a `choose! off hoff using hitCl_covered t k` at line 600. The file's own comment at lines 601-602 names it: "`Set.Finite.bddAbove` is where the second (and fatal, for any bound) use of choice sits: it exhibits no `L`." So the bound does not fail for want of a proof; it fails because `L` is a choice-extracted upper bound -- in the `bddAbove` sense, a bound on a set of naturals, never a bound on a procedure -- over a choice-extracted offset image, and every cardinality figure downstream of it is a function of a number nothing produces.

**The ownership gap, verified.** Invocation and result:

    jq -r '.active_projects[] | select((.status=="completed" or .status=="abandoned" or .status=="expanded") | not)
           | select((.description//"") | test("kTypeOf_listSeg_replicate_eventually_periodic|computable bound|hitCl_eq_truncated|eventually_periodic"; "i"))
           | [(.project_number|tostring),.status,.project_name]|@tsv' specs/state.json

returns exactly one row: `748 researching revise_and_create_tasks_lplus_decidability` -- this task itself. Over all tasks including terminal ones the only other row is `745 completed`. **No non-terminal task claims the bound.** This confirms the task description's claim by independent measurement.

**The obligation is invisible to every mechanical gate.** Three invocations, run from the repo root:

    grep -rn "kTypeOf_listSeg_replicate_eventually_periodic" . --exclude-dir=.git
    grep -rn "kTypeOf_listSeg_replicate_eventually_periodic" --include=*.lean . --exclude-dir=.git
    grep -rn "^\s*\(theorem\|lemma\|def\|axiom\)\s*kTypeOf_listSeg_replicate" . --exclude-dir=.git

The first returns 23 hits, every one prose: markdown in `docs/theorem-index.md:206`, `specs/ROADMAP.md`, `RaySummary/README.md:285,291,376`, and `specs/**` records. The second returns exactly two `.lean` hits. The third returns three declaration-position hits, of which two are markdown (745's report and plan) and one is `hit-presented-model-a.lean:91`.

**That one hit is the whole absence claim, so it was checked directly rather than assumed.** `hit-presented-model-a.lean` opens a block comment with `/-` at **line 1** and closes it with `-/` at **line 131**; `import FormalSystem` is line 132, and `awk` over the first 140 lines finds no other delimiter. Line 91 is four-space-indented inside that block. So the only declaration-position occurrence in any `.lean` file is a stated signature inside a module header comment, and the obligation has **no declaration body anywhere in the repository**.

**And it is carried by no `sorry` -- established at the compiler, not textually.** `grep -rnE ":= *sorry|by *sorry|exact *sorry|^ *sorry *$|<;> *sorry"` returns zero over both `FormalSystem/` and `specs/evidence/`, but that rules out source-level `sorry` only, not `sorryAx` arriving through a dependency. `bash .claude/scripts/lean-sorry-census.sh FormalSystem --cross-check` closes that gap: `sorry_count: 0`, `compiler_sorry_count: 0`, `stripper_sorry_count: 0`, `cross_check: MATCH` -- the cross-check arm runs `lake build`, so this is a compiler result. Two spot axiom checks via `lean_verify` corroborate it: `RaySummary.hitPresented_of_presented` and `RaySummary.anchorCells_ncard_le` each return `["propext","Classical.choice","Quot.sound"]` with `trust: standard` and an empty `non_standard_axioms`, so no `sorryAx` reaches either.

**The consequence, stated plainly, is the argument for filing.** Obligation (iii) is unproved, is owned by no task, is carried by no `sorry`, and the library is sorry-free at the compiler. So `lake build` is green, the sorry census matches, the evidence gate passes and the axiom pins hold -- while the obligation is outstanding. Nothing in the build surface would ever surface it. That is the mechanism by which a descoped bound became invisible, and it is why the successor must be **filed** rather than left to be noticed.

**Descoped deliberately, or overlooked? The split matters and is kept.** *Verified*: the three null `jq` scans over `specs/state.json`, and the obligation named in-tree at `RaySummary/README.md:285,291,376`, `docs/theorem-index.md:206` and `specs/ROADMAP.md`. *Inferred*: that the absence of an owner was deliberate. The record's own wording supports it -- `hit-presented-model-a.lean:88-90` reads "The single missing obligation, STATED AND NOT PROVED, and deliberately not landed as a `sorry` anywhere in this tree:", and `:99-100` "provable from `kTypeOf_listSeg_append_congr` plus `kType_finite` by finite-semigroup idempotence. It is the named unit of successor work, not a discharged one." That is a descope with the successor named, not a hygiene defect; "deliberately not landed as a `sorry`" is an authorial choice. But nothing in the tree proves the successor's never being filed was intended, and **the filing decision does not need the inference**: unowned is unowned either way.

**One obstruction seen from two angles.** The pinned axiom profiles of the (C) family carry `Classical.choice` (`KTypeSummaryAxiomTest.lean:405-413`, and `lean_verify`-confirmed above for `hitPresented_of_presented`), and `hitCl_eq_truncated`'s `L` comes from `Set.Finite.bddAbove` over a `choose!`-extracted image. These are not two findings: the choice axiom in the profile *is* the non-exhibited bound, recorded in the axiom foot rather than in prose. Stated with no extrapolation: this says the landed route is non-constructive at that step. It says nothing about whether a computable bound exists, and no complexity claim of any kind follows from it.

**The proof route, with a binder note the implementer needs.** The README and the probe header both say the obligation is "provable from `kTypeOf_listSeg_append_congr` plus `kType_finite` by finite-semigroup idempotence". Both entry points exist:

- `kTypeOf_listSeg_append_congr` -- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean:276`, binders `[Fintype sig.preds] (k : ℕ)` plus two implicit list pairs and two hypotheses; **no `DecidableEq`**. Proved (not a `sorry`) via `listSeg_append_kEquiv`, a `kTypeColouring` congruence, and `kEquiv_orderedSum_of_kEquiv_colour`. Axiom-pinned at `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean:269`. **Note the namespace**: although the file sits under `Decidability/RaySummary/`, the declaration closes `end FormalSystem.Metalogic.WeakCanonical` at `Compose.lean:296`, and the pin at `KTypeSummaryAxiomTest.lean:265` reads `FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_append_congr`.
- `kType_finite` -- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Basic.lean:112`, binders `(sig : MonadicSignature) [Finite sig.preds] (k : ℕ)`.

The three binder sets do not match: `append_congr` asks `[Fintype sig.preds]`, `kType_finite` asks `[Finite sig.preds]`, and the stated obligation carries `[Fintype sig.preds] [DecidableEq sig.preds]`. `Fintype → Finite` is automatic, so this is a bookkeeping point rather than an obstruction, but a plan that does not notice it will fight instance resolution.

**The threshold consequence is confirmed absent from where it would live.** `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean` holds exactly four theorems -- `kTypeColouring_eq_of_matching_segments` (:66), `kEquiv_zFiber_of_matching_segments` (:83), `kTypeOf_zFiber_eq_of_sameTriple` (:108), `kTypeOf_zFiber_eq_of_inFamily` (:133) -- and a case-insensitive sweep for threshold / block length / periodic returns nothing. This reproduces, by my own grep, the check `README.md:279-284` records. **Path correction to the carried records**: both 745's summary and the probe header write this file as `KTypeSummary/Saturation.lean`, which resolves under `WeakCanonical/`, not under `Decidability/` (there is an unrelated `FormalSystem/Metalogic/Decidability/Saturation.lean`, a tableau module).

**F2. The three (W) run-layer obligations are not three tasks. [VERIFIED]**

`RaySummary/README.md:308-400` ("(W): what landed and what did not") is the authority, and it separates them by kind:

1. **A frame-scheme constructor** for infinite-width, finitely branching regular frames (README:366-374). A construction to be built. Its source is the wired probe `b2b-frame-constructor-branching.lean`, which refuted `Rbad`/`Rok` as repair shapes; the `Node` thread-unfolding shape of `Limits/NoFiniteWidth.lean` is "neither refuted nor built". The ~120-160 line figure covers the regularity part only and the README itself marks it "**carried, unverified**".
2. **A Hit-level per-cell realization hypothesis** (README:378-383). **This is not a deliverable at all** -- it is a hypothesis the run layer may assume, and (C) already states it as `HitPresented`. Its content is a prohibition: never trace-level `Presented`, because `stab_iff_of_presented_nowUnique` (`w-soundness-shape-refuted.lean:188`) shows that at a `Presented` seam with `Cons.nowUnique` every closure formula satisfies `ψ ↔ ⊡ψ`, so no `⊡`-refutation is witnessable there, independent of width.
3. **The presentation-size bound** (README:376-377) -- `kTypeOf_listSeg_replicate_eventually_periodic`, "stated under 'The bound: blocked, with the obligation named' above and not proved". **This is F1.** Item 1 and item 2's third bullet of the task description are the same obligation.

So the count is: one task for the bound (shared with (C)), one record for the run layer with the frame-scheme question as its phase 1, and nothing for (ii). 747's own follow-up says the same in its own words -- "The run layer, if attempted, is its own record with the frame-scheme design question (thread-indexed unfolding vs. a bounded-deadline encoding) as its phase 1" -- and `ROADMAP.md:212-213` repeats it. **Neither record has been filed.** A scan of non-terminal task descriptions for `run layer|frame-scheme|per-cell|anchor layer|AnchorCons|infinite-width` returns only 748.

**What the run layer would and would not deliver, quoted so no successor overstates it** (README:380-385): without obligation (iii), "a landed composition theorem would read `¬ PlusValidZTime φ ↔ ∃ object, …` over an UNBOUNDED run layer -- at best semi-decidable -- and NOT `Decidable (PlusValidZTime φ)`."

**F3. The R2 contingency is void twice over, and nothing replaces it. [VERIFIED]**

`ROADMAP.md:186-187` reads: "**Promote this line if 745 refutes, or if 733 falsifies the two-factor presentation**: R2 is the route to switch to."

*Neither trigger fired.*
- 745 did not refute. `HitPresented` **holds** on the fixture: `README.md:154` records `Probe745.hitPresented_modelA` as the wired positive result, and `HitPresented` is a real library declaration at `Trace.lean:340` (`def … : Prop := HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`) with `hitPresented_of_presented` at `Trace.lean:353` proving `Presented → HitPresented` for `k ≥ 1` by the term `hit_eq_hitOf_of_presented M τ t φ lab step k hk hP`.
- 733 did not falsify; it came back POSITIVE. `Probe733Mirror.pastStab_iff_allBwdPathsMeet` at `backward-dual-mirror-fixture.lean:622`, `Probe733Mirror.two_bwd_paths` at :550, `Probe733Mirror.decide_past_stab` in the same file, all wired at `scripts/check-evidence-probes.sh:642`. The fixture has backward branching factor exactly 2 at every spine state -- the one region where the finite-width obstruction can appear -- so R1 survived its sharpest *landed* falsifier.

  **Citation hazard, flagged because it would silently corrupt a successor's evidence.** `pastStab_iff_allBwdPathsMeet` and `decide_past_stab` each exist **twice** under different namespaces, because probes in this collection re-declare rather than import: `Probe733Mirror` in `backward-dual-mirror-fixture.lean` (:622, :599-ish) and `Probe719Backward` in the sibling `backward-dual-asymmetric-fixture.lean` (:577, :599). A bare name is ambiguous between two probes proving things about two different fixtures. Every citation of either must carry its namespace. [`two_bwd_paths`'s axiom-free status is CARRIED-UNVERIFIED: `specs/733_…/summaries/01_backward-dual-mirror-fixture-summary.md`, "What Changed", and the probe header's own six-line `#print axioms` record. I confirmed the declaration exists at the cited line; `lean_verify` does not reach it, since probes under `specs/` are outside the Lake build graph.]

  **A coverage gap worth recording, since the ranking leans on this probe.** `two_fwd_paths` does not exist: `grep -rn "two_fwd_paths" . --exclude-dir=.git` returns **zero** lines repo-wide. The mirror probe established backward non-determinism only, so "sharpest available falsifier" is a claim about the probes that exist, not about the probe space. This is a gap in coverage, not a refutation, and it manufactures no route switch -- 739's standing ruling that a refutation is not a route-switch signal binds here too. It does mean R2's non-promotion rests on F3's *other* two legs (unsatisfiable falsifier, external blocker), not on 733 alone.

*And the contingency's mechanism is unusable even had a trigger fired.* `stabSaturated_univ` at `mosaic-stab-saturated.lean:108` is

    theorem stabSaturated_univ (M : TaskModel F) (S : Finset (Mosaic F t)) : StabSaturated M S :=
      fun _ _ _ hχ m' _ heq => hχ m'.hist heq.symm

-- a one-line term with no hypothesis on `S` at all, and **the tree itself records the consequence** at `mosaic-stab-saturated.lean:28-32`: "**The falsifier is unsatisfiable as stated.** The review's R2 falsifier -- a finite mosaic set with mixed germ states on which `StabSaturated` is FALSE while every finite coherence condition holds -- cannot be instantiated: no finite mosaic set, mixed or not, makes `StabSaturated` false." So this leg of the ranking rests on a wired probe's own header, not on a carried agent claim. The reason is visible by putting two definitions side by side: `Probe718Mosaic.StabSaturated` (`mosaic-germ-amalgamation.lean:127-129`) has body `∀ m ∈ S, ∀ χ, PlusTruthAt M m.hist t (.stab χ) → ∀ m' ∈ S, m'.hist.state t = m.hist.state t → PlusTruthAt M m'.hist t χ`, and `PlusTruth.stab_iff` (`FormalSystem/PlusLanguage/PlusTruth.lean:145-147`) is `PlusTruthAt M τ t (.stab φ) ↔ ∀ σ, τ.state t = σ.state t → PlusTruthAt M σ t φ`, proved by **`Iff.rfl`**. The predicate's body is its own antecedent restricted to `S`. So the literal R2 falsifier -- a finite mosaic set on which `StabSaturated` is false -- is unsatisfiable, and no probe can ever promote R2 on it. (Two precision points on the neighbouring theorem, both places a reviewer will press. `stabSaturated_of_sameState` at `mosaic-germ-amalgamation.lean:138` is **not** a one-line term -- its body is four tactics, `intro` then two `have`s then `exact`, routing through `stab_state_only` and then `PlusTruth.stab_iff`. And its `[F.IsRegular]` is not among its own binders: it arrives from the file's section variable block at `:49`, `variable {F : TaskFrame} [F.IsRegular] (M : TaskModel F) {t : F.Duration}`, which covers `StabSaturated` and the theorem alike. So "the theorem carries `[F.IsRegular]` unused" is true only via the section, and the one-line-term property belongs to `stabSaturated_univ`, not to this theorem.)

*A correction the task description owes.* The description stops at "the real mosaic content is the witness direction". 734 went further and **landed it**: `StabWitnessedAt` at `mosaic-stab-saturated.lean:113` is the SH1 diamond clause, and it **discriminates** -- `Smix_witnessed` (:227) holds on `{stayA, jumpB, stayB}`, `Sdrop_not_witnessed` (:242) fails on `{jumpB, stayB}`, both genuinely mixed sets. So R2's content is not vacuous; only the hypothesis as the prior review stated it was.

*Why that nonetheless does not make R2 a fallback.* Two independent reasons, both from 734's report:
- Deciding the witness direction on **semantic** mosaics presupposes deciding `⊡`. 734's report F5 states it: checking `StabWitnessedAt` over a finite `S` is a finite enumeration "ONLY after `⊡χ`'s truth at each `m ∈ S` is known", and on the fixture that truth is `stab_will_iff`, forward reachability -- "R1's finite-graph summary". A semantic-label mosaic set is a **consumer** of R1's device, not an alternative to it.
- The route content therefore lives entirely in a **syntactic** calculus, whose soundness is an unproved Thm-3.13 analogue for L+ requiring a bespoke `⊡`-fibre interaction condition Caleiro does not list. And Caleiro section 4.3, immediately after Thm 4.11, states the mosaic decidability argument "does not extend to the logics `L(C, D)` for `D ≠ ()`" -- once vertical and horizontal components interact -- while mosaics over the full language would restore saturation but leave their number infinite. `⊡` interacts with the task relation by construction. [These two bullets are CARRIED from `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/reports/01_e4-stabsaturated-mixed-germ-probe.md` findings F5 and section 4.3 read; the Caleiro quotation is reproduced there from a `verified_conversion` corpus source, which I did not re-read. CARRIED-UNVERIFIED as to the primary source.]

*And R2 is externally blocked regardless.* 734 is `partial` in `specs/state.json`, resting there "by the recorded user decision (cycle 4, 2026-10-09)" on an external blocker: Hodkinson-Reynolds Handbook ch. 11 sections 5.10-5.11, unobtainable (3-page preview, DOI paywalled).

**Conclusion, stated as the honest answer the task asked for: there is no fallback route.** R4 (filtration) is closed by landed library theorems -- `no_finite_carrier_sat` at `PlusSlicedCertificate/Limits/FiniteCarrier.lean:248` and `not_finite_width_fmp` at `Limits/NoFiniteWidth.lean:1280`. R5 routes back to R1/R2 by the roadmap's own standing text. R2 cannot be promoted by probe, is a consumer of R1 where it is decidable, and is blocked on unobtainable literature. R3 is a component, not a route. **Stage 1 proceeds on R1 alone, with the named risks in F2.** No fallback is invented to fill the hole.

**F4. Item 4 is moot. [VERIFIED]** 747 is `completed` in `specs/state.json`. Revising a terminal record's `dependencies[]` buys nothing. The lesson survives the instance and is applied below: every task this report proposes declares `file_scope`, so the overlap gate serializes it without a dependency edge that would falsely assert blocking.

**F5. 725 is subsumed; the subsumption is visible in the tree, not inferred. [VERIFIED]**

725's filed experiment is: build the backward dual on a time-asymmetric fixture, reusing `Probe710.Node`/`Probe710.Step`, deciding the backward stability operator at a seam state by backward reachability. That file exists and is wired: `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`, namespace `Probe719Backward` (line 81), whose own header lines 1-20 read "Probe 719 (experiment E1): **the backward dual of the finite-graph `⊡` summary, on a TIME-ASYMMETRIC fixture** … This file therefore transcribes Probe710's time-asymmetric step graph", with `pastStab_iff_allBwdPathsMeet` at :577 and `decide_past_stab` at :599. It is wired at `scripts/check-evidence-probes.sh:641`. 725's own SUBSUMPTION CLAUSE -- "IF 719 LANDS E1 FIRST, THIS TASK CLOSES AS SUBSUMED" -- is therefore triggered by the probe file itself. 733's mirror fixture (`:642`) then did the harder, backward-nondeterministic case on top.

**F6. 720 is larger than filed: a gate-integrity defect, not a citation tidy-up. [VERIFIED]**

Its blockers are gone -- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/` now exists and holds `FiniteCarrier.lean`, `NoFiniteWidth.lean`, `README.md`, which 720's own description recorded as non-existent on 2026-10-03. Both of its deliverables are live, and one is worse than filed:

- *Deliverable 1 is untouched.* `FormalSystem/Metalogic/Decidability/FMP/README.md` still cites `Probe706.no_finite_carrier_sat` (lines 84, 96) and `Probe710.not_finite_width_fmp` (lines 87, 98) by probe namespace, with the parenthetical "(compiled outside the build graph" at line 84 -- which 720's description correctly predicts "becomes FALSE the moment the theorems are in the build graph". They are in it.
- *Deliverable 2 has acquired a new defect.* The two `WIRED_REPO` entries now read `specs/archive/706_…/probes/NoFiniteCarrierModel.lean` and `specs/archive/710_…/probes/NoFiniteWidthModel.lean`. Both files exist on disk; `git ls-files --error-unmatch` reports both **untracked**, because `.gitignore:94` excludes `specs/archive/`. **The evidence gate therefore depends on two files absent from a fresh clone.** 720's description anticipated this hazard for the third, out-of-scope entry but not for its own two.

So 720's Deliverable-3 close-as-subsumed branch does **not** apply. It earns its cycles.

**F7. 734 earns no cycles, and its marker disagrees with its summary. [VERIFIED]** The work is done (probe landed, wired, 27 probes passing per its own verification block) and what remains is an external acquisition with a reactivation condition. Its summary's header reads `- **Status**: [BLOCKED]` while its prose says it "rests `[PARTIAL]`" and `specs/state.json` carries `partial`. Under the permissive status model a `partial` task is offered to any `/orchestrate` cycle, so the current marker invites re-dispatch of a task whose only remaining work is unobtainable.

**F8. 716 before 714, and 714 cannot be batched as it stands. [VERIFIED]** Both are `not_started`. 716 declares a four-entry `file_scope` under `PlusSlicedCertificate/`; **714 declares none** (it is among the 28 in F9). 716 is the only *regression* on the front -- a landed, gated decision procedure that does not return within 300s on a 4-position total-edge certificate while instant on self-loop ones, with a preserved reproducer at `specs/704_certificate_non_vacuity_and_shape_gates/probes/03_tier2_sliced_certificates.lean`. 714 is an evaluation whose own central question is whether decidability of the check survives full labels -- i.e. it may *cost* the decidable search `PlusSlicedCertificate/Check.lean` is built around. Fixing a defect in shipped code outranks an evaluation that might remove a landed capability. R2's not being a fallback does not change their relative order; it raises the whole sub-front's value only insofar as R3 is a component of R1, which the standing ruling against a fourth certificate class already bounds.

**F9. Both declaration-hygiene defects are real, already detected, and WARN-only. [VERIFIED]** `bash .claude/scripts/validate-state.sh` reports, as warnings on a PASSED run (9 passed, 16 warnings, 0 failed):

- "Coarse file_scope declaration: project_number 177, entry `FormalSystem/Metalogic/Decidability/` overlaps 9 distinct non-terminal task(s): 428,429,430,464,465,481,482,716,720" -- **9, not 10, and 747 is no longer among them** (it is terminal). Check 8.
- "file_scope visibility: 28 missing-key, 0 literal-null, 0 empty-array, out of 51 non-terminal task(s)" -- the 28 is confirmed; the denominator is **51, not 52**. Check 10.

Both defects are therefore already enumerated by an existing detector; what is missing is remediation, not detection.

**F10. `roadmap-integration.sh --regenerate` is inoperative here, and the task said to own that does not exist. [VERIFIED]**

`specs/ROADMAP.md` uses the Stage 0-4 layout. `assemble_roadmap` (`.claude/scripts/roadmap-integration.sh:393`) emits a fixed eight-section skeleton -- `## Goal`, `## Gate state`, `## Next`, `## Open work`, `## Checks before and after every call`, `## Settled decisions (do not re-litigate)`, `## Standing rules`, `## Unfiled observations (none worth a task yet)` -- and the roadmap contains **none** of them (`grep -n "## Open work\|## Next" specs/ROADMAP.md` matches only the prose phrase at line 3). Every `extract_section` therefore returns empty. Observed behaviour of `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run`: **exit 1, zero bytes on stdout, zero bytes on stderr** -- a silent abort with no diff. A line-numbered trace shows the last statement reached is line 628, inside `mode_regenerate` and well before `write_or_diff`, so a non-dry `--regenerate` aborts without writing too.

Two consequences for this task's deliverable (c): **this roadmap has no generated sections**, so the dispatch's "do not hand-edit the generated sections" has no referent here and the whole file must be hand-edited; and `--regenerate` must not be relied on, nor feared as a clobber risk.

And the ownership claim fails: `jq '[.. | objects | select(.project_number? == 371)] | length' specs/state.json` returns `0`. There is no task 371. The only 371 artifact is `specs/archive/371_revise_bimodal_reference_bimodal_only`, an unrelated reference-manual task. **The stage-layout incompatibility is unowned.**

**F11. An adjacent named successor, found in the library, deliberately not filed. [VERIFIED]** `Trace.lean:363-370`, the docstring of `plusStab_iff_forall_hitOf_of_presented`, names a second effectiveness obligation: the per-triple condition `∀ c, InFamily … → stabTargetSig …` quantifies over all colourings in a family, and making it effective "through `kTypeOf_zFiber_eq_of_inFamily` and a middle-segment representative, so that one representative colouring per triple suffices -- is the frame of the successor record that assembles `Decidable (PlusValidZTime φ)`; it is not done here." This is distinct from F1 (a size bound) and from F2's (i) (a frame constructor). It is recorded here and **not filed**: it presupposes both, and filing it now would schedule an assembly whose inputs do not exist.

**F12. The no-complexity-bound constraint has an in-tree authority; quote it rather than paraphrase. [VERIFIED]**

The `2 ^ (2 ^ |cl φ|)` figure has exactly one declaration position in the repository: `anchorCells_ncard_le` at `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean:324`, proved by a `calc` through `Set.ncard_le_ncard`, `Set.ncard_powerset` and `Finset.card_powerset`. Everything else naming the figure is prose. Its docstring at `:317-323` is the strongest disclaimer form available and should be cited verbatim by this report and by every task it files:

> "The one bound (W) can state honestly: a cardinality bound on the SET OF CELLS of a model, syntactic in `|cl φ|` … It is not a complexity bound of any kind: it counts cells, it does not time anything, and it must not be described as a bound on any procedure's running time."

Its `Paper:` line adds that the figure has no literature counterpart and "in particular the ARGUED CTL⋆ 2EXPTIME ceiling is not one". `lean_verify` on `FormalSystem.Metalogic.Decidability.RaySummary.anchorCells_ncard_le` returns `["propext","Classical.choice","Quot.sound"]`, `trust: standard`, no non-standard axioms.

Neighbouring shapes, corrected against the records that paraphrase them: `AnchorCons` at `:252` is a **`structure`**, not a `def`; `anchorCons_anchorCells` at `:276` is a structure-instance proof (`where` at `:277`), with `anchorCells` at `:225`, `anchorCells_subset_powerset` at `:307`, `anchorCells_finite` at `:313`, `AnchorConsFin` at `:338` and `decidableAnchorConsFin` at `:356`.

**F13. The tableau front's do-not-re-attempt register is not where the task description says. [VERIFIED]**

`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` returns **zero** hits for `C9`; the register lives in the submodule `MintBound/Register.lean`, headed at `:9` "# C9. The do-not-re-attempt register" and described there as "Twenty-five statements that look like the natural next lemma and are **not** available. Each is cited by declaration name and, where one exists, by refuting witness". The ruling is unaffected; only its address was wrong, and a successor sent to `MintBound.lean` would find nothing and might conclude the register had been retired.

Two entries bear on whether the tableau front earns cycles, and both are measured rather than argued -- recorded here for the ranking, with no extrapolation beyond what the register itself says:
- Entry 1 (`Register.lean:16`) tombstones `buildTableau_isSome` unconditionally: `expandBranchWithFuel` returns `none` once `branchesUsed` reaches `maxBranches = 50000`, "at every fuel figure whatsoever", and the true statement is the budget-quantified `buildTableauAt_isSome_of_budget`.
- Entry 2 (`Register.lean:22`) tombstones `buildTableau_isSome_of_budget` in its original target shape, "Refuted by measurement: `φ = F(G p)` returns `none` at `fuel = 229376` and `maxBranches = 10¹²`, and the cause is `resolveOpenArm = none`, neither the fuel guard nor the budget guard." **So the failure cause is a third mechanism, distinct from both guards the task description names.** This is in-tree measured evidence and is weighed in the ranking below; it is not read as a verdict on the tableau front's overall viability.

**F14. The two landed obstruction halves are not symmetric. [VERIFIED]**

The task description says "both halves of that obstruction are landed under `PlusSlicedCertificate/Limits/`". Both headline theorems do exist -- `not_finite_width_fmp` (`Limits/NoFiniteWidth.lean:1280`, supported by `no_finite_width_sat:1200`) and `not_finite_carrier_fmp` (`Limits/FiniteCarrier.lean:349`, with the `⊡`-free twin `not_finite_carrier_fmp_fragment:533`) -- but that directory's own `README.md:3-4` opens "This directory states no positive result", and `:11-15` records the asymmetry: the finite-carrier shape "was never landed, so this is a limit of a *rejected* class shape rather than of the landed one". One half bounds the landed shape; the other bounds a shape already rejected. **The no-fourth-certificate-class ruling holds regardless** -- nothing below files one -- but a successor must state the asymmetry rather than assert two equivalent landed halves.

### External Resources

- Caleiro, Vigano, Volpe 2013, "On the Mosaic Method for Many-Dimensional Modal Logics", sections 3.1-3.2 (Defs 3.2-3.9, Lemma 3.10, Thm 3.13) and 4.3 (Thm 4.11 and the following paragraph). In corpus at `/home/benjamin/Projects/Literature/sources/caleiro_2013/`, provenance `verified_conversion`. Consulted here only through 734's report; the relevant content is the non-transfer statement in F3.
- Hodkinson-Reynolds, "Temporal Logic" (Handbook of Modal Logic ch. 11), sections 5.10-5.11. **Not obtainable**: `hodkinson_2006` in `specs/literature-index.json` is a 3-page preview with a recorded hazard and a paywalled DOI, re-measured 2026-10-09. This is 734's external blocker and the reason R2 cannot be ranked.
- Hodkinson-Wolter-Zakharyaschev 2000, "Decidable fragments of first-order temporal logics" -- the sub-index maps its Defs 6-12 onto this repository's time-sliced certificate and HWZ Def. 12 is the structural comparison point `README.md:323-328` uses to state where this semantics parts from it (histories are all bi-infinite frame paths, path-closed and limit-closed, so there is no free choice of runs). Relevant to the run-layer record's phase 1; not re-read here.
- No new literature is required by any disposition below. The run-layer record's phase 1 is a design question over in-tree objects, not a literature question.

### Recommendations

Ranked. Each names the evidence that drove it. Sorry-free completion is required of every filed item; where a route may not close, the instruction is `[BLOCKED]` with the obstruction named, never a `sorry` and never a new axiom.

**R1 (highest value) -- CREATE: the presentation-size bound shared by (C) and (W).**
- *Driven by*: F1 (descoped, unowned, invisible to all gates) and F2 (it is (W)'s obligation (iii), and without it no lift states a decidability result).
- *Headline*: prove `kTypeOf_listSeg_replicate_eventually_periodic` at the signature stated verbatim at `RaySummary/README.md:285-290`, then revisit `hitCl_eq_truncated` (`hit-presented-model-a.lean:593`) to replace its `Set.Finite.bddAbove` witness (line 603) with an exhibited `L`.
- *Route*: finite-semigroup idempotence from `kTypeOf_listSeg_append_congr` (`Compose.lean:276`) and `kType_finite` (`WeakCanonical/KTypeSummary/Basic.lean:112`). Carry the binder note from F1.
- *task_type*: `lean4`. *dependencies*: none. *file_scope* (required, F4): `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean`, `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`, `docs/theorem-index.md`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh`.
- *Non-negotiables to write into the record*: the `∃ m₀ p, 0 < p ∧ …` shape exactly as stated, not weakened; no complexity bound asserted or implied, and the result is a periodicity threshold, never a time or space figure; if the idempotence route does not close, mark `[BLOCKED]` and name the obstruction rather than landing a `sorry` or an axiom; exhibiting `L` changes `hitCl_eq_truncated`'s statement, so the `∃ L` prefix of `Probe745.hitPresented_modelA` and its five-bullet "what this does NOT say" section must be revised in the same change rather than left asserting non-exhibition.
- *Why first*: smallest scope on the front, no dependencies, and it is the single obligation two requirements share.

**R2 -- CREATE: the (W) run layer, with the frame-scheme design question as phase 1.**
- *Driven by*: F2 (unowned; 747's follow-up and `ROADMAP.md:212-213` both instruct that it be its own record).
- *Phase 1 is the design question only*: thread-indexed unfolding versus a bounded-deadline encoding, for a frame-scheme constructor producing infinite-width, finitely branching regular frames. Inputs: the refuted repair shapes `Rbad`/`Rok` in `b2b-frame-constructor-branching.lean`, and the `Node` thread-unfolding shape of `Limits/NoFiniteWidth.lean`, which is neither refuted nor built.
- *Must assume `HitPresented` per cell and never trace-level `Presented`*, with `stab_iff_of_presented_nowUnique` (`w-soundness-shape-refuted.lean:188`) cited as the reason.
- *Must carry the semi-decidability caveat* from `README.md:380-385` verbatim in its acceptance: without R1's bound, a composition theorem is `¬ PlusValidZTime φ ↔ ∃ object, …` and is not a decidability result. `Decidable (PlusValidZTime φ)` must appear in no statement.
- *Infinite width is forced*, by `not_finite_width_fmp` (`Limits/NoFiniteWidth.lean:1280`) and concretely by `modelOf_incomplete` (`w-soundness-shape-refuted.lean:131`); any phase reintroducing a finite-width or finite-fibre assumption reproduces a refuted shape.
- *The ~120-160 line figure must be carried marked, not inherited silently* -- `README.md:368-370` marks it "carried, unverified" and scopes it to the regularity part only; the unfolding design is unmeasured and the record must state that it has no cost figure.
- *task_type*: `lean4`. *dependencies*: **none** -- see Decisions D3 for why no edge to R1 is filed. *file_scope*: `FormalSystem/Metalogic/Decidability/RaySummary/`-resident new module(s) plus `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md`, `specs/evidence/seam-gluing-ray-product/`, `scripts/check-evidence-probes.sh`.
- *Dispatch guidance, not a status*: dispatch phase 1 and stop. Phase 1's outcome is what makes the rest costable; the record should say so.

**R3 -- REVISE `specs/ROADMAP.md`: delete the void contingency and state that there is no fallback.** Hand-edit only (F10). Specifically: replace the sentence at lines 186-187 with the F3 finding and its consequence; update the 745 bullet (lines 128-133), whose "Probe before bound … Re-cost the bound half against that before planning it" is spent -- the probe ran and the bound is now R1's record; update the Run-order block (lines 20-26), where `745,746`, `733,734` and `747` are terminal or externally blocked; add R1 and R2 to the Stage 1 ordering ahead of `716,714`; and record 725's close-as-subsumed and 720's enlarged scope. Leave constraint 1 and the 739 bullet exactly as they are -- 739's refutation remains load-bearing and is not a route-switch signal.

**R4 -- REVISE 725 to close as subsumed.** F5. Record the evidence in the closure: `backward-dual-asymmetric-fixture.lean` is Probe 719 experiment E1 on the transcribed `Probe710` time-asymmetric graph, wired at `check-evidence-probes.sh:641`, with `pastStab_iff_allBwdPathsMeet` at :577 and `decide_past_stab` at :599; and 733's mirror fixture covers the backward-nondeterministic case at :642. 725's own subsumption clause forbids manufacturing a redundant second probe.

**R5 -- REVISE 720's description to add the untracked-file finding and remove its subsumption branch.** F6. Add: `Limits/` now exists, so the "PATHS NOT YET BUILT" paragraph is spent and the landed library names are `no_finite_carrier_sat`/`not_finite_carrier_fmp` (`Limits/FiniteCarrier.lean:248,:349`) and `no_finite_width_sat`/`not_sliced_complete`/`not_finite_width_fmp` (`Limits/NoFiniteWidth.lean:1200,:1257,:1280`), in namespace `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth` (`NoFiniteWidth.lean:95-103`). Add: the two in-scope `WIRED_REPO` entries now point into gitignored, untracked `specs/archive/` paths, so resolving them is a gate-integrity repair. State that Deliverable 3 (close as subsumed) no longer applies, with the `FMP/README.md:84-98` citations as the reason.

**R6 -- REVISE 734's marker so the gate stops offering it.** F7. See Decisions D6: this one touches a recorded user decision and is raised for the user rather than settled here.

**R7 -- 716 then 714, and declare 714's `file_scope` before either is batched.** F8. 714's missing `file_scope` makes it invisible to the overlap gate while both tasks touch `PlusSlicedCertificate/`; declaring it is the prerequisite to running them as a batch at all.

**R8 (low priority) -- FILE the declaration-hygiene remediation.** F9. Backfill `file_scope` on the 28 missing-key non-terminal tasks and narrow 177's `FormalSystem/Metalogic/Decidability/` entry to the files it actually touches. `task_type: meta`. Not a Stage 1 item: the detector already enumerates both defects, and Stage 1's own exposure is closed more cheaply by R1/R2 declaring `file_scope` at creation.

**R9 (low priority) -- FILE the roadmap tooling gap.** F10. Teach `roadmap-integration.sh` the Stage-based layout, or decide that `specs/ROADMAP.md` is authored-only and make `--regenerate` say so loudly instead of exiting 1 in silence. `task_type: meta`. Filing this is what makes the "task 371" reference in circulation resolve to something real.

**Not recommended, stated so the omission is deliberate**: filing F11's assembly obligation (premature -- presupposes R1 and R2); filing anything for (W)'s obligation (ii) (a hypothesis, not a deliverable); any fourth certificate class; re-ranking 713 (held by ruling, not schedulable); and re-opening 709 or 712 (Stage 0 rulings).

**Out of scope, flagged rather than silently skipped.** F13's entry-2 measurement is a genuine input to whether the tableau front earns cycles, but that front (410, 411, 412, 428, 429, 430, 481, 482) is Stage 4, and this review's remit is Stage 1 and the L+ decidability programme's task graph. The finding is recorded at F13 so a Stage 4 review can weigh it; it is not used here to re-rank Stage 4, and `Register.lean`'s own scope limit applies -- it tombstones specific statements, not the front.

## Decisions

- **D1. The (C)-bound question is answered DESCOPED, not delivered, and the task is filed.** 745's own closure artifacts say so in three places (F1), and no non-terminal task claims it. This satisfies the task's acceptance criterion from 745's artifacts rather than from any agent summary.
- **D2. Items 1 and 2(iii) are merged into one filing.** `README.md:376-377` identifies them. Filing two tasks for one obligation would have produced a duplicate whose two owners could each weaken the statement.
- **D3. No dependency edge from R2 to R1.** An edge would assert that the run layer cannot proceed without the bound; `README.md:380-385` says it can, yielding a weaker (semi-decidable) statement. Serialization is instead obtained from the `file_scope` overlap both records declare on `RaySummary/README.md` and `docs/theorem-index.md`, and ordering from the roadmap's Run block. This is the honest mechanism: the gate serializes, the roadmap orders, and no record claims a blocking relation that does not exist.
- **D4. (W)'s obligation (ii) gets no task.** It is a hypothesis the run layer assumes, already stated as `HitPresented` at `Trace.lean:340`. What it needs is a prohibition in R2's record, not a record of its own.
- **D5. No fallback route is invented.** R2 is not promoted, not closed, and not ranked: its literal falsifier is unsatisfiable, its decidable part is a consumer of R1, and its remaining content is blocked on unobtainable literature. The roadmap will say there is no fallback and name the risks.
- **D6. 734's marker change is referred to the user, not made here.** Its `[PARTIAL]` resting state is a *recorded user decision* (cycle 4, 2026-10-09) with a reactivation condition. The evidence (F7) favours `blocked`, so the admission gate stops offering a task whose only remaining work is an unobtainable acquisition -- but overriding a recorded user decision is not this report's call. Surfaced as a non-blocking `user_decision`.
- **D7. 720 keeps its cycles; 725 loses them.** Both follow from reading the tree rather than the records: 725's deliverable exists and is wired; 720's does not and has decayed further.
- **D8. The hygiene and tooling defects are filed as successors, not fixed here.** Neither is a Stage 1 blocker, and this task's own file territory is `specs/ROADMAP.md` plus task records.
- **D9. `roadmap-integration.sh --regenerate` will not be invoked by the implementing phase.** F10 shows it aborts silently without writing, so the whole roadmap is hand-edited and there is no clobber hazard to manage.

## Risks & Mitigations

- **Risk: R1's finite-semigroup route may not close.** The idempotence argument is named in two records but has never been attempted. *Mitigation*: R1's record mandates `[BLOCKED]` with the obstruction named over any weakening, and the binder mismatch in F1 is written into the record so the first hour is not lost to instance resolution.
- **Risk: R1 lands the bound but `hitCl_eq_truncated` resists an exhibited `L`.** The threshold bounds where periodicity starts for a *replicated* label list; the truncation bound ranges over the offsets realized in `HitCl` on a specific fixture, and the two need not compose. *Mitigation*: R1's record separates the two as distinct deliverables, so a landed threshold with an unexhibited `L` is a partial result with a named residue rather than a failure.
- **Risk: R2 is dispatched past phase 1 and burns cycles on an unmeasured construction.** *Mitigation*: phase 1 is the design question only, and the record says dispatch stops there pending its outcome.
- **Risk: Stage 1 now has no fallback, which is a real programme risk rather than a reporting artifact.** If R1's gluing route stalls, there is nothing to switch to. *Mitigation*: name it in the roadmap rather than conceal it behind a contingency that cannot fire; the named risks are F2's three obligations and the absence of any backward Bool-fixture bridge.
- **Risk: the roadmap's authored prose drifts from `state.json` again, since no generator maintains it.** *Mitigation*: R9; until then the roadmap's derivation date must be updated by hand whenever Stage 1 prose changes.
- **Risk: a future closure descopes an obligation invisibly, as F1's did.** A green build, a clean sorry census and a passing gate set are all compatible with an outstanding obligation held only in prose. *Mitigation*: R1 removes this instance. The general form is a candidate for the hygiene successor (R8) and is recorded in this task's issue log.

## Tactic Survey Results

- Not applicable (no tactic survey performed). No proof goal was elaborated in this dispatch: the task's deliverable is a set of task creations and revisions, and the verification work was reading declarations, documentation and machine state. `lean_multi_attempt`, `lean_hammer_premise` and `lean_state_search` were not invoked, and no `lake build` was run. R1's record is where tactic survey belongs, once it has a goal to survey.

## Context Extension Recommendations

- **Topic**: mosaic-method vocabulary for L+ -- points, H1, SH1, the bespoke `⊡`-fibre interaction condition, and why semantic-label saturation is vacuous while the witness direction is not.
- **Gap**: nothing in `context/project/logic/` or under `FormalSystem/Metalogic/Decidability/` explains what saturation means in this development, so the next reader of `mosaic-germ-amalgamation.lean` meets `StabSaturated` with no way to see that it is implied by `PlusTruth.stab_iff`'s `Iff.rfl`.
- **Recommendation**: a short subsection "Mosaics: what saturation means here" in `FormalSystem/Metalogic/Decidability/README.md`, citing Caleiro Defs 3.2-3.6 and the two probes by declaration name. 734's report already recommended this and its own `file_scope` excluded it; it remains unowned and would fit R8 or R2's record.
- **Second topic**: the pattern in F1 -- an obligation outstanding with a green build, a zero sorry census and no owning task. A short note under `context/patterns/` on checking for prose-only obligations at task closure would generalize the one instance this report repairs.

## Appendix

**Verification invocations run in this session** (all read-only except the issue log):

- `jq` scans of `specs/state.json` for non-terminal tasks, `file_scope` presence, dependency edges, and description keyword matches (the two load-bearing ones are quoted verbatim in F1)
- `grep -rn "kTypeOf_listSeg_replicate_eventually_periodic" . --exclude-dir=.git` -- unfiltered repo-wide, 23 hits, all prose (F1)
- `grep -rn "^\s*\(theorem\|lemma\|def\|axiom\)\s*kTypeOf_listSeg_replicate" . --exclude-dir=.git` -- no declaration body
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem` -- `sorry_count: 0`
- `bash .claude/scripts/validate-state.sh` -- 9 PASS, 16 WARN, 0 FAIL; Checks 8 and 10 quoted in F9
- `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` -- exit 1, zero stdout, zero stderr; `PS4`-instrumented `bash -x` trace to locate the abort (F10)
- `git ls-files --error-unmatch` on both in-scope `WIRED_REPO` paths -- both untracked (F6)
- `awk '/^WIRED_REPO=\(/,/^\)/' scripts/check-evidence-probes.sh` -- three entries (F6)
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem --cross-check` -- `sorry_count: 0`, `compiler_sorry_count: 0`, `stripper_sorry_count: 0`, `cross_check: MATCH` (the cross-check arm runs `lake build`, so this is a compiler result, not a textual one)
- `grep -rnE ":= *sorry|by *sorry|exact *sorry|^ *sorry *$|<;> *sorry"` over `FormalSystem/` and `specs/evidence/` -- zero each (source-level only; superseded by the census above)
- `lean_verify` on `FormalSystem.Metalogic.Decidability.RaySummary.hitPresented_of_presented` and `…RaySummary.anchorCells_ncard_le` -- both `["propext","Classical.choice","Quot.sound"]`, `trust: standard`, `non_standard_axioms: []`
- `grep -rn "two_fwd_paths" . --exclude-dir=.git` -- zero lines (F3)
- `awk` over the first 140 lines of `hit-presented-model-a.lean` for comment delimiters -- `/-` at 1, `-/` at 131, nothing else (F1's load-bearing disqualifier)
- `grep -rn "C9" …/MintBound.lean` -- zero hits (F13)
- `sed -n` reads of every file:line cited above

**Authorities, in precedence order, as used here**
1. Lean declarations in `FormalSystem/` and wired probes under `specs/evidence/` -- what is actually proved.
2. `FormalSystem/Metalogic/Decidability/RaySummary/README.md` -- the verdict table and the "(S)"/"(W)"/bound sections are the stated authority for requirement shapes.
3. `docs/theorem-index.md` and the `KTypeSummaryAxiomTest.lean` pins -- what is index-visible and axiom-watched.
4. `specs/state.json` -- machine truth for status, dependencies and `file_scope`.
5. Task summaries and reports -- used for intent and for recorded user decisions; every mechanical claim taken from them is either re-derived above or marked `CARRIED-UNVERIFIED`.

**Corrections to the task description** (the description asked for these rather than their propagation)
1. Items 1 and 2(iii) name one obligation, not two (`README.md:376-377`).
2. Item 2's obligation (ii) is a hypothesis, not a buildable deliverable; it warrants no task.
3. Item 4 is moot: 747 is `completed`.
4. Item 7's overlap count is **9** non-terminal tasks, not 10, and 747 is no longer among them; the visibility ratio is **28 of 51**, not 28 of 52.
5. **There is no task 371.** The roadmap-tooling gap it was cited for is unowned; the only 371 artifact is an unrelated archived reference-manual task.
6. `--regenerate` rebuilds `## Open work` and `## Next` *in files that have them*. This roadmap has neither, so it has no generated sections at all and `--regenerate` aborts silently (exit 1, no output, no write).
7. 734 is `partial` and externally blocked by a recorded user decision; the description omits both, and omits that 734's witness-direction predicate `StabWitnessedAt` is non-vacuous and discriminating (`mosaic-stab-saturated.lean:227`, `:242`).
8. The tautology theorem is `stabSaturated_univ` (`mosaic-stab-saturated.lean:108`), which concerns the landed `Probe718Mosaic.StabSaturated` (`mosaic-germ-amalgamation.lean:127`); the description's attribution is right but the name was unstated. `stabSaturated_of_sameState`'s `[F.IsRegular]` is inherited from the section variable at `mosaic-germ-amalgamation.lean:49`.
9. `KTypeSummary/Saturation.lean` resolves under `FormalSystem/Metalogic/WeakCanonical/`, not under `Decidability/`.
10. `kTypeOf_listSeg_append_congr`'s file is under `Decidability/RaySummary/` but its namespace is `FormalSystem.Metalogic.WeakCanonical` (`Compose.lean:296`, pin at `KTypeSummaryAxiomTest.lean:265`).
11. **`Formula`, not `PlusFormula`** -- the easiest place in this deliverable to overclaim by dropping one plus sign. `decidableValidZTime` at `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:147` is a `def` (not an `instance`, deliberately per `Assembly.lean:31`) of type `Decidable (ValidZTime φ)` over **`Formula`**, consumed at `FormalSystem/Metalogic/ZTimeProvability.lean:107`. The settled ruling that "Z-time validity of L is already decided by the witness-family route" is therefore confirmed exactly as stated: it decides **L**. It is not a `Decidable (PlusValidZTime φ)` in any form, supplies nothing for L+, and neither undercuts nor supports the (W) records.
12. "Do not re-attempt the C9-register tombstones in `MintBound.lean`" names the wrong file: `MintBound.lean` is a pure aggregator with zero `C9` hits. The register is `MintBound/Register.lean:9`. See F13.
13. "Both halves of that obstruction are landed" overstates a real asymmetry: one half bounds the landed class shape, the other a rejected one, per `Limits/README.md:11-15`. See F14.
14. `modelOf_incomplete` is **probe evidence, not a library declaration** -- `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean:131`, namespace `Probe747` (declared at `:104`), with a research prototype at `specs/747_…/evidence/02_modelOf-finite-width-incomplete.lean`. The description presents it alongside landed results. Its docstring at `:129-130` states the gap in one sentence: "`Φ.neg` is not ℤ-valid, yet no `Cons` presentation's `modelOf` refutes it."
15. `nowUnique` is a **field of the `Cons` structure** (`RaySummary/Realize.lean`, described at `:551` as one of the marker conditions), not a standalone theorem. Cite `Cons.nowUnique`.
16. `anchorCells_ncard_le` is at `AnchorLayer.lean:324`, and its no-complexity-bound disclaimer at `:317-323`. See F12 for the neighbouring shapes, several of which circulating records paraphrase as `def` where the tree has `structure`.
17. **A near-miss worth recording so a future reader does not make 709 the owner of F1's obligation.** 709's finding F4 is also phrased "eventually periodic", but it is a materially different statement: "every finite-width sliced structure satisfying a target has an eventually periodic, hence tail-stable-presentable, model of the SAME width". That is about sliced structures and width preservation; obligation (iii) is `k`-type periodicity under block replication over `listSeg (List.replicate …)`. A paraphrase search on the shared phrase matches 709 and would wrongly dissolve the gap F1 identifies. Nothing here reopens 709, which is demoted to a component of R1, sequenced under 719, and carries its own "DO NOT COMMIT A WIDTH BOUND TO A PLAN"; its filed headline is not to be attempted, per the standing ruling.
18. **A schema trap for anyone re-running F1's null scans.** The fields are `project_number` and `project_name`, not `number` and `title`. A selector keyed on the latter matches nothing and reads like a null result one could cite. The invocations quoted in F1 and in the Appendix use the correct keys.

**References**
- 745 closure: `specs/745_hit_level_completeness_computable_bound/summaries/01_hit-presented-model-a-summary.md`
- 747 closure: `specs/747_closure_wide_quasimodel_lift_to_validity/summaries/01_closure-wide-quasimodel-anchor-layer-summary.md`
- 733 closure: `specs/733_backward_dual_mirror_fixture_branching_probe/summaries/01_backward-dual-mirror-fixture-summary.md`
- 734 closure and report: `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/{summaries/01_…-summary.md,reports/01_…-probe.md}`
- Precedent for this task's shape: `specs/archive/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md`
- Issue log for this dispatch: `specs/748_revise_and_create_tasks_lplus_decidability/issues.jsonl`
