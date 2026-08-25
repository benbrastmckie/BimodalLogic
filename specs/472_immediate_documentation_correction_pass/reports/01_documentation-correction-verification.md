# Research Report: Immediate documentation-correction pass

**Task**: Immediate, ungated documentation-correction pass (items (a)–(i))
**Started**: 2026-08-24
**Completed**: 2026-08-24
**Effort**: medium (documentation-only; no proof changes)
**Dependencies**: none outstanding
**Sources/Inputs**:
- The nine files in `file_scope`, read in full or in the relevant docstring blocks
- `scripts/check-module-invariants.sh --no-build` (B0, C3–C11) — full green run this pass
- `lake build` (exit 0, 2462 jobs) and `lake build BimodalTest` (exit 0, 2512 jobs) — green baseline
- `specs/reviews/review-2026-08-24.md` (C-1, H-3, L-2, A-4)
- Model: `specs/archive/467_update_decidability_readme/reports/01_decidability-readme-alignment.md`
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All nine reported defects reproduce.** Every one was independently re-verified by symbol
  (`grep -E '^(theorem|lemma|def|…) <name>\b'` over `FormalSystem/` minus `Boneyard/`) or by
  filesystem existence, not by trusting the task description's line numbers or the prose in place.
- **Six of the nine are worse than the task description states.** In each case the *same* docstring
  block carries additional false claims beyond the one named. These are listed per item below and
  are all inside `file_scope`, so correcting them costs nothing extra.
- **The largest single find**: item (e). The task says `Verified/Decidable.lean`'s Status block is
  stale about the six fresh-time producers. It is stale about *everything it lists as owed*. All 34
  `RuleSound` instances are proved, and so is the sub-phase 7.2 assembly
  `ruleSound_of_mem_allRulesForFC` — which the Status block still lists as "still owed" and which
  `Correctness.lean` already cites as landed. A second stale block sits at the same file's
  the `untlNeg`/`snceNeg` section header ("BLOCKED, two independent engine defects"), above two theorems that are proved
  ~660 lines *earlier* in the same file.
- **Item (g) is a second self-contradiction, structurally identical to item (i).**
  `ShuffleReal.lean`'s module docstring says `doets_lemma_1_5` "is stated but not proved" and is
  "carried as a documented strategic `sorry`"; the docstring on `doets_lemma_1_5` itself, in the
  same file, says "**Nothing in this module is conditional any longer.**" The theorem is proved.
- **Baseline is green.** `lake build` exit 0, `lake build BimodalTest` exit 0, and
  `check-module-invariants.sh --no-build` reports ALL CHECKS PASSED at commit `1f192f3f8`. The
  implementer inherits a clean tree; any red is theirs.
- **One in-scope grounding hazard**: three sites in `PriorExpressivenessDense.lean` cite
  `PriorDefsDense.lean:372` for `semanticPriorU_not_implies_semanticPriorUZ`, which is at line
  **373**. Live line-number rot, in a file this task edits, on the very symbol item (i) asks to
  record. Convert to a symbol reference.

## Context & Scope

`file_scope` is nine files, one per lettered item:

| Item | File |
|---|---|
| (a) | `FormalSystem/Metalogic/Decidability.lean` |
| (b) | `FormalSystem/Metalogic/Decidability/Verified/README.md` |
| (c) | `FormalSystem/Metalogic/Decidability/FMP/README.md` |
| (d) | `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` |
| (e) | `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` |
| (f) | `FormalSystem/Metalogic/WeakCanonical.lean` |
| (g) | `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` |
| (h) | `FormalSystem/Metalogic/Soundness.lean` |
| (i) | `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` |

This report does not edit any of them. It hands the implementation phase a per-item correction list
in which every replacement claim is already grounded in a named symbol or a named check.

**Method note.** Two claim-shapes recur and are worth separating, because the task constraints turn
on the difference:

- *Exists as a declaration* — checked by `grep -rnE '^(theorem|lemma|def|noncomputable def|abbrev|instance|structure|class) NAME\b' --include='*.lean' FormalSystem/ | grep -v Boneyard`. A prose
  mention is not an existence proof; several of the defects below are exactly a prose-only symbol.
- *Sorry-free* — the tree has **exactly one** structural `sorry`, `countermodel_discrete` in
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1102`, asserted by content (not line number)
  by check C3. So for any *other* declaration in the live tree, "it exists" ⇒ "it is sorry-free",
  and no separate check is needed. This is what discharges items (f), (g) and (i) mechanically.

These are different properties and the task explicitly requires saying which one holds. A third,
also distinct, is *axiom-clean*: C2's baseline records that
`FormalSystem.Metalogic.BXCanonical.completeness` depends on `sorryAx` while `completeness_dense`
and `completeness_discrete` do not. That distinction is load-bearing for item (a).

## Findings

### (a) `Decidability.lean` — Status block attributes Hilbert-system results to the tableau

**Text in place** (module docstring, `## Status` section — the block sits at the end of a docstring
whose title is "Decision Procedure for TM Logic" and whose body is entirely about the tableau
engine, so every claim in it reads as a claim about that engine):

```
## Status

- Soundness: Proven
- Completeness: Proven (via BFMCS approach)
- Proof extraction: Partial (axiom instances only)
```

**What is actually true**, verified:

1. **"Soundness: Proven" is a Hilbert-system result, not a tableau result.** The theorem is
   `FormalSystem.Metalogic.soundness` (`Soundness.lean`), `Γ ⊢[fc] φ → Γ ⊨ φ`. The tableau's own
   soundness statement is `decide_sound` (`Decidability/Correctness.lean`), `⊢ φ → ⊨ φ`, which
   `Correctness.lean` derives *from* `soundness` at the empty context — i.e. the tableau contributes
   the derivation, not the soundness. `Correctness.lean` says so in its own words: "`decide_sound`
   … is the real one-directional fact."
