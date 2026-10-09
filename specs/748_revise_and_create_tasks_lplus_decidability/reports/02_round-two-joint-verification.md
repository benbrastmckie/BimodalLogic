# Research Report: Task #748

**Task**: 748 - Revise existing tasks and create new ones to move the L+ decidability programme forward (round 2)
**Started**: 2026-10-09T19:21:18Z
**Completed**: 2026-10-09T19:45:00Z
**Effort**: ~0.4 hours (one scratch elaboration of 2.3 s; the rest reads of declarations, probes, CI, and git history)
**Dependencies**: 747 (completed)
**Sources/Inputs**:
- Round 1: `specs/748_revise_and_create_tasks_lplus_decidability/reports/01_ranked-route-analysis-dispositions.md` (read in full; its settled findings F1-F14 are not re-derived here, only built on or corrected)
- In-tree Lean (primary authority): `FormalSystem/Metalogic/Decidability/RaySummary/{Compose,Trace,Closure,AnchorLayer}.lean`, `FormalSystem/Metalogic/WeakCanonical/{NEquivalence.lean,KTypeSummary/{Basic,Family,Universal}.lean}`, `FormalSystem/PlusLanguage/Subformulas.lean`, `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`
- Wired probes: `specs/evidence/seam-gluing-ray-product/{hit-presented-model-a,w-soundness-shape-refuted,backward-dual-mirror-fixture,finite-graph-stab-summary,b2b-frame-constructor-branching,stab-depth-two-shared-stratum}.lean`
- Gate and CI: `scripts/check-evidence-probes.sh`, `.github/workflows/ci.yml`, `.gitignore`, `git ls-files` / `git log` over the two archive probe paths
- Records: `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md`, `specs/state.json`, 747's report, `.claude/commands/task.md`, `.claude/context/patterns/task-abandon-mode.md`, `.claude/scripts/{state-write,update-task-status}.sh`
- One scratch file, never to be landed from the scratchpad: `replicate_periodic_probe.lean` (contents reproduced in the Appendix)
- Mathlib: `Finite.exists_ne_map_eq_of_infinite`, `Fintype.exists_ne_map_eq_of_card_lt` (`Mathlib/Data/Fintype/Pigeonhole.lean`), `List.replicate_add` (`Mathlib/Data/List/Basic.lean`), `Nat.card_eq_fintype_card`
**Artifacts**:
- `specs/748_revise_and_create_tasks_lplus_decidability/reports/02_round-two-joint-verification.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Obligation (iii) closes, and cheaply.** `kTypeOf_listSeg_replicate_eventually_periodic`, at the signature stated verbatim at `RaySummary/README.md:285-290`, compiled in a 15-line scratch proof in 2.3 s against the current oleans with axioms `[propext, Classical.choice, Quot.sound]`; so did a strengthened shape with the threshold bounded by `Nat.card (KType sig k)`. The route is pigeonhole plus `kTypeOf_listSeg_append_congr`, not idempotence. Round 1's R1 risk "the finite-semigroup route may not close" is retired.
- **But (iii) is not (C)'s bound, and the tree's "single missing obligation" wording (`hit-presented-model-a.lean:88`, `README.md:283-284`) understates what the bound needs.** `hitCl_eq_truncated`'s `L` bounds jump offsets over `familyTriples`, each an existential over `SegmentFactorization` cutting sequences (`Family.lean:70-95`, `:201-203`), and nothing in the tree transports a factorization across a lengthened replicated block. That transport lemma, not (iii), is R1's unmeasured cost. And (C)'s row (`README.md:154`) names a general every-model statement that (iii) plus an exhibited `L` on model A does not touch; it is unowned.
- **Round 1's reading of obligation (ii) is corrected.** (ii) is not "a hypothesis, not a deliverable": against `README.md:378-383`, `w-soundness-shape-refuted.lean:44-49` and 747's report, it is two proof obligations of the run-layer record -- a Hit-level realization theorem for the constructor of (i), and the per-cell extraction for every model, which is (C)'s general statement. The filing count stays at two; R2's record changes.
- **The 739 re-costing round 1 did not perform is done, and it is already the tree's alphabet.** `clSig φ` is `subformulas φ ⊕ Unit` (`Closure.lean:80-81`) and `subformulas` carries both `untl` and `snce` arguments (`Subformulas.lean:66-73`): closure-indexed, backward labels included. The periodicity threshold is bounded by `Nat.card (KType (clSig φ) k)`, a count of `k`-types syntactic in `(|subformulas φ| + 1, k)`. It is a count; no complexity bound is asserted.
- **The gate-integrity defect has reach, and CI is its first casualty.** The two untracked `WIRED_REPO` files were deleted from the index by the archive commit `70321e938` and re-pointed by `e8cfcd868`; CI runs the gate (`ci.yml:119-125`) and its summary step exits 1 on a failed outcome (`:352-356`) from a plain `actions/checkout@v5` with no workspace cache. The gate checks `-f` only (`check-evidence-probes.sh:717-720`), and the abandon flow moves task directories into the ignored archive (`task-abandon-mode.md:58-65`), so the mechanism recurs for any future `WIRED_REPO` entry into a live task directory.
- **"R1 alone" stress-tested: four named failure modes, none realized, one nominal gap dissolved.** `two_fwd_paths` is absent by name only: forward branching is exercised by `Rf := fun _ _ _ => True` (`finite-graph-stab-summary.lean:47`, decided at `:148`) and by model A's `RA` (`hit-presented-model-a.lean:153`, steps `a→a, a→b`) at the Hit level. No route switch is manufactured; 739's ruling binds.

## Context & Scope

This is the second research round on 748. Round 1 established the filing case (F1: descoped, unowned, invisible to every gate), the void contingency (F3), and 18 corrections to the brief; the coordinator's message and this dispatch both forbid re-deriving those, and this report does not. Its territory is the five joints round 1 left thin: the successor task's framing and cost; obligation (ii); whether the anchor object supports a procedure or only a count; the honest shape of "R1 alone"; and the reach of the gate-integrity defect. Where this report disagrees with round 1 it says so with the citation that settles it.

Constraints honoured, each checked against this text before writing: no complexity bound, upper or lower, is asserted or implied, and the one in-tree disclaimer is quoted verbatim at 2.5 rather than paraphrased; the ARGUED CTL-star 2EXPTIME ceiling is not cited as a source for anything; no fourth certificate class; no settled ruling reopened; no unqualified decidability claim for L-plus; every decidability statement cited carries frame class, fragment, premise set and hypothesis; no `sorry` deferral and no axiom is recommended for any filed work. The scratch proof below is feasibility evidence and is not a landing: the successor record lands it under its own `file_scope`, pins, and index row.

**Evidence tier.** One Lean elaboration was run: `lake env lean` on the scratch file (the same invocation the evidence gate uses, `check-evidence-probes.sh:723`; not `lake build`, so no detach or guard was needed). `lean_local_search` returned `index: warming` or `error` on every call, so no absence claim rests on it; the one absence claim that matters (no landed periodicity lemma under another name) rests on a repo-wide `grep` quoted in the Appendix. Everything else is `sed`/`grep`/`jq`/`git` reads of the cited lines.

## Findings

### Codebase Patterns

**2.1 Obligation (iii) closes by pigeonhole, in 15 lines, with standard axioms. [VERIFIED by elaboration]**

The scratch file in the Appendix was compiled with `lake env lean` against the oleans the tree currently holds (`.lake/build/lib/lean/FormalSystem/Metalogic/Decidability/RaySummary/Compose.olean` present; 2.3 s wall clock; exit 0). Its `#print axioms` foot reads, for both theorems, `[propext, Classical.choice, Quot.sound]` -- the same profile as every (C) pin at `KTypeSummaryAxiomTest.lean:405-413`. No `sorryAx`.

