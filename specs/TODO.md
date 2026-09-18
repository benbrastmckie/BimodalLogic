---
next_project_number: 621
---

# TODO

## Task Order

*Updated 2026-09-18. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 127,128,178,257,298,464,476,481,502,504,534,559,563,568,597,603,604,605,610,614,615,619 | -- | algebraic-representation, categorical-structure, dataset-enhancement, ... |
| 2 | 231,282,296,465,497,540,560,564,565,567,570,606,616,617 | 298,464,502,559,563,568,597,605,615,619 | algebraic-representation, categorical-structure, dataset-enhancement, ... |
| 3 | 219,428,498,499,500,566,589,608,618 | 231,465,497,540,564,565,606,616 | algebraic-representation, categorical-structure, dataset-enhancement, ... |
| 4 | 125,429,543,600 | 428,498,499,500,603,608 | algebraic-representation, decidability, frame-extensions, ... |
| 5 | 410,501,607 | 125,429,600 | algebraic-representation, decidability, documentation |
| 6 | 411 | 410 | decidability |
| 7 | 430 | 411 | decidability |
| 8 | 177,412 | 430 | decidability, formula-refactor |
| 9 | 482 | 412 | decidability |

**Grouped by Topic** (indented = depends on parent):

### Algebraic Representation

502 [NOT STARTED] — RESEARCH TASK. Ground the algebraic representation front in...
  └─ 497 [NOT STARTED] — Bring the Shift-closed Tense S5 Algebra class into live code...
    └─ 498 [NOT STARTED] — Phase 1 of the Jonsson-Tarski representation: the complex...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the...
        └─ 501 [NOT STARTED] — Phase 4 of the Jonsson-Tarski representation: extend STSA...
    └─ 499 [NOT STARTED] — HARD. Phase 2 of the Jonsson-Tarski representation: the...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the... (see above)
    └─ 500 [NOT STARTED] — RESEARCH TASK. Prevent two parallel representation theorems...

### Categorical Structure

563 [NOT STARTED] — Promote the presheaf skeleton into the library. DELIVER: the...
  └─ 564 [NOT STARTED] — Prove app:gluing for two interval sections whose germs agree...
    └─ 618 [NOT STARTED] — Formalize the path category Path(F) and prove...
  └─ 565 [NOT STARTED] — Prove app:presheaf-dictionary's Totality and Directed Gluing...
    └─ 566 [NOT STARTED] — Prove app:presheaf-dictionary's Possible Worlds clause: HF...
  └─ 567 [NOT STARTED] — Prove app:presheaf-dictionary's Determinism clause -- F...
  └─ 616 [NOT STARTED] — Formalize the duration monoid BD+, its twisted-arrow...
    └─ 618 [NOT STARTED] — Formalize the path category Path(F) and prove... (see above)
  └─ 617 [NOT STARTED] — Prove app:presheaf-dictionary's Reflection clause: reflection...

### Dataset Enhancement

257 [BLOCKED] — Complete the Hugging Face Hub migration for large dataset...
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded...
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset...
    └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline...
  └─ 282 [PARTIAL] — Flip complexity-9 dataset generation from stratified to...
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release,...
604 [NOT STARTED] — Add zstd-compressed .jsonl dataset support across the data...

### Decidability

464 [NOT STARTED] — Design and land gapPotential, the density coordinate of the...
  └─ 465 [NOT STARTED] — Complete the terminus restatement family at the repaired...
    └─ 428 [BLOCKED] — Engine totality at a quantified branch budget. Owns...
      └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2...
        └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program...
          └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program...
            └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction...
              └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program...
                └─ 482 [NOT STARTED] — CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT...
476 [NOT STARTED] — THE BOX-FAITHFUL SMALL-MODEL THEOREM.  CLASSIFICATION: OPEN...
481 [BLOCKED] — CLASSIFICATION: genuinely open -- the predicate is refuted as...

### Documentation

610 [NOT STARTED] — Update remaining documentation references to lakefile.lean...
614 [NOT STARTED] — readme-lint.sh reports 47 of 60 FormalSystem/README.md files...
607 [NOT STARTED] — Resync typst/FormalFoundations.typ with the current Lean tree...

### Formula Refactor

178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of...
177 [NOT STARTED] — Update README.md, docs/, and FormalSystem/ module-level...

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ...
128 [NOT STARTED] — Add topological open set (interior) operator for dense and...
603 [IMPLEMENTING] — Investigate how to define a ℚ-time frame predicate...
  └─ 600 [PLANNED] — Investigate why the dense frame-class extension is named...

### Incompleteness

534 [NOT STARTED] — Research and, where feasible, establish in Lean whether the...

### Literature

504 [NOT STARTED] — Retry acquisition of the standard modal-representation...

### Metalogic

559 [NOT STARTED] — RESEARCH TASK, verdict-first -- report and sorry-free probe...
  └─ 560 [NOT STARTED] — GATED IMPLEMENTATION -- do not plan or dispatch until...
568 [NOT STARTED] — Promote the alternative consequence relations into the...
  └─ 570 [NOT STARTED] — OPEN RESEARCH QUESTION, not an implementation task. Is the...
543 [NOT STARTED] — Machine-check the principal new results from the MF...

### Paper Refactor

605 [NOT STARTED] — Reconcile the Burgess/Xu axiom provenance and add the paper's...
  └─ 606 [NOT STARTED] — Revise the primitive axiom system in...

### Codebase Cleanup

597 [NOT STARTED] — Adopt Mathlib's standard linter set, following cslib's...
  └─ 540 [NOT STARTED] — Close the three declaration categories that sit far below the...
    └─ 589 [NOT STARTED] — C20 tier 1 verifies 1,012 file.lean:NNN citations land on a...
619 [IMPLEMENTING] — Every linter suppression in the tree must carry a recorded...
608 [NOT STARTED] — Decide whether to rename the swapUS, swapMinus and swapvalid...

### Semantics Refactor

615 [IMPLEMENTING] — Close the residue of the possible-world index retarget. The...

## Tasks

### 620. Lean appendix bimodal reference
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: None
- **Research**: [620_lean_appendix_bimodal_reference/reports/01_lean-appendix-research.md]
- **Plan**: [620_lean_appendix_bimodal_reference/plans/01_lean-appendix-plan.md]
- **Summary**: [620_lean_appendix_bimodal_reference/summaries/01_lean-appendix-summary.md]

**Description**: Develop a Lean 4 appendix for typst/BimodalReference.typ, building up from the basics. It should cover what Lean is, types vs Props and dependent types, propositions-as-types and proof terms, inductive types (with Formula and DerivationTree as running examples), structures and classes, tactic proofs vs term proofs, Mathlib conventions, and lake and project layout. Then go all the way to reading the FormalSystem/ source that the book's formal claims point to. None exists yet: the only back-matter appendix is chapters/ax-machine-appendix.typ. Add it as a new chapters/ax-lean-appendix.typ included in the back matter, and cross-reference it from the introduction. Seed material: the existing markdown Lean guides. The main candidate is docs/user-guide/tutorial.md ('Logos Tutorial': installing Lean, formula construction, derivation trees, Type vs Prop), plus docs/user-guide/quickstart.md, docs/development/LEAN_STYLE_GUIDE.md and docs/reference/tactic-reference.md. Also check /home/benjamin/Projects/Logos/Verification/ (notes/, docs/) for any Lean basics note. Research should confirm which document the user meant and inventory what can be reused versus what is out of date. Consult /home/benjamin/Projects/Logos/Theory/typst/manual/LogosManual.typ only where it helps. Its chapters/01-introduction.typ section 'Lean Implementation' (sec-lean-implementation) and the leansrc cross-reference convention are relevant; it has no Lean-from-basics primer. Every Lean snippet must compile against the current toolchain and cite real declarations. Follow the typst/SYNC-MAP.md and typst-sync-check.sh conventions

---

### 619. Require reasons for linter suppressions
- **Effort**: medium
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: codebase-cleanup
- **Dependencies**: Task 585, Task 588
- **Research**: [619_require_reasons_for_linter_suppressions/reports/01_linter-suppression-reasons.md]
- **Plan**: [619_require_reasons_for_linter_suppressions/plans/01_linter-suppression-reasons-c29.md]

**Description**: Every linter suppression in the tree must carry a recorded reason, and a check must keep it that way. An audit performed during the compiler-warning burn-down found 10 declaration- and file-scoped `set_option linter.* false` suppressions in the live tree, of which SIX are bare -- no comment above them, nothing in the surrounding docstring, no rationale anywhere. An undocumented suppression is indistinguishable from giving up, and the new C28 warning gate will report a clean zero while they sit there.

THE SIX (verified at burn-down time; re-verify line numbers before editing, since the burn-down shifted lines in several of these files):
- FormalSystem/Metalogic/Decidability/Verified/Bridge/UntlSnceFree.lean:352 -- `set_option linter.unusedTactic false in`
- FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:128 -- `set_option linter.unusedVariables false in`
- FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:278 -- `set_option linter.unusedVariables false in`
- FormalSystem/Semantics/Ultraproduct/Carrier.lean:63 -- file-scoped `linter.unusedSectionVars`
- FormalSystem/Semantics/Ultraproduct/Los.lean:47 -- file-scoped `linter.unusedSectionVars`
- FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean:60 -- file-scoped `linter.unusedSectionVars`

DIVISION OF LABOUR WITH THE MATHLIB-LINTER-SET TASK IN THIS TOPIC. That task already owns converting the three file-scoped Ultraproduct blankets to `in`-scoped form and adding a ratchet that permits only the `in`-scoped shape. It does NOT require a reason for any suppression, and it does not touch the three declaration-scoped ones at all -- those are already correctly scoped and merely unexplained, so they fall through both tasks otherwise. THIS task owns the reason requirement. Do not re-do the scoping conversion here; if that task has already run, the Ultraproduct three will be `in`-scoped and still need reasons.

WORK:
(1) For each of the three declaration-scoped suppressions, determine WHY it is there -- git archaeology on the introducing commit, then an empirical deletion trial: remove the suppression, build, and record what actually breaks. The trial is the evidence, not the commit message.
(2) Dispose of each explicitly: if the suppression is load-bearing, keep it with an in-source comment naming what the deletion trial showed (the house model is the documented suppression in MintBound/Invariants.lean, which names all twelve goals its deletion experiment left unsolved). If it is not load-bearing, delete it and fix the warning it was hiding.
(3) Same treatment for the three Ultraproduct suppressions. Their deletion trial has a known prerequisite: the un-suppressed warning count behind them was measured during the burn-down -- read that measurement rather than re-deriving it.
(4) Add a check to scripts/check-module-invariants.sh requiring that every `set_option linter.* false` occurrence has a non-blank comment line immediately above it, or is listed in a companion allowlist with a reason column. Follow the C28 precedent from the burn-down task: build-free, runnable under `--no-build`, with an anti-silence guard that exits non-zero rather than passing when it finds nothing to check. Take the next free check ID -- C26 and C27 are already live, and the burn-down takes C28, so verify the current highest ID rather than assuming.
(5) Add a row for the new check to docs/development/MODULE_INVARIANTS.md.

ACCEPTANCE: zero bare `set_option linter.* false` occurrences in the tree; every retained suppression names what breaks without it, on evidence from an actual deletion trial; the new check fails loudly on an injected bare suppression (negative-test it); `lake build` green; the warning budget unchanged or reduced, never increased to accommodate a deletion.

---

### 618. Path category and conduche fibration
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563, Task 564, Task 616

**Description**: Formalize the path category `Path(F)` and prove `cor:path-fibration`: the length functor `len : Path(F) -> BD+` is a discrete Conduche fibration whose associated presheaf is `Beh(F)`, together with the `D = Z` clause identifying `Path(F)` as the free category on the graph `(W, =>_1)`.

DELIVER:
- `def:conduche`'s notions: a discrete Conduche fibration `P : E -> BD+` (every morphism `e` and every factorization `P(e) = x + y` admits a unique pair `e1 : A -> C`, `e2 : C -> B` with `e = e2 . e1`, `P(e1) = x`, `P(e2) = y`); the associated presheaf of such a fibration; the associated category of a sheaf on `Int(D)`; and the length functor.
- `def:path-category`'s `Path(F)`: the associated category of `Beh(F)`, whose objects the Germs clause identifies with the world states and whose morphisms `w -> u` of length `l` are the sections `tau` in `Beh(F)(l)` with `tau(0) = w` and `tau(l) = u`, composing by gluing with the germs as identities.
- `cor:path-fibration` proper. Note the paper's proof establishes something sharper than the equivalence alone delivers: the associated presheaf of `len` is EQUAL to `Beh(F)`, not merely naturally isomorphic to it, because restriction along `Tr p` is literally the middle factor of the unique factorization. Formalize the equality, and say in the docstring why it is available.
- The `D = Z` clause: iterating Compositionality identifies `=>_n` for positive `n` with the `n`-fold composite of `=>_1`, and `=>_0` is the identity by `lem:nullity` and Limit, so a function on `[0, l]` is a convex history exactly when it is a path of length `l` in `(W, =>_1)`, gluing is concatenation, and `Path(F)` is the free category on that graph.

HARD SCOPE LIMIT. `fact:conduche-equivalence` -- Johnstone's general equivalence between the sheaves on `Int(D)` and the discrete Conduche fibrations over `BD+` -- is stated in the paper as a CITED FACT (Johnstone, Prop. 3.6; Schultz, Spivak, and Vasilakopoulou, Thm. A.2.1) and is not proved there. Do NOT set out to formalize Johnstone's theorem in general. Formalize the instance: build `Path(F)` directly and prove the fibration property for it. Record in the module docstring that the general equivalence is external and cited, so a later reader does not mistake the instance for the theorem. If a phase discovers the general proof is cheap at this site, that is a finding to report, not a licence to expand scope mid-task.

WHY IT IS WORTH DOING. The `D = Z` clause is the payoff a reader can hold onto: it says the whole categorical packaging, over the discrete temporal order, is the free category on the one-step task graph. It is also the clause most likely to connect to existing work here, since `FormalSystem/Semantics/IntTransfer.lean` already carries the adjacency characterization of `H_F` over `Z`; reuse that reasoning rather than re-deriving it.

PAPER ANCHORS. `def:conduche`, `def:path-category`, `fact:conduche-equivalence`, and `cor:path-fibration` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, all COMMENTED OUT inside the "SECTION CUT" block holding `app:Structure` -- read them there.

DEPENDENCIES. Task 563 (interval site and behavior presheaf), task 564 (the Sheaf clause, since composition in `Path(F)` IS gluing), and the twisted-arrow task, which supplies the factorization-linearity the fibration property leans on. This is the last and largest item on the categorical front; it should not be started before those land.

CONSTRAINTS. `lake build FormalSystem` green with no new sorry at the end of every phase.

---

### 617. Reflection clause converse frame naturality
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Prove `app:presheaf-dictionary`'s Reflection clause: reflection is a natural isomorphism `Beh(F) iso Beh(F-) . ref` between the behavior presheaf of a task frame and that of its converse frame, precomposed with the reflection automorphism of the interval category.

DELIVER, following `def:behavior-presheaf` and the Reflection paragraph of `app:presheaf-dictionary`'s proof:
- The reflection of a section: `tau^r (z) = tau(l - z)` on `[0, l]`.
- The converse frame `F- = (W, D, =>-)` with `w =>-_x u` iff `w =>_{-x} u`.
- The reflection automorphism `ref` of `Int(D)`: involutive, fixing objects, sending `Tr p : l' -> l` to `Tr (l - p - l') : l' -> l`, thereby interchanging left and right restrictions. Prove it preserves composition, fixes identities, and is its own inverse.
- That `tau^r` lies in `Beh(F-)(l)` whenever `tau` lies in `Beh(F)(l)`, naturality in the translations, and that each component is a bijection, using `(F-)- = F` and `(tau^r)^r = tau`.

THE POINT OF THE CLAUSE, which belongs in the module docstring rather than being left implicit in the proof terms: this natural isomorphism is what underlies the soundness of the time reflection metarule `TR` (`thm:TR-valid` in the paper). The reflection convention on the task relation supplies the involution by definition rather than by assumption, which is why the clause costs so little. Along with the Determinism clause of task 567, this is one of the few places where the categorical packaging says something about the logic rather than merely restating the semantics.

REUSE, NOT REBUILD. This repository already carries time-reflection and converse machinery -- `FormalSystem/Semantics/TruthTransport.lean` and the `reflectTime` vocabulary adopted in the TD->TR rename, with the `swapUS`/`swapMinus` families still under review in task 608. Survey what exists before defining a second converse-frame construction. If the existing API already yields the converse frame, this task consumes it; if not, say in the docstring why a separate one was needed. A duplicate converse frame is a failure of this task, not a side effect of it.

PAPER ANCHOR. The Reflection clauses of `def:behavior-presheaf` and `app:presheaf-dictionary` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, both COMMENTED OUT inside the "SECTION CUT" block holding `app:Structure` -- read them there.

DEPENDENCY. Task 563, for `Beh(F)` and `Int(D)`.

CONSTRAINTS. `lake build FormalSystem` green with no new sorry at the end of every phase.

---

### 616. Duration monoid twisted arrow interval site
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Formalize the duration monoid `BD+`, its twisted-arrow category, and `lem:interval-twisted-arrow`: `BD+` is factorization-linear and `Tw(BD+)` is isomorphic to the interval category `Int(D)` by an isomorphism carrying the Johnstone coverage of the one to that of the other.