2. **"Completeness: Proven (via BFMCS approach)" is likewise not the tableau's.** The theorems are
   `FormalSystem.Metalogic.BXCanonical.completeness` / `completeness_dense` / `completeness_discrete`
   (`BXCanonical/Completeness.lean`). "BFMCS" names the `Metalogic/Bundle/` canonical-frame
   construction (`Metalogic.lean`: "**Bundle/**: BFMCS infrastructure"), which is not part of
   `Decidability/` at all. **And the four-word parenthetical hides a real qualification**: per C2's
   recorded baseline, `completeness` depends on `sorryAx`; `completeness_dense` and
   `completeness_discrete` do not. So the honest statement distinguishes the class-specific results
   (proved *and* sorry-free) from the Base-class one (proved, not sorry-free).
3. **The tableau's own completeness direction is open, and this file's own subdirectory says so.**
   `Correctness.lean` carries a section titled "`validity_decidable` /
   `validity_has_decision_procedure` — Retired as vacuous", recording that two theorems with those
   names were removed because "their *names* claimed a decidability result their *proofs* did not
   contain" (one was `Classical.em (⊨ φ)`; the other the same with a `Bool` around it). It then
   states what is still owed: "`isValid φ fc = true ↔ ⊨ φ`, and the `Decidable (⊨ φ)` instances for
   the four frame classes … That obligation is open." The aggregator's Status block is the exact
   overclaim that section exists to prevent, one directory up.
4. **What the tableau side *has* proved** and can be claimed without qualification:
   `ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean`) — every rule `allRulesForFC` can
   schedule at a frame class preserves satisfiability under that class's carrier property, all 34,
   sorry-free. This is the rule half of `allClosed → valid`. It is not `valid_iff_allClosed`.

**Also false in the same block, not named in the task**: "Proof extraction: Partial (axiom instances
only)". `extractProof` (`ProofExtraction.lean`) runs **five** strategies in order — `tryAxiomProof`,
`matchDerived`, the closure-based `.axiomNeg` filter, `buildCompositionalProof`, and
`enhancedSearch` — before returning `.incomplete`. "Axiom instances only" describes strategy 1 of 5.
"Partial" remains correct; the parenthetical does not.

**Correction shape.** Make the subject of each claim explicit and name the theorem. Suggested
grounding (every symbol below verified present):

- Soundness of the **proof system** — `Metalogic.soundness`, with `Decidability.decide_sound` the
  corollary at the empty context that `decide`'s `.valid` witness consumes.
- Completeness of the **proof system** — `BXCanonical.completeness_dense` and
  `completeness_discrete` (sorry-free per C2); `BXCanonical.completeness` at `.Base` (proved,
  `sorryAx`-dependent per C2).
- Soundness/completeness of **this directory's decision procedure** — the rule half of
  `allClosed → valid` is `ruleSound_of_mem_allRulesForFC`; the `isValid ↔ ⊨` biconditional and the
  `Decidable (⊨ φ)` instances are open, per `Correctness.lean`'s retirement section.
- Proof extraction — five strategies, `.incomplete` on exhaustion; drop "axiom instances only".

### (b) `Verified/README.md` — Layout table diverges from the live tree in three directions

The live tree under `FormalSystem/Metalogic/Decidability/Verified/` is **21 `.lean` files** plus
`README.md`, and **all 21 are imported directly by the `FormalSystem/Metalogic/Decidability.lean`
aggregator** (counted against that file's import block; C4 confirms all 1388 import lines in the
tree resolve). The README's Layout table has 15 rows. Cross-referencing:

**FALSE — marked `planned`, but the file exists, compiles, and is imported (8 rows, exactly as
reported):**

| Row | Live size |
|---|---|
| `Termination/TimeTypeBound.lean` | 1,995 lines |
| `Termination/Fuel.lean` | 2,762 lines |
| `Bridge/Carrier.lean` | 239 lines |
| `Bridge/BranchOrder.lean` | 474 lines |
| `Bridge/Embed.lean` | 118 lines |
| `Bridge/Interpolate.lean` | 720 lines |
| `Bridge/TruthLemma.lean` | 521 lines |
| `Decidable.lean` | 3,171 lines |

**OMITTED — exists and is imported, but has no row (11 files, exactly as reported):**

`Termination/MintBound.lean` (12,994 lines — the largest file in the subtree by a factor of four,
and entirely absent from the table), `Bridge/RegionFrame.lean` (580), `Bridge/Valuation.lean` (713),
`Bridge/BoxSaturation.lean` (642), `Bridge/PropSaturation.lean` (108),
`Bridge/TemporalSaturation.lean` (257), `Bridge/RegionLabel.lean` (490),
`Bridge/TemporalGate.lean` (724), `Bridge/IntGaps.lean` (173), `Bridge/IntTruth.lean` (1,088),
`Bridge/DenseTruth.lean` (687).

**ABSENT — no such path exists in the tree (5 rows), and this is the register collision:**

| Row | Marker in place | Exists? |
|---|---|---|
| `Internalize.lean` | planned | no |
| `Refutation/Core.lean` | planned | no |
| `Refutation/Rules/*.lean` | planned | no |
| `Bridge/Omega.lean` | planned | no |
| `Provable.lean` | deferred | no |

So `planned` currently means both "exists and is done" (8 rows) and "does not exist" (4 rows). A
reader cannot tell which sense applies to any given row — which is the defect.

**Compounding**: the paragraph immediately under the table asserts "Nothing in this table is a
placeholder file — a path exists here only once its contents do." That sentence is *false as
written* in the other direction too: `Internalize.lean`, `Refutation/*`, `Bridge/Omega.lean` and
`Provable.lean` are exactly paths in the table whose contents do not exist.

**Correction shape.** Rebuild the table against the 21 live files with a two-value status vocabulary
that is mechanically checkable rather than aspirational:

- `landed` — file exists and is imported by the `Decidability.lean` aggregator. Checkable by
  `test -f` plus a grep of the aggregator's import block; C4 keeps the import resolvable.