The argument, so the record can state it exactly:
1. `kType_finite sig k : Finite (KType sig k)` (`KTypeSummary/Basic.lean:112`) makes `m ↦ kTypeOf sig k (listSeg (List.replicate m ℓ))` a map from `ℕ` into a finite type, so `Finite.exists_ne_map_eq_of_infinite` gives `i ≠ j` with equal images.
2. For `i < j` and `m ≥ i`: `List.replicate_add` rewrites `replicate (m + (j - i)) ℓ` as `replicate j ℓ ++ replicate (m - i) ℓ` and `replicate m ℓ` as `replicate i ℓ ++ replicate (m - i) ℓ`; `kTypeOf_listSeg_append_congr` (`Compose.lean:276`) with `h₁ := hf.symm` and `h₂ := rfl` closes the goal. Threshold `m₀ := i`, period `p := j - i`.

Three corrections to the tree's own framing fall out:
- **"Finite-semigroup idempotence" (`README.md:291`, `hit-presented-model-a.lean:97`) is a misnomer.** No semigroup is constructed and no idempotent is needed; the congruence is applied once, with the *first* argument varying and the second fixed. A plan that sets out to build the semigroup structure on `KType sig k` would be doing work the statement does not need.
- **The binder mismatch round 1 flagged is real and harmless.** The scratch theorem carries the stated `[Fintype sig.preds] [DecidableEq sig.preds]`; `kType_finite`'s `[Finite sig.preds]` was found by instance search from `Fintype`, and `append_congr`'s `[Fintype sig.preds]` matched directly. `DecidableEq sig.preds` is unused by the proof, exactly as `Compose.lean:270-275`'s linter note predicts for `append_congr`; the successor should expect the `unusedArguments` linter to say so and should keep the binder anyway, because the stated signature is the recorded one.
- **A strictly stronger shape also closes**, with the threshold bounded by the number of `k`-types: `∃ m₀ p, 0 < p ∧ m₀ + p ≤ Nat.card (KType sig k) ∧ ∀ m, m₀ ≤ m → …`, via `Fintype.exists_ne_map_eq_of_card_lt` on `Fin (Nat.card (KType sig k) + 1)` after `Fintype.ofFinite` and `Nat.card_eq_fintype_card`. This is the shape the successor should land, because it is the one that makes the threshold a function of something the tree can name. It is a count of types; see 2.3 and 2.5 for what it is not.

**No landed lemma already says this under another name.** `grep -rn "List.replicate\|eventually_periodic\|eventuallyPeriodic\|exists_idempotent\|pow_eq_pow\|IsOfFinOrder"` over `FormalSystem/Metalogic/{WeakCanonical,Decidability/RaySummary,GroupModel}` returns nothing outside comments and READMEs, and `KTypeSummary/Saturation.lean`'s four theorems (round 1 F1) are not about thresholds. Round 1's absence claim for the exact name stands; this extends it to the content.

**2.2 (iii) is not (C)'s bound. The composition into `hitCl_eq_truncated` is the unmeasured step, and (C)'s general statement is a second unowned gap. [VERIFIED at source]**

What (C)'s bound needs on the fixture is an exhibited `L` in `hitCl_eq_truncated` (`hit-presented-model-a.lean:593-596`):

```
HitCl MA stayA t Fp k = familyTriples (clSig Fp) k (clTrace MA Fp t stayA)
  ∪ ⋃ w ∈ Set.Icc t (t + L), familyTriples (clSig Fp) k (clTrace MA Fp t (jump w))
```

`L` bounds the jump *offsets* whose family-triple sets are needed to cover `HitCl`. A family triple is `InFamily sig k τneg τzero τpos c := ∃ F : SegmentFactorization sig k c, …` (`Family.lean:201-203`), and a `SegmentFactorization` is a monotone covering cutting sequence `W : ℤ → ℤ` with every segment above the middle of type `τpos`, every segment below of type `τneg`, and the middle of type `τzero` (`Family.lean:70-95`). So "the triple sets of `jump (t+n)` stop changing for `n` beyond a threshold" is a statement about *cutting sequences of a bi-infinite colouring*, and (iii) is a statement about the `k`-type of one finite replicated block. The two meet only through a lemma of this shape, which is **not in the tree**:

> if `c'` is `c` with a maximal constant run `ℓ^n` replaced by `ℓ^(n+p)`, and `n` is beyond (iii)'s threshold, then `InFamily … c ↔ InFamily … c'`.

Its proof is a cut-surgery argument -- shrink or extend one segment that holds the run, with (iii) and `append_congr` preserving its type -- and it has a genuine case split a plan must face: when every segment meeting the run is short, no single segment can absorb the `p` deleted positions and the factorization must be re-cut. The converse direction the tree does hold, `kTypeOf_zFiber_eq_of_inFamily` (`Saturation.lean:133`: a block's type is determined by any triple it lies in), is the wrong direction for this.

**The honest consequence for R1's cost.** Phase 1 (land (iii), strengthened) is hours. Phase 2 (the transport lemma on model A's traces, which by `clTrace_jump_apply`/`clTrace_stayA_apply` at `:470-500` are `(Fp,¬p)^(ω*) · now · (Fp,¬p)^n · (Fp,p)^ω`) is the real work and has no figure anywhere in the tree; the record must say so rather than inherit "provable by idempotence". Phase 3 (exhibit `L` and revise the probe's `∃ L` headline and its "does NOT say" section at `:1303-1312`) is bookkeeping once phase 2 lands.

**The second gap.** (C)'s row at `README.md:154` is "For every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled presentation … with `Fintype.card Q` below a computable bound in `φ`, such that `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`", and the same cell says what landed is "**one fixture**, so no computable bound and no general regular `ℤ`-model statement follows." Round 1's R1 covers the bound on the fixture. Nothing covers the every-model statement, and the `jq` scan round 1 ran (keywords `computable bound|hitCl_eq_truncated|eventually_periodic`) would not have found an owner for it under any wording. Where it belongs is settled at 2.4.

**2.3 The 739 re-costing: the alphabet is already closure-indexed in the tree, and the threshold is a count of `k`-types over it. [VERIFIED at source]**

The brief demanded that the bound be re-costed against 739's surviving constraint. Round 1 did not do this; it carried the tree's phrase. The re-costing is short because the tree already instantiates the constraint:

- `clSig φ := ⟨{ψ // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩` (`Closure.lean:80-81`), with `clNow φ := Sum.inr ()` (`:91`) and one letter per closure formula (`clLetter`, `:95-97`).
- `subformulas` (`Subformulas.lean:66-73`) carries both arguments of `untl` **and** of `snce`, so the backward labels 739 requires (`stab-depth-two-shared-stratum.lean:87-89`: "including BACKWARD labels … must be the closure-indexed alphabet, never one bit per depth") are letters of `clSig φ` by construction.
- The `k`-type alphabet is `KType (clSig φ) k := NormalForm (clSig φ) k 0 → Bool` (`NEquivalence.lean:62-63`), finite by `kType_finite`.

So (iii)'s threshold, in the strengthened shape of 2.1, is bounded by `Nat.card (KType (clSig φ) k)`: a count of depth-`k` types over an alphabet of `|subformulas φ| + 1` letters. Two things the record must say about it, and one it must not:
- It is a **count**, in exactly the sense `anchorCells_ncard_le`'s docstring gives its own figure (quoted at 2.5). It times nothing.
- `k` is a free parameter. For the `⊡` bridge alone, `k = 1` suffices: `plusStab_iff_forall_hitSig` and `plusStab_iff_forall_hitCl` carry only `(hk : 1 ≤ k)` (`Trace.lean:240`), and so does `hitPresented_modelA` (`hit-presented-model-a.lean:1282`). What depth the `untl`/`snce` run layer needs is an R2 design input, not an R1 one, and R1's record should say it lands the bound for every `k` and chooses none.
- It must **not** be turned into a running-time figure, and the record must not derive one from the size of `NormalForm (clSig φ) k 0`. The brief's "exponential in |φ|, not linear in depth" is a statement about `Fintype.card Q`'s *dependence*, correctly reflected by the alphabet being `clSig φ`; it is not a bound and this report states none.

**2.4 Obligation (ii) is two proof obligations of the run-layer record, not a hypothesis with no deliverable. Correction to round 1 D4. [VERIFIED at source]**

Round 1 D4: "(W)'s obligation (ii) gets no task. It is a hypothesis the run layer assumes, already stated as `HitPresented` at `Trace.lean:340`." The sources read against it:

- `README.md:378-383` lists (ii) under "Blocked: the run layer, on three named obligations. … Each obligation has its source", as "A Hit-level per-cell realization hypothesis -- (C)'s `HitPresented` … at every cell -- and never trace-level `Presented`", sourced to `stab_iff_of_presented_nowUnique`.
- `w-soundness-shape-refuted.lean:44-49`: "Consequence for (W): the realization hypothesis of its run layer must be Hit-level or product-level per cell (`HitPresented`, family-triple SETS …), never trace-level `Presented`; and the frame of its run layer must have infinite-width slices".
- 747's report, line 106: "the truth lemma's `stab` case needs every cell-path of the constructed frame to lift to a run with the right type at the seam -- the product/splice condition -- which is exactly the realization hypothesis (C) could only discharge at the Hit level with no bound."

A lift `¬ PlusValidZTime φ ↔ ∃ object, …` has two halves, and the hypothesis appears in each as something to be *proved*:
- **Soundness (object → model).** The constructor of (i) builds a model; the `stab` case of its truth lemma needs that model to be `HitPresented` at every cell by the object's per-cell presentation. That is a theorem about the constructor -- the Hit-level analogue of `presented_modelOf` (`Realize.lean`, the (S) realization theorem that discharged `Presented` for `modelOf`) -- and it is what `stab_iff_of_presented_nowUnique` (`w-soundness-shape-refuted.lean:188`) says cannot be done at trace level.
- **Completeness (model → object).** Every refuting model must yield an object whose per-cell presentations present its cells: `HitPresented` at every cell, for every regular `ℤ`-model. That is (C)'s general row (2.2), and `Probe735.not_presented` (`presented-not-complete.lean`, quoted at `README.md:118-121`) is the proof that the trace-level version of it is false, which is why the Hit level is the only one left.

So D4 was right that (ii) is not a *separate* task and wrong that it is not a deliverable. **The filing count is unchanged -- two creations -- but R2's record must carry both halves as phases**, and the general (C) statement is named there as the completeness half rather than left unowned. This also answers 2.2's second gap without a third task: a task for "general (C)" alone would be a task for one half of a theorem whose other half is the constructor.

**2.5 The anchor object supports a count and a checker on a concrete object; nothing in the tree states a procedure, and this report states none. [VERIFIED at source]**

The in-tree words, quoted rather than paraphrased, from `AnchorLayer.lean:317-320`:

> "The one bound (W) can state honestly: a cardinality bound on the SET OF CELLS of a model, syntactic in `|cl φ|` — a cell is a set of subsets of `cl φ`, so there are at most `2 ^ (2 ^ |cl φ|)` of them. It is not a complexity bound of any kind: it counts cells, it does not time anything, and it must not be described as a bound on any procedure's running time."

and `:321-322`: "the manuscript carries no counterpart and no literature bound is cited — in particular the ARGUED CTL⋆ 2EXPTIME ceiling is not one". The theorem is `anchorCells_ncard_le` at `:324` (round 1's `:325` was off by one; `:324` is the `theorem` line).

What the anchor layer provides beyond the count is `decidableAnchorConsFin` (`:356`), whose `docs/theorem-index.md` row (the fourth of the four quoted in the Appendix) opens "**The decidable checker is on a concrete finite object and decides nothing about a model**". So the landed object is: a finite count of candidate cells, and a decider for whether a given finite candidate satisfies the five anchor equations. The step from "a finite object" to "a decision" is the run layer's, and its shape without (iii) is spelled out at `README.md:380-382`: "`¬ PlusValidZTime φ ↔ ∃ object, …` over an UNBOUNDED run layer — at best semi-decidable". With (iii) in the strengthened shape, the run layer's *per-cell presentations* acquire a size bound (a count of `k`-types, 2.3); with (C)'s general statement (2.4), every refuting model has one. Together they would make the object space finite. That sentence is the whole of what this report claims about a procedure: it names the two missing inputs and asserts nothing about what it would cost to search the space. Every task proposed below carries the `:317-320` quotation and the prohibition.

**2.6 "R1 alone": the named failure modes, with their realized status. [VERIFIED at source]**

Round 1 concluded, correctly under the brief, that there is no fallback and invented none. The honest version of "R1 alone" names what would have to fail for the route to stall, and says whether it already has:

| Failure mode | Where it lives | Realized? |
|---|---|---|
| (a) No constructor for infinite-width, finitely branching regular frames | `Rbad` (`b2b-frame-constructor-branching.lean:178`) and `Rok` refuted as repair shapes; positive half `fib_finite_of_finBranch` (`:147`) and `saturation_of_finBranch` (`:169`) need two-sided finite branching; the `Node` thread-unfolding shape (`Limits/NoFiniteWidth.lean:132`) neither refuted nor built | **No.** Two shapes refuted, one unbuilt. Open, not failed. |
| (b) The transport lemma of 2.2 does not close on model A | Not in tree; no attempt recorded anywhere | **No.** Never attempted. |
| (c) Hit-level completeness fails for some regular `ℤ`-model | Trace level is false (`Probe735.not_presented`); Hit level holds on model A (`Probe745.hitPresented_modelA`); no Hit-level negative exists anywhere (`grep "¬ *HitPresented\|not_hitPresented"` over probes and `RaySummary/`: zero) | **No.** One positive fixture, zero negatives, no general argument. |
| (d) The `⊡` summary is not finitely computable under infinite backward branching | Held by `device-selection-probe.lean`, per `backward-dual-mirror-fixture.lean:65-72` ("the residue … is a question about the summary device, not about fixtures") | **Not a Stage 1 question**; the mirror header says so and declines to spawn harder fixtures. |

**The `two_fwd_paths` question, settled.** The name does not exist (round 1 F3), but the forward direction is not unprobed. `finite-graph-stab-summary.lean:47` fixes `Rf : ℤ → Bool → Bool → Prop := fun _ _ _ => True` -- the complete graph on `Bool`, "branching at every state" by its own docstring (`:44-46`) -- and decides the forward operator on it (`will_iff_allPathsMeet` `:82`, `decide_will` `:148`, `decidable_will` `:153`, namespace `Probe718FiniteGraph`). Model A's `RA` (`hit-presented-model-a.lean:153`, `v = u ∨ v = b`) has two successors at `a`, and `hitPresented_modelA` is a Hit-level positive on it. The asymmetric fixture (`Probe719Backward`) is forward-branching with unique predecessors, and the mirror (`Probe733Mirror`) is the reverse (`backward-dual-mirror-fixture.lean:18-24`). So each factor has been probed where it branches; what is missing is a *symmetric naming* of the two results, not coverage. Round 1's "sharpest available falsifier" stands for the backward factor, which is the one the finite-width refutation inhabits (`:12-14`). No route switch follows from any row above; 739's ruling binds.

**2.7 The gate-integrity defect reaches CI, and its mechanism recurs. [VERIFIED by `git` and `ci.yml`]**

Tracking status of every gate entry, by `git ls-files --error-unmatch`: all 25 `WIRED` entries tracked; of the three `WIRED_REPO` entries, `specs/archive/476_…/evidence/fmp-hypothesis-is-false.lean` is **tracked** (one of the five force-tracked archive files `ci.yml:239-240` names, listed by `git ls-files specs/archive`), while the 706 and 710 entries are untracked. How they became so: both files were tracked under their live task paths (`1b7b8431f`, `b1180dbf8`), **deleted from the index by the archive commit `70321e938`** (349 and 1180 lines, `git show --stat`), and then **re-pointed to the ignored `specs/archive/` paths by `e8cfcd868`** (task 732 phase 3). The gate never checked tracking: `check_probe` tests `[ ! -f "$file" ]` only (`check-evidence-probes.sh:717-720`), and `grep "ls-files\|check-ignore"` over the script finds nothing executable.

**Consequence for CI, stated with its one inference marked.** `ci.yml:119-125` runs `bash scripts/check-evidence-probes.sh` after a plain `actions/checkout@v5` (`:22-23`; no `actions/cache` of the workspace, only `lean-action`'s `.lake` cache); the step is `continue-on-error: true` (`:121`) but the summary step counts a failed outcome and exits 1 (`:352-356`). A checkout that lacks untracked files hits the missing-file branch for both entries. *Inference*: the gate therefore reports `FAIL (missing: …)` twice in CI and the summary step fails the job. I did not fetch CI logs; the chain is `git ls-files` + `.gitignore:94` + `:717-720` + `:352-356`, each verified.

**Why it recurs.** `task-abandon-mode.md:58-65` moves a task directory into `specs/archive/` with `mv`; `/todo` archival does the same (the 70321e938 commit). Any `WIRED_REPO` entry that points into a live task directory will be silently un-tracked the day that task is archived, with the gate still green locally for everyone who has the file on disk. 720's record names this hazard for the third entry (`specs/state.json`, 720 description, "OUT OF SCOPE" paragraph) and missed it for its own two. **The repair has two parts**, and 720 is the right home for both: (1) a tracked-ness check in `check_probe` (`git ls-files --error-unmatch "$file"` beside the `-f` test, failing loudly), which closes the mechanism; (2) for the two entries, either force-track (the 476 precedent, `ci.yml:239-240`) or resolve per 720's own Deliverable 2 (convert to `WIRED` under `specs/evidence/`, or delete if the landed `Limits/` theorems subsume them). Library prose also cites the force-tracked 476 path (`Limits/FiniteCarrier.lean:55,146`, `BiLasso/Assembly.lean:26`); those are not broken, and are noted only so a future force-track audit knows they exist.

**2.8 Round 1's dispositions, re-verified against today's tree. [VERIFIED]**

- 747 is `completed` (`specs/state.json`, `last_updated 2026-10-09T16:00:21Z`); item 4 of the brief stays moot.
- No task has been created since round 1: `next_project_number` is 749 and no project numbered above 748 exists. Deliverable (a) is entirely outstanding for the plan and implement phases.
- 734: `blockers: null`, `status: partial`. The user's own sync commit `6419dd80a` ("drop task 734 dependency edge … recorded as an accepted residual gap") is the most recent ruling on it. That supports round 1's D6 reading (the residue is accepted, so `blocked` with a `blockers` entry naming the Handbook acquisition is the honest marker), but it is a status change on a record the user has already touched by hand; round 1's non-blocking `user_decision` referral stands and is not re-raised here.
- 725, 714 and 716 have no task directories (`ls -d specs/725_* specs/714_* specs/716_*`: none), so a `/task --abandon 725` moves nothing into the ignored archive. 720 has one (`specs/720_promote_fmp_width_refutations_to_evidence/`).
- The mechanisms the plan phase will call, verified to exist with the usage shown: creation is the `state-write.sh` filter at `.claude/commands/task.md:181-196` (prepends a `not_started` record and bumps `next_project_number`; `file_scope` is **omitted by that filter**, `:223`, so the creating phase must add it in the same or a following `state-write.sh` call); description revision is a `state-write.sh` jq filter on `.active_projects[] | select(.project_number == N) | .description`; dependency edges are `update-task-status.sh … --depends-on-add=<json-array>` (`update-task-status.sh:10`); closure as subsumed is `/task --abandon 725` per `task-abandon-mode.md` (the archive write goes through `state-write.sh --state-file specs/archive/state.json`, `:39-41`), with the subsumption evidence written into the description first so the archived record carries it.

### External Resources

- Mathlib at pin `v4.33.0-rc1`: `Finite.exists_ne_map_eq_of_infinite` and `Fintype.exists_ne_map_eq_of_card_lt` (`Mathlib/Data/Fintype/Pigeonhole.lean`), `List.replicate_add` (`Mathlib/Data/List/Basic.lean`), `Nat.card_eq_fintype_card`, `Fintype.ofFinite`, `Fintype.card_fin`. All five were consumed by the compiled scratch proof, which is the verification.
- No literature was consulted this round and none is needed by any disposition. The transport lemma of 2.2 is a cut-surgery argument over in-tree objects; HWZ 2000 and Caleiro 2013 bear on R2's design question exactly as round 1 recorded and are not re-read.

### Recommendations

Ranked, and stated as revisions to round 1's R1-R9 so the plan phase has one list. Where a recommendation changes, the changed text is given; where it does not, it is confirmed by reference. Sorry-free completion is required of every filed item; a route that does not close is marked `[BLOCKED]` with the obstruction named.

**R1 (highest value) -- CREATE the (C)-bound task, RE-SCOPED into three phases with the cost on phase 2.** Driven by 2.1, 2.2, 2.3.
- *Headline*: (C)'s bound half on model A: land `kTypeOf_listSeg_replicate_eventually_periodic` in the strengthened shape, prove the factorization-transport lemma on model A's traces, and exhibit `L` in `hitCl_eq_truncated`.
- *Phase 1 (hours)*: land the strengthened statement -- `∃ m₀ p, 0 < p ∧ m₀ + p ≤ Nat.card (KType sig k) ∧ ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) = kTypeOf sig k (listSeg (List.replicate m ℓ))` -- with the stated form as its one-line corollary, in `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Saturation.lean` (namespace `FormalSystem.Metalogic.WeakCanonical`, matching `append_congr`'s at `Compose.lean:296`), by the proof in 2.1; pin both in `KTypeSummaryAxiomTest.lean` at `[propext, Classical.choice, Quot.sound]`; one `docs/theorem-index.md` row reading "a count of `k`-types, not a complexity bound". Replace "finite-semigroup idempotence" with "pigeonhole plus `kTypeOf_listSeg_append_congr`" at `README.md:291` and `hit-presented-model-a.lean:97`.
- *Phase 2 (unmeasured; the record must say so)*: the transport lemma -- `InFamily` is invariant under lengthening a maximal constant run beyond phase 1's threshold -- stated first generally over `sig` and, if that resists, on model A's traces (`clTrace_stayA_apply`/`clTrace_jump_apply`, `hit-presented-model-a.lean:470-500`). The case split (one long segment vs. many short ones) is named in the record. If it does not close: `[BLOCKED]`, obstruction named, never a `sorry`.
- *Phase 3*: exhibit `L` (`≤ m₀ + p` from phase 1, so `≤ Nat.card (KType (clSig Fp) k)`), revise `hitCl_eq_truncated`'s statement and the probe's "What `hitPresented_modelA` does NOT say" block (`:1303-1312`) in the same change, re-run `check-evidence-probes.sh`.
- *Non-negotiables*: `Nat.card (KType …)` is described as a count and nothing else, with `AnchorLayer.lean:317-320` quoted in the record; `k` stays free; no `Decidable (PlusValidZTime φ)` anywhere; the general every-model statement is **out of scope here and named as R2's completeness half**.
- *task_type*: `lean4`. *dependencies*: none. *file_scope*: as round 1 R1 plus `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` (the `:291`-adjacent docstring edit is in README, but `append_congr`'s docstring at `Compose.lean:271-275` is where a phase-1 cross-reference belongs).

**R2 -- CREATE the (W) run-layer task, REVISED to carry obligation (ii) as two phases and to name (C)'s general statement.** Driven by 2.4, 2.2, 2.6.
- Round 1's phase 1 (the frame-scheme design question, inputs `Rbad`/`Rok` at `b2b-frame-constructor-branching.lean:178ff` and `Node` at `Limits/NoFiniteWidth.lean:132`) stands as phase 1, and dispatch stops there.
- *Add phase 2 (soundness half)*: a Hit-level realization theorem for the phase-1 constructor -- the analogue of `presented_modelOf` (`Realize.lean`) at `HitPresented` level, per cell -- with `stab_iff_of_presented_nowUnique` (`w-soundness-shape-refuted.lean:188`) cited as the reason trace level is excluded.
- *Add phase 3 (completeness half)*: (C)'s general statement, `README.md:154`'s row quoted verbatim: for every regular `ℤ`-model, seam, `φ` and `1 ≤ k`, a presentation presenting `HitCl` at that cell. The record states that `Probe735.not_presented` refutes the trace-level version and that model A is the only Hit-level positive (2.6(c)); no cost figure, and the record says none exists.
- *Carry forward from round 1 unchanged*: infinite width forced (`not_finite_width_fmp`, `Limits/NoFiniteWidth.lean:1280`; `Probe747.modelOf_incomplete`, `w-soundness-shape-refuted.lean:131`); the semi-decidability caveat `README.md:380-385` verbatim; the ~120-160 line figure carried marked; no dependency edge to R1 (round 1 D3); `file_scope` declared at creation.
- *Add*: the depth `k` the run layer needs is a phase-1 output, since R1 lands its bound for every `k` and chooses none (2.3).

**R3 -- REVISE `specs/ROADMAP.md`, as round 1 R3, with two additions.** Add to the (C) bullet that the bound's phase 1 is closed-in-principle by a compiled scratch proof and that the cost sits in the transport lemma; add to the Run-order block, beside `720`, that it is now a CI repair (2.7). The contingency deletion and the "no fallback, named risks" replacement are as round 1; the named risks are the four rows of 2.6's table.

**R4 -- REVISE 725 to close as subsumed.** As round 1, with the mechanism named: write the subsumption evidence into the description (`Probe719Backward.pastStab_iff_allBwdPathsMeet` at `backward-dual-asymmetric-fixture.lean:577`, `Probe719Backward.decide_past_stab` at `:599`, wired at `check-evidence-probes.sh:641`; `Probe733Mirror.two_bwd_paths` at `backward-dual-mirror-fixture.lean:550`, wired at `:642`), then `/task --abandon 725`. No directory moves (2.8).

**R5 -- REVISE 720, ENLARGED beyond round 1.** Add to its description: the tracking history (`70321e938`, `e8cfcd868`), the CI consequence with `ci.yml:119-125` and `:352-356` cited, the `check_probe` tracked-ness check as a new deliverable, the force-track precedent (`ci.yml:239-240`), and `scripts/check-evidence-probes.sh:717-720` as the line to change. Keep round 1's additions (the landed `Limits/` names, the spent "PATHS NOT YET BUILT" paragraph, Deliverable 3 no longer applying). Its `file_scope` already covers the script. **Promote it in the Stage 1 run order ahead of `716,714`**: a red CI gate on every push outranks a local defect.

**R6, R7, R8, R9 -- as round 1**, confirmed: 734's marker is referred to the user with the `6419dd80a` evidence added (2.8); 716 before 714 with 714's `file_scope` declared first; the hygiene filing; the roadmap-tooling filing. One addition to R8's record: the recurring mechanism of 2.7 (archival un-tracks `WIRED_REPO` targets) is a hygiene defect with a one-line detector and belongs in that filing's scope if 720 does not land the check first.

**Not recommended, stated so the omission is deliberate**: a third creation for (C)'s general statement (it is one half of R2's theorem, 2.4); any task naming a running-time figure for anything; re-naming or re-probing the forward factor to manufacture a `two_fwd_paths` (2.6: coverage exists); landing the scratch proof from the scratchpad (it is R1's phase 1 under R1's `file_scope`, pins and index row, not a research-round commit).

## Decisions

- **D10. R1 is re-scoped with the cost on the transport lemma, not on (iii).** The scratch elaboration (2.1) makes (iii) a phase, and `Family.lean:70-95, :201-203` make the transport lemma the content. A record that said "prove (iii) by idempotence" would close its phase 1 in an hour and then discover its deliverable; this record says where the work is.
- **D11. The strengthened `Nat.card` shape is the one to land.** It is what makes `L` a function of something nameable (2.3), and it compiles. The stated shape is kept as a corollary so the README's and the probe's recorded signature remains literally true.
- **D12. (C)'s general statement is R2's completeness phase, not a third task.** It is one half of the lift whose other half is the constructor (2.4); filing it alone would schedule half a theorem.
- **D13. Round 1 D4 is amended, not reversed.** (ii) is still no separate task; it is two phases of R2. The filing count is unchanged.
- **D14. 720 is promoted above `716,714` and enlarged with the tracked-ness check.** A gate that CI runs and that fails on a fresh checkout (2.7) is a defect every push sees; 716's defect is seen only by whoever runs the 300 s reproducer.
- **D15. The `two_fwd_paths` gap is recorded as nominal and no probe is filed for it.** Both factors are probed where they branch (2.6); a symmetric name would add a row to the gate table and nothing to the evidence.
- **D16. No complexity bound is stated, and the one count this report introduces is labelled as the tree labels its own.** `Nat.card (KType (clSig φ) k)` is written only beside `AnchorLayer.lean:317-320`'s words.
- **D17. Nothing is landed from this round.** The scratch file stays in the scratchpad and is reproduced in the Appendix for R1's implementer; the deliverable of this round is the corrected filing text.

## Risks & Mitigations

- **Risk: R1's phase 2 does not close, and the task stalls with a landed (iii) and no `L`.** *Mitigation*: the record separates the phases, so a landed phase 1 is a partial result with a named residue (the transport lemma), never a `sorry`; and phase 2 is stated on model A's concrete traces as the fallback target before any generality is attempted.
- **Risk: an implementer reads the `Nat.card` bound as a running-time figure.** *Mitigation*: D16; the record quotes `AnchorLayer.lean:317-320` and prohibits deriving anything from the size of `NormalForm (clSig φ) k 0`.
- **Risk: R2's completeness phase (general (C)) is open mathematics with one positive fixture and no argument, and a dispatch past phase 1 burns cycles on it.** *Mitigation*: dispatch stops at phase 1 (round 1's rule, unchanged); phases 2-3 exist so the record is honest about what the lift needs, not so they are scheduled now.
- **Risk: 720's CI repair is done by force-tracking and the recurrence mechanism survives.** *Mitigation*: the tracked-ness check in `check_probe` is a named deliverable of R5, not an option.
- **Risk: the scratch proof is copied into the tree from this report without its pins and index row.** *Mitigation*: D17 and R1's non-negotiables; the Appendix labels the file "feasibility only".
- **Risk: Stage 1 has no fallback (unchanged from round 1).** *Mitigation*: 2.6's table replaces a contingency that could not fire with four named modes and their status, so the roadmap can say exactly what "R1 stalls" would mean.

## Tactic Survey Results

One goal was elaborated this round, outside the build graph, as a feasibility probe (not landed):

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `kTypeOf_listSeg_replicate_eventually_periodic` (stated shape, `README.md:285-290`) | `Finite.exists_ne_map_eq_of_infinite` then `rcases Nat.lt_or_gt_of_ne`, `rw [List.replicate_add]`, `exact kTypeOf_listSeg_append_congr k hf.symm rfl` | success, 2.3 s, axioms `[propext, Classical.choice, Quot.sound]` | `kType_finite sig k` supplied via `haveI`; `omega` for the index arithmetic |
| same, strengthened with `m₀ + p ≤ Nat.card (KType sig k)` | `Fintype.exists_ne_map_eq_of_card_lt` on `Fin (Nat.card _ + 1)` after `classical`, `Fintype.ofFinite`, `Nat.card_eq_fintype_card`, `Fintype.card_fin` | success, same profile | `omega` discharges `0 < p` and `m₀ + p ≤ Nat.card` from `i.1, j.1 < Nat.card + 1` |
| the transport lemma of 2.2 | not attempted | n/a | no statement in tree; R1 phase 2 |

`lean_multi_attempt`, `lean_hammer_premise` and `lean_state_search` were not invoked; the goal closed on the first hand-written attempt and the gate-equivalent `lake env lean` run is the verification.

## Context Extension Recommendations

- **Topic**: evidence-gate tracking discipline. **Gap**: nothing under `context/project/lean4/` or in `check-evidence-probes.sh`'s header says that a `WIRED_REPO` target must be tracked, or that archival un-tracks live task directories (2.7). **Recommendation**: one paragraph in `check-evidence-probes.sh`'s header ("TRACKED, NOT MERELY PRESENT") and a sentence in `task-abandon-mode.md` beside the `mv`, landed by R5 or R8.
- **Topic**: what a `k`-type count is and is not. **Gap**: the tree states its no-complexity-bound rule once, at `AnchorLayer.lean:317-322`, and R1 will introduce a second count. **Recommendation**: R1's theorem-index row cross-references the `AnchorLayer` row so both counts carry the same disclaimer in the same words.
- Round 1's two recommendations (mosaic saturation vocabulary; prose-only obligations at closure) stand.

## Appendix

**The scratch file, verbatim, as compiled** (`lake env lean <scratchpad>/replicate_periodic_probe.lean`, exit 0, 2.3 s; feasibility only, never to be landed from here):

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.Compose

namespace Probe748Scratch

open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature}

theorem periodic_of_collision [Fintype sig.preds] (k : ℕ) (ℓ : sig.preds → Bool)
    {i j : ℕ} (hij : i < j)
    (hf : kTypeOf sig k (listSeg (List.replicate i ℓ))
        = kTypeOf sig k (listSeg (List.replicate j ℓ))) :
    ∀ m, i ≤ m →
      kTypeOf sig k (listSeg (List.replicate (m + (j - i)) ℓ))
        = kTypeOf sig k (listSeg (List.replicate m ℓ)) := by
  intro m hm
  have e1 : m + (j - i) = j + (m - i) := by omega
  have e2 : m = i + (m - i) := by omega
  rw [e1, List.replicate_add]
  conv_rhs => rw [e2, List.replicate_add]
  exact kTypeOf_listSeg_append_congr k hf.symm rfl

theorem kTypeOf_listSeg_replicate_eventually_periodic (sig : MonadicSignature)
    [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) (ℓ : sig.preds → Bool) :
    ∃ m₀ p, 0 < p ∧ ∀ m, m₀ ≤ m →
      kTypeOf sig k (listSeg (List.replicate (m + p) ℓ))
        = kTypeOf sig k (listSeg (List.replicate m ℓ)) := by
  haveI : Finite (KType sig k) := kType_finite sig k
  obtain ⟨i, j, hij, hf⟩ := Finite.exists_ne_map_eq_of_infinite
    (fun m : ℕ => kTypeOf sig k (listSeg (List.replicate m ℓ)))
  rcases Nat.lt_or_gt_of_ne hij with h | h
  · exact ⟨i, j - i, by omega, periodic_of_collision k ℓ h hf⟩
  · exact ⟨j, i - j, by omega, periodic_of_collision k ℓ h hf.symm⟩

theorem kTypeOf_listSeg_replicate_eventually_periodic_bounded (sig : MonadicSignature)
    [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) (ℓ : sig.preds → Bool) :
    ∃ m₀ p, 0 < p ∧ m₀ + p ≤ Nat.card (KType sig k) ∧ ∀ m, m₀ ≤ m →
      kTypeOf sig k (listSeg (List.replicate (m + p) ℓ))
        = kTypeOf sig k (listSeg (List.replicate m ℓ)) := by
  classical
  haveI : Finite (KType sig k) := kType_finite sig k
  haveI : Fintype (KType sig k) := Fintype.ofFinite _
  have hN : Fintype.card (KType sig k) = Nat.card (KType sig k) :=
    (Nat.card_eq_fintype_card).symm
  obtain ⟨i, j, hij, hf⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun m : Fin (Nat.card (KType sig k) + 1) => kTypeOf sig k (listSeg (List.replicate m.1 ℓ)))
    (by rw [hN, Fintype.card_fin]; omega)
  have hij' : i.1 ≠ j.1 := fun h => hij (Fin.ext h)
  rcases Nat.lt_or_gt_of_ne hij' with h | h
  · exact ⟨i.1, j.1 - i.1, by omega, by omega, periodic_of_collision k ℓ h hf⟩
  · exact ⟨j.1, i.1 - j.1, by omega, by omega, periodic_of_collision k ℓ h hf.symm⟩

#print axioms kTypeOf_listSeg_replicate_eventually_periodic
#print axioms kTypeOf_listSeg_replicate_eventually_periodic_bounded

end Probe748Scratch
```

Observed output: both `#print axioms` lines report `[propext, Classical.choice, Quot.sound]`.

**Verification invocations run this round** (read-only except the scratchpad write and the issue log):
- `lake env lean <scratchpad>/replicate_periodic_probe.lean` -- exit 0, 2.3 s (2.1)
- `grep -rn "List.replicate\|eventually_periodic\|eventuallyPeriodic\|exists_idempotent\|pow_eq_pow\|IsOfFinOrder" FormalSystem/Metalogic/{WeakCanonical,Decidability/RaySummary,GroupModel}` -- nothing outside comments/READMEs (2.1)
- `grep -rn "¬ *HitPresented\|not_hitPresented\|HitPresented.*False"` over `specs/evidence/seam-gluing-ray-product/*.lean` and `RaySummary/*.lean` -- zero (2.6)
- `git ls-files --error-unmatch` over every `WIRED` and `WIRED_REPO` path; `git ls-files specs/archive` (5 files); `git check-ignore -v` on the 476 path (2.7)
- `git log --oneline --follow` and `--diff-filter=D` on the two 706/710 probe paths; `git show 70321e938 --stat`; `git log -S"specs/archive/706_lplus" -- scripts/check-evidence-probes.sh` (2.7)
- `git grep -n "specs/archive/" -- ':!specs'` -- 12 files, listed in 2.7's last paragraph where they matter (2.7)
- `grep -n "actions/cache\|uses:" .github/workflows/ci.yml`; `sed -n '108,128p;236,246p;345,362p'` (2.7)
- `jq` over `specs/state.json` for 734's `blockers`, `next_project_number`, and any project numbered above 748 (2.8)
- `lean_local_search` on `exists_ne_map_eq_of_infinite`, `exists_ne_map_eq_of_card_lt`, `List.replicate_add`, `plusStab_iff_forall_hitSig` -- index `warming`/`error` throughout; used only to locate files, never for absence
- `sed -n` reads of every file:line cited above

**The four `docs/theorem-index.md` rows cited at 2.5** (`:204-208`, opening words): "`□ψ` is a per-model datum, on EVERY task frame"; "Requirement (W) of the ray-product verdict, the ANCHOR LAYER, complete for EVERY model"; "The one bound (W) can state honestly"; "The decidable checker is on a concrete finite object and decides nothing about a model".

**Corrections to round 1** (each with the citation that settles it; a correction is worth more than a confirmation):
1. D4 / F2(2): obligation (ii) is two proof obligations of the run-layer record, not a hypothesis with no deliverable -- `README.md:378-383`, `w-soundness-shape-refuted.lean:44-49`, 747 report line 106 (2.4).
2. R1's cost: "the finite-semigroup route may not close" is retired; the route is pigeonhole and it closes (2.1). The cost is the transport lemma, which round 1's risk list named only as "`hitCl_eq_truncated` resists an exhibited `L`" without locating it in `SegmentFactorization` (2.2).
3. R1's scope: (C)'s row has a general every-model half that round 1's R1 does not cover and that no task owns; it is placed in R2 (2.2, 2.4, D12).
4. F3's coverage gap: `two_fwd_paths` is a naming gap, not a coverage gap -- `finite-graph-stab-summary.lean:44-47,82,148` and `hit-presented-model-a.lean:153` (2.6).
5. F6 / R5: 720 is not only a gate-integrity repair but a CI repair with a recurring mechanism -- `ci.yml:119-125,352-356`, `check-evidence-probes.sh:717-720`, `task-abandon-mode.md:58-65`, commits `70321e938` and `e8cfcd868` (2.7). Its run-order position moves ahead of `716,714` (D14).
6. F12: `anchorCells_ncard_le` is at `AnchorLayer.lean:324` (round 1's body text) -- the coordinator's `:325` is the `calc` line; the quoted disclaimer is `:317-320` and the `Paper:` note `:321-322` (2.5).
7. The brief's re-costing instruction was not performed by round 1; it is performed at 2.3 and found already reflected in `clSig`'s definition.

**References**
- Round 1: `specs/748_revise_and_create_tasks_lplus_decidability/reports/01_ranked-route-analysis-dispositions.md`
- Issue log for both rounds: `specs/748_revise_and_create_tasks_lplus_decidability/issues.jsonl` (this round's entries carry `dispatch_seq: 2`)
- 745 closure: `specs/745_hit_level_completeness_computable_bound/summaries/01_hit-presented-model-a-summary.md`
- 747 report: `specs/747_closure_wide_quasimodel_lift_to_validity/reports/01_closure-wide-quasimodel-characterization.md`