WHY THIS IS NOW ITS OWN TASK. Task 563 carries this as "OPTIONAL, only if cheap". It is being promoted because the paper has changed around it: the presheaf appendix `app:Structure` was cut from /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, and the main-body conclusion is being rewritten to assert the Johnstone route in prose -- interval site, sheaf condition, discrete Conduche fibrations, path category -- with the supporting results promised elsewhere. This repository is where "elsewhere" is meant to be. The lemma is no longer an optional extra on the interval-site task; it is the load-bearing step behind a claim the paper now makes in its body with no appendix under it.

DELIVER:
- The duration monoid `BD+`: the one-object category whose morphisms are the durations in the positive cone, composing by addition with identity 0.
- The factorization category `Fact(l)` of a duration: objects the factorizations `l = x + y` with `x, y` positive, morphisms `(x, y) -> (x', y')` the durations `z` with `z + x = x'` and `y = z + y'`.
- Factorization-linearity: each factorization category is a linear preorder -- any two objects related by at most one morphism, and by at least one in one direction or the other.
- The twisted-arrow category `Tw(BD+)`: objects the durations, morphisms `l' -> l` the pairs `(p, q)` of positive durations with `p + l' + q = l`, composing `(p, q) . (p', q') = (p + p', q' + q)` with identities `(0, 0)`.
- The Johnstone coverage on both `Tw(BD+)` and `Int(D)`, and the coverage-preserving isomorphism `Int(D) iso Tw(BD+)`.

SHAPE OF THE WORK. This is pure order algebra over the positive cone of a linearly ordered abelian group. It needs no task frame, no world states, and no history theory -- only `TemporalOrder.lean`'s carrier and its order and group structure. That makes it the most self-contained item on the categorical front and a reasonable one to land early.

DESIGN DECISION TO RECORD EXPLICITLY, not to settle by accident in the first proof: whether these categories are stated as concrete Lean structures with hand-rolled composition lemmas, or as `Mathlib.CategoryTheory.Category` instances. `grep -rl CategoryTheory FormalSystem/` currently returns exactly one file, `FormalSystem/Boneyard/RetiredTactics/AesopRuleSet.lean`, so the live tree imports no category theory at all. Introducing it is a real dependency decision for the whole categorical cluster (tasks 563-567 included) and should be made once, here, and written into the module docstring with its reasoning -- not made implicitly by whichever task gets there first. The concrete route is cheaper and keeps the import surface flat; the Mathlib route is what makes `fact:conduche-equivalence` and the free-category statement expressible without re-inventing vocabulary. State the trade-off, pick one, say why.

PAPER ANCHORS. `def:interval-site`, `def:twisted-arrow`, and `lem:interval-twisted-arrow` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex. NOTE that all three are COMMENTED OUT in the current source, inside the "SECTION CUT" block that holds `app:Structure` in full -- read them there rather than concluding the paper never had them. Docstrings must cite the labels. Read also /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/111_verify_interval_twisted_arrow_lemma/reports/01_verify-twisted-arrow-lemma.md, where the lemma was verified and its proof rebuilt on that repository's side; that report is the statement of record, ahead of any older phrasing.

DEPENDENCY. Task 563, which introduces `Int(D)`. If 563 lands the optional twisted-arrow material after all, this task narrows to the factorization-linearity proof and the coverage transport rather than disappearing -- reconcile at plan time rather than assuming disjointness.

CONSTRAINTS. `lake build FormalSystem` green with no new sorry at the end of every phase.

---

### 615. Close world history reach through residue
- **Effort**: small
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: semantics-refactor
- **Dependencies**: Task 588
- **Research**: [615_close_world_history_reach_through_residue/reports/01_close-reach-through-residue.md]
- **Plan**: [615_close_world_history_reach_through_residue/plans/01_close-reach-through-residue.md]

**Description**: Close the residue of the possible-world index retarget. The seven-phase retarget itself was already executed by three earlier tasks in this topic; research against the current tree confirmed the surviving gap is 36 sites, not the ~600 the superseded description assumed (28 reach-throughs plus 8 layer crossings).

REQUIRED WORK:

(1) Add `WorldHistory.respects_task` -- a three-line lemma, already machine-checked in the probe at `specs/archive/569_retarget_semantics_to_possible_world_index/probes/01_possible-world-spike.lean`. This single lemma is what 22 of the 28 reach-through sites need; rewrite those 22 call sites to use it instead of reaching through the subtype.

(2) Fix the two layer-crossing defects at `FormalSystem/Automation/IntNormalForm.lean:282` and `FormalSystem/Metalogic/Extension.lean:219`.

(3) Triage the remaining 6 reach-throughs and 8 layer crossings, disposing of each explicitly.

OUT OF SCOPE (deliberately, each needing its own justification rather than inheriting one from the superseded description):
- The `PossibleWorld` rename (503 binders plus the namespace). Blocked on settling whether H_F or the time-shift quotient W_F owns the name "possible world" -- `possible_worlds.tex:1046` makes them different objects and `:1050` licenses both names.
- Converting `WorldHistory` from a subtype to a flat structure. Research found this is a real net win (the `CoeOut` instance never fires, `WorldHistory.ext` has zero call sites, `states_eq_state` goes away) at the cost of a ~6-line `toPartialHistory` bridge for the Extension Theorem -- but it relocates bridging rather than removing it, so it belongs in its own task.

VERIFY: `lake build FormalSystem` exits 0, and `#print axioms` on `validZTime_iff_validInt` and `truthAt_map` still returns exactly `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.

---

### 614. Refresh stale readme date stamps across
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: documentation
- **Dependencies**: None

**Description**: readme-lint.sh reports 47 of 60 FormalSystem/README.md files with a stale or missing date stamp (stamp predates the directory's last git-committed change), left behind by the recent Syntax/Semantics language-family nesting, Metalogic import-cycle repair, and WorldHistory retarget work. Advisory only (readme-lint.sh exits RESULT: PASS regardless), but the drift is now wide enough to warrant a single sweep. Update each listed README's date stamp to reflect its directory's current state, and add a date line to the 3 files currently missing one (Metalogic/Conservativity/Star/README.md, Metalogic/Decidability/Verified/Termination/MintBound/README.md, Syntax/StarLanguage/README.md). See specs/reviews/review-2026-09-17.md's Low Priority Issues section for the full 47-file list. Purely mechanical; re-verify with scripts/readme-lint.sh after.

---

### 610. Replace remaining lakefile lean mentions in docs
- **Status**: [NOT STARTED]
- **Task Type**: markdown
- **Topic**: documentation
- **Dependencies**: None

**Description**: Update remaining documentation references to lakefile.lean now that the project uses lakefile.toml (package renamed to BimodalLogic): docs/user-guide/architecture.md:1131, docs/development/LEAN_STYLE_GUIDE.md:790, docs/user-guide/troubleshooting.md:55, docs/development/NAMING_CONVENTION_DEVIATION.md:333. Task 578 skipped these because concurrent tasks held uncommitted edits in them; re-grep the tree for any other lakefile.lean or Logos package-name mentions.

---

### 608. Decide and rename swapus swapminus families
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: codebase-cleanup
- **Dependencies**: Task 606

**Description**: Decide whether to rename the swapUS, swapMinus and *_swap_valid* identifier families to match the time-reflection vocabulary adopted in the TD->TR rename (swapTemporal -> reflectTime), and if so perform the rename via a map file with whole-word matching, keeping serialized dataset strings byte-stable. These families were explicitly left out of scope by task 584; see specs/584_reconcile_lean_tree_with_paper_vocabulary/rename-map.tsv and the record's 2026-09-17 section for the conventions used.

---

### 607. Resync formalfoundations typ with lean tree
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: documentation
- **Dependencies**: Task 600, Task 603, Task 605, Task 606, Task 608

**Description**: Resync typst/FormalFoundations.typ with the current Lean tree and paper vocabulary: audit every claim about the proof system, axiom counts, the TR (time reflection) rule, renamed identifiers (reflectTime, time_reflection, TimeReflection), and the Some/All Past/Future labels, and correct stale statements. Task 584 fixed the one remark that wrongly said there was no TR rule and that uniformity axiom counts don't match, but deferred a full resync.

---

### 606. Adopt paper axiom system and derive surplus axioms
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 588, Task 605, Task 615, Task 619

**Description**: Revise the primitive axiom system in FormalSystem/ProofSystem/Axioms.lean (the Axiom type index and the DerivationTree constructor set) to match the paper's axiom system exactly, and demote every current axiom that goes beyond the paper to a derived theorem. The paper is the JPL paper (/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, read-only); cite it through docs/reference/paper-definitions-of-record.md by \label{} or \aitem{} key, never by line number. GOAL: the primitive axioms and rules are exactly the paper's (def:BX plus its modal and interaction axioms). Everything else currently primitive becomes a theorem with a DerivationTree proof, keeping its current name where possible so downstream code keeps compiling. KNOWN SURPLUS in the BX temporal group (see "Paper Key Correspondence" in docs/reference/axiom-reference.md): the explicitly stated past mirrors (serial_past, connect_past, temp_linearity_past, since_P, P_since_equiv, absorb_since, right_mono_since, self_accum_since, left_mono_since_H, enrichment_since, linear_since, discrete_symm_bwd), which the paper obtains through the TR time-reflection rule (DerivationTree.time_reflection, Formula.reflectTime). Derive each one by TR from its primary. Also restate temp_linearity (TL) and linear_until (CN) with the paper's disjunct order and grouping, keeping the old forms as derived lemmas if anything uses them. Note that discrete_propagate_bwd is the paper's NA itself, not a mirror of NF: it stays primitive, and consider renaming it to match. RESEARCH FIRST: audit the WHOLE Axiom type (all constructors, not only the temporal group) against the paper's full axiom list. Produce a table classifying every constructor as paper-primitive, derivable surplus (with a derivation sketch), or surplus with no known derivation. The last class must be reported, not silently kept or dropped. Also check whether any surplus axiom is needed per FrameClass (Base, Dense, ZTime, RTime) and whether TR is available in every frame class where a mirror is used. BLAST RADIUS to plan for: soundness (per-axiom validity cases shrink; keep the mirror validity lemmas as lemmas), completeness and canonical-model constructions that pattern-match on Axiom constructors, the decidability/tableau and proof-extraction code, Automation (apply_axiom, proof search, axiom tables), the lake exe machine_appendix JSONL and typst/generated/ counts (the axiom count drops from its current value), the dataset pipeline's serialized axiom names (keep existing serialized datasets byte-stable or version them explicitly), Tests/BimodalTest, and docs/reference/axiom-reference.md (turn the correspondence table into a statement of the primitive system plus its derived mirrors). ACCEPTANCE: lake build is green with no new sorry or axiom, all tests pass, and every former primitive is either a paper axiom or a proved theorem, with a lean_verify axiom check on the derived mirrors. Supersedes the earlier scope of this task, which only proved the two presentations equivalent without changing the primitive set.

---

### 605. Reconcile burgess a7a provenance and add axiom source footnote
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 588

**Description**: Reconcile the Burgess/Xu axiom provenance and add the paper's axiom-source footnote to FormalSystem/ProofSystem/Axioms.lean. The paper's footnote says CN is Burgess's A7a, but an existing note in Axioms.lean says A7a was removed as unsound; determine which claim is correct against Burgess and Xu, then copy the reconciled provenance into the axiom docstrings and docs/reference/paper-definitions-of-record.md. Follow-up recorded by the paper-vocabulary reconciliation (task 584).

---

### 604. Support zstd compressed jsonl datasets
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None

**Description**: Add zstd-compressed .jsonl dataset support across the data pipeline so large datasets can live on disk as .jsonl.zst. data/bmlogic-c7.jsonl was compressed to data/bmlogic-c7.jsonl.zst to reclaim disk space (17G -> 153M; lossless, sha256 of decompressed stream 4079d0a6b4310d417ae91999abcd581e5ebd9dacd4e9f3c33d1d9b3aa55f2704 verified identical; restore with `zstd -d data/bmlogic-c7.jsonl.zst`). Consumers that hardcode data/bmlogic-c7.jsonl are currently broken. Research first: (1) inventory every reader/writer of .jsonl datasets -- Python scripts (validate_benchmark.py, validate_datasets.py, verify_benchmark.py, migrate_schema_v2.py, standardize_metadata.py, curate_benchmark.py, curate_very_hard_plus.py, finalize_benchmark.py, validate_c5_dataset.py), shell scripts (run_dataset_generation.sh, export-training-data.sh, typst-machine-appendix.sh, typst-sync-check.sh), Lean executables under FormalSystem/Automation/*Main.lean, lakefile.lean, Tests/BimodalTest/Automation/ProofFirstTests.lean, data/hf-dataset/ tooling, and path fields in data/*_metadata.json; (2) choose the Python approach, e.g. one shared open_dataset() helper transparently handling .jsonl and .jsonl.zst (zstandard package vs zstd subprocess) and how that dependency is provided; (3) decide how Lean executables handle compressed data given Lean has no native zstd (IO.Process pipe through zstd, or shell-wrapper streaming via stdin/stdout) and whether generators should write .jsonl.zst directly; (4) reconcile with the Hugging Face Hub storage migration (task 257). Then implement, keeping plain .jsonl working, and verify every updated consumer against data/bmlogic-c7.jsonl.zst

---

### 603. Investigate qtime frame predicate
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None
- **Research**: [603_investigate_qtime_frame_predicate/reports/01_qtime-frame-predicate.md]
- **Plan**: [603_investigate_qtime_frame_predicate/plans/01_qtime-frame-predicate.md]

**Description**: Investigate how to define a ℚ-time frame predicate (TaskFrame.IsQTime) parallel to TaskFrame.IsZTime and TaskFrame.IsRTime in FormalSystem/Semantics/FrameProperty.lean, appropriate to this setting (durations are TemporalOrder = nontrivial ordered abelian groups; task frames; TM_d over the dense task frames in the paper ~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex) and its application (a semantic class inside IsDense whose validity ValidQTime := ValidOnFrames IsQTime is proved equal to ValidDense via soundness_dense and the Rat countermodel countermodel_dense_enriched; NOT a new FrameClass constructor). Compare candidate definitions: (a) intrinsic divisible + pairwise commensurable (rank-one divisible), the analogue of IsZTime's "generated by one step"; (b) bare Nonempty (F.Duration ≃+o ℚ); (c) countable + dense (order-iso to ℚ by Cantor but admits ℚ+ℚ√2 as a group); (d) any other characterization found in Mathlib or the literature (e.g. Archimedean + divisible + countable, prime-subfield style). For each assess: whether it picks out ℚ up to order-and-group isomorphism, fidelity to how IsZTime/IsRTime are phrased (Prop-valued intrinsic conditions, abbrev/def reducibility and instance-cache concerns documented in FrameProperty.lean), what Mathlib already provides (DivisibleBy, Archimedean, Order.iso_of_countable_dense, existing ≃+o ℚ results), proof cost of Rat satisfying it and of the optional characterization IsQTime -> Nonempty (≃+o ℚ), and whether the paper vocabulary or in-tree usage (Chronicle Cantor iso, WeakCanonical RealModel) favours one. Also check whether strong completeness over ℚ-time comes nearly free from the compactness route. Recommend one definition with naming and file placement

---

### 600. Rename dense extension qtime
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: Task 603, Task 606, Task 608
- **Research**: [600_rename_dense_extension_qtime/reports/01_dense-vs-qtime-naming.md]
- **Plan**: [600_rename_dense_extension_qtime/plans/01_dense-naming-rationale.md]

**Description**: Investigate why the dense frame-class extension is named Dense (FrameClass constructors Base | Dense | ZTime | RTime in FormalSystem/ProofSystem/Axioms.lean, and derived names such as detCompletenessDense, derivable_of_validDetDense, cantorBfmcsDense) instead of QTime, which would match ZTime and RTime. Research first: check whether the class is really the theory of Q (e.g. canonical/completeness constructions over ℚ, and whether every dense temporal order validates exactly the same formulas so QTime is accurate) or deliberately named for the density axiom over arbitrary dense orders, and check how the paper (PossibleWorlds JPL/possible_worlds.tex) and docs name it. If there is good reason, rename Dense to QTime systematically (constructor, IsDense-style predicates, theorem/def names, file and module names, docstrings, tests, docs), keeping the naming scheme uniform and elegant; otherwise record the rationale in the relevant docstring and close without renaming. Coordinate with other in-flight renaming/nesting tasks

---

### 597. Adopt mathlib standard linter set
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: codebase-cleanup
- **Dependencies**: Task 585

**Description**: Adopt Mathlib's standard linter set, following cslib's precedent. MEASURED AT REORGANIZATION TIME (2026-09-16; re-measure before planning): `lakefile.lean` sets only `autoImplicit false` and `pp.unicode.fun`; cslib enables `weak.linter.mathlibStandardSet = true` in `[leanOptions]`. Against Mathlib defaults this tree has 692 lines over 100 characters in 154 files (`longLine`) and 37 files over 1,500 lines (`longFile`; largest `EFGames/GapDetection.lean` at 5,090). There are 4 file-scoped blanket `set_option linter.* false` suppressions (3 in `Semantics/Ultraproduct/`, 1 in a test) and 7 unscoped `set_option maxHeartbeats` (48 are already `in`-scoped).

WORK: (1) enable `weak.linter.mathlibStandardSet` with documented opt-outs where a linter does not fit this project (cite cslib's `docs/lint-suppression-policy.md` as a model); (2) measure the new warning surface; (3) fix cheap classes, and baseline the rest under the compiler-warning gate from the warning burn-down task in this topic -- never bulk-suppress; `longFile` is baselined, not fixed by splitting, unless a split is independently justified; (4) convert the 4 blanket linter suppressions and 7 unscoped `maxHeartbeats` to `in`-scoped form; (5) add a blanket-suppression ratchet check (only `set_option ... false in` allowed) to the invariant harness or CI.

ORDERING NOTE: runs after the warning burn-down/gate task so the new warnings land under an existing gate. Large: the planner should split phases per linter class rather than truncate.

ACCEPTANCE: linter set enabled; `lake build` green; warning count within the recorded baseline; zero blanket suppressions and zero unscoped `maxHeartbeats`; ratchet check in place and documented.

---

### 589. Disambiguate basename citations
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: codebase-cleanup
- **Dependencies**: Task 588, Task 540, Task 597, Task 584, Task 591, Task 596
- **Research**: [589_disambiguate_basename_citations/reports/01_unverifiable-citation-inventory.md]

**Description**: C20 tier 1 verifies 1,012 `file.lean:NNN` citations land on a real, non-blank line. A further 35 are unverifiable and the check reports them and moves on. They are precisely the citations most likely to be silently wrong -- a basename ambiguous to the checker is ambiguous to a reader too, and none has ever had its line number checked.

22 are AMBIGUOUS (basename resolves to 2+ live files): `Axioms.lean` x7, `Defs.lean` x7, `Formula.lean` x6, `Completeness.lean` x1, `Soundness.lean` x1. Fix by qualifying the path -- but note that is only half the job: once the path resolves, tier 1 checks the LINE, and these lines have never been checked. Expect some to be wrong; correct the number, not the prose. Exploitable structure: the 7 `DenseModelSurgery/` citations almost certainly all mean their own sibling `DenseModelSurgery/Defs.lean`, and `Defs.lean:461` recurs three times across three files.

13 are UNRESOLVED and need ONE convention decision, not 13 edits: 11 cite files in `FormalSystem/Boneyard/` (`NegationIndep.lean` x8, `RefutationF2.lean` x2, `ExteriorPinnedProbeK.lean` x1 -- all real archived files, pruned from every C20 walker by name), and 2 cite `Mathlib/Tactic/Linter/Header.lean` from `check-copyright-headers.sh`, which are genuinely external and doing useful work. Options: a marker suffix C20 recognises; extending C20's resolver to check the archive for real; or dropping line numbers from archive citations in favour of declaration names. The third is most consistent with how this repository already thinks about citations -- C15 resolves paper anchors by name 'never by line number, ... which is what lets the lint survive reflowing', and commit `a16df671f` de-line-numbered citations for that reason. Evaluate it first.

The complete 35-row list is in the report; no re-measurement needed.

Verify: C20's INFO count is 0 or exactly the intentionally-external set; tier 1's verified count rises by the number of newly-resolvable citations with still zero out-of-range or blank-line landings; tier 2 still zero.

See specs/reviews/review-2026-09-16.md, Finding M4.

ALSO ABSORB (codebase-cleanup reorganization, 2026-09-16) three broken `specs/` citations in live Lean docstrings, verified at reorganization time: `FormalSystem/Syntax/BigConj.lean:30` (`specs/098/reports/...` -- no such directory), `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean:42` (`specs/305 report 40`), and `FormalSystem/Syntax/MinusLanguage/Axioms.lean:76` (`specs/archive/514_...` -- `specs/archive/` is gitignored). Replace each with a durable anchor (declaration name, ADR, or record under the home 595 settles) or drop it. Apply the same convention decision as the Boneyard citations.
ORDERING NOTE: this is the terminal task of the codebase-cleanup topic because every earlier rename/move/reflow shifts cited lines; re-measure the 35-row list if any predecessor has landed since the report.

---

### 588. Triage zero occurrence declarations
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: codebase-cleanup
- **Dependencies**: Task 585, Task 591, Task 594
- **Research**: [588_triage_zero_occurrence_declarations/reports/02_c17-zero-occurrence-triage.md]
- **Plan**: [588_triage_zero_occurrence_declarations/plans/02_c17-census-filter-and-triage.md]
- **Summary**: [588_triage_zero_occurrence_declarations/summaries/02_c17-census-filter-and-triage-summary.md]

**Description**: Triage the 1,029 declarations C17 reports as having zero occurrences outside their own declaring line. The scan runs on every invariant run, is explicitly REPORTED-never-gated and explicitly approximate, and has never been triaged -- 1,029 is large enough that the number has stopped being informative.

DELIVERABLE IS A CLASSIFICATION, NOT A DELETION SPREE. The scan is textual, so false positives are guaranteed: `instance` declarations resolved by typeclass search, `@[simp]`/`@[aesop]`-attributed declarations reached by attribute, `lean_exe` `main` entry points, constructors reached by pattern matching, and declarations whose only consumers are in `Boneyard/` (excluded from every walker).

Recommended order: (1) stratify by declaration kind and directory before reading anything; (2) mechanically eliminate the known false-positive classes and report how many that removes -- highest-value first step; (3) re-run with `Boneyard/` as a reference source, since 'only consumer is archived' is a different case from 'no consumer'; (4) triage survivors by CLUSTER, not by line; (5) deliver a disposition per cluster and execute only the unambiguous ones, spawning follow-ups for anything contentious.

Strongest true-positive signal to start from: `Automation/Normalization.lean`'s ten consecutive `*_fold` / `*_unfold` entries (`release_unfold` 146, `weak_until_unfold` 150, `trigger_unfold` 154, `weak_since_unfold` 158, `top_fold` 753, `diamond_fold` 760, `some_future_fold` 764, `some_past_fold` 768, `next_fold` 772, `prev_fold` 776). Ten unreferenced siblings is not the shape of a false positive -- and `Boneyard/RetiredTactics/Normalization.lean` holds seven tactic macros lifted out of that very file, which are plausibly their former consumers.

Consider extending C17's filters permanently so the number it reports is the number that matters -- arguably the most durable deliverable here. Do NOT gate C17.

Verify: `lake build` exits 0 and the full invariant harness passes after every deletion batch (C2/C14 baselines unmoved, C15 anchors unbroken, C21 intact); the drop in C17's count is accounted for line by line.

See specs/reviews/review-2026-09-16.md, Finding L1.

ABSORBS THE FORMER DEAD-DECLARATION TRIAGE TASK (542, `dead_declaration_triage_c17_findings`, abandoned as a duplicate of this task; it measured the same C17 census at 989 flagged of 10,346 declarations). Carry over its step (1) as a required early step: quantify the attribute/simp-set blind spot before deleting anything -- enumerate the attribute and simp-set mechanisms in use (`@[formula_unfold]`, `@[simp]` sets, aesop rule sets, instance registration) and report how many flagged declarations are reachable only through one of them. If that reachability analysis is mechanizable, fold it into C17 and document the new counting rule in the script header.

DISPUTED READING TO RESOLVE, NOT ASSUME: the two task descriptions disagreed on `release_unfold`. This description treats the `*_fold`/`*_unfold` run as a true-positive signal; the absorbed task treated `release_unfold` as live via `@[formula_unfold]`. Verified at reorganization time (2026-09-16): `release_unfold` IS registered with `@[formula_unfold]`, but the only consumers of that simp set in live code are the `#check`/`example` block inside `Automation/Normalization.lean` itself and `Tests/BimodalTest/Automation/NormalizationTest.lean`. Whether a simp set consumed only by its own smoke tests and one test file counts as "live" is the decision this task must make explicitly. Note also that the in-library smoke-test relocation task in this topic runs first and will change C17 occurrence counts (C17 counts `#check @foo` as an occurrence).