- `not built` — no such path exists. Checkable by `test -e`.

Both are reproducible; neither asserts anything about schedule or intent, which is where the current
table goes wrong. Keep the 5 absent rows (they record a designed-but-unbuilt route and are worth
keeping visible) but move them under their own subheading with the `not built` marker, so the two
registers cannot be confused. Where a successor is known, say so in the Contents column rather than
inventing a third status — e.g. `Bridge/Omega.lean`'s "history construction and shift-closure" is
covered by `Bridge/RegionFrame.lean`, whose aggregator description reads "its region histories, the
fact that those are exactly the frame's total histories — which is what `valid` quantifies over".

**The Contents column can be written without new research.** `Decidability.lean`'s module docstring
already carries a one-to-three-line description of **every one of the 21 files**, written against the
current code. Lifting those is both cheaper and less rot-prone than composing new ones, and it keeps
the two files in agreement.

**Cross-file consistency check (informational, no edit needed)**: the parent
`Decidability/README.md` already carries an accurate row — "`Verified/` | Correctness theory for the
tableau engine … all files imported by the aggregator … (21 files) | Sorry-free" — and links to this
README. That row is correct and out of scope; the fix here brings the child into line with it.

**Optional, low priority**: unlike its siblings `FMP/README.md` and `Decidability/README.md`, this
README carries no "Related Documentation" section and no `Last verified` stamp. Adding them matches
the directory convention.

### (c) `FMP/README.md` — two Key Results do not exist, and all six Modules line counts are wrong

**Verified absent** (zero occurrences anywhere in `FormalSystem/` outside `Boneyard/`, as
declarations *or* as prose mentions): `filtration_is_finite`, `truth_preserved_under_filtration`.
This confirms review issue L-2.

**Verified present**, and available as replacements (all sorry-free by C3):

| Symbol | File | What it says |
|---|---|---|
| `fmp_contrapositive` | `FMP.lean` | `(∀ S : ClosureMCSBundle φ, φ ∈ S.carrier) → Derivable .Base [] φ` — the FMP-based completeness direction |
| `mcs_finite_model_property` | `FMP.lean` | `¬Derivable .Base [] φ → ∃ S, φ ∉ S.carrier ∧ Finite (FilteredWorld φ)` |
| `assignmentSpace_card` | `FMP.lean` | the assignment space has exactly `2^|closure φ|` elements |
| `filtered_world_bound` | `FMP.lean` | `Nat.card (FilteredWorld φ) ≤ 2^|closure φ|` |
| `fmp_size_bound` | `FMP.lean` | the FMP countermodel is finite and bounded by `2^|closure φ|` |
| `FilteredWorld.finite` | `FiniteModel.lean` | `noncomputable instance` — the filtered world type is finite |
| `filteredCharacteristicSet_injective` | `FiniteModel.lean` | the injection the cardinality bound rides |
| `filtration_lemma_membership`, `filtration_imp_forward`, `filtration_box_forward`, `filtration_lemma_bot` | `TruthPreservation.lean` | the filtration lemma, **as membership**, one clause per connective |
| `exists_lt_iter_of_card_le`, `exists_bounded_iter` | `Periodicity.lean` | already correctly listed; keep verbatim |

The `TruthPreservation.lean` row matters for honesty: the four `filtration_*` theorems are exactly
the "truth preservation" content the deleted `truth_preserved_under_filtration` name gestured at,
but they are stated as **MCS membership** facts, not as `TruthAt` facts — which is precisely what the
README's own "These theorems are about MCS membership, not about truth" section already explains.
Naming them makes that section's claim checkable instead of merely asserted.

**The two facts the task says to keep are already there and are accurate**:

- "This directory contains **zero** occurrences of `TruthAt`": `grep -c TruthAt` over the six files
  gives `0 0 0 1 0 0`. The single hit is `FMP.lean:231` — and it is *this very sentence*, in prose:
  "`TruthAt` occurs **zero** [times]". So the claim is true of the code and self-referentially
  witnessed. Keep it; the implementer should not "fix" the count to 1.
- "`refinedFilteredTaskRel` is permissive": `def refinedFilteredTaskRel` is present in
  `Filtration.lean`, and the README quotes its body correctly
  (`fun w d u => if d = 0 then w = u else True`).

**Also wrong in the same file, not named in the task** — the Modules table's Lines column, every row:

| File | README says | Actual |
|---|---|---|
| `ClosureMCS.lean` | 279 | 289 |
| `Filtration.lean` | 323 | 487 |
| `FiniteModel.lean` | 177 | 231 |
| `FMP.lean` | 248 | 345 |
| `Periodicity.lean` | 210 | 239 |
| `TruthPreservation.lean` | 400 | 409 |

Six for six. Recommendation: **replace the Lines column with a declaration count**, which is what a
reader of a proof directory actually wants and which rots an order of magnitude slower
(`grep -cE '^(theorem|lemma|def|abbrev|instance|noncomputable def|structure) '`): ClosureMCS 16,
Filtration 29, FiniteModel 13, FMP 10, Periodicity 7, TruthPreservation 16. If the Lines column is
kept, correct all six.

**Also wrong in the same file**: the Dependencies section uses the **pre-rename `Bimodal.*`
namespace** — "Imports from: `Bimodal.Metalogic.Core.RestrictedMCS`, `Bimodal.Syntax.SubformulaClosure`" and "Imported by: `Bimodal.Metalogic.Decidability`". The live namespace is
`FormalSystem.*`. These slip past check C5 precisely *because* C5 only resolves module-shaped
`FormalSystem.*` paths — a stale `Bimodal.*` path is invisible to it. Renaming them to
`FormalSystem.*` both fixes the claim and brings them under C5's guard, so the next drift is caught.

**Stale footer**: `*Last verified: 2026-05-29*`.

### (d) `DecisionProcedure.lean` — `decideAuto` claims a termination guarantee no theorem supports

**Text in place** (docstring of `def decideAuto`):