---

### 585. Burn down compiler warnings and add gate
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: codebase-cleanup
- **Dependencies**: Task 583, Task 584
- **Research**: [585_burn_down_compiler_warnings_and_add_gate/reports/02_warning-gate-design-remeasure.md]
- **Plan**: [585_burn_down_compiler_warnings_and_add_gate/plans/02_warning-burndown-and-c28-gate.md]
- **Summary**: [585_burn_down_compiler_warnings_and_add_gate/summaries/02_warning-burndown-and-c28-gate-summary.md]

**Description**: `lake build` exits 0 with 316 warnings across 47 live files, and nothing gates them: C16 runs the Batteries `env_linter` (a declaration linter) which does not see Lean compiler warnings. The two sets are disjoint -- this is a real hole, not a redundancy.

By kind: unused section variable 86, unused simp argument 84, deprecated `push_neg` 71, 'tactic does nothing' 25, unreferenced variable name 25, `Try this: intro` 12, 'never executed' 9, deprecated `IsTrichotomous`/`IsIrrefl` 4.

75 of those are forward-compatibility debt that becomes build errors at the next Mathlib bump. 34 ('does nothing' + 'never executed') are correctness smells -- each marks a tactic whose removal changes nothing, usually a proof that drifted from its intended shape. These deserve reading, not bulk deletion; they cluster with the unused-simp warnings in the termination layer (`SubformulaProperty.lean` 78, `MintPotential.lean` 15, `Fuel.lean` 2), which suggests ONE refactor left several proofs carrying dead tactics. Investigate those three files as one cause.

Then add a gate. Preferred: a CI step that fails when the `warning:` count exceeds a committed baseline (the `nolints.json` pattern applied to compiler warnings), so a PR that adds a warning must edit the baseline and say why. `-DwarningAsError=true` in `lakefile.lean` is the strict alternative but is brittle against Mathlib deprecations. Coordinate the gate with task 583 so CI changes once.

Phase it: (1) push_neg + Mathlib deprecations (75, mechanical); (2) the termination-layer trio (95, needs reading); (3) section variables (86, rebuild per file); (4) names + Try this + remaining simp args (40); (5) the gate. Commit per phase.

Verify: warning count at target; `lake build` exits 0; full `check-module-invariants.sh` passes with C2/C14 axiom baselines unmoved and no `sorry` introduced.

See specs/reviews/review-2026-09-16.md, Finding H4.

GATE-PHASE NOTE (codebase-cleanup reorganization, 2026-09-16): weigh cslib's approach -- CI builds with `--wfail --iofail` -- against the committed warning-count baseline proposed above, and record the choice. The CI wiring task (583) now lands first and records the wiring pattern; extend its workflow rather than editing CI independently. The Mathlib-standard-linter task (597) runs after this and will baseline its new warnings under whichever gate is chosen here, so the gate should accommodate a per-linter baseline.

---

### 570. C3 completeness question
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: metalogic
- **Dependencies**: Task 568

**Description**: OPEN RESEARCH QUESTION, not an implementation task. Is the logic of C3 -- the domain-restricted consequence relation -- equal to Burgess-Xu without the unboundedness assumption, plus S5?

WHAT IS ALREADY ESTABLISHED (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.2) is the CONTAINMENT: C3 includes classical propositional logic, S5 for box, the whole Burgess-Xu monotonicity, enrichment, accumulation, absorption and linearity block, and `modal_future`; and C3 excludes seriality and the uniformity layer. The study explicitly DECLINES the completeness claim. Establishing or refuting it is this task, and the honest starting position is that it is open.

THE FIRST OBSTACLE, which any canonical-model construction will hit immediately (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.3): the germ constraint. Every C3-validity holds at every one-point germ, and `box (phi U psi)` and `box (phi S psi)` are C3-UNSATISFIABLE for every `phi` and `psi`. That is stronger than the loss of seriality: it constrains what any axiomatization of C3 could look like, since no boxed binary-tense formula can ever be a theorem. A canonical model for C3 must either accommodate germs in the box range or the box range must be cut back first.

SEQUENCING. Do not start before the box-range design choice recorded in the C3/C4 library task is settled by the author. If the box range is cut back, this task is about a DIFFERENT logic and this description must be revised before any work begins.

LITERATURE. Burgess 1982 and Xu 1988 axiomatize `U`/`S` over an arbitrary linear order BEFORE unboundedness is added, which is exactly the setting C3 lives in. Check the Literature/ index for both before starting; acquire them if absent.

---

### 568. C3 c4 consequence relations as library definitions
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: None

**Description**: Promote the alternative consequence relations into the library, from `specs/553_decide_convex_history_layer_collapse/probes/02_alternative-consequence.lean` and `specs/553_decide_convex_history_layer_collapse/probes/03_axiom-survival.lean`. This is the task the author's own reframing most directly asks for: it is what makes C3 and C4 things this repository HAS rather than things a probe file mentions.

THE FOUR RELATIONS (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 3.1). C1 (current, and the paper's `def:logical-consequence`): total index, box over `H_F`, tenses over all of `D`. C2: any convex index, box over `H_F`, tenses over all of `D` -- DIAGNOSTIC ONLY, and strictly worse than both C1 and C3, since it invalidates `modal_t`; do not promote it as a candidate semantics. C3 (the paper's footnote at possible_worlds.tex line 1102): index any convex `tau` with `x` in `dom tau`, box over the convex histories whose domain contains `x`, tenses and evaluation time restricted to `dom tau`. C4: C3 with the index restricted to closed bounded interval domains -- the domain shape of `Beh(F)(l)`'s sections up to translation.

DELIVER: `TruthAtConvex` (a local recursion written BESIDE the library's `TruthAt`, never a modification of it), `ValidC3`, `ValidC4`; the germ theorems `germ_untl_false`, `c3_box_untl_unsat`, `c3_box_snce_unsat`, `c3_valid_imp_germ_valid`, `c3_nec`; the shift-invariance lemma `truthC3_timeShift`; the separations `valid_C1_someFuture_top`, `refute_C3_someFuture_top`, `refute_C3_somePast_top`, `refute_C4_someFuture_top`; the containment `validC3_imp_validC4`; and the section 4.1 axiom-survival table as theorems, INCLUDING the six machine-checked failures (`serial_future`, `serial_past`, `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_box_necessity`).

CLOSE THE FOUR GAPS section 4.1 leaves open: `discrete_propagate_bwd` and `z1` are CONDITIONAL; `prior_U_gap`, `prior_S_gap` and `sep` are UNRESOLVED. The RTime layer is genuine work -- `K+` is itself a restricted `U`/`S` formula whose endpoint behaviour was never checked.

WORKING DEFAULT ON THE BOX-RANGE DESIGN CHOICE, revisable by the author and recorded here so it is not settled by accident: keep the footnote's own reading as the PRIMARY C3 -- box ranging over ALL convex histories through `x`, one-point germs included -- and add the cut-back variant (interval sections of some minimum length, or those whose domain contains `dom tau`) as a NAMED ALTERNATIVE. Rationale: the footnote is the definition of record, and the germ result is more interesting stated than avoided. If the author overrides this, the override changes what the completeness sequel is about, so it must be recorded here BEFORE that sequel starts.

WHAT C3 IS, for docstrings (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.2): TM's S5 modal layer over a bounded-interval tense logic. Every axiom failure is an EXISTENCE ASSERTION about the temporal order, and boundedness is exactly what makes existence assertions fail. `modal_future` SURVIVES, because C3 is time-uniform -- `truthC3_timeShift` is the C3 analogue of `app:auto_existence`. Do NOT claim that C3 equals Burgess-Xu-without-seriality plus S5; that is a completeness question and it belongs to the sequel task.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase. C1 -- the library's own `TruthAt` and `ConsequenceOnFrames` -- must be left semantically unchanged by this task.

---

### 567. Determinism clause and separatedness asymmetry
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Prove `app:presheaf-dictionary`'s Determinism clause -- `F` deterministic iff every restriction map of `Beh(F)` is injective -- and connect it to `states_eq_of_deterministic` in `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean`.

THE DELIVERABLE THAT MAKES THIS WORTH DOING is not the dictionary row but the asymmetry the study found (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.2.1): SEPARATEDNESS of `Beh(F)` is STRICTLY STRONGER than the validity of `Determined` on `F`. The witness for the failure of the converse is the drift frame already living in `FormalSystem/Metalogic/Independence/` -- this repository's own countermodel, not a new construction. State the result as a THEOREM PAIR (one direction proved, the converse refuted by that countermodel), not as a single clause.

WHY IT MATTERS. This is one of only two results the study found running FROM this repository's semantics TO the paper's category theory rather than the reverse. That direction is the point of the categorical front, not a by-product of it.

OPEN QUESTION TO POSE, NOT TO SETTLE: does any `BL-star` formula characterize separatedness of `Beh(F)` exactly? `PlusDeterminism.lean`'s own choice-dependence note suggests it does not. Record the question in the module docstring; do not spend phases attacking it.

DEPENDENCY NOTE, NOW DISCHARGED. The language-name sync has landed: the file is `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean`.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase.

---

### 566. Possible worlds clause hf as limit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563, Task 565

**Description**: Prove `app:presheaf-dictionary`'s Possible Worlds clause: `H_F iso lim Beh(F)(2x)` along the central restrictions.

EXISTING HOOK, to be used rather than rebuilt: over `D = Z` this connects to `FrameOver.mem_HF_iff_adjacent`, already proved in `FormalSystem/Semantics/IntTransfer.lean`. Do not re-derive the adjacency argument.

DEPENDS on the interval-site/presheaf cluster and on the Totality clause, since the limit construction consumes Totality.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase. Background: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.1.

---

### 565. Totality and directed gluing from extension theorem
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Prove `app:presheaf-dictionary`'s Totality and Directed Gluing clauses. Both are WRAPPERS on `thm:extension`, which is fully proved in this repository under `FormalSystem/Semantics/Extension/`: translate a section to its subinterval, extend to a possible world, restrict.

WHY THIS MATTERS OUT OF PROPORTION TO ITS SIZE. It is the task that demonstrates the Extension Theorem was the presheaf appendix's analytic content all along -- the strongest structural claim the study makes about the relationship between this repository and `app:Structure`, and the clearest single piece of evidence that the categorical material was already present here under non-categorical names. Small (1-2 phases), high explanatory value.

RECORD explicitly, rather than leaving it implicit in the proof terms, which clauses are choice-free: Sheaf is; Directed Gluing is NOT.

HARD CONSTRAINT. Leave `PartialHistory` and the Extension Theorem themselves untouched. This task CONSUMES `thm:extension`; it does not restate, strengthen or reprove it. lake build FormalSystem must be green with no new sorry at the end of every phase.

Background: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.1.

---

### 564. Sheaf clause gluing and starpasting generalization
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Prove `app:gluing` for two interval sections whose germs agree at the seam, plus the two restriction identities and uniqueness.

THE COMPOSITION STEP IS ALREADY PROVED as `glue_seam` in `specs/553_decide_convex_history_layer_collapse/probes/04_presheaf-skeleton.lean`. The remainder is assembling the glued section by cases and applying `ShiftSet.wh_ext`.

THE DE-DUPLICATION THAT MAKES THIS WORTH DOING, and which is part of the deliverable rather than optional: generalize `PlusPasting`s `paste` off its totality hypothesis. `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean`'s `paste_rel_le_lt` is the SAME ARGUMENT as the interval-site gluing step. The study established that the general-convex and interval-site versions share one proof and should not be written twice; delivering the Sheaf clause while leaving `paste` untouched creates exactly the duplication this task exists to prevent.

RECORD in the module docstring which dictionary clauses are choice-free. Sheaf is.

DEPENDENCY NOTE, NOW DISCHARGED. This formerly waited on the language-name sync. That rename has landed: the file is `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` and `paste_rel_le_lt` lives there in namespace `FormalSystem.Semantics`. Nothing blocks the generalization on naming grounds any longer.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase. Background: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` sections 5.1 and 5.2.

---

### 563. Formalize interval site and behavior presheaf
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: None

**Description**: Promote the presheaf skeleton into the library. DELIVER: the section type `Beh F l` (the convex histories with domain exactly [0, l]), restriction along the translation `Tr p`, presheaf functoriality (`restrict_id`, `restrict_comp`), and the Germs clause `Beh(F)(0) iso W`.

ALL FOUR ARE ALREADY PROVED, sorry-free, against the live tree in roughly 200 lines in `specs/553_decide_convex_history_layer_collapse/probes/04_presheaf-skeleton.lean`. The work here is siting, naming and docstrings -- not discovery. Read that probe before planning.

SITING. A new `FormalSystem/Semantics/Presheaf/` cluster, placed BELOW `Truth.lean` in the module layering so that the existing `assert_not_exists` on the proof system still holds. Two repo conventions apply: a directory `X/` has exactly one sibling aggregator `X.lean`, and `scripts/check-module-invariants.sh` C24 requires every module to stay in the root closure.

PAPER ANCHORS: `app:Structure`'s `def:interval-site` and `def:behavior-presheaf` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex. Docstrings must cite those labels. NOTE that `app:Structure` carries a `% TODO: review in full` marker in the LaTeX source, so this task tracks material the author has not finished reviewing -- flag that in the module docstring rather than silently depending on it.

OPTIONAL, only if cheap: `BD+` and the twisted-arrow category with `lem:interval-twisted-arrow`. That lemma is pure order algebra and needs no frame.

WHY THIS FIRST. It is the cheapest task on the categorical front -- the theorems already exist -- and it gates the Sheaf, Totality/Directed Gluing, Possible Worlds and Determinism clauses. Background and the full `app:Structure`-to-tree dictionary: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.1.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase.

---

### 560. Implement tm star completeness nondeterministic canonical model
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 559

**Description**: GATED IMPLEMENTATION -- do not plan or dispatch until research task 559 has reported; rescope this description on 559's verdict table and implementation design first, exactly as task 537 was rescoped on 535. GOAL: implement in Lean the completeness of TM⁺ (L plus the stability modal ⊡) over the paper's all-histories task-frame semantics, using the nondeterministic canonical model that 559 designs, at the frame class 559 selects first (ZTime expected: plus_completeness_ztime : PlusValidZTime φ → PlusDerivable FrameClass.ZTime [] φ), then extending class by class in the order 559's table justifies (Dense, then Base by re-running the three-way root-MCS split of BXCanonical/Completeness.lean's `completeness` with both nondeterministic engines and a PlusFormula mcs_mixed_case_absurd, then Dedekind if 559 finds a route). If 559 finds that additional ⊡-axioms or a naming rule are needed, add them to PlusAxiom / PlusDerivationTree under the landed discipline (closed inductive, minFrameClass arm, one soundness lemma per constructor in Conservativity/Plus/AxiomValidity.lean and PlusSoundness.lean, swap-validity arm for TD), re-establish plus_soundness at all four classes, and re-check that both conservativity directions in Conservativity/Plus/Forward.lean (forward_plus, plusDerivable_ofFormula_iff, plus_of_tmMinus, tmFrag_iff_plus) still hold -- a new constructor that breaks conservativity over TM is a defect, not a result. If 559's verdict is that only the BUNDLED semantics is reachable, this task implements bundled completeness under a distinct validity predicate (e.g. PlusValidBundled) and documents in PlusLanguage/README.md and the Metalogic README that it is a different semantics from the paper's, with the all-histories problem recorded as open; it must not present a bundled theorem as completeness over task frames. CONSISTENCY CHECKS: the deterministic completeness landed by task 537 must be recoverable as the ⊡ = id special case (states_eq_of_deterministic, Semantics/PlusDeterminism.lean), and the PS/US underivability record from 537 must be respected -- the canonical frame must realize pasting (Semantics/PlusPasting.lean's `paste`). HARD CONSTRAINTS: never state a completeness theorem and discharge it with sorry; each phase one agent run with lake build FormalSystem green and no new sorry at its end; keep C2/C3/C14 invariants green; no task numbers under FormalSystem/. DOCUMENTATION: Metalogic/Conservativity/Plus/README.md and Metalogic/README.md metatheory rows (this task edits the same rows 537 edits, which is why it is sequenced after 537). DEPENDENCIES: 559 (design and verdict), 537 (baseline results and shared file territory).

---

### 559. Nondeterministic canonical model tm star completeness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: None

**Description**: RESEARCH TASK, verdict-first -- report and sorry-free probe files under this task's directory only; no changes to FormalSystem/ or Tests/. GOAL: adapt the existing chronicle-based completeness constructions so that the canonical frame admits NONDETERMINISM (several total histories through one world state at one time), and thereby completely axiomatize TM⁺ -- the extended language with the stability modal ⊡ -- over the paper's all-histories semantics, at whichever frame class is easiest first, with a design the other classes build on. This is the problem research task 535 recorded as BLOCKED at all four classes; this task is the dedicated attack on it and replaces the one-dispatch Lifting-Lemma spike that task 537 formerly carried. Task 537 (deterministic completeness of TM⁺ + Determined, non-definability of ⊡, PS/US underivability) proceeds independently and is the baseline any construction here must specialize to; task 560 is the gated implementation of this task's verdict.

WHY NO EXISTING ENGINE CAN BE REUSED AS IS: every countermodel is deterministic, so ⊡ = id on it and it validates Determined, hence cannot refute a consistent set containing ¬(φ → ⊡φ). Concretely: bundleFlowFrame = multiFamTaskFrameGen (Metalogic/Algebraic/FlowFrame.lean), WorldState := FamIdx × D, TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d, used by countermodel_dense_enriched / derivable_of_validDense and by completeness_dedekind; zTaskFrameV2 (Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean), WorldState := ℤ, TaskRel w d u := u = w + d, used by countermodel_discrete_reynolds_v2 / derivable_of_validZTime; WeakCanonical.countermodel_discrete (WeakCanonical/GroupModel/CountermodelBase.lean) on the non-Archimedean carrier ℚ ×ₗ ℤ, used by the Base engine. NOTE ON 'BASE FIRST': the Base theorem `completeness` (BXCanonical/Completeness.lean) is not one construction but a three-way case split on the root MCS -- dense (□(F'⊤) ∈ w₀) → the ℚ engine, purely discrete (□(U(⊤,⊥)) ∈ w₀) → the ℚ ×ₗ ℤ engine, mixed → eliminated by mcs_mixed_case_absurd via discrete_box_necessity -- so 'Base first' means adapting TWO engines and re-verifying the mixed-case elimination for PlusFormula. The single-engine targets are ZTime (derivable_of_validZTime) and Dense (derivable_of_validDense). RECOMMENDED ORDER, to be confirmed or overturned by this task's evidence: ZTime first (over ℤ Limit is limit_of_succOrder and Saturation is within reach from finite steps; 535 §4.4 agrees the ℤ setting is the most promising), then Dense (Limit at risk on the class frame), then Base by re-running the three-way split with both nondeterministic engines, Dedekind last (the Doets route is a linear-order result with no branching analogue).

THE OBSTRUCTION TO BEAT, named precisely (535 §4.2-4.3): on the class frame W := MCS/≈ with Γ ≈ Δ iff Γ and Δ have the same ⊡-formulas, Compositionality forces H_F to be closed under splicing two total histories at a shared (state, time) -- Semantics/PlusPasting.lean's `paste` IS this closure, proved from TaskFrame.comp and converse alone -- so H_F contains pasted class-sequences that are the class-image of no single canonical chronicle, and the ⊡ truth lemma's left-to-right direction (⊡φ ∈ Γ ⇒ φ at every σ through [Γ]) needs the LIFTING LEMMA: every ⇒-respecting σ : D → W lifts to a tense-coherent MCS labelling Λ with Λ(t) ∈ σ(t). PS and US secure exactly the pure-future/pure-past shadow of this; a mixed demand such as FPq ∈ Λ(s) is not covered. The literal class construction also fails comp's composition direction, and the repair (close ⇒ under composition) moves the problem into H_F rather than removing it. OVER ℤ THE SEMANTICS IS CONCRETE AND SHOULD BE EXPLOITED: a task frame over ℤ is a digraph (W, ⇒₁) in which every node has an in-edge and an out-edge, ⇒_n = (⇒₁)^n by comp, H_F is the set of bi-infinite walks, □ quantifies over all walks at the current time, ⊡ over the walks through the current node at the current time, atoms are valued on nodes; this is the complete (all-walks) semantics, the analogue of full CTL* / complete-tree Ockhamist validity as against bundled validity, except that walks through a node may diverge in the PAST as well (the T×W / Kamp-frame shape of Thomason 1984 §4, not the tree shape).

QUESTIONS TO SETTLE, each with a verdict and machine-checked evidence where a claim is checkable: (1) FRAME DESIGN. Choose W and ⇒ -- ⊡-classes of MCSs; MCSs themselves with ⇒ realized by chronicles; or a step-by-step Burgess-Xu construction that builds the digraph and its walks together so that the truth lemma is only ever asked about walks the construction made -- such that all six TaskFrame axioms (nullity_identity, comp both directions, converse, serial, limit, saturation; TaskFrame.lean) hold; record which are automatic over ℤ and which need argument. (2) LIFTING OVER ℤ. Prove the Lifting Lemma over ℤ-time for the chosen W, or exhibit the first mixed-formula demand that PS/US cannot meet with a sorry-free countermodel to naive lifting. If it fails as stated: (a) which additional schemata are valid over ALL task frames and would close the gap -- mixed pasting schemata, and a limit-closure analogue of Reynolds' LC axiom for the bundled→complete gap -- each probed with lean_run_code against PlusTruthAt and recorded sorry-free or labelled UNVERIFIED; (b) whether a Gabbay/IRR-style naming rule is unavoidable (535 §3.2's candidate: from ⊢ (q ∧ ⊡q ∧ □H¬q ∧ □G¬q) → φ infer ⊢ φ, q fresh; soundness UNVERIFIED), what it costs PlusDerivationTree, and whether the ANF phenomenon (p → ⊡p valid for atoms, Fp → ⊡Fp refutable; uniform substitution unsound, Independence/DeterminismUndefinable.lean) forces it; (c) whether the L⁺-indistinguishability technique the tree already has -- fzero_plusValidOn_iff_f1 via Independence/{StateSetTruth,OrderTransfer}.lean, where a nondeterministic frame and a deterministic one validate the same L⁺-formulas -- generalizes to show that a BUNDLED canonical model and its all-histories completion satisfy the same L⁺-formulas at the evaluation point; that would close the bundled→complete gap with no rule and is the most repo-native route, so assess it honestly rather than assume it. (3) BUNDLED FALLBACK. Define bundled TM⁺ semantics (models (F, B, V) with B ⊆ H_F closed under time shift and paste, □ and ⊡ quantifying over B; this is Zanardo 1991's setting transposed) and determine whether completeness of the CURRENT PlusAxiom set over bundled models is provable from the existing engines with modest changes. If the all-histories result is out of reach at every class, this is the result to recommend, stated plainly as a different semantics from the paper's. (4) PER-CLASS VERDICT TABLE in the 535 §4.4 style for ZTime, Dense, Base, Dedekind: provable / provable with named additions / blocked with the failing axiom and formula class, with the engine to fork and the file territory for each, and what each class's result gives the next. (5) IMPLEMENTATION DESIGN for task 560: phases sized one agent run each, first-class target theorem plus_completeness_ztime : PlusValidZTime φ → PlusDerivable FrameClass.ZTime [] φ (or the augmented system, if additions are needed), the consistency check against 537's deterministic completeness, and the soundness obligations for any new constructor (closed-inductive PlusAxiom, one soundness lemma per constructor, both-direction conservativity in Conservativity/Plus/Forward.lean re-checked -- a new ⊡-axiom must not disturb forward_plus and plusDerivable_ofFormula_iff).

GROUND TRUTH to read first: 535's report §3-4 and §7.3 with its probes; 533's PlusLanguage/* and Metalogic/Conservativity/Plus/* (PlusAxiom is closed inductive, 53 constructors, soundness by atomization + a PlusFormula TruthAntiIso); 536's Semantics/PlusDeterminism.lean and Metalogic/Independence/{DriftFrame,DriftHistories,OrderTransfer,StateSetTruth,DeterminismUndefinable}.lean; the engines named above and Metalogic/README.md's three-routes section. LITERATURE (consult via --lit and online): Reynolds 2001 'An axiomatization of full computation tree logic' (the LC axiom and the bundled/full gap -- the closest published analogue of this task), Reynolds 2003 (complete-tree Ockhamist, F/P only, IRR + ANF), Zanardo 1991 (bundled S/U), Thomason 1984 §4 (T×W and Kamp frames), von Kutschera 1997 and Di Maio-Zanardo 1996 (T×W axiomatizations, with and without a rule), Burgess 1982 / Burgess-Xu chronicle construction. HARD CONSTRAINTS: never state a completeness theorem and discharge it with sorry; a written obstruction naming the failing TaskFrame axiom and the formula class where lifting breaks is a complete outcome; every proposed new axiom carries a sorry-free validity probe or the label UNVERIFIED; do not begin the implementation here. OUTPUT: report plus probes under this task's directory; on any positive or conditional verdict, rescope task 560's description on the report exactly as 537 was rescoped on 535.

---

### 543. Formalize mf correspondence rigidity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 500

**Description**: Machine-check the principal new results from the MF frame-correspondence research conducted in the PossibleWorlds paper repository. SOURCE MATERIAL (read before starting; six reports, all outside this repository): /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/136_rewrite_mf_paragraph_frame_correspondence/reports/02_mf-substrate-weakening-definability.md (Theorem A), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/136_rewrite_mf_paragraph_frame_correspondence/reports/03_worlds-topological-categorical-characterization.md (rigidity, T1 converse), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/136_rewrite_mf_paragraph_frame_correspondence/reports/04_dense-correspondent-and-rigidity.md (Theorems B and C, scope limits), and /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/136_rewrite_mf_paragraph_frame_correspondence/reports/05_lean-verification-and-formalization-program.md (THE ROADMAP -- effort estimates, elaborated statements, and Mathlib dependencies, all checked against this tree). VERIFIED BASELINE, established by that round-3 work against this repository: lake build FormalSystem green (2591 jobs); 20 lean_verify calls returning standard axioms with no sorryAx; and the claim that modal_future_valid discharges no frame field now verified at the proof-term level by a transitive constant-closure walk (696 of 703 constants, imported bodies loaded via findAsync?) finding no FrameOver or TaskFrame field projection and no hF_nonempty. TARGETS, in roadmap priority order. R1: the result that deterministic task frames determine the same BL-logic as all task frames. It is NOT the pure composition of reverse_repr and forward_repr that the originating report claimed -- it needs a third fact, S.frame.Deterministic, absent from this tree; with a one-line helper it typechecks in about 25 lines, reproduced in report 05 Appendix A.1 (elaborated in scratch only; nothing was written into this repository). R2 -- BEST EFFORT-TO-VALUE IN THE SET: the rigidity theorem (report 03 section 4.3.6): over a dense Archimedean temporal order a task frame is static iff it has a uniform dwell time, hence every task frame over such an order with finitely many world states is static. Approximately 100 lines, and the finite-W half ALREADY EXISTS here as exists_uniform_radius_of_finite. The proof uses only Limit and Compositionality; Mathlib supplies Archimedean and DenselyOrdered. The claim is surprising enough that machine-checking it before it enters the paper is the point. Note report 04's refinement: for time-indexed frames the boundary is Dedekind completeness rather than the Archimedean property. R3: the T1-converse witness (report 03 section 4.2.3), a 4-state structure refuting the converse of the paper's Limit-implies-T1 result. BLOCKER TO RESOLVE FIRST: this witness cannot currently even be STATED here, because WorldHistory requires a TaskFrame and the witness violates that structure's limit field; a structural workaround is needed, and this would introduce the first topology into the repository. R4: Theorem A (MF valid iff the task relation is stationary) over Z-time, medium-large; the TimeIndexed structure and the statement are elaborated in report 05. CRITICAL SCOPE CONSTRAINT from report 04 Theorem C: Theorem A's scope is EXACTLY D isomorphic to Z -- for every discrete D not isomorphic to Z (including Z x_lex Z) and every countable or divisible dense D, a non-affine order-automorphism yields a deterministic non-stationary MF-valid frame. Do not state it more generally. Also worth formalizing: Theorem B (report 04) -- MF valid iff its past mirror MP valid iff every box-sentence is globally constant in every model -- which is exact and uniform over every D and is flagged in report 04 as reachable via box_const. NOT RECOMMENDED: Theorem A-prime; report 05 judges the formalization cost unjustified and the paper statement fine unformalized. DEPENDENCY RATIONALE: this task depends on the ShiftSet representation-theorem reconciliation research task because Theorems A and B both touch FormalSystem/Semantics/ShiftSet.lean, and that task exists precisely to prevent two parallel representation theorems from being developed and having to be reconciled afterwards. Settle that question before landing R4. Land real proofs; no sorry. This repository already carries a task-relation correspondent the paper lacks, density_schema_iff_fwdRec over Z, which is a useful model for how to state these.

---

### 540. Docstring coverage class instance lemma
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: codebase-cleanup
- **Dependencies**: Task 588, Task 597

**Description**: Close the three declaration categories that sit far below the repository's docstring-coverage floor. MEASURED STATE: C19 in scripts/check-module-invariants.sh reports 92.34% aggregate coverage over non-Boneyard FormalSystem/**/*.lean, against a 90% reporting floor, using a heuristic that counts a declaration documented if a `/-- -/` doc comment ends within the 3 lines above it OR it falls within an enclosing `/-! -/` section comment's scope. The aggregate passes, but it hides three categories that do not: class 16.3%, lemma 55.6%, instance 57.6%. For comparison the healthy categories are def 97.1%, abbrev 96.3%, inductive 96.3%, theorem 86.8%, structure 82.5%. `class` in particular is the worst-covered category in the tree and also the most consequential to a reader, since a typeclass's docstring is where its intended instances and laws are stated. Note also that the aggregate is dominated by theorem, which is 6429 of 10427 declarations, so category-level gaps do not move the headline number much. WORK: raise class, instance, and lemma coverage to at least the 90% floor by writing real docstrings -- what the declaration IS, present tense, with caller traps where they exist, per the repository's three-register docstring convention. Do not close the gap by widening C19's heuristic further; the heuristic was already deliberately refined once (to credit `/-!` sections) under explicit authorization, and a second widening to make a category pass would be fitting the measure to the data. Where a `lemma` is genuinely an internal step not worth documenting, consider whether it should be `private` rather than undocumented. ACCEPTANCE: C19 reports at least 90% for each of class, instance, and lemma individually, not merely in aggregate; the aggregate does not regress below its current 92.34%; no change to C19's counting rule.

---

### 534. Hg fragment finite axiomatizability
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: incompleteness
- **Dependencies**: None

**Description**: Research and, where feasible, establish in Lean whether the H/G-fragment of TM is finitely axiomatizable natively in the tense-only language L⁻ (primitive tense operators H and G) -- Kamp/Burgess territory. THE OBJECT: TMFrag fc φ := TM ⊢_fc tr φ, the H/G-fragment of TM delivered by task 533 (Metalogic/Conservativity/Fragment.lean), which by the fragment completeness theorem is exactly Log_{H,G}(fc), the set of H/G-sentences valid over the frame class fc, for each of Base, Dense, Discrete, Dedekind. KNOWN: TM⁻ ⊊ TMFrag at Discrete (witness Z1, machine-checked: not_minus_derivable_z1, z1_translate) and at Base (witness the splitting schema (DD), formerly (Sp), refuted in source); by tmMinusComplete_iff_forward these gaps are exactly TM's semantic incompleteness. THE QUESTION: for each class fc, is there a FINITE set Σ_fc of H/G-schemas (or at least a recursive set) with TM⁻ + Σ_fc = TMFrag_fc? Candidates: (DD); Z1-type backward-induction schemas; the classical H/G axiomatizations of linear discrete/dense/complete flows of time (Burgess 1982 Axioms for tense logic I and II; Burgess 1984 handbook chapter; Kamp 1968; Gabbay-Hodkinson-Reynolds 1994; Prior), adapted to the bimodal setting where □ ranges over all world histories of a single task frame with the MF interaction axiom and every history shares one temporal order (so Log(all task frames) = Log(Discrete) ∩ Log(Dense) and (DD) is a split validity -- see the Halldén analysis in PossibleWorlds tasks 72 and 82, which record that completeness of TM⁻ + (DD) turns on whether TM⁻_f and TM⁻_d axiomatize their classes, both open). Consult the Literature/ corpus (burgess_1982, burgess_1982_ii, burgess_1982b, burgess_1984, venema_1993_since_until, venema_2001) via --lit and survey online sources. DELIVERABLES: a per-class verdict (finitely axiomatizable / recursively axiomatizable / open with the precise obstruction named), a candidate axiom set Σ_fc, and the machine-checked partial results that are honestly obtainable: soundness of TM⁻ + Σ_fc relative to TMFrag_fc (i.e. TM⁻ + Σ_fc ⊆ TMFrag_fc) and either a completeness proof (canonical model or filtration in the H/G language) or a separating H/G-validity showing TM⁻ + Σ_fc ⊊ TMFrag_fc. A negative or open verdict with evidence is a complete outcome. HARD CONSTRAINT: never state a completeness or conservativity theorem and discharge it with sorry. PAPER DEPENDENCY: the paper (PossibleWorlds, possible_worlds.tex, sub:Logic, the footnote following "TM⁻ owes its strength to since and until", currently commented out) waits on this task. The paper wants to assert that the Past/Future language admits no complete finite axiomatization of the fragment, and the footnote stays commented out until a negative verdict is established here. Note the claim must be non-FINITE-axiomatizability: the fragment is r.e. via TM⁻+, so a recursive axiomatization exists trivially. A positive or open verdict must also be reported back so the footnote can be reworded to match.

---

### 506. Fix typst display defects via playwright visual loop
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: codebase-cleanup
- **Dependencies**: Task 586
- **Research**: [506_fix_typst_display_defects_via_playwright_visual_loop/reports/01_typst-display-defects-catalog.md]
- **Plan**: [506_fix_typst_display_defects_via_playwright_visual_loop/plans/01_typst-layout-defect-fixes.md]
- **Summary**: [506_fix_typst_display_defects_via_playwright_visual_loop/summaries/01_typst-layout-defect-fixes-summary.md]

**Description**: Fix all outstanding display/layout defects in the compiled typst documents (typst/FormalFoundations.typ and typst/BimodalReference.typ) using a Playwright-driven visual check loop. Known defect: in <sec:representation> Definition 5.1 (TM+-algebra), the display equation listing the derived operators (F a := 1 ▷ a, G a := ¬F(¬a), P a := 1 ◁ a, H a := ¬P(¬a), Next a := 0 ▷ a, △a := H a ∧ a ∧ G a) is set as one unbreakable math line and overflows both the definition box and the page margins; it must be broken across lines (e.g. an aligned block or a two-row layout) so it fits within the text block. Approach: compile each document to PDF (and/or SVG/PNG pages via `typst compile --format png`), serve the output to a headless browser via the Playwright MCP tools, screenshot every page, and systematically inspect for overflowing display math, content escaping theorem/definition boxes, text running past margins, clipped tables, orphaned headings, broken cross-references or citation placeholders, and any other visual defect. Catalogue every finding with page number and source line, then plan and implement fixes in the .typ sources (line-breaking long equations, resizing tables, adjusting box widths, etc.), recompiling and re-screenshotting after each fix and repeating the full sweep until no display issues remain. Both documents must compile cleanly and scripts/typst-sync-check.sh must pass at the end. Do not change mathematical content — layout only

ORDERING NOTE (codebase-cleanup reorganization, 2026-09-16): this layout pass follows the proof-automation chapter rewrite (586), which replaces a whole section of `typst/chapters/p4-proof-automation.typ`; screenshot after that lands so layout fixes are not made to text that is about to be rewritten.

---

### 504. Retry acquisition of missing representation sources
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: None

**Description**: Retry acquisition of the standard modal-representation sources that the representation-section literature research could not obtain because Semantic Scholar (literature-discover.sh Tier 3) was rate-limited (HTTP 429) for the whole session: Sambin & Vaccaro 1988 "Topology and duality in modal logic"; S. K. Thomason 1972 "Semantic analysis of tense logics" and 1975 "Categories of frames for modal logic"; Goldblatt 1976 "Metamathematics of modal logic" I-II; Fine 1975 "Some connections between elementary and modal logic"; Gehrke & Jonsson 2004 "Bounded distributive lattice expansions" (mscand.dk URLs 404; proxy gehrke_vosmaer_2011 already ingested); Gabbay & Shehtman "Products of modal logics I"; Marx & Venema 1997 "Multi-dimensional modal logic" (Zotero metadata only, no PDF). Use /literature "<title>" or literature-discover.sh once Tier 3 recovers (or after the S2_API_KEY / multi-provider fallback lands in the literature extension), ingest what is open-access or in Zotero, record paywalled items honestly as not acquired, and register every acquired doc in specs/literature-index.json with reason and citation_rule fields following the existing entries. Evidence and the full standard-sources checklist are in specs/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md sections 2.2-2.3

---

### 502. Ground algebraic representation in goldblatt and brv
- **Effort**: 12-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

**Description**: RESEARCH TASK. Ground the algebraic representation front in the literature BEFORE the STSA axiom set is fixed and before Uf(A) is constructed. Gates the STSA port; the complex-algebra and ultrafilter-frame tasks inherit the gate transitively.

WHY THIS RUNS EARLY. Goldblatt 1989 is largely about which varieties of Boolean algebras with operators are complex algebras, and about canonicity. Those are design questions for the STSA axiomatization and for the Uf(A) construction, not questions the eta-embedding capstone can act on. On the pre-existing graph this paper was ingested in wave 1 and not opened until wave 4, by which point three tasks would have committed to designs it should have informed.

PRIMARY SOURCE, WITH A HARD READING CONSTRAINT. Goldblatt, R. "Varieties of complex algebras", Annals of Pure and Applied Logic 44 (1989) 173-242, doi 10.1016/0168-0072(89)90032-8. The acquired PDF is an Acrobat 3.0 Capture scan (70 pages) whose OCR text layer is UNRELIABLE ON MATHEMATICS: symbols mangle, lines drop and reorder, and even the title page renders New Zealand as "New 2Miand". READ THE PAGE IMAGES via the Read tool's pages parameter. Do NOT grep the text layer for definitions or theorem statements, and do NOT accept a pdftotext- or /literature --convert-derived markdown as a faithful source for any axiom or equation. The text layer is usable only as a rough locator.

PAGINATION. Journal page 173 is PDF page 1, so PDF page = journal page - 172. The paper's own table of contents is partly OCR-garbled in its page-number column; verify each section start against the actual page image rather than trusting the offsets below.

SECTIONS IN SCOPE (do not read the whole paper):
- 2.2 The dual space of a lattice (journal ~185) and 2.3 Bounded morphisms (~192) -- the duality machinery the eta embedding rests on.
- 3.1 Canonical structures (~198) -- the canonical extension / Uf(A) construction. Bears directly on the ultrafilter-frame task.
- 3.5 Canonical varieties (~208) -- IS THE STSA VARIETY CANONICAL? This is the single most load-bearing question for the STSA port, which must restate three Boneyard sorries against the current 45-constructor axiom set and should not do so blind.
- 3.6 The elementary case (~210) and 3.8 First-order definability -- bears on whether the Spherical frame condition is first-order definable and preserved, which is the ultrafilter-frame task's dominant and explicitly unattempted obligation, and one the paper's finite-W discharge pattern does not cover.
- 4.2 Preservation by bounded morphisms and inner substructures (~229) -- whether the TaskFrame axioms transfer along the constructions.
EXPLICITLY OUT OF SCOPE: 2.4 Heyting algebras (intuitionistic, not this signature).

CROSS-FRONT NOTE, RECORD BUT DO NOT PURSUE HERE: section 4.3 covers preservation by DISJOINT UNIONS, which may bear on the two-fibre structure named in Metalogic/Conservativity.lean as the CEB countermodel shape. That belongs to the TM-completeness research task on the metalogic front; if 4.3 looks relevant, record a pointer for that task rather than expanding this one.

SECONDARY SOURCE: Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002, born-digital, full text) is the standard Jonsson-Tarski reference and should be read alongside. CAVEAT: the corpus warns this entry is 365,868 tokens and exceeds a single context budget -- create a chapter-scoped sub-entry before an agent consumes it.

DELIVERABLE: a grounding report answering, with citations to specific pages read as images: (1) does the STSA axiom set as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean match the standard BAO presentation, and where does it diverge; (2) is the variety canonical, and what does that buy or cost the representation; (3) what the literature says about discharging a Spherical-style frame condition on an ultrafilter frame; (4) a concrete recommendation on how the three removed-axiom sorries (temp_a, temp_l) should be restated against the current axiom set. A finding that the literature does NOT settle one of these is a complete and valid answer for that item -- record it as unsettled rather than manufacturing a verdict.

---

### 501. Extend stsa with until since operators
- **Effort**: 20-32 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 125

**Description**: Phase 4 of the Jonsson-Tarski representation: extend STSA with the binary Until and Since operators. The STSA class as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean carries only the unary box, G, H and sigma. The live object language's primitives are untl and snce (Formula, Syntax/Formula.lean), with allFuture and allPast DERIVED from them (:167, :177) -- so an STSA over the unary fragment alone does not represent the actual logic, and the representation theorem is incomplete without this. SCOPE: add binary operators to the STSA signature with their algebraic laws, extend the complex algebra Cm(F) to interpret them from the frame relations, extend the ultrafilter frame Uf(A) correspondingly, and re-prove the eta embedding at the extended signature. SEQUENCING: this deliberately follows the unary capstone rather than being folded into it -- the unary representation is a standalone result worth landing first, and folding the binary case in would make a single task that cannot complete in one dispatch. LITERATURE: Blackburn/de Rijke/Venema 2002 Chapter 5 (in the corpus as blackburn_2002, full text) is the standard reference for Jonsson-Tarski and its extensions to n-ary operators. Note the corpus warns blackburn_2002 exceeds a single context budget at 365,868 tokens -- a chapter-scoped sub-entry should be created before an agent consumes it.

---

### 500. Reconcile shiftset representation with stsa route
- **Effort**: 10-16 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: RESEARCH TASK. Prevent two parallel representation theorems from being developed and having to be reconciled after the fact. THE OBSERVATION: FormalSystem/Semantics/ShiftSet.lean -- landed by task 424 for the COMPACTNESS route -- is already a representation theorem. forward_repr (:263) and reverse_repr (:362) represent task models as shift sets, both directions, sorry-free. Separately, the STSA design report (specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md) identifies its key structural claim as: box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra, which is the algebraic encoding of OMEGA BEING SHIFT-CLOSED. That is the same shift structure ShiftSet.lean makes explicit. These look like two views of one representation. SCOPE: determine whether they are, and if so, specify the shared infrastructure so the algebraic route consumes ShiftSet rather than duplicating it. Concretely: (a) is Cm(F) expressible as an algebra of shift-invariant subsets of a ShiftSet carrier? (b) does ShiftSet's sep hypothesis correspond to an STSA axiom, and if so which? (c) can the eta embedding be factored through reverse_repr? DELIVERABLE: a report with a verdict and, if affirmative, a concrete refactor specification. A NEGATIVE VERDICT IS A COMPLETE OUTCOME -- if the two representations are genuinely different objects, say so with evidence and record it so the question is not reopened. TIMING: run this after the Los-lemma work and the STSA port have both landed, so both sides are concrete rather than projected.

---

### 499. Build ultrafilter frame and prove task frame axioms
- **Effort**: 24-40 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: HARD. Phase 2 of the Jonsson-Tarski representation: the ultrafilter frame Uf(A), and the proof that it is a TaskFrame. THE SEED: Boneyard/UltrafilterFrame/UltrafilterFrame.lean (1189 lines, behind #exit, 4 sorry hits) already has R_G (:82), R_Box (:90), R_H (:98) and a substantial body of proved structure -- R_Box_refl (:111), R_Box_euclidean (:127), R_Box_symm (:154), R_Box_trans (:164), R_G_R_H_converse (:179), the preimage and upward-closure lemmas (:229-251), R_G_trans (:281), R_H_trans (:304), and the F/P resolution lemmas (:515, :750). Port and revive rather than rebuild. THE GENUINELY NEW OBLIGATION, flagged in task 125's own FOUR-AXIOM EXPOSURE NOTE (2026-08-10): proving SPHERICAL for an ultrafilter frame is nontrivial and unattempted, and the paper's finite-W discharge pattern EXPLICITLY DOES NOT APPLY. Budget this as the dominant cost of the task; Compositionality, Seriality and Limit are expected to be far cheaper. MATHLIB HOOKS: Order/PrimeSeparator.lean:44 (DistribLattice.prime_ideal_of_disjoint_filter_ideal -- the Boolean prime ideal theorem in distributive-lattice form) is what a Zorn-free Uf(A)-nonemptiness argument should use; Order/Ideal.lean and Order/PrimeIdeal.lean (:156, :171) give the ultrafilter-as-prime-filter characterization. NOTE: Mathlib has NO Ultrafilter on an abstract Boolean algebra -- its Ultrafilter is Filter-on-Set-based. UltrafilterMCS.lean:44 rolls its own structure for exactly this reason, and its MCS-to-ultrafilter bijection (ultrafilter_correspondence :782) is available, though stated existentially rather than as a named Equiv. SHADOWING HAZARD: if Mathlib's Ultrafilter is opened in that namespace it collides with the bespoke one; keep them explicitly qualified.

---

### 498. Build complex algebra for task frames
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: Phase 1 of the Jonsson-Tarski representation: the complex algebra Cm(F). Construct the powerset STSA over a TaskFrame -- carrier the powerset of the world-history space, with box, G, H and sigma defined from the frame relations -- and prove it satisfies every STSA axiom. GREENFIELD WARNING: Mathlib has NO Boolean algebras with operators, no complex algebras, no canonical extensions, and no modal-algebra machinery of any kind; a survey of the pinned v4.33.0-rc1 tree found nothing reusable for this. What Mathlib DOES supply and should be used: Order/BooleanAlgebra/ (already consumed by BooleanStructure.lean:421) and Order/CompleteBooleanAlgebra.lean:711 (CompleteAtomicBooleanAlgebra). CONSTRAINT FROM THE FOUR-AXIOM WORK (task 420, completed): TaskFrame (Semantics/TaskFrame.lean:474-577) now carries SEVEN fields, not five -- biconditional Compositionality, Seriality, Limit and Spherical plus a Nonempty WorldState field and [Nontrivial D]. The complex algebra must be built against the live seven-field structure, not the five-field shape the older design documents assume. ACCEPTANCE: Cm(F) defined, instance STSA (Cm F) proved, sorry-free, lake build green.

---

### 497. Port stsa class and add g operator
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 502

**Description**: Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap. Phase 1 groundwork for the Jonsson-Tarski representation. THE SEED: Boneyard/UltrafilterFrame/TenseS5Algebra.lean (361 lines, behind #exit) already contains the full class STSA extending BooleanAlgebra with fields box, G, H, sigma and axioms box_deflationary, box_monotone, box_idempotent, box_s5, G_monotone, H_monotone, sigma_involution, sigma_neg, sigma_sup, sigma_G, sigma_H, sigma_box, MF, TF, TA, TL. This is the exact algebraic signature the representation needs. IT CARRIES 3 SORRIES, AND THEY MUST NOT BE PROVED AS-IS: they are for temp_a and temp_l, axioms that have since been REMOVED or restructured; restate them against the current 45-constructor ProofSystem.Axiom set (Axioms.lean:115-464) rather than reviving the old shapes. THE G GAP: LindenbaumQuotient.lean supplies boxQuot (:305-ish), hQuot, and sigmaQuot (:346) with its four laws (sigma_quot_involution :353, sigma_quot_neg :362, sigma_quot_sup :373, sigma_quot_box :385) -- but there is NO gQuot. G on the Lindenbaum quotient must be constructed and its congruence proved before LindenbaumAlg can be an STSA instance. Boneyard/SorriedDeclExcisions/AlgebraicGQuotChain.lean is the excised prior attempt and should be consulted, not trusted. DESIGN REFERENCE: specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md (538 lines) gives the full axiom-to-equation translation table and the key structural claim that box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra -- the algebraic encoding of Omega being shift-closed. It is stale on file names (references deleted AlgebraicRepresentation.lean and ParametricRepresentation.lean) but sound on the mathematics. ACCEPTANCE: STSA class live and sorry-free, gQuot constructed with congruence, instance STSA LindenbaumAlg, lake build green.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.

---

### 482. Discharge proof extraction completeness
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 412

**Description**: CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT be re-described as engineering, and must not be scheduled or budgeted as a routine task.

TARGET: eliminate `.extractionFailed` as a live outcome of `decide` on a genuinely closed tableau. Currently `verifyProof` is `fun _ _ => true` (`FormalSystem/Metalogic/Decidability/ProofExtraction.lean:345`, honestly commented, misleadingly named) and no theorem establishes that a closed tableau ALWAYS yields an extractable Hilbert-system derivation. `ProofExtraction.lean` has zero theorems today (re-confirmed at task 468 realignment time, 2026-08-25).

WHAT THIS REQUIRES: the missing refutation induction (`allClosed → Derivable`, the content that would live under `FormalSystem/Metalogic/Decidability/Verified/Refutation/` -- this directory does not exist today, zero files, re-confirmed 2026-08-25) is a PREREQUISITE owned by task 412, which already targets exactly this induction (`allClosed_derivable`). This task is sequenced AFTER 412 rather than folded into 412's acceptance criteria as an additional corollary, precisely so the research problem is not hidden behind 412's engineering-shaped description -- see the planner's decision recorded in task 468's implementation plan (`specs/468_realign_task_programme_from_proof_state_audit/plans/01_programme-realignment-execution.md`, "Planner decisions taken here" item 1). Task 412's own description carries a one-line REVISE naming this task as the owner of `.extractionFailed` elimination.

DEPENDENCIES: `[412]`.

FILE SCOPE: `FormalSystem/Metalogic/Decidability/ProofExtraction.lean`,
`FormalSystem/Metalogic/Decidability/Verified/Refutation/` (does not yet exist -- this task or a predecessor may need to create it).

DO NOT schedule this as an independent parallel effort that would redundantly re-derive the refutation induction 412 already targets -- consume 412's `allClosed_derivable` once it lands.

ACCEPTANCE: `.extractionFailed` is unreachable on a genuinely closed tableau (stated and proved as a corollary of `allClosed_derivable` or equivalent); `lake build` green; no regression to any currently-passing check-module-invariants.sh check; `verifyProof` either proved correct against the new theorem or replaced by an implementation whose correctness the new theorem certifies.

PROVENANCE: specced by task 468's realignment (report `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` §5, new-task-spec-2), itself descended from `specs/reviews/review-2026-08-24.md` amendment 10b's surviving ADD-list item, per R4.

---

### 481. Discharge or replace unorderedsuccessorlabelclosed residual
- **Effort**: large
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**:
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/01_unorderedsuccessorlabelclosed-verdict.md]
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/02_spawn-analysis.md]
- **Plan**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/plans/01_sharpen-replace-labelclosed-residual.md]
- **Summary**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/summaries/01_sharpen-replace-labelclosed-residual-summary.md]

**Description**: CLASSIFICATION: genuinely open -- the predicate is refuted as stated, so this is a repair-or-replace problem, not routine discharge. This is the FIFTH termination residual; the four-residual framing used elsewhere in this programme (`UniverseClosed`, `DifficultyBounded`/`StepLengthBounded`, `MintPaysForTime`, `PostBlockingSettles`) is WRONG and must be corrected wherever it recurs.

TARGET: `UnorderedSuccessorLabelClosed` (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean:836`) is carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` (`ClosureResidual.lean:1139`) and has an in-tree refutation at `ClosureResidual.lean:889` (`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`) -- the same shape of problem `DifficultyBounded` presented before `StepLengthBounded` replaced it.

WHAT TO DO -- determine which of three outcomes applies:
(a) the predicate can be discharged at the frame classes/settings the surviving terminus theorems actually need (distinct from the setting `ClosureResidual.lean:889` refutes it in -- check precisely which); or
(b) it needs a `StepLengthBounded`-style weaker replacement, analogous to the `DifficultyBounded` -> `StepLengthBounded` repair pattern already in this file; or
(c) it is unclosable as stated and needs a C9 register entry (the file already has 24 such entries; this would be the 25th) plus an explicit statement of which theorem still carries it and at which frame classes.

A C9 REGISTER ENTRY IS A VALID, COMPLETE DELIVERABLE for this task -- do not treat "prove it" as the only acceptable outcome.

SEQUENCING NOTE (direct from `specs/reviews/review-2026-08-24.md` amendment 10e, re-affirmed by task 468's realignment): task 462 targets `MintPaysForTimeFixed` discharge at a NONEMPTY UNIVERSE, which is the same setting `ClosureResidual.lean:889`'s refutation applies in. If this task and 462 are not sequenced, 462 risks either duplicating the discovery of the refutation or, worse, building on an implicit assumption that this residual is harmless. This task should run BEFORE OR ALONGSIDE 462.

DEPENDENCIES: `[434]` (established the residual set this belongs to). Do NOT fold into 465 (the mechanical restatement-family task) -- 465 is explicitly scoped as "a one-line application of its family root" for SETTLED residuals; this residual is not settled, so folding it in would either force 465 to do research work outside its charter or produce a restatement of an unsettled predicate, which is exactly the kind of premature-closure risk this whole realignment exists to prevent.

VERIFIED at task-468 realignment time (2026-08-25): none of tasks 462, 463, 464, 465 mentions the symbol `UnorderedSuccessorLabelClosed` in its live description.

ACCEPTANCE: one of outcomes (a)/(b)/(c) above is reached and recorded; `lake build` green; no regression to any currently-passing check-module-invariants.sh check.

PROVENANCE: specced by task 468's realignment (report `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` §5, new-task-spec-3), itself descended from `specs/reviews/review-2026-08-24.md` amendment 10e.

POINTER REFRESH (2026-09-16 reorganization): `MintBound.lean` was split into the `MintBound/` directory (the monolithic `MintBound.lean` is now a 121-line aggregator). Line references above were re-confirmed against `MintBound/ClosureResidual.lean` (definition :836, in-tree refutation :889, carrying theorem :1139); "this file" in the text above now means that directory. The completed dependency numbers 434/483 were pruned from the dependency list; the blocked status and blockers are unchanged.

---

### 476. Box faithful small model theorem
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None

**Description**: THE BOX-FAITHFUL SMALL-MODEL THEOREM.

CLASSIFICATION: OPEN MATHEMATICS. MULTI-MONTH. This is a genuine research problem in the same
category as the audit's R4 "semantic FMP" entry. IT MAY NOT BE RE-DESCRIBED AS ENGINEERING, AND IT
MAY NOT BE MERGED INTO THE BILASSO WIRING TASK OR THE CARRIER-NORMALIZATION TASK. Merging is
precisely how a research problem gets hidden behind an engineering description, and this task
exists partly to prevent that.

DO NOT BEGIN before the BiLasso wiring task and the carrier-normalization task (task 475) are
landed. Those two have standalone value; this one does not, and its cost is dominated by a problem
a two-day literature check might refute outright.

=== LITERATURE GATE -- RUN FIRST, AND IT IS EMPOWERED TO STOP THE TASK ===

Acquire Gabbay, Kurucz, Wolter, Zakharyaschev, *Many-Dimensional Modal Logics* (2003) and read its
temporal-products chapter. IF the two-dimensional `Until`/`Since` case is recorded there as
undecidable or as lacking the finite model property, THIS TASK IS REFUTED and must be REPORTED AS
SUCH rather than attempted. A negative result here is as valuable as a positive one and would
redirect the whole decidability front.

What is already firm from a prior search: products of THREE OR MORE modal logics are undecidable,
with no logic between K x K x K and S5 x S5 x S5 decidable, and S5 x S5 x S5 lacks the finite model
property. What is NOT settled: the two-dimensional case with `Until`/`Since`, which is what this
logic is closest to. Note that TM is in any case NOT a full product -- its second dimension is the
path space of a graph, not an arbitrary set of runs -- so a product-logic result would be evidence,
not a decision.

=== THE TARGET ===

Build `cands : Formula -> List IntPresentation` and prove

    not (ValidDiscrete phi) -> exists P in cands phi, exists w, SatAtState P w phi.neg

This is the SINGLE remaining obligation for decidability of `ValidDiscrete`. Everything else is
already compiled: given this hypothesis, `check`-over-`cands` is equivalent to `ValidDiscrete phi`
and `decidable_of_iff` reads the `Decidable` instance off it. There is no bridge theorem, no
transfer lemma, no enumeration over `Atom`, and no `Fin n`-from-`Finite` extraction anywhere in the
assembly; `check_correct` is the FINAL step.

=== THE CONSTRUCTION (the tractable part) ===

Build `cands phi` from the CLOSURE-TYPE SPACE: subsets of `subformulaClosure phi` satisfying the
local Hintikka conditions, with `step` given by `LocalCoherent`'s `untl`/`snce` unfolding clauses
(`BiLasso/Annotation.lean` already states them, and they relate the label at `t` to the label at
`t` plus-or-minus one only -- i.e. they ARE an adjacency relation), and the valuation read off the
state by deciding atom membership. Every ingredient is `Finset`/`Bool` data with `DecidableEq`.
Two real obligations, neither research-grade:

  1. `fwd`/`bwd` SERIALITY OF THE TYPE GRAPH. Not free: a Hintikka type may have no locally
     coherent successor, forcing an ITERATED PRUNING to a maximal serial subgraph. Standard,
     bounded, fiddly.
  2. INDEXING. `IntPresentation` demands `Fin card` specifically, so the type `Finset` must be
     listed and indexed. Mechanical.

Estimate for this part alone: two to four weeks.

DO NOT instead try "bound `card` by some `presentationBound phi`, then enumerate the presentations
up to that bound". That does not typecheck as stated: `IntPresentation.val : Atom -> Fin card ->
Bool` is a function on the `Infinite` type `Atom`, so presentations of a given `card` are not a
finite collection. Closing that would need a valuation-restriction lemma that is not in the tree.
The formula-indexed candidate list sidesteps the problem rather than solving it.

=== THE CRUX: BOX-FAITHFULNESS (the research part) ===

The `box` clause of `TruthAt` quantifies universally over ALL total histories. Two landed facts
make this a GLOBAL modality rather than a local one:

  - `Truth.box_const` (`Semantics/Truth.lean`): box truth is independent of both the history and
    the time. Its own docstring: "a model has one finite set of box facts, computed once."
  - `Extension.occurrence` (`cor:occurrence`): every state occurs at every time in some total
    history.

That collapse is why `BoxOracleSound P bx` types `bx` as `Formula -> Bool` -- one `Bool` per
formula, per model. It is also the obstruction:

  The box facts of the SOURCE model M and of the TARGET presentation P are each global constants
  of their own model, and they need not agree. P admits every path of its graph. The subgraph of
  types realized in M still generates paths that M does not realize, and along such a path a
  `box chi` true in M can fail. When it fails, the type-map image is no longer a `LocalCoherent`
  annotation, and the transfer breaks.

Restricting `cands phi` to realized-type subgraphs does NOT by itself close this: the subshift
generated by the realized edges properly contains the realized paths. So the residue is a genuine
BOX-FAITHFUL small-model theorem -- in effect a bounded-model property for LTL(Until, Since) over
bi-infinite paths of a graph, PLUS a universal path quantifier over the whole structure.

Is it true? Almost certainly -- the shape is the classical automata-theoretic bounded-model
setting, and the analogous results (CTL*-style satisfiability, LTL with a universal modality) are
decidable with finite/bounded model properties. Is it in reach? Not routinely. Neither Mathlib nor
this tree carries omega-automata, Buchi complementation, or any language-inclusion machinery, so a
Lean proof must be hand-rolled.

=== WHAT TO REUSE ===

`BiLasso/GoodCycle.lean`'s good-cycle argument, `cycleBound`, and `exists_annot_of_truth` are
exactly the fulfilment machinery a hand-rolled proof would reuse. Be clear-eyed that they operate
INSIDE a presentation, not across the model boundary, which is the whole difficulty.

=== DO NOT PROMISE A CHOICE-FREE RESULT ===

`wlem_of_spherical` (`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`) derives weak
excluded middle from `Spherical R` at the finite carrier `Bool` over `D = ZZ`, from
`[propext, Quot.sound]` alone. So NO finite-carrier frame with an arbitrarily shaped relation can
be choice-free, on any route. The cost is already paid by `IntPresentation.toTaskFrame`. Any spec
promising choice-freedom here is promising something proved impossible. Note the separate
distinction: `instDecidableSatAtState` COMPUTES (kernel-evaluated `#guard`s prove it) while
measuring `[propext, Classical.choice, Quot.sound]`. Computability and choice-freedom are different
properties.