> Uses `soundFuel` (from subformula closure cardinality) instead of the ad-hoc `recommendedFuel`
> heuristic. Combined with subset blocking in `expandBranchWithFuel`, this ensures termination for
> all formulas.

**Verified**, four separate ways:

1. **`decideAuto` runs below `soundFuel'`.** `decideAuto φ fc = decide φ (5 + φ.complexity / 2) (soundFuel φ) fc`, and `soundFuel` (`Saturation.lean`) is `min (n * 2^n) 100000` — capped. The
   uncapped figure is `soundFuel' φ = 2 * n * 2^(2*n)` (`Verified/Termination/Fuel.lean`), and
   `theorem soundFuel_le_soundFuel'` proves `soundFuel φ ≤ soundFuel' φ` outright. So the runtime
   figure is provably ≤ the justified one, and `soundFuel'`'s own docstring says the cap "is exactly
   what stops it from being a justified bound: a quadratic constant cannot cover an exponential step
   count."
2. **`soundFuel'` is itself insufficient in general.** `chain_le_soundFuel'` reaches `soundFuel'`
   only under hypothesis `hL` (label count at the T2 figure), and its own docstring records: "**`hL`
   is not dischargeable in general** … `hL` asks for `|worlds| * |times|` to sit under the T2 *time*
   figure, which holds only when the run stays in a single world … `hL` fails as soon as any
   `boxNeg` or `diamondPos` fires. … therefore `soundFuel'` is not the general fuel figure." The
   general figure is `chain_le_worlds_bounded`'s / `worldFuel'`, larger by about `2*|C|*2^(2*|C|)`.
3. **The obligation the claim would need does not exist.** `buildTableau_isSome` is **absent** as a
   declaration. `Fuel.lean` states why: "The plan's named deliverable was `buildTableau_isSome` at
   `soundFuel'`, and it is **false as stated**", because `buildTableau` calls
   `expandBranchWithFuel` at `maxBranches := 50000`, "whose very first line returns `none` once
   `branchesUsed` reaches that figure, at *any* fuel whatsoever."
4. **What *is* proved**, and is the honest replacement — two theorems, both present, both
   sorry-free, both hypothesis-bearing:
   - `expandBranchWithFuel_isSome_of_noSplit`
   - `expandBranchWithFuel_isSome_of_stock` — totality of the expansion given a formula stock `C`, a
     label set `L`, `NoSplit P fc`, fuel `> 2 * C.card * L.card`, and `branchesUsed + fuel ≤ maxBranches`.

   Note all three hypothesis families: no splitting, a confined label set, and a branch budget that
   accommodates the fuel. `Fuel.lean` names the split case as "a genuinely separate obligation — it
   needs `resolveOpenArm`, which has its own `none`".

**Correction shape.** State what `decideAuto` actually guarantees: it terminates because it is a
*total function at a finite fuel figure* — every path returns a `DecisionResult`, with
`.fuelExhausted` a first-class outcome — and *not* because any theorem rules out `.fuelExhausted`.
Then say what is bounded and under what hypotheses (`expandBranchWithFuel_isSome_of_stock`), and that
`soundFuel` is a capped runtime default dominated by `soundFuel'` (`soundFuel_le_soundFuel'`), which
is itself the single-world figure only. Subset blocking is a real and useful mechanism — `Fuel.lean`
measures `buildTableau ((G p) → □(G p)) n .Base` as `none` for every `n ≤ 24` and `hasOpen` for every
`n ≥ 25`, four orders of magnitude below `soundFuel'` — so keep the observation, but as a measured
behaviour with its witness named, not as a universally quantified guarantee.

### (e) `Verified/Decidable.lean` — the Status block is stale about *every* item it lists as owed

**Text in place** (module docstring, `## Status`):

> Still owed by sub-phase 7.2: the four fresh-*time* existential rules (`allFutureNeg`,
> `allPastNeg`, `someFuturePos`, `somePastPos`); `untlPos`/`untlNeg`/`sncePos`/`snceNeg`; the two
> dense, three discrete and three Dedekind rules; and the assembly
> `∀ r ∈ allRulesForFC fc, RuleSound _ r` via `RuleSpec.mem_allRulesForFC_iff`.
>
> All six fresh-*time* producers are blocked on a defect in `RuleSound`'s own statement, not on
> proof effort … Two remedies are priced there; both change a definition the landed rules are
> stated against, so both are escalated rather than taken.

**Every item on that owed-list is now a proved, sorry-free theorem in this same file.** Verified by
declaration grep — 34 `ruleSound_*` theorems, plus the assembly:

| Owed-list item | Status | Symbol |
|---|---|---|
| four fresh-time existentials | **proved** | `ruleSound_allFutureNeg`, `ruleSound_allPastNeg`, `ruleSound_someFuturePos`, `ruleSound_somePastPos` |
| `untlPos`/`sncePos` | **proved** | `ruleSound_untlPos`, `ruleSound_sncePos` |
| `untlNeg`/`snceNeg` | **proved** | `ruleSound_untlNeg`, `ruleSound_snceNeg` |
| two dense rules | **proved** | `ruleSound_densityRule` (`carrierDense`), `ruleSound_denseIndicatorClosure` (`carrierBase`) |
| three discrete rules | **proved** | `ruleSound_priorUZ`, `ruleSound_priorSZ`, `ruleSound_z1Rule` (`carrierDiscrete`) |
| three Dedekind rules | **proved** | `ruleSound_priorUGap`, `ruleSound_priorSGap`, `ruleSound_sepRule` (`carrierDedekind`) |
| **the 7.2 assembly** | **proved** | `ruleSound_of_mem_allRulesForFC (fc) (r) (h : r ∈ allRulesForFC fc) : RuleSound (carrierForFC fc) r`, by `cases fc <;> cases r` over all 34, riding `ruleSound_base_mono` for 27 of them |