---

### 465. Complete terminus restatement family
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 464

**Description**: Complete the terminus restatement family at the repaired residuals. Task 433's Phase 6 landed EIGHT of the twenty-two restatements -- the four family roots and their four caller-facing seed forms -- and recorded the remaining FOURTEEN as a Reasoned Exclusion with the recipe written down: each is a `_lengthBudget` / `signedUniverse` substitution, "a one-line application of its family root".

This is deliberately MECHANICAL work with the recipe already recorded. Its value is uniformity: a caller reaching for a `_lengthBudget` or `signedUniverse` form of a repaired terminus should find it landed rather than having to re-derive it, and a half-populated family is a trap for a future reader who assumes an absent member is absent for a reason.

SCOPE: read Phase 6's Reasoned Exclusions section in specs/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md for the enumerated list and the recipe. The family roots and existing members are the `buildTableauAt_isSome_*` declarations in MintBound.lean (the `_at`, `_selfGuarded`, `_fixed` and `_run` families, roughly :6308-:12240). Land the fourteen missing members following the naming convention the file already uses; do not invent a new convention.

WHY THIS RUNS LAST: it restates termini at the repaired residuals, so it must run after the residuals themselves are settled. If 462, 463 or 464 changes a predicate's shape or sheds a hypothesis, the restatements must reflect the settled form -- doing this work earlier would mean doing it twice. Before starting, RE-DERIVE the list of missing members from the file as it then stands rather than trusting the count of fourteen recorded here: earlier tasks may have landed some, or added new family roots.

PROHIBITED: no `sorry`; additive only; do not alter any previously-landed declaration; do not edit Fuel.lean, Saturation.lean or Tableau.lean; axioms within {propext, Classical.choice, Quot.sound}; full `lake build` green. If any of the fourteen turns out NOT to be a one-line application -- i.e. the recipe does not actually apply -- STOP on that member, record why, and do not force it; a member that needs real mathematics belongs in its own task, not smuggled in here.

Dependencies: 462, 463, 464 -- all three, so that the restatements are made against a settled set of residuals rather than a moving one.

---

### 464. Gappotential density measure component
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None

**Description**: Design and land `gapPotential`, the density coordinate of the termination measure. This is the one genuinely OPEN MATHEMATICAL question remaining on the totality terminus; it is research, not plumbing, and should be run with --lit.

THE PROBLEM, stated exactly. `densityRule` mints a fresh time while lying OUTSIDE BOTH `freshLabelRules` AND `selfGuardRules`. Consequently no disjunct of the current measure moves at a `densityRule` step, FOR ANY sigma WHATSOEVER. This has been open since C9 register entry 17 named it, and task 434's Phase 8 records the current state bluntly: `gapPotential` "remains implemented nowhere and assumed by nothing". Because `densityRule` is `denseRules`-gated, this blocks a nonempty `MintPaysForTimeFixed` discharge at `.Dense` and `.Dedekind` frame classes specifically; every frame class needs `gapPotential` for a fully general result.