**And the stated obstruction is retracted elsewhere in the same file.** The Status block says the six
fresh-time producers are blocked on an `ordResp`/`OrdWithin` defect in `RuleSound`'s statement. The
`untlNeg`/`snceNeg` section states the opposite: "Neither obstruction is the ordering gap this
section's predecessors were about. **That gap is closed**: `OrdWithin` is in `RuleSound`, and the
four fresh-time existentials above are proved against it."

`Correctness.lean` has already been updated to the true state and now *contradicts* this file's own
Status block: "`ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean`) is the rule half of the
`allClosed → valid` direction: every rule `allRulesForFC` can schedule at a frame class preserves
satisfiability under that class's carrier property, all 34 of them, sorry-free."

**Second stale block in the same file, not named in the task** — the section header

```
## `untlNeg` and `snceNeg` — BLOCKED, two independent engine defects
```

and its body ("This section is retained because `untlNeg`/`snceNeg` are still blocked"; "Defect 2 …
still open, and it alone is why these two rules remain unproved"). `ruleSound_untlNeg` and
`ruleSound_snceNeg` are proved roughly 660 lines **above** this header. The section's own "Current
status" paragraph already records that the ACTIVE arms were repaired and gated on the conformance
corpus; what it did not get is the final update once the PASSIVE arm was retired — and the retirement
is recorded elsewhere in the file, in `exists_gt_not_untl_disj`'s docstring: "the whole difference
between the **retired PASSIVE arm** and the surviving ACTIVE one".

**Correction shape.** Rewrite `## Status` as a landed/open split with the assembly named:

- **Landed**: all 34 `RuleSound` instances (list by carrier: 27 at `carrierBase` via
  `ruleSound_base_mono`, `densityRule` at `carrierDense`, three at `carrierDiscrete`, three at
  `carrierDedekind`), and the sub-phase 7.2 assembly `ruleSound_of_mem_allRulesForFC`. Sorry-free,
  per C3.
- **Not landed**: `valid_iff_allClosed` (sub-phase 7.3), which additionally needs the
  fuel/termination side and the truth-lemma gate; and the two rules scheduled outside
  `allRulesForFC` — `serialityRule` and `timeLinearity`, stages 2 and 3 of `expandOnce` — which need
  their own obligations at the point where `expandOnce`, not `applyRule`, is the object. Both of
  these are already stated correctly in `ruleSound_of_mem_allRulesForFC`'s own docstring; lift that
  wording rather than composing new.
- Delete the "blocked on a defect in `RuleSound`'s own statement" paragraph and the two escalated
  remedies, or retain them explicitly as a past-tense record with the closure noted (the file's own
  convention elsewhere — "Read Defect 1 below in the past tense" — supports the latter).
- Retitle the `untlNeg`/`snceNeg` section so the header does not say BLOCKED, and convert its body to
  past tense, keeping the counterexample material (it is genuinely instructive and explains why the
  PASSIVE arm was retired).

### (f) `WeakCanonical.lean` — five nonexistent sorries, plus a stale architecture line and a stale fallback claim

**Text in place** (`## Status`):

> The full Reynolds construction has documented sorries at:
> - Truth lemma: G/H backward, Until/Since
> - KEquivalenceFramework: awaiting Tarski semantics instance
> - Table correctness: monadic FO satisfaction deferred
> - One-class theorem: depends on gap-elimination lemmas
> - chronicle_is_good: cofinal sequence construction
>
> All definitions are NON-VACUOUS … Sorries are clean … Currently delegates to the chronicle
> construction as interim fallback. The structural Reynolds pipeline is fully wired for activation
> when the Phase 3-5 sorries are resolved.

**Verified**: a structural-sorry scan over `FormalSystem/Metalogic/WeakCanonical/` (same regex C3
uses, `Boneyard/` excluded) returns **exactly one** hit —
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1102`, inside `theorem countermodel_discrete`.
None of the five bullets survives:

| Bullet | Verified state |
|---|---|
| Truth lemma G/H backward | `G_backward_mcs` and `H_backward_mcs` exist in `WeakCanonical/TruthLemma.lean` and are sorry-free |
| Truth lemma Until/Since | no sorry anywhere in `TruthLemma.lean` |
| `KEquivalenceFramework` | exists as `class KEquivalenceFramework` in `NEquivalence.lean`; no sorry |
| Table correctness | `table_correctness` exists in `Table.lean`; no sorry |
| One-class theorem / `chronicle_is_good` | **`chronicle_is_good` does not exist as a declaration at all** — this bullet names a symbol that is not in the tree |

**Also stale in the same docstring, not named in the task:**

- Architecture line 2: "**TruthLemma**: Truth lemma (atom/bot/imp proved, **rest sorried**)". False
  by the same scan.
- Architecture line 7: "**Table**: Temporal-to-monadic table translation (**deferred**)".
  `Table.lean` is 296 lines with `table`, `table_depth_bound`, `TemporalTruth` and
  `table_correctness` all landed.
- "Currently delegates to the chronicle construction as interim fallback. The structural Reynolds
  pipeline is fully wired for activation when the Phase 3-5 sorries are resolved." The chronicle
  chain is **archived** — this same docstring says so eight lines earlier ("that whole chain is
  archived — see `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`") — so it
  cannot be a live fallback, and there are no Phase 3-5 sorries left to resolve.

**Verified accurate; keep verbatim** (the `## Main Export` block is the one part of this docstring
that is current): `countermodel_discrete` carries the repository's sole live `sorry`; the sorry-free
discrete result is `completeness_discrete`, via `countermodel_discrete_reynolds_v2`, which exists at
`WeakCanonical/IntegerModel/ReynoldsBridge.lean`. Both symbols verified present.

**Correction shape.** Replace the five bullets with the single true statement, anchored to the check
rather than to a line number: the subtree carries exactly one structural `sorry`,
`countermodel_discrete` in `WeakCanonical/Transfer.lean`, which check C3 asserts **by content** (it
locates the enclosing declaration by scanning backwards, never by line number). Note that
`completeness_discrete` — the result a consumer wants — routes around it via
`countermodel_discrete_reynolds_v2` and is sorry-free. Fix the two architecture lines and delete the
interim-fallback paragraph.