SHAPE SUGGESTED BY PRIOR WORK (a starting point, NOT a specification to follow blindly): task 434 records the expectation that `gapPotential` is indexed by `U x U` and `denseRules`-gated. Validate or refute that shape as part of the research; if a different indexing is correct, say so and justify it.

HARD REQUIREMENT -- PRESERVATION ACROSS THE IDENTIFICATION ARM. Any candidate component must be preserved across `TimeOrdering.identifyTime`, which can LOWER `ord.timeCount`. This is the same maxTime-lowering mechanism that refuted earlier candidates; see `nextTime_reissues_retired_time` and `reuse_driven_through_engine`, and task 436's oriented-arm re-gate (`orientedGate*` family, :8592-8788) for how the analogous obstacle was handled for the self-guard component. A component that pays at `densityRule` steps but is destroyed by the identification arm is not a solution.

REFUTED ROUTES -- C9 register entries 14, 17, 18, 19, 20, 24. Read them ALL in full before designing anything. In particular entry 14 forbids BOTH (1) re-indexing `mintPotential` on `freshTimeRules` instead of `freshLabelRules` -- refuted by `witnessPresent_eq_false_of_not_freshLabel`, whose match has exactly eight arms so the three added columns are permanently false -- and (2) dropping disjunct 1's cardinality conjunct in favour of the ordering-rank conjunct alone -- refuted by `splitOrderedRank_lt_of_knownTimes_lt` plus `mintPaysForTime_rank_repair_false`. Neither may be re-attempted.

LITERATURE. Run with --lit against the sub-index curated for this line of work, drawing specifically on: venema_2001 section 5 (interval-based temporal logic) for the density/gap-guarded component itself; caleiro_2013 sections 6-7 (mosaic-method decidability for combined tense-and-modal logics) as a structural analogue for a combined-logic termination measure; gerth_1995 and baier_katoen_2008 (closure-set LTL tableau termination) as a model for a measure over an evolving, non-monotonically-changing time set; and massacci_2000 for rule-bounding technique.

DONE MEANS EITHER: (a) `gapPotential` defined, its payment at `densityRule` steps proved, its preservation across `identifyTime` proved, integrated into the measure, and a nonempty `MintPaysForTimeFixed` discharge extended to `.Dense` and `.Dedekind`; OR (b) a machine-checked impossibility result showing no such component exists at the current measure's shape, with the obstruction identified precisely and a C9 entry recording it. Outcome (b) is a genuine and valuable result, NOT a failure -- this repo's practice is that a proved refutation ranks with a proof, and several of this measure's real advances came from refutations.

PROHIBITED: no `sorry`, no vacuous or false predicate, no weakening presented as a repair (a direction lemma is a GATE, not a nicety -- C9 entry 7 exists because that mistake was made once); do not edit Fuel.lean, Saturation.lean or Tableau.lean (md5-pinned frozen); additive only in MintBound.lean; axioms within {propext, Classical.choice, Quot.sound}; full `lake build` green.

Dependencies: 462 is a REAL SEMANTIC dependency -- the engine-level assembly is what makes a per-rule payment usable at the successor, and `gapPotential`'s payment needs the same threading. 463 is a file_scope SERIALIZATION edge only (both edit MintBound.lean), with no mathematical content.

---

### 430. Semantic lift and track a assembly valid iff allclosed
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428, Task 429, Task 411

**Description**: The semantic lift and the Track A assembly. Owns obstruction O4 of the Phase 7.3 deadlock, then delivers what Phase 7.3 of task 165 was for. Grounding: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

THIS TASK CARRIES THE WORK MOVED OUT OF TASK 165's PHASE 7.3. Task 165 terminated with Phase 7 scoped to what it delivered (the truth lemma and Track A's conditional results); 7.3 -- `valid_iff_allClosed` and the `Decidable` instances -- was moved here rather than closed, because it is blocked on prerequisites no task owned.

O4 HAS TWO DISTINCT PIECES, per Verified/Decidable.lean:3062-3067: "It is not yet `valid_iff_allClosed` (7.3), which additionally needs the fuel/termination side and the truth-lemma gate, and it says nothing about the two rules scheduled outside `allRulesForFC` -- `serialityRule` and `timeLinearity` run as stages 2 and 3 of `expandOnce` and need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the object."

(a) Two more `RuleSound`-analogues at the `expandOnce` level, for `serialityRule` and `timeLinearity`. These are deliberately outside `allRulesForFC`, so `ruleSound_of_mem_allRulesForFC` (landed, 34/34) does NOT cover them.
(b) THE SEMANTIC LIFT: the induction lifting single-step satisfiability preservation to the whole recursion, so that `.allClosed` yields a contradiction. This is the LARGER of the two and is comparable in weight to a landed sub-phase, not to a wrapper. Naming it inside "the two outside rules" understates it.

THEN, and only after (a), (b) and both predecessors: `valid_iff_allClosed` plus the four `Decidable` instances for validity over Base, Dense, Discrete and Dedekind.

WHAT IS ALREADY LANDED (do not re-prove): the rule half is done -- `ruleSound_of_mem_allRulesForFC` is a single landed induction over `mem_allRulesForFC_iff`, ledger complete at 34/34, from task 165 Phase 7.2.

PLAN AGAINST SIX ROWS, NOT EIGHT: the truth-lemma gate hypothesis hTW is discharged on SIX accepted TemporalWitnessProbe rows (A, B, C, D, E, F), not the historical eight -- rows I and K left when the PASSIVE arms of untlNeg/snceNeg were retired. See the banner at the head of Tests/BimodalTest/TemporalWitnessProbe.lean.

DO NOT write a conditional `valid_iff_allClosed` carrying hTW as an explicit hypothesis. Correctness.lean:98-105 refuses exactly this shape, and the O4(b) hypothesis would BE the conclusion's forward direction, making the theorem vacuous. Four vacuous theorems were deleted in 165's Phase 8; do not land a fifth.

DONE WHEN: `valid_iff_allClosed` and the four `Decidable` validity instances are landed unconditionally, sorry-free and axiom-clean outside Boneyard, lake build green.

---

### 429. Repair truth lemma side conditions boxanchored and temporalwitness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428

**Description**: Repair the truth-lemma side conditions. Owns obstructions O2 and O3 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md. THIS IS THE TASK WITH GENUINE OPEN MATHEMATICS IN IT and should be budgeted accordingly.

READ FIRST: specs/418_*/artifacts/boxanchored-finding.md -- it carries the measurement, the full carrier list, and the repair options. Then TruthLemma.lean:399-404 and BoxSaturation.lean:430-435, :574-580.

O2 -- `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches. BoxSaturation.lean:430-435: the two copy blocks "have since been removed as unsound ... They were the ONLY route by which T(G phi)/T(H phi) could reach a freshly minted world ... `boxAnchoredCheck` is therefore expected to compute `false` on multi-world branches now." :574-580: "a caller can no longer expect to discharge that hypothesis from a real run." TruthLemma.lean:399-404 names the repair as "an open design decision with its own soundness obligations" and lists THREE candidate routes: (a) propagate T(box phi) itself; (b) copy T(G phi)/T(H phi) only when box-derived; (c) restructure the `box` case to need no anchor.

CRITICAL CONSTRAINT: this was caused by task 418 (completed) removing a GENUINE UNSOUNDNESS. It is the cost of a correct fix, not a regression to revert. TruthLemma.lean:404 says "Do NOT reinstate the removed copies." Any repair must re-establish the anchor WITHOUT reinstating them.

O3 -- `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a negative until with a known future time. TemporalWitnessProbe.lean:66-73: `untlNegFuture` demands F(event) at every known future time of every negative until; the PASSIVE arm's branch 1 was the ONLY producer of `not event` at an EXISTING time; that arm was retired as unsound (user-authorized rank 2), so the producer is gone. Measured cost: fourteen probe rows moved check=true -> check=false; the accepted set went from EIGHT rows to SIX (rows A, B, C, D, E, F; I and K left). :86-88: "it was already `false` on the branches the engine actually builds. What it removes is the last set of hand-built branches on which the hypothesis was discharged."

DO NOT REOPEN (settled by 165): guardWitnessed in any variant; restoring sat_untl_neg / sat_snce_neg (they are FALSE against the current engine, not merely unproved); reinstating the retired PASSIVE arms or the removed box copy blocks.

GOAL: choose among the three documented BoxAnchored repair routes and land it with its soundness obligations discharged; and re-establish a producer for `not event` at existing future times. Both must hold on branches the engine ACTUALLY builds, measured by the probes, not on hand-built branches.

DONE WHEN: `boxAnchoredCheck` and `temporalWitnessCheck` are dischargeable on real engine output for the relevant branch classes, evidenced by probe rows moving back to check=true; no unsound copy block or retired arm is reinstated; lake build green.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- RECOMMENDED ROUTE, NAMED UP FRONT: of the three O2
repair routes listed above, route (a) -- propagate T(box phi) itself to the fresh world -- is the
RECOMMENDED route (per specs/reviews/review-2026-08-24.md amendment 10a and the box-anchor
artifact's own §5), so a dispatch need not re-derive the recommendation from
boxanchored-finding.md each time. It follows the S5 axiom-4/5 pattern, carries its own RuleSound
obligation, and has named fuel/termination consequences that Fuel.lean's bounds and the
subformula property must absorb -- all as already detailed in that artifact. Route (b) remains
available but reduces to route (a)'s obligation once branch provenance is tracked, per the
artifact. Route (c) stays recorded as CLOSED AS FORMULATED (boxGridCheck fails for the same
structural reason the anchor does, so weakening only the anchor buys nothing) -- do not
re-attempt it. This addendum names a recommendation; it does not narrow the task's own account of
all three routes and their obligations above, which stands as written.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 465
- **Plan**:
  - [428_engine_totality_at_a_quantified_branch_budget/plans/02_lexicographic-splitordered-measure.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/01_budget-totality-engine-repair.md]
- **Summary**:
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/02_lexicographic-splitordered-measure-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/01_budget-totality-engine-repair-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/04_ordtimesknown-strengthening-totality-summary.md]
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/02_splitordered-measure-blocker.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]

**Description**: Engine totality at a quantified branch budget. Owns obstruction O1 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md section "The four obstructions" (read it first; do not re-derive the refutation).

THE REFUTED THEOREM, SETTLED: `buildTableau_isSome` in unconditional form is FALSE, not merely unproved, and is on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine SIGNATURE, not a proof difficulty: `buildTableau` (Saturation.lean:928-951) calls `expandBranchWithFuel` at the default `maxBranches := 50000` (Saturation.lean:590), whose first line is `if branchesUsed >= maxBranches then none` (:594). A formula exploring more than 50000 branches returns `none` at ANY fuel whatsoever. Independently, `buildTableau`'s last arm returns `none` on a still-unsaturated branch (:950). Neither is fuel exhaustion, so no fuel figure rules them out. DO NOT attempt the unconditional form.

WHAT LANDED INSTEAD, and why it is unusable as-is: Verified/Termination/Fuel.lean:1587-1598 carries two hypotheses -- `(hP : NoSplit P fc)` and `(hbud : branchesUsed + fuel <= maxBranches)`. `NoSplit` excludes impPos, orPos, untlPos, untlNeg, sncePos, snceNeg, orderTrichotomy and every frame-class-gated splitting rule, i.e. it holds only on non-branching runs. 165's plan:1467-1468 records "Residual 2 (branching arms) -- isolated, not discharged."

GOAL: add a `maxBranches`-parameterised entry point ALONGSIDE `buildTableau` -- an ADDITION, never an edit to the existing default, because `maxBranches = 50000` is a deliberate runtime guard -- and prove totality against a quantified budget. Target shape:

  theorem buildTableau_isSome_of_budget (phi : Formula) (fc : FrameClass)
      (maxBranches : Nat) (hmb : <bound in phi> <= maxBranches) :
      (buildTableauAt phi (soundFuel' phi) fc maxBranches).isSome = true

THREE SUB-OBLIGATIONS:
1. Discharge the branching-arm residual that `NoSplit` currently hypothesises (Fuel.lean:1587, Saturation.lean:661-664, :686-689).
2. Supply the missing WORLD-COUNT dimension. 165's plan:1484-1488: "T1 bounds formulas and T2 bounds times; neither bounds worlds ... as defined, `soundFuel' = 2*n*2^(2n)` has no world factor at all." A branch bound that ignores worlds cannot bound branches.
3. Establish the `<bound in phi> <= maxBranches` side condition in a form callers can actually discharge.

COORDINATION: overlaps task 426's hypothesis (b) on the same file (Fuel.lean). Sequence with 426 or merge; do not both edit Fuel.lean concurrently. Task 412 consumes this theorem in place of the refuted `buildTableau_isSome`.

DONE WHEN: the budget-parameterised totality theorem is landed sorry-free with no `NoSplit` hypothesis, lake build green, and the world dimension is either supplied or its absence is proved harmless.

RETARGET DECISION (user-approved, post-research): the specified unconditional target shape is refuted (see reports/01_budget-totality-refuted-and-repair.md). Task WIDENED to own the validated certificate repair: swap findUnexpanded -> findUnexpandedUnblocked at resolveOpenArm's two decision points, discharge the accompanying soundness obligation on what .hasOpen certifies (shared with O2/O3), lift the proved saturateBlocked_isSome asset, close the world dimension via worldFuel'/WorldWitness, and land the budget-parameterised totality theorem against the repaired engine. The per-path budget finding (maxBranches >= 3*fuel linear invariant) supplies the side condition.

SECOND RETARGET DECISION (user-approved, post-research 03). The per-step framing of Phase 11 cannot be closed: reports/03_phase11-potential-obstruction.md section 4 is a proof about the SHAPE of the argument, not a report of a failed attempt. Route (a) (a lower bound on branch cardinality after identification) is DEAD by definition -- `Branch.identifyTime = (b.map relabel).eraseDups`, so all shrinkage comes from eraseDups and is bounded only by |U|. Route (b) (an independent mint bound) is the APPROVED path.

THE CHEAPER ALTERNATIVE IS EXPLICITLY REJECTED BY THE USER: do NOT carry the mint bound as a hypothesis in the shape `hT` has, and do NOT push the discharge obligation onto task 412. Do it the right way.

APPROVED WORK (route (b), ~6-7 phases, comparable in size to everything landed so far):
1. WITNESS PRESERVATION (~3 phases): the eight-rule case analysis of report 03 section 3 step 4, resting on the three lemmas already machine-checked in that report's section 1 (`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`).
2. RESTATEMENT (~1 phase): give `expandBranchWithFuel_isSome_of_budget` an explicit MINT-BUDGET PARAMETER, in the shape `branchesUsed`/`maxBranches` already establishes. This is what converts route (b)'s amortized bound into something the induction can carry; a per-step potential over (b, ord) provably cannot express it (report 03 section 4), and `maxTime` was checked and is not a usable proxy (arm 3 can lower it).
3. AMORTIZED INDUCTION (~2-3 phases): #mints <= 8*|U|; #identifications <= |knownTimes|_0 + #mints; total shrinkage <= #identifications * |U|; #extensions <= |U| + total shrinkage; then the terminus `buildTableauAt_isSome_of_budget`.

RESEARCH GATE -- MACHINE-CHECK BEFORE PLANNING. Report 03 marks two load-bearing claims UNCERTAIN, and the whole mint bound rests on both:
  (i) section 3 step 4, witness preservation across `.splitOrdered` arm 3 -- ARGUED, NOT MACHINE-CHECKED. The two modal rules are trivial (their witness sits at the same time as `sf`, so identification moves both together); THE SIX TEMPORAL ONES NEED THE REACHABILITY TRANSPORT and were not verified.
  (ii) section 3 step 3, "formulas are never deleted" -- read off the rule shapes, consistent with the landed `expandOnceUnblocked_card_lt` / `expandOnceUnblocked_split_card_lt`, but NOT PROVED.
Machine-check BOTH before any plan is written. This task has twice had a plan rest on an unverified lemma that later turned out FALSE (the unconditional `buildTableau_isSome`; then the `.splitOrdered` cardinality twin). A third occurrence is not acceptable. If witness preservation fails for any temporal rule, ROUTE (b) IS DEAD and that is a THIRD retarget decision requiring human approval -- report it plainly, do not work around it and do not substitute a weaker statement.

PRESERVED, DO NOT RE-PROVE: phases 1-10 of plans/02_lexicographic-splitordered-measure.md are landed, sorry-free, axiom-free, and green repo-wide. Consume those declarations. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default stay BYTE-IDENTICAL. No `NoSplit` reintroduction; no admitted `WorldWitness` or `hT`; no `sorry`; no narrowing a statement into vacuity. The refuted unconditional `buildTableau_isSome` and the refuted `.splitOrdered` cardinality twin stay on the do-not-re-attempt register. `resolveOpenArmCancellable` in CancellableExpansion.lean remains a DECLARED, deliberately-unrepaired out-of-scope divergence. Task 412 must not be planned against `buildTableauAt_isSome_of_budget` until it lands; the Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`) are available and sorry-free meanwhile.

RESUME SEQUENCE: `/research 428` first (discharge the two uncertain claims above), then `/orchestrate 428`. The stale loop guard from the prior invocation has been removed so a restart gets a fresh cycle budget.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- ASSESS-AND-C9-REGISTER ESCAPE CLAUSE FOR THE
SPLIT-ARM FUEL SCALING PROBLEM: the opening "THE REFUTED THEOREM, SETTLED" paragraph above is
unaffected by this addendum and gets a CURRENT verdict on that point -- do NOT touch it.

`Fuel.lean:1595-1610` documents that fuel adequate for a split run scales like
`beta ^ depth * worldFuel'`, and depth is not bounded by anything proved in that file -- this is,
in its own words, "a real property of a deliberate engine policy, not a gap in a proof," of the
same class as the already-settled `buildTableau_isSome` refutation. If, in the course of this
task's approved route (b) work, the split-arm fuel-adequacy question proves genuinely unclosable
as specified -- i.e. no depth bound can be established or supplied without weakening the engine's
own proportional-fuel policy -- the correct deliverable is an explicit ASSESS-and-C9-register
outcome: name the specific obstruction, add a C9 register entry (in
`Verified/Termination/MintBound.lean`, alongside its other entries) stating precisely which
theorem still carries the split-arm scaling exposure and under what hypothesis, and stop there.
This is a VALID, COMPLETE outcome for this sub-question -- do not treat "close it" as the only
acceptable result, and do not force a proof past this obstruction by weakening `NoSplit`,
reintroducing a hypothesis this task's own do-not-re-attempt register forbids, or narrowing a
statement into vacuity.

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 410, Task 411, Task 428, Task 430

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi; supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense). Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.
RE-SCOPING ADDENDUM (2026-07-29, supersedes the buildTableau_isSome reference above): the scope text above depends on "Track A's buildTableau_isSome", which task 165 proved FALSE and placed on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine signature, not a proof difficulty: buildTableau returns none whenever a formula explores more than maxBranches := 50000, at ANY fuel. Consequently this task's acceptance criterion "zero sorries repo-wide outside Boneyard" was UNREACHABLE AS SCOPED, independently of task 165's own status.

CORRECTED DEPENDENCE: consume the budget-parameterised totality theorem from task 428 (engine_totality_at_a_quantified_branch_budget) -- shape `buildTableau_isSome_of_budget phi fc maxBranches (hmb : <bound in phi> <= maxBranches)` -- in place of the unconditional buildTableau_isSome. Task 428 has been added as a predecessor. Do NOT attempt the unconditional form yourself.

ALSO NOTE: this task inherits obstructions O2 and O3 (the boxAnchoredCheck and temporalWitnessCheck truth-lemma side conditions) from Phase 7.3 of task 165 by way of not_valid_of_hasOpen. Those are owned by task 429. If your induction reaches a point where a truth-lemma gate hypothesis must be discharged on real engine output, that is 429's work, not this task's -- record it and coordinate rather than re-deriving it. Grounding for all of this: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

REALIGNMENT CORRECTION (task 468, 2026-08-25): the struck clause above ("discharge the
pre-existing sorry countermodel_discrete at Transfer.lean:1242") is STALE. That sorry no longer
exists -- countermodel_discrete is CLOSED, via tasks 477/478/479's k-equivalence/groupable-
companion route, and now lives sorry-free in
FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean, not Transfer.lean. Verified
fresh by scripts/check-module-invariants.sh C2/C3 at realignment time: C3 reports zero live
structural sorries tree-wide; C2 reports BXCanonical.completeness axiom-clean
([propext, Classical.choice, Quot.sound]). This task's remaining scope (allClosed_derivable, the
Decidable (Derivable fc [] phi) instance, the completeness corollaries, the Dedekind engine) is
UNCHANGED and still open.

New task 482 (discharge_proof_extraction_completeness, dependencies: [412]) is the owner of
eliminating .extractionFailed as a live outcome on a genuinely closed tableau -- it is gated on
this task's allClosed_derivable induction as a prerequisite and consumes it once landed. This
task's own acceptance criteria are unchanged by 482's existence; 482 is a downstream consumer,
not an addition to this task's scope.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 410

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 429
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**:
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

**Description**: Flip complexity-9 dataset generation from stratified to exhaustive-by-default once feasibility is confirmed. Prior work (see plans/01_exhaustive-enumeration-plan.md, handoffs/phase-1-6-handoff-20260714.md) verified the 0-sentinel/.take-guard machinery is already correct and unlimited-capable, and corrected stale infeasibility claims in data/README.md and scripts/run_dataset_generation.sh. The next action is the deferred c9 feasibility probe (Plan Phase 2), followed -- pending a GO verdict and explicit user approval for the multi-hour compute -- by c8/c9 exhaustive regeneration and HF Hub republication (Phases 3, 4(rest), 5, 6(rest), 7).

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

**Description**: Complete the Hugging Face Hub migration for large dataset storage. Prior work (see plans/01_implementation-plan.md, summaries/01_execution-summary.md) removed Git LFS tracking from .gitattributes and rewrote data/README.md to point at HF Hub (logos-labs/bmlogic-bench) as the canonical source, but Phase 1 -- the actual upload to HF Hub via the existing data/hf-dataset/upload.py pipeline -- was never executed because it requires user HF authentication. This task is blocked on that credential; once supplied, run the upload, validate, and confirm data/hf-dataset/PUBLISHING.md's 'Migration Status' header reflects completion.

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.
=== ITEM (7) TARGETS A DISPOSABLE DEPLOY ARTIFACT -- CORRECTED 2026-08-24 ===

Item (7) above says "Integrate into agent context (.claude/context/project/dataset/)". DO NOT WRITE
THERE. Verified 2026-08-24: `.claude/` in this repository is fully gitignored (`.gitignore:81`) with
zero tracked files, and is regenerated wholesale from a source store that is NOT in this repository
-- it lives at /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
`.claude/context/project/dataset/` will be silently destroyed on the user's next agent-system
reload.

Item (7) therefore CANNOT be completed from inside this repository. Two acceptable dispositions,
both of which require asking the user first:

  (a) DROP item (7) from this task's scope and record why. The other seven sub-targets of this task
      are ordinary repository work (`data/scripts/sync-all.py`, `data/README.md`,
      `data/dataset-card.md`, `croissant.json`, the splits file, schema validation, contamination
      check) and are unaffected. This is the recommended default -- it keeps the task in one repo.
  (b) Split item (7) into a task filed in the nvim repository's own tracker
      (/home/benjamin/.config/nvim/specs/state.json), targeting
      agent-system/extensions/<appropriate-extension>/context/, and committed there.

Do not silently satisfy item (7) by writing into `.claude/`.
=== ITEM (7) DROPPED FROM SCOPE -- 2026-08-24, user decision ===

Item (7) ("Integrate into agent context (.claude/context/project/dataset/) so /implement for
dataset tasks runs sync-all as post-implementation step") is REMOVED from this task's scope. It is
not a defect and not deferred -- it is out of scope here, permanently, and no successor task owns
it in this repository.

WHY. The disposition options recorded above were put to the user on 2026-08-24 and option (a) was
chosen. Three considerations decided it:

  1. `.claude/` here is gitignored (`.gitignore:81`, zero tracked files) and regenerated wholesale
     from /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
     `.claude/context/project/dataset/` is destroyed on the next agent-system reload.
  2. Filing it in the nvim tracker instead was considered and declined. There is no `dataset`
     extension in that source store (verified 2026-08-24: core, cslib, email, epidemiology,
     filetypes, formal, founder, latex, lean, literature, memory, nix, nvim, present, python,
     slidev, typst, web, z3), and a BimodalLogic-specific post-implementation hook placed in the
     shared global agent-system would deploy to every repository that loads it. It would have to be
     generalized into a repo-local hook mechanism first -- a different and larger piece of work
     than this task.
  3. The `.syncprotect` escape hatch (project root; honored by deploy-headless.sh and the picker's
     sync path) would survive a reload, but leaves the file untracked and unbacked-up in a repo
     where everything else is version-controlled.

WHAT REMAINS IN SCOPE. Items (1) through (6) and (8), unchanged and unaffected -- they are ordinary
repository work under `data/`: `data/scripts/sync-all.py`, `data/README.md`,
`data/dataset-card.md`, `croissant.json`, `bmlogic-bench-splits.json`, schema validation, the
train/benchmark contamination check, and the metadata-key consistency check. Do not treat the
removal of item (7) as reducing any of them.

IF THE HOOK IS WANTED LATER. `sync-all.py` is a plain script with CI-friendly exit codes (item 5).
Wire it from repository CI or run it manually after a regeneration. That reaches the same outcome
without depending on agent-system context at all.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness and completeness on a concrete formula, plus decidability of the propositional fragment (genuinely complete today, per the soundness/completeness metatheory's axiom-clean status). Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

REALIGNMENT CORRECTION (task 468, 2026-08-25, carried from specs/reviews/review-2026-08-24.md
amendment M-7, independently re-confirmed at realignment time): the struck original acceptance
criterion above ("Complete worked example showing soundness-completeness-decidability on a
concrete formula") is RESCOPED. Decidability of TM (the full bimodal logic) is still open --
re-confirmed fresh this dispatch: grep -rn "isValid" FormalSystem/Metalogic/Decidability/ shows no
declaration takes DecisionProcedure.isValid as its subject, and ruleSound_of_mem_allRulesForFC is
not lifted to any allClosed -> valid theorem. `truthAt_of_isValid`
(Verified/Decidable.lean:2412) is NOT evidence of decidability -- it concerns a different,
semantic-side `SoundnessLemmas.IsValid`, not the decision procedure's `DecisionProcedure.isValid`.
Do not cite it as such. This task's decidability example is therefore rescoped to the
propositional-fragment case (genuinely decidable today) rather than the full logic; a full-logic
decidability example remains gated on the decidability/tableau front (410-465,
480-482) landing.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 428, Task 429, Task 430

**Description**: Update README.md, docs/, and FormalSystem/ module-level docstrings to their final post-refactor state, once the decidability chain (426, 428, 429, 430, 432, 433, 434) lands. This is the final polish pass, distinct from and run after task 472's already-completed immediate correction pass. Explicitly excludes: every item task 472 already corrected (the Decidability.lean Status block, Verified/README.md, FMP/README.md, DecisionProcedure.lean's decideAuto docstring, Verified/Decidable.lean's Status docstring, WeakCanonical.lean, RealModel/ShuffleReal.lean, Soundness.lean, PriorExpressivenessDense.lean) and the two Kamp files task 473 already swept (Kamp/EANegationClosure.lean, NfMultiAnchorBridge/NavigatedSpine.lean). This task's residual content is: re-auditing all touched documentation for drift accumulated during the decidability chain's landing (472/473 audited a snapshot; the chain's remaining tasks will touch further files after 472/473 ran), and the Axiom Reference update the charter names as part of 177's original scope.

REALIGNMENT NOTE (task 468, 2026-08-25, verdict per specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md §6): DIVIDE, already half-executed exactly as specs/reviews/review-2026-08-24.md amendment 10f states -- tasks 472 (documentation correction pass) and 473 (Kamp vacuity deletion) already ran the ungated half; the description above is the remaining, gated half's text. `file_scope` (README.md, specs/ROADMAP.md, FormalSystem/, docs/) was already repaired by task 470 item (G) and is confirmed resolvable, no duplicate -- left unchanged here.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 530 (documentation single source of truth + theorem index, from specs/reviews/review-2026-09-01-lean-engineering.md) is the UN-GATED metalogic half of this charter and is now a dependency; this task remains the gated post-decidability-chain pass and its residual shrinks to re-auditing drift the decidability chain introduces plus the Axiom Reference update.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 498, Task 499

**Description**: CAPSTONE of the algebraic representation front. Prove the Jonsson-Tarski representation theorem for the bimodal logic: the embedding eta(a) = {U | a in U} is an injective STSA homomorphism A -> Cm(Uf(A)).

RE-SCOPED. This task's original four phases are now distributed: Phase 1 (complex algebra Cm(F)) and Phase 2 (ultrafilter frame Uf(A), including the Spherical obligation) are separately tasked and are this task's dependencies; Phase 4 (binary untl/snce operators) is separately tasked and depends on this one. What remains here is Phase 3 -- the embedding itself and its injectivity -- stated at the unary signature (box, G, H, sigma).

PREREQUISITE STATE, RE-VERIFIED 2026-08-26: the STSA class and the R_G/R_H/R_Box ultrafilter frame exist as Boneyard seeds behind #exit and are ported by the dependency tasks. The MCS-to-ultrafilter bijection is live at Algebraic/UltrafilterMCS.lean:782 (ultrafilter_correspondence), though stated existentially rather than as a named Equiv -- converting it to an Equiv may be worth doing here. The BooleanAlgebra LindenbaumAlg instance is at BooleanStructure.lean:421.

THE PRIOR PREREQUISITE LIST IN THIS DESCRIPTION IS STALE and is superseded: it named 'resolve 6 algebraic sorries in TenseS5Algebra/InteriorOperators/LindenbaumQuotient'. InteriorOperators.lean and LindenbaumQuotient.lean are sorry-free today; the remaining sorries are the 3 in the Boneyard TenseS5Algebra seed, and they are for REMOVED axioms (temp_a, temp_l) that must be restated against the current 45-constructor axiom set rather than proved as-is. That is the STSA port task's business, not this one's.

LITERATURE: Goldblatt 1989 'Varieties of complex algebras' (APAL 44, 173-242, doi 10.1016/0168-0072(89)90032-8) has been acquired. CAVEAT THAT MUST BE HONORED: the acquired PDF is an Acrobat 3.0 Capture scan with a badly degraded OCR text layer -- math-heavy pages yield mangled symbols, dropped and reordered lines. READ THE PAGE IMAGES DIRECTLY (the Read tool's pages parameter); do NOT rely on a pdftotext-derived conversion for any axiom statement or equation. Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002) is the primary reference and is born-digital.

MATHLIB HOOK: Order/Atoms.lean:710 (toSetOfIsAtom : alpha <-> Set {a // IsAtom a} for CompleteAtomicBooleanAlgebra) is the atom-structure half of Stone/Jonsson-Tarski for the complete atomic case and is the single most relevant Mathlib lemma here; supporting lemma eq_setOf_le_sSup_and_isAtom at :695. Mathlib has NO Stone duality for Boolean algebras and no BAO machinery -- the rest is greenfield.

SEE ALSO the reconciliation task on whether this embedding can be factored through ShiftSet.lean's reverse_repr rather than built independently; if it can, that supersedes part of this task's construction and this description should be revised again before implementation starts.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.