### (g) `RealModel/ShuffleReal.lean` — module docstring contradicts the theorem docstring below it

**Text in place** (module docstring, "What is landed here, and what is not"):

> **`doets_lemma_1_5` is stated but not proved.** … the two-index case is not in the tree and is not
> derived here. It is carried as a documented strategic `sorry` with the follow-up named in the
> docstring …
>
> The `≡ₖ` fact about the coloured index orders themselves … is likewise not proved here. It is
> carried as an **explicit hypothesis** of `kEquiv_shuffle_shuffleReal` rather than as a second
> `sorry` …

**Verified**: `theorem doets_lemma_1_5` exists in this file and its body is
`kEquiv_orderedSum_of_kEquiv_colour k m m' hcol` — a term, not a `sorry`. By C3 the file carries no
structural `sorry`. **Both** quoted paragraphs are false, and the file already says so, in
`doets_lemma_1_5`'s own docstring ~165 lines below the module block:

> **Nothing in this module is conditional any longer.** The order-theoretic properties of `R` … were
> already proved outright, and `kEquiv_shuffle_shuffleReal` — this lemma's only consumer — now is too.

And the second paragraph is refuted by the actual signature: `kEquiv_shuffle_shuffleReal (k) (N) (hγ : γ₁ ∈ S) (hσ : IsShuffleMap S σ)` takes no `hcol`. `kEquiv_shuffle_shuffleReal`'s own docstring
records the removal: the `≡ₖ` colour fact "is now **proved**, by `kEquiv_colourStructure`
(`ColourOrders.lean`) … It was carried as an explicit hypothesis `hcol` while it was open; **that
hypothesis is gone**".

**Third stale line, one sentence later in that same docstring**: "The only thing this theorem is
still conditional on is `doets_lemma_1_5` itself." Vacuous now that `doets_lemma_1_5` is proved.

**Correction shape.** Rewrite the module docstring's "What is landed here, and what is not" section
to match the theorem docstrings: `doets_lemma_1_5` is proved via
`kEquiv_orderedSum_of_kEquiv_colour` (with `BackAndForth.lean`'s `BackForth`/`kEquiv_iff_backForth`
and `MixedSum.lean`'s `Mixed`/`backForth_of_mixed` supplying the engine — all named in the theorem
docstring); the coloured-index `≡ₖ` fact is proved by `kEquiv_colourStructure`; the module is
sorry-free and unconditional. Keep the Doets/Reynolds provenance prose — it is accurate and is the
module's value. Delete the trailing "still conditional on `doets_lemma_1_5`" sentence.

### (h) `Soundness.lean` — an inference rule and a file that do not exist, plus a broken doc link

**Verified absent:**

- **`IRRSoundness.lean` does not exist**, anywhere in the repository (`find . -iname '*IRRSoundness*'`
  returns nothing outside `.lake`). It is cited **twice**: once in the numbered soundness-components
  list ("6. **IRR rule**: Sound by construction (see IRRSoundness.lean)") and once as a Markdown link
  in `## References` (`[IRRSoundness.lean](./IRRSoundness.lean)`).
- **There is no IRR rule in the proof system.** `inductive DerivationTree` (`ProofSystem/Derivation.lean`) has exactly seven constructors — `axiom`, `assumption`, `modus_ponens`,
  `necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening` — and
  `Derivable.lean`'s own docstring lists the same seven mirroring lemmas. There is nothing for an IRR
  soundness clause to be about. (The `ProofSystem/` hits for "irr" are all `irreflexive`/`irrational`
  and unrelated; `Axioms.lean` mentions IRR only in a bibliographic comment citing Reynolds' 1992
  title, "…without the IRR rule".)
- **`irr_sound_dense_at_domain` does not exist as a declaration.** Every occurrence is prose inside
  `Soundness.lean` itself (three sites, in the notes attached to `soundness_dense_valid` and
  `soundness_dense`), describing an IRR case that the derivation type has no constructor for.

**Verified present, and unaffected** — the rest of the numbered list checks out:
`derivable_implies_swap_valid` (`SoundnessLemmas/DenseValidity.lean`) and
`derivable_implies_swap_valid_discrete` (`SoundnessLemmas/FrameClassVariants.lean`) both exist, and
`SoundnessLemmas.lean` plus the `SoundnessLemmas/` directory exist as linked.

**One more broken reference in the same block, not named in the task**:
`[architecture.md](../../../docs/user-guide/architecture.md)`. The file exists at
`docs/user-guide/architecture.md`, but relative to `FormalSystem/Metalogic/`, `../../` is already the
repository root — so `../../../` points one level *above* it. The correct link is
`../../docs/user-guide/architecture.md`. This is invisible to check C5, which lints markdown files;
this link lives in a `.lean` docstring.

**Correction shape.** Delete list item 6 and the `IRRSoundness.lean` reference link — with seven
`DerivationTree` constructors and no IRR among them, there is nothing to replace them with; the
numbered list should enumerate the constructors the soundness induction actually cases on. Remove or
rewrite the three `irr_sound_dense_at_domain` prose notes. Fix the `architecture.md` link depth.

**Verified accurate; do not touch**: this file's own claims "All soundness theorems are sorry-free"
and the three `(sorry-free)` annotations on `soundness` / `soundness_dense` / `soundness_discrete`.
C3 confirms them, and the Frame-Class Architecture block is otherwise current.

### (i) `PriorExpressivenessDense.lean` — the self-contradiction, and three further stale sites

**The contradiction, both halves verified in place** (review issue A-4 confirms it independently):

- "What this module lands" bullet: "`uSExpressivelyCompleteOverDensePrior` — the plan-shaped target,
  obtained from the conditional by the single open obligation. **It carries this module's only
  `sorry`**, isolated in `kampFaithfulExpressiveCompleteness_open`."
- Section heading ~130 lines later: "## The plan-shaped target — **DISCHARGED** … **This module is
  now sorry-free**, and with it the whole route: the obligation below was the only gap."

**The second is correct**, by C3 (sole tree sorry is in `Transfer.lean`) and by the code:
`kampFaithfulExpressiveCompleteness` is a real definition delegating to
`Kamp.kampPriorExpressiveCompletenessFaithful`, and `kampFaithfulExpressiveCompleteness_open` is now
a **retained alias** for it — its own docstring says "This *was* the module's strategic sorry; it is
now `kampFaithfulExpressiveCompleteness` under its former name, at the same type and with no
weakening … it no longer contributes `sorryAx` to anything downstream."

**Three further sites stale for the same reason** (all in the same file, all in scope):

1. "What this module lands", first bullet: "`KampFaithfulExpressiveCompleteness` — **the open
   obligation, named and stated** … stated as a type rather than proved, because the measurement
   above shows it is a re-base of the whole zeta wire and not a composition." It has since been
   proved, in four sorry-free rungs that the DISCHARGED section enumerates
   (`Kamp.kampArm_zeta_faithful`, `Kamp.aggOdPopFold_iff_faithful`, the bridge/trichotomy files,
   and `Kamp/KampPriorFaithful.lean`). All four anchor symbols verified present.
2. `uSExpressivelyCompleteOverDensePrior`'s docstring: "**Rests on one open obligation**,
   `kampFaithfulExpressiveCompleteness_open`; see its docstring."
3. `uSExpressivelyCompleteOverDensePrior_at_denseWindow`'s docstring: "it does not inherit **the open
   obligation's `sorry`** … This is the strongest anti-vacuity statement available **while the
   obligation is open**."

**The Reynolds Theorem 3 point the task asks to record is already in the file, and is accurate.**
`uSExpressivelyCompleteOverDensePrior`'s docstring states: "**this declaration is Reynolds' Theorem
3**, whereas `uSExpressivelyCompleteOverPrior`, pinned at the strictly stronger `SemanticPriorUZ` /
`SemanticPriorSZ`, is not". Verified: `noncomputable def uSExpressivelyCompleteOverPrior` exists in
`PriorExpressiveness.lean`; `theorem semanticPriorU_not_implies_semanticPriorUZ` exists in
`PriorDefsDense.lean` and exhibits `denseRayFlow` satisfying `SemanticPriorU ∧ SemanticPriorS` while
refuting `SemanticPriorUZ`; `uSExpressivelyCompleteOverDensePrior_not_by_reuse` is stated in this
file. So the task's instruction here is **keep and strengthen, not add** — the correction is to make
sure the header's version of the point survives the rewrite of the surrounding bullets, and to note
explicitly that `uSExpressivelyCompleteOverDensePrior` is now unconditional, which is what makes it
Theorem 3 outright rather than Theorem 3 modulo an obligation.

**Grounding hazard, in scope, must be fixed**: this file cites `PriorDefsDense.lean:372` for
`semanticPriorU_not_implies_semanticPriorUZ` at **three** sites. The theorem is at line **373**.
Live off-by-one rot on the exact symbol item (i) turns on. Replace with a symbol reference
(``semanticPriorU_not_implies_semanticPriorUZ` (`PriorDefsDense.lean`)`) at all three.

The file carries **30** line-number citations in total; the other 27 spot-checked resolve correctly
today (`PriorExpressiveness.lean:357`, `Kamp/KampPrior.lean:363` and `:672`,
`Kamp/KPlusFaithful.lean:474`/`:524`, `Kamp/ZetaUniformExtractFaithful.lean:522`,
`Kamp/NfMultiAnchorBridge/AggregateOffDiagK1Faithful.lean:89`, `AggregateOffDiagK1.lean:1226` all
confirmed exact). Converting all 30 is a larger diff than this task needs; converting the ones inside
rewritten passages, plus the three wrong `:372`s, is the proportionate call.

## Decisions

- **Two-value status vocabulary for (b)** — `landed` / `not built` — chosen over keeping
  `planned`/`deferred` because both new values are mechanically checkable (`test -f` plus the
  aggregator import block) and neither asserts intent. This is what makes the register collision
  impossible to reintroduce.
- **Lift Contents-column text for (b) from `Decidability.lean`'s aggregator docstring** rather than
  composing new descriptions. It covers all 21 files, is written against current code, and keeps the
  two files in agreement instead of creating a second thing to drift.
- **Replace FMP's Lines column with a declaration count.** All six line figures are already wrong;
  a count that rots more slowly is a better trade than six corrected numbers that will rot again.
  Flagged as a recommendation, not a mandate — correcting the six figures is an acceptable
  alternative.
- **Fix the six defects found beyond the task's nine** (the extra false claims in (a), (c), (e),
  (f), (g), (h) noted above). Each is inside `file_scope`, inside the same docstring block being
  edited, and of the same defect class. Leaving them would mean shipping a corrected block with a
  known-false line still in it.
- **Do not widen scope to `FMP/FMP.lean`** even though its module docstring lists
  `finite_model_property` under "Main Results" and no such declaration exists (the real one is
  `mcs_finite_model_property`). It is outside `file_scope`. Recorded below as a follow-up.
- **Convert line-number citations to symbol references only inside rewritten passages**, plus the
  three wrong `PriorDefsDense.lean:372` sites. A whole-file conversion of all 30 citations in
  `PriorExpressivenessDense.lean` is disproportionate to a prose-correction task.

## Risks & Mitigations

- **Risk**: docstrings are compiled, so a malformed `/-!` … `-/` block breaks `lake build`. Items
  (a), (d), (e), (f), (g), (h), (i) all edit `.lean` docstrings, and several contain backticked Lean
  syntax and Unicode (`⊨`, `≡ₖ`, `→`, `∀`).
  **Mitigation**: the baseline is green (both builds verified exit 0 this pass), so any failure is
  attributable to the edit; edit one file at a time and rebuild. Nested `/-` inside `/-!` is the
  usual culprit — the DISCHARGED section of `PriorExpressivenessDense.lean` and the untlNeg section
  of `Verified/Decidable.lean` are the two longest blocks being restructured.
- **Risk**: item (e) is a 3,171-line file whose Status block and `untlNeg`/`snceNeg` section are
  ~2,750 lines apart, and the file's convention is to retain superseded prose in the past tense
  rather than delete it. A careless rewrite could delete the counterexample material, which is
  genuinely load-bearing (it explains why the PASSIVE arms were retired).
  **Mitigation**: retitle and re-tense; delete only claims about *current* status, never the
  measured refutations.
- **Risk**: (b) rebuilds a table against a tree that other in-flight tasks may be changing.
  **Mitigation**: the status values chosen are re-derivable in one command, and C4 fails loudly if
  an aggregator import stops resolving. Re-run `check-module-invariants.sh` immediately before
  committing.
- **Risk**: writing "sorry-free" where only "proved" holds, or vice versa. The task calls this out
  explicitly and item (a) is where it bites — `BXCanonical.completeness` is proved but `sorryAx`-
  dependent, while `completeness_dense`/`completeness_discrete` are both.
  **Mitigation**: C2's baseline is the authority; quote its distinction rather than paraphrasing.

## Verification Recipe for the Implementation Phase

Each item's corrected claims are re-checkable by the following, all of which pass on the current
tree and should still pass afterwards:

```
bash scripts/check-module-invariants.sh            # C1-C11, including build + axiom baseline
lake build && lake build BimodalTest               # both must exit 0
git diff --name-only                               # must be a subset of file_scope (9 files)
```

Plus, for the "no claim names a nonexistent declaration" acceptance criterion, per touched file:

```
# extract backticked identifiers from the touched docstrings and confirm each resolves
grep -rnE '^(theorem|lemma|def|noncomputable def|abbrev|instance|structure|class) NAME\b' \
  --include='*.lean' FormalSystem/ | grep -v Boneyard
```

The symbols this report asserts as **present** (safe to cite): `soundness`, `decide_sound`,
`decide_sound'`, `decide_result_exclusive`, `fmp_completeness`, `fmp_incompleteness_witness`,
`countermodel_size_bound`, `BXCanonical.completeness`, `completeness_dense`, `completeness_discrete`,
`ruleSound_of_mem_allRulesForFC`, `ruleSound_base_mono`, `carrierForFC`, all 34 `ruleSound_*`,
`soundFuel`, `soundFuel'`, `soundFuel_le_soundFuel'`, `chain_le_soundFuel'`, `chain_le_stock`,
`chain_le_worlds_bounded`, `worldFuel'`, `timeFinset_card_le_of_not_blocked`,
`expandBranchWithFuel_isSome_of_noSplit`, `expandBranchWithFuel_isSome_of_stock`,
`fmp_contrapositive`, `mcs_finite_model_property`, `assignmentSpace_card`, `filtered_world_bound`,
`fmp_size_bound`, `FilteredWorld.finite`, `filteredCharacteristicSet_injective`,
`filtration_lemma_membership`, `filtration_imp_forward`, `filtration_box_forward`,
`filtration_lemma_bot`, `refinedFilteredTaskRel`, `mem_HF_iff_adjacent`,
`exists_lt_iter_of_card_le`, `exists_bounded_iter`, `countermodel_discrete`,
`countermodel_discrete_reynolds_v2`, `G_backward_mcs`, `H_backward_mcs`, `KEquivalenceFramework`,
`table_correctness`, `doets_lemma_1_5`, `kEquiv_shuffle_shuffleReal`, `kEquiv_colourStructure`,
`kEquiv_orderedSum_of_kEquiv_colour`, `derivable_implies_swap_valid`,
`derivable_implies_swap_valid_discrete`, `kampFaithfulExpressiveCompleteness`,
`kampFaithfulExpressiveCompleteness_open`, `uSExpressivelyCompleteOverDensePrior`,
`uSExpressivelyCompleteOverDensePrior_of_faithful`,
`uSExpressivelyCompleteOverDensePrior_not_by_reuse`, `uSExpressivelyCompleteOverPrior`,
`semanticPriorU_not_implies_semanticPriorUZ`, `Kamp.kampArm_zeta_faithful`,
`Kamp.aggOdPopFold_iff_faithful`, `Kamp.kampPriorExpressiveCompletenessFaithful`,
`prior_hasFaithfulDedekindINF_dense`, `prior_hasFaithfulDedekindSUP_dense`.

The symbols this report asserts as **absent** (must not be cited by any surviving claim):
`filtration_is_finite`, `truth_preserved_under_filtration`, `buildTableau_isSome`,
`chronicle_is_good`, `irr_sound_dense_at_domain`, `finite_model_property` (bare — only
`mcs_finite_model_property` exists). Absent **files**: `IRRSoundness.lean`,
`Verified/Internalize.lean`, `Verified/Refutation/`, `Verified/Bridge/Omega.lean`,
`Verified/Provable.lean`.

## Follow-Ups (out of this task's `file_scope`)

- **`FMP/FMP.lean` module docstring** lists `finite_model_property` under "Main Results"; no such
  declaration exists (the theorem is `mcs_finite_model_property`). Same defect class as item (c),
  one file away, but outside `file_scope`.
- **`Soundness.lean`-style broken relative doc links in `.lean` docstrings** are invisible to check
  C5, which only lints markdown. The `architecture.md` depth error found under item (h) is one
  instance; a C5 extension covering `.lean` docstring links would catch the class. Worth a check
  extension rather than a documentation task.
- **`PriorExpressivenessDense.lean` carries 30 line-number citations**; 27 currently resolve, 3 do
  not. A repo-wide line-citation lint (or a convention forbidding them outright) would retire the
  observed failure mode the task constraints name.
