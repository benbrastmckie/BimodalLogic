# Roadmap: TM Decidability, Completeness, and Publication

## Overview

TM is a bimodal logic combining S5 modality with irreflexive linear temporal logic, axiomatized
via the **Burgess-Xu (BX) system**. This roadmap was retitled and rewritten wholesale on
2026-08-25 by task 468 (programme realignment from a verified proof-state audit) to give
**decidability/tableau** — now the largest active front, previously absent from the title — equal
billing with completeness, to replace a decade of stacked dated "Current state" blocks with one
current-state statement per front, and to ground every status claim in a named
`scripts/check-module-invariants.sh` check. Historical material (superseded dated blocks, retired
diagrams, dead-end catalogs, the old 111-row task cross-reference table) was moved verbatim to
`specs/ROADMAP-ARCHIVE.md` — consult it for provenance, never for current status.

**Architecture**: the proof system has 42 BX axiom constructors in 6 layers: propositional (4),
S5 modal (5), Burgess-Xu temporal (24), modal-temporal interaction (2, 1 derivable), uniformity
(5), and Prior-UZ/SZ (2, discrete-only). Temporal semantics is **irreflexive**: G/H quantify over
`t < s` / `s < t` (strict inequality), and Until/Since require strictly future/past witnesses. See
`## BX Axiom System` and `## Irreflexive Truth Semantics` below for the full technical reference.

### PROVEN vs. SORRY-FREE — the distinction this rewrite exists to enforce

**A zero `sorry` count is not the same claim as "proven."** This repository's own history
contains three ways the two come apart, and conflating them is the specific failure this
realignment (task 468) was dispatched to correct:

1. **A theorem can be absent rather than merely unproven.** `DecisionProcedure.isValid`
   (`FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:317`) has no theorem anywhere
   relating it to semantic validity — no `isValid φ fc = true → ⊨ φ` biconditional exists, proven
   or otherwise (see the Decidability front below). C3's sorry count is silent on this: there is
   no sorry because there is no declaration to carry one.
2. **A stub can be sorry-free and prove nothing.** `verifyProof`
   (`FormalSystem/Metalogic/Decidability/ProofExtraction.lean:345`) is
   `fun _ _ => true` — a total, sorry-free function that certifies every input. `Verified/
   Refutation/` (the directory that would house the theorem making that certification honest)
   does not exist on disk.
3. **A predicate can compute without being the property its name suggests.** BiLasso's
   `Decidable` instance (below) computes — genuinely, mechanically — while depending on
   `[propext, Classical.choice, Quot.sound]`. Computability and choice-freedom are different
   properties; the instance has the first, not the second.

Every status line below names the check that grounds it: **C2** (`#print axioms` on named
theorems), **C3** (structural sorry inventory, content-based, never by line number), **C4/C5**
(import/reference resolution), **C7** (live file/line inventory, informational only). A claim this
document makes that no check can reproduce is a defect in the document, not a fact about the
tree — report it as such.

---

## Phase 1: Weak and Strong Completeness (Low Priority — weak DONE, strong-completeness capstone open)

**Current state, grounded in C2/C3 (re-verified 2026-08-25, task 468 Phase 1):**

- [x] **Base weak completeness — DONE.** `BXCanonical.completeness` is axiom-clean:
      `[propext, Classical.choice, Quot.sound]`, zero `sorryAx`. The Base-class discrete branch's
      former sole live sorry, `WeakCanonical.countermodel_discrete`, is **closed** — tasks 477
      (`ta_qz_target_structure_plumbing`) → 478 (`tb_groupable_companion_lemma`) → 479
      (`tc_close_countermodel_discrete_at_base`), all completed, proved it via a k-equivalence/
      groupable-companion construction at the non-Archimedean carrier `ℚ ×ₗ ℤ`, landing the
      theorem in `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean`.
      `WeakCanonical/Transfer.lean` no longer contains this theorem; its own header names the new
      location and confirms the `sorryAx`-free status. *(Completed: tasks 477-479, 2026-08-25)*
- [x] **Dense weak completeness — DONE.** `completeness_dense` axiom-clean, same set, C2-confirmed.
- [x] **Discrete weak completeness — DONE.** `completeness_discrete` axiom-clean, same set.
- [x] **Dedekind weak/consequence completeness — DONE.** Task 408 (completed, archived): headline
      `completeness_dedekind` and corollary `consequence_completeness_dedekind`, both
      `sorryAx`-free.
- [ ] **Consequence-completeness capstone (task 362, not_started)** — Leg A: finite-context
      consequence completeness for all four frame classes, `Derivable`-stated corollaries of the
      four weak engines above, all now unblocked (the weak engines they build on are DONE). Legs
      B (genuine `Set Formula` strong completeness, Base/Dense only) and C/D (Discrete/Dedekind
      non-compactness record, LaTeX alignment) — Leg B gated on task 424 (shift-set representation
      theorem, **completed** — the gate that authorizes the ultraproduct route has been passed;
      the expensive ultraproduct work itself is not yet scoped as tasks).
- [ ] **Two tasks proposed for abandonment, not transitioned by this rewrite** — 169
      (`build_discrete_chronicle...`, deps `[361,422,448]`) and 95 (the axiom/sorry confirmation
      pass, deps `[169]`): both tasks' entire deliverable is the `countermodel_discrete` closure
      above, already accomplished via a different route (477→478→479) than the one 169/422 were
      built to supply. See `specs/468_.../reports/04_realignment-decisions-and-verdicts.md` for
      the full adjudication and evidence; **status transition is a user decision, not performed by
      this rewrite.**
- [ ] **422** (`build_discrete_chronicle_over_non_archimedean_block_carrier_with_restricted_coherence`,
      researched): its specified deliverables (a block-carrier isomorphism into `ℚ ×ₗ ℤ`, plus
      three restricted-coherence analogues) are permanently REFUTED at the isomorphism level (its
      own report 01, machine-checked: no linearly ordered abelian group has order type `ℤ+ℤ`) and
      superseded — its own report 02 recommended the k-equivalence route 477-479 actually used.
      Also proposed for abandonment; see the same report.

**Strong-completeness terminology** (settled 2026-07-27, authority: `StrongCompleteness.lean`'s
module docstring): "strong completeness" names consequence from possibly-infinite premise sets
(`Γ : Set Formula`, finitary set-derivability); any finite-context (`Context = List Formula`)
consequence statement is inter-derivable with weak completeness via the deduction theorem and is
named **consequence completeness**, never strong. Discrete and Dedekind are non-compact (Discrete:
`{F p} ∪ {¬Xⁿ p}` witness under `IsSuccArchimedean`; Dedekind: Reynolds 1992 Theorem 7 is weak-only
by the paper's own restriction) — **IMPOSSIBLE**, not open, for genuine strong completeness at
those two classes.

**Check grounding**: C2 (four flagship axiom sets), C3 (zero live structural sorries tree-wide).

---

## Phase 2: Decidability and the Tableau Engine (High Priority — the largest open front)

**Current state, grounded in C2/C3/C4 (re-verified 2026-08-25):**

- [x] **Soundness of the tableau-derived judgment is proven for the engine as it stands.** No
      unsound rule fires uncontrolled (task 418's cross-world temporal-copy fix removed the one
      known unsoundness).
- [ ] **`isValid`-to-validity bridge is MISSING, not merely unproven.** No declaration anywhere
      takes `DecisionProcedure.isValid` (the `Bool`-valued convenience wrapper,
      `DecisionProcedure.lean:317`) as its subject in a semantic theorem. `decide_sound'`
      (`Correctness.lean:66`) proves the underlying `decide φ ... = .valid proof → ⊨ φ`, but
      nothing bridges the `Bool` wrapper back to it. **ADD, task 480**
      (`bridge_isvalid_bool_to_semantic_validity`, routine engineering, no dependencies, startable
      today).
- [ ] **`ruleSound_of_mem_allRulesForFC` is not lifted to `allClosed → valid`.** The rule-level
      soundness assembly (`Verified/Decidable.lean:3155`) exists; the engine-level lift
      (`valid_iff_allClosed`) is task 430's target, not yet landed.
- [ ] **The unconditional `buildTableau_isSome` is FALSE, permanently, by construction** — not an
      unproven conjecture. `buildTableau` returns `none` whenever a formula explores more than
      `maxBranches := 50000` branches, at any fuel (task 428's own settled finding, on a
      do-not-re-attempt register). Task 428 targets a budget-parameterised replacement instead,
      via the amortized mint-bound route (route (b), user-approved), with an explicit
      ASSESS-and-C9-register escape clause for the split-arm fuel scaling problem
      (`allocateFuelProportionally`, depth not bounded by anything proved — added by task 468's
      realignment, 2026-08-25).
- [ ] **The box-anchor family is REFUTED, broader than originally scoped — verdict NEGATIVE,
      re-confirmed 2026-08-25 without re-running the probe (amendment 10a).** The entire
      decidable-branch-gate family — `boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
      `regionLabelCheck`, `rayUpOk`/`rayDnOk` — collapses to `false` on any branch that mints a
      world, because task 418's sound fix removed the only route by which `T(Gφ)`/`T(Hφ)` reach a
      freshly minted world. **Task 429 is a redesign, not a repair.** Recommended route (added
      2026-08-25): (a) propagate `T(□φ)` itself to the fresh world (S5 axiom-4/5 pattern, own
      `RuleSound` obligation, named fuel/termination consequences) — see
      `specs/archive/418_.../artifacts/boxanchored-finding.md` for the full artifact and all three
      routes. Cross-reference: this is a tombstoned route family — see `## Tombstoned Routes`
      below and the C9 register in `Verified/Termination/MintBound.lean`.
- [ ] **`Verified/Refutation/` does not exist; `ProofExtraction.lean` has zero theorems;
      `verifyProof` is the constant stub `fun _ _ => true`.** Eliminating `.extractionFailed` as a
      live outcome on a genuinely closed tableau is **OPEN MATHEMATICS, multi-month** — **ADD,
      task 482** (`discharge_proof_extraction_completeness`, deps `[412]`, MUST NOT be
      re-described as engineering).
- [ ] **Five termination residuals, not four** (the four-residual framing used elsewhere in this
      programme is WRONG and is corrected here): `UniverseClosed`, `DifficultyBounded`/
      `StepLengthBounded`, `MintPaysForTime`, `PostBlockingSettles`, and **`UnorderedSuccessorLabelClosed`**
      — carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`
      and refuted in-tree (`MintBound.lean:6238`). **ADD, task 481**
      (`discharge_or_replace_unorderedsuccessorlabelclosed_residual`, deps `[434]`, genuinely
      open — repair-or-replace, not routine discharge; a C9 register entry is a complete, valid
      outcome). Sequencing: recommended before or alongside task 462, which targets discharge at
      the same nonempty-universe setting `:6238`'s refutation applies in (advisory, not a hard
      dependency edge — task 481 may run alongside 462, not only before it).

**Critical path** (re-derived 2026-08-25 by longest-path over the live `dependencies` graph, not
carried forward from any prior hand-drawn diagram):

```
462 (ROUTINE, unblocked today, deps 469✓/470✓)
  -> 463 (ROUTINE)
    -> 464 (HARD -- gapPotential, the one genuinely open mathematical question on this spine)
      -> 465 (ROUTINE -- mechanical restatement of settled residuals only)
        -> 428 (HARD -- split-arm fuel scaling, ASSESS/C9-register escape clause)
          -> 429 (HARD -- box-anchor redesign, genuine open mathematics)
            -> 410 -> 411
              -> 430 (HARD -- item (b), "the semantic lift")
                -> 412 -> 482 (HARD -- proof-extraction completeness, open mathematics)
                        -> 177 (retained-half documentation polish)

481 (HARD -- repair-or-replace) -- parallel entry, recommended before/alongside 462
480 (ROUTINE, independent, startable today)
476 (HARD -- open mathematics, gated only on 475=completed) -- parallel, does not feed this spine
```

11 waves from 462 to 482 (10 to 412). Full derivation, per-task status, and the routine/hard split
rationale: `specs/468_.../reports/03_implementation-evidence-ledger.md` (Phase 6 section).

**Check grounding**: C2 (axiom sets), C3 (sorry inventory — zero, tree-wide), C4 (import
resolution), direct symbol-level `grep`/`ls` re-verification (Phase 1 of the 2026-08-25
realignment).

---

## Phase 3: Kamp Theorem and Expressive Completeness (Low Priority — DONE)

- [x] **The Kamp chain is complete and sorry-free.** All four chain declarations —
      `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`,
      `kamp_prior_expressive_completeness` (`Kamp/KampPrior.lean`), and
      `US_expressively_complete_over_prior` (`WeakCanonical/PriorExpressiveness.lean`) —
      kernel-verify to `[propext, Classical.choice, Quot.sound]`.
- [x] **Stavi/EFGames is LIVE, not superseded and parked** — corrected 2026-08-25. Re-verified by
      direct import check: `FormalSystem/Metalogic/WeakCanonical.lean` imports
      `WeakCanonical.EFGames.StaviCompleteness` directly, and at least four further live modules
      (`PriorExpressiveness.lean`, `EFGameTactics.lean`, `EFGames/Decomposition.lean`,
      `Expressiveness/Claim1.lean`, among others) import from `EFGames/`. A prior claim that this
      subtree was superseded and parked off the live path was **wrong** and is retracted here.
- [x] **Rabinovich 2014 coverage**: every paper artifact (Def 3.1, Lemma 3.2, Prop 3.5, Def 4.1,
      Prop 4.2, Lemma 5.1, Lemma 5.3, Cor 5.4) has a landed sorry-free Lean counterpart. See `##
      Burgess-Xu Until-Induction Technique` below for the durable technique reference.

**Check grounding**: C2, C4 (import resolution, confirming the Stavi/EFGames correction above).

---

## Phase 4: Finite Model Property and Decidable Model Checking (Medium Priority)

- [x] **`FormalSystem/Metalogic/Decidability/BiLasso/`** — landed sorry-free, 19 modules,
      registered in the build graph (`Decidability.lean` imports the re-export). Decides truth of
      a formula at a state of a **given** `IntPresentation` by bounded enumeration of annotated
      bi-lassos (`check`/`check_correct`, a computing `Decidable` instance). **Honest scope
      statement**: it does not decide the logic (nothing in the layer quantifies over frames), and
      it performs no part of the finite-model step (`exists_annot_of_truth` takes a
      `WorldHistory` as *input*, compressing within a presentation rather than producing one from
      an arbitrary countermodel). **Axioms**: `[propext, Classical.choice, Quot.sound]` — this is
      computability, not choice-freedom; they are different properties (see the PROVEN-vs-
      SORRY-FREE note above), and `wlem_of_spherical` rules out any choice-free finite-carrier
      route.
- [ ] **What remains is exactly one theorem, `fmp`**: `∀ ψ, ¬ ValidDiscrete ψ → ∃ P ∈ cands ψ, ∃
      w, SatAtState P w ψ.neg`. Its crux is box-faithfulness — `box` truth is a global constant of
      its own model, so a source model's and a target presentation's box facts need not agree —
      and it is genuinely hard. Given `fmp`, the assembly (`validDiscrete_iff_checkFamily`,
      `decidableValidDiscreteFamily`) is already live and machine-checked.
- [ ] **This qualifies a prior audit finding**: the original proof-state audit's finding F6 ("FMP
      is syntactic, not semantic") was reached from `Decidability/FMP/` without accounting for
      BiLasso; the honest picture is the one stated above, not F6 as originally framed.
- [ ] **Task 476** (`box_faithful_small_model_theorem`, not_started, deps `[475]` = completed) —
      the genuine SEMANTIC finite model property, correctly scoped as open mathematics,
      multi-month, with an explicit literature gate (Gabbay-Kurucz-Wolter-Zakharyaschev) and a
      must-not-merge-into-engineering clause. This is the best-scoped version of the semantic FMP
      candidate; do not duplicate it.

**Check grounding**: C2 (BiLasso axiom sets), C3 (BiLasso sorry-free), C6 (BiLasso now reachable
from the build graph, no longer isolation-only).

---

## Phase 5: Publication and Documentation (Medium Priority)

- [ ] **Task 177** (retained half, not_started) — README/docs/module-docstring final polish, once
      the decidability chain (426, 428, 429, 430, 432, 433, 434) lands. **Already half-executed**:
      tasks 472 (documentation correction pass, nine files plus six more) and 473 (Kamp vacuity
      deletion, `neg_2var_vec_ea`/`reflatten_neg_step`, two files) are both completed; this task's
      residual scope explicitly excludes their territory (see the task's own description for the
      full exclusion list). `file_scope` already repaired (task 470 item (G)).
- [ ] **Task 178** (not_started) — rescoped 2026-08-25 (carried from `specs/reviews/
      review-2026-08-24.md` amendment M-7): the decidability-example acceptance criterion is
      rescoped to the propositional fragment (genuinely decidable today), since decidability of
      the full logic is still open (Phase 2 above). `truthAt_of_isValid`
      (`Verified/Decidable.lean:2412`) is **not** evidence of decidability — it concerns a
      different, semantic-side `SoundnessLemmas.IsValid`.
- [ ] **BimodalReference living monograph** (task 313, skeleton COMPLETED; tasks 314-318 in
      flight/not-started) — five-part typst monograph at `typst/BimodalReference.typ`, with
      `scripts/typst-status-counts.sh`/`typst-sync-check.sh` as mechanical claim-verification
      infrastructure.
- [ ] **LaTeX alignment** — restate `latex/subfiles/04-Metalogic.tex`'s "Strong Completeness and
      Compactness" section for the `Set Formula` statement only, owned by task 362 (Phase 1
      above).

**Check grounding**: C5 (module-shaped path resolution in markdown/docs), C9 (zero task-number
citations under `FormalSystem/`).

---

## Phase 6: Dataset and Training Infrastructure (Medium Priority — carried forward, not
freshly re-verified by this rewrite)

**These rows are restated from `specs/reviews/review-2026-08-24.md` Addendum A-6/A-7 (one day old
at task 468's dispatch), not independently re-derived by the 2026-08-25 realignment** — this
front sits outside that task's decidability/completeness/roadmap charter, and the distinction is
recorded here explicitly so a reader does not mistake carried-forward evidence for fresh
verification.

- [ ] **298** (partial) — top of cluster. **Note (2026-08-25)**: the c7 dataset-regeneration
      process (`dataset_generator --max-complexity 7 --mode exhaustive`) was observed **actively
      running** at realignment time (live PID, 645+ CPU-minutes, output past 1.5M lines vs. the
      2026-08-24 review's 13,749-line truncation snapshot). Do not disturb; re-check line/metadata
      counts before treating this task as still blocked on the truncation finding.
- [ ] **296** (partial) — KEEP, review-verified.
- [ ] **282** (partial) — REVISE; null description reconstructed by task 470's own research, not
      re-verified by task 468.
- [ ] **257** (blocked) — REVISE + reclassify; blocked on human action (HF account/token).
- [ ] **231** (not_started) — KEEP, downgrade priority; must follow 298.
- [ ] **219** (researched) — KEEP, depends on 231.
- [ ] **125** (not_started) — KEEP, move off critical path.
- [ ] **127, 128** (not_started) — candidates for ABANDON or park; both extend the object language,
      antagonistic to the termination work Phase 2's front depends on (`MintBound.lean`'s
      34-constructor rule set).
- [ ] **193** (not_started) — KEEP, runnable today.
- [ ] **461** (blocked) — KEEP as blocked, lower priority; blocked on literature acquisition.

---

## Phase 7: Repository Hygiene and Programme Metadata (Low Priority)

- [x] **ROADMAP split** — this file split from a 1,970-line stacked-history document into this
      current-state file plus `specs/ROADMAP-ARCHIVE.md` (historical sediment, verbatim).
      *(Completed: task 468, 2026-08-25)*
- [x] **`active_topics` gap closed** — `metalogic` (carried by completed tasks 477/478/479) added.
      *(Completed: task 468, 2026-08-25)*
- [x] **Dangling-edge scan** — zero dangling dependency edges across `active_projects` union the
      archive's archived+completed sets, confirmed zero-padded (avoiding a lexicographic-vs-
      numeric `comm` mismatch that produced 50 false positives in an earlier, unpadded run).
- [ ] **`state.json` counters (`metadata.total_tasks`, `task_counts.*`) — REPAIR DEFERRED, argued,
      not fixed by this rewrite.** The live status breakdown (including `completed` and a plural
      `researched`) cannot be represented by the current `task_counts` key set without inventing a
      schema convention no consumer script exists to confirm (`grep` across `.claude/scripts/` and
      `.claude/hooks/` for either field: zero hits). Left to `/task --sync` or a dedicated
      schema-clarification task; see `specs/468_.../reports/03_implementation-evidence-ledger.md`
      (Phase 6 section) for the full argument.

---

## Tombstoned Routes

Refuted approaches, recorded so they are not silently re-attempted. Cross-reference: the **C9
register** (a section inside `FormalSystem/Metalogic/Decidability/Verified/Termination/
MintBound.lean`) carries the full, itemised list (24 entries as of 2026-08-25); this section
names only the routes this rewrite's audit specifically re-confirmed, without duplicating C9's
own entries.

- **Unconditional `buildTableau_isSome`** — FALSE at the engine's `maxBranches` guard, at any
  fuel. Property of the engine signature, not a proof difficulty. See Phase 2.
- **The decidable-branch-gate family** (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
  `regionLabelCheck`, `rayUpOk`/`rayDnOk`) — collapses to `false` on any branch minting a world,
  caused by task 418's sound (not unsound) removal of cross-world temporal-copy propagation.
  Repair option (c) (weaken only the anchor) is **closed as formulated** — `boxGridCheck` fails
  for the same structural reason, so weakening only the anchor buys nothing. See Phase 2.
- **`UnorderedSuccessorLabelClosed`** — refuted in-tree at a nonempty universe
  (`MintBound.lean:6238`). See Phase 2, task 481.
- **The discrete block-carrier isomorphism into `ℚ ×ₗ ℤ`** (task 422's original deliverable) — no
  linearly ordered abelian group has order type `ℤ+ℤ`; machine-checked, permanent. See Phase 1.
- **`succ_cofinal`** — unprovable by the constant-MCS gap scenario; bypassed entirely by the
  Reynolds route the tree actually uses. Do not re-attempt.

---

## Sorry Inventory

**(re-verified 2026-08-25 by a fresh `scripts/check-module-invariants.sh` run; generator of
record: check C3 — regenerate this section from C3's live output, never hand-edit it.)** The live
(non-Boneyard) tree has **zero** structural sorries — `grep -rn --include='*.lean' -E
'^\s*sorry\s*$' FormalSystem/ | grep -v Boneyard` returns empty, and C3 independently confirms
zero. This is a change from the tree's history: the former sole live sorry,
`WeakCanonical.countermodel_discrete`, was closed by tasks 477-479 (see Phase 1). **Zero sorries
does not mean zero open mathematics** — see the PROVEN-vs-SORRY-FREE note at the top of this
document, and Phase 2's `isValid` bridge / proof-extraction / termination-residual items, none of
which carries a sorry today because none of them is a stated theorem yet.

**C2 axiom baseline**: `BXCanonical.completeness`, `.completeness_dense`, `.completeness_discrete`,
and `.Chronicle.countermodel_dense` all depend on exactly `[propext, Classical.choice,
Quot.sound]` — no `sorryAx`, tree-wide, across all four flagship theorems.

---

## BX Axiom System

`FormalSystem/ProofSystem/Axioms.lean` defines 42 axiom constructors in
six layers (see `Axioms.lean:55-59` for the Burgess 1982/84, Xu 1988, and Venema 1993
references; Reynolds 1992 is cited inline at `Axioms.lean:309`, not in that block). Under
irreflexive semantics (strict `<` for G/H,
strict witness for U/S), the axiom set replaces BX1/BX1' (reflexive T) with
seriality axioms and removes BX8/BX8' (not sound under irreflexive Until/Since).

### Layer 1: Propositional (4)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `prop_k` | Axioms.lean:71 | `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` | Intuitionistic K |
| `prop_s` | Axioms.lean:75 | `φ → (ψ → φ)` | Weakening |
| `ex_falso` | Axioms.lean:78 | `⊥ → φ` | Ex falso |
| `peirce` | Axioms.lean:81 | `((φ → ψ) → φ) → φ` | Classical |

### Layer 2: S5 Modal (5)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `modal_t` | Axioms.lean:86 | `□φ → φ` | Reflexivity |
| `modal_4` | Axioms.lean:89 | `□φ → □□φ` | Transitivity |
| `modal_b` | Axioms.lean:92 | `φ → □◇φ` | Symmetry |
| `modal_5_collapse` | Axioms.lean:95 | `◇□φ → □φ` | S5 characteristic |
| `modal_k_dist` | Axioms.lean:98 | `□(φ → ψ) → (□φ → □ψ)` | Normal modality |

### Layer 3: BX Temporal (24)

| Axiom | File:Line | Statement (future direction) | Role |
|-------|-----------|------------------------------|------|
| `temp_k_dist` | Axioms.lean:107 | `G(φ → ψ) → (Gφ → Gψ)` | K for G |
| `temp_4` | Axioms.lean:112 | `Gφ → GGφ` | Transitivity; needed for `bx_le_trans` |
| BX1 `serial_future` | Axioms.lean:117 | `T → F(T)` | Seriality (replaces reflexive T) |
| BX1' `serial_past` | Axioms.lean:122 | `T → P(T)` | Mirror seriality |
| BX3 `right_mono_until` | Axioms.lean:139 | `G(φ→ψ) → ((χUφ)→(χUψ))` | Right monotonicity |
| BX3' `right_mono_since` | Axioms.lean:143 | mirror for S | |
| BX4 `connect_future` | Axioms.lean:150 | `φ → G(P(φ))` | Temporal connectedness |
| BX4' `connect_past` | Axioms.lean:155 | `φ → H(F(φ))` | Mirror |
| BX5 `self_accum_until` | Axioms.lean:161 | `(φUψ) → ((φ ∧ (φUψ))Uψ)` | **Key eventuality axiom** |
| BX5' `self_accum_since` | Axioms.lean:166 | mirror for S | |
| BX6 `absorb_until` | Axioms.lean:173 | `(φU(φ ∧ (φUψ))) → (φUψ)` | Prevents infinite deferral |
| BX6' `absorb_since` | Axioms.lean:177 | mirror for S | |
| BX7 `linear_until` | Axioms.lean:184 | four-formula linearity disjunction | Linearity of U witnesses |
| BX7' `linear_since` | Axioms.lean:194 | mirror for S | |
| BX10 `until_F` | Axioms.lean:211 | `(φUψ) → F(ψ)` | Eventuality extraction |
| BX10' `since_P` | Axioms.lean:216 | mirror for S | |
| BX11 `temp_linearity` | Axioms.lean:225 | F-witness linearity disjunction | Linear order on F witnesses |
| BX11' `temp_linearity_past` | Axioms.lean:234 | mirror for P | |
| BX12 `F_until_equiv` | Axioms.lean:243 | `F(φ) → (⊤Uφ)` | Bridges F to U |
| BX12' `P_since_equiv` | Axioms.lean:248 | `P(φ) → (⊤Sφ)` | Mirror |
| BX13 `enrichment_until` | Axioms.lean:160 | `p ∧ (φUψ) → (φU(ψ ∧ S(φ,p)))` | Burgess A3a enrichment |
| BX13' `enrichment_since` | Axioms.lean:165 | mirror for S | Burgess A3b |
| BX2H `left_mono_until_G` | Axioms.lean:140 | `G(φ→χ) → (φUψ) → (χUψ)` | Guard strengthening under G |
| BX2H' `left_mono_since_H` | Axioms.lean:146 | `H(φ→χ) → (φSψ) → (χSψ)` | Guard strengthening under H |

*Note: BX8/BX8' (until_step/since_step) removed -- not sound under irreflexive semantics.*
*Note: BX9/BX9' (until_elim/since_elim) and until_guard/since_guard removed -- not sound under open guard `(t,s)` semantics (task 113).*
*Note: BX14/BX14' (separation_until/separation_since) removed -- redundant under transitive frames. Xu 3.2.1 (BX5 self-accumulation) subsumes BX14's role in chronicle splitting (task 115).*
*Note: BX2/BX2' (left_mono_until/left_mono_since) removed in task 133. Under open-guard irreflexive semantics the pointwise conjunct in BX2 is redundant; BX2H/BX2H' (left_mono_until_G/left_mono_since_H, added in task 107 Phase 5b) subsume BX2/BX2' and are now the canonical left-monotonicity axioms.*

### Layer 4: Modal-Temporal Interaction (2 → 1 after task 124)

| Axiom | File:Line | Statement | Status |
|-------|-----------|-----------|--------|
| `modal_future` | Axioms.lean:328 | `□φ → □(Gφ)` | Primitive |
| `temp_future` | Axioms.lean:331 | `□φ → G(□φ)` | **Task 124: derive from MF+T+Modal4, remove as primitive** |

### Layer 5: Uniformity (5)

| Axiom | Statement | Role |
|-------|-----------|------|
| `discrete_symm_fwd` | `U(⊤,⊥) → S(⊤,⊥)` | Forward gap implies backward gap |
| `discrete_symm_bwd` | `S(⊤,⊥) → U(⊤,⊥)` | Backward gap implies forward gap |
| `discrete_propagate_fwd` | `U(⊤,⊥) → G(U(⊤,⊥))` | Gap propagates to all future points |
| `discrete_propagate_bwd` | `U(⊤,⊥) → H(U(⊤,⊥))` | Gap propagates to all past points |
| `discrete_box_necessity` | `U(⊤,⊥) → □(U(⊤,⊥))` | Discreteness propagates to all box-accessible worlds (task 142) |

*These encode the uniformity of discreteness in ordered abelian groups. Valid on all linear orders with AddCommGroup structure. The `discrete_box_necessity` axiom is the key to eliminating the mixed case in `completeness`: it ensures that if any world is discrete, all box-accessible worlds are discrete too.*

### Layer 6: Prior Axioms for Integers (2) — Task 119

| Axiom | Statement | Role |
|-------|-----------|------|
| `prior_UZ` | `F(φ) → U(φ, ¬φ)` | Nearest future φ-point is reachable (Reynolds 1992 §10, Venema 1993 axiom W) |
| `prior_SZ` | `P(φ) → S(φ, ¬φ)` | Nearest past φ-point is reachable (dual) |

*These are discrete-only axioms (`isBase = False`, `isDenseCompatible = False`, `isDiscreteCompatible = True`, `frameClass = .Discrete`). Valid on all discrete orders with `IsSuccArchimedean`. Soundness proofs are sorry-free (well-founded descent via `Nat.find` on succ/pred chain). Added by task 119.*

### Irreflexive semantics and the seriality switch

Under the irreflexive semantics switch (task 93), BX1/BX1' (`Gφ → φ` / `Hφ → φ`)
were replaced by seriality axioms (`T → F(T)` / `T → P(T)`). This means:

- `bx_le` is no longer reflexive (g_content(w) is NOT a subset of w)
- `g_content_set_consistent` uses seriality instead of BX1: if G(bot) in MCS,
  seriality gives F(T) = not G(neg T), and G(bot) implies G(neg T) by ex falso,
  contradiction
- BX8/BX8' (until_step/since_step) were removed entirely -- not sound under irreflexive semantics
- `φ → F(φ)` is NOT derivable -- this is the KEY insight for completeness:
  resolved defects do not re-enter as F-obligations

---

## Irreflexive Truth Semantics

All four temporal operators in TM use strict (irreflexive) ordering. The current
point is EXCLUDED for G and H (`<`), and Until/Since witnesses must be strictly
future/past (`t < s` / `s < t`) with open guards.

From `FormalSystem/Semantics/Truth.lean` (the definition is named `TruthAt`):

- **G (`all_future`)**: `∀ s, t < s → ...` — strict future (excludes `t`).
- **H (`all_past`)**: `∀ s, s < t → ...` — strict past (excludes `t`).
- **U (`untl`)**: `∃ s, t < s ∧ ψ@s ∧ ∀ r, t < r < s → φ@r` — strict witness,
  open guard `(t, s)`.
- **S (`snce`)**: `∃ s, s < t ∧ ψ@s ∧ ∀ r, s < r < t → φ@r` — mirror.

Under irreflexive semantics, `Gφ → φ` is NOT valid (BX1 removed), and
`φ → F(φ)` is NOT derivable. Seriality axioms (`T → F(T)`, `T → P(T)`)
ensure the temporal order has no maximum/minimum elements.

---

## X/Y Operator Status

From `FormalSystem/Syntax/Formula.lean:430-436`:

```lean
/-- Next-step operator: X(phi) = U(phi, bot) (Burgess convention: event first, guard second).
    X(phi) at t means phi holds at t+1 (event=phi at immediate successor, guard=bot vacuous). -/
def next (φ : Formula) : Formula := Formula.untl φ Formula.bot

/-- Previous-step operator: Y(phi) = S(phi, bot) (Burgess convention: event first, guard second).
    Y(phi) at t means phi holds at t-1 (event=phi at immediate predecessor, guard=bot vacuous). -/
def prev (φ : Formula) : Formula := Formula.snce φ Formula.bot
```

Under irreflexive semantics, `⊥ U φ` at `t` requires a strictly future witness `s > t` with `φ(s)`
and an empty open interval `(t, s)`.

- **Discrete order** (e.g., `ℤ`): The interval `(t, s)` is empty iff `s = t + 1`.
  So `X(φ)` at `t` means `φ` holds at the immediate successor `t + 1`. This is
  a genuine next-step operator. Similarly, `Y(φ)` at `t` means `φ` holds at `t - 1`.
- **Dense order** (e.g., `ℚ` or `ℝ`): The interval `(t, s)` is never empty for
  `s > t`. So `⊥ U φ` is unsatisfiable on dense orders, and `X(φ)` is always
  false. Similarly, `Y(φ)` is always false on dense orders.

They are not currently used in proofs, but they are no longer trivially equivalent to their
argument as they were under the former reflexive semantics.

---

## Canonical Model Construction (BXCanonical)

**Note**: the `File.lean:NNN-MMM`-style line citations in this section are approximate pointers,
not exact current line ranges — re-verify by symbol before relying on them.

### BXPoint (Frame.lean:46-53)

```lean
structure BXPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas
```

A canonical frame point is a maximally consistent set (MCS) of formulas.

### Canonical Temporal Ordering (Frame.lean:56-62)

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

Equivalently: `w ≤ v ↔ ∀ φ, G(φ) ∈ w → φ ∈ v`.

- **Reflexivity** (`bx_le_refl`): NOT valid under irreflexive semantics (BX1 removed).
- **Transitivity** (`bx_le_trans`): requires `Gφ → GGφ` = `temp_4`.

### Key Infrastructure Lemmas (Frame.lean:79+)

- `g_content_closed_derivation`: if `L ⊆ g_content(S)` and `L ⊢ φ`, then `Gφ ∈ S`.
- `h_content_closed_derivation`: dual for H.
- `g_content_set_consistent`: `g_content` of an MCS is consistent; uses seriality. Sorry-free.
- `bx_forward_witness` / `bx_backward_witness`: Lindenbaum extension producing G/H canonical
  witnesses.
- `bx_modal_witness`: constructs the modal-direction witness. Sorry-free.

### Truth Lemma (TruthLemma.lean:27-36)

Proved by formula induction. All cases sorry-free (the `U`/`S` forward cases delegate to
`bx_until_eventuality_resolution`/`bx_since_eventuality_resolution`, closed by tasks 98+102).

### Completeness Theorem (Completeness.lean:124-154)

```lean
theorem completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

Contrapositive proof flow: assume `valid φ` and `¬derivable φ`; `{¬φ}` is consistent
(`neg_consistent_of_not_derivable`, sorry-free); extend to an MCS `M` (`set_lindenbaum`); build a
canonical `TaskModel`; the truth lemma gives `φ` false at `M`; contradiction. Per
`Completeness.lean`'s own module docstring: `completeness_dense`/`completeness_discrete` are
`sorryAx`-free, and (per Phase 1 above) `completeness`'s former discrete-branch debt is now closed
too — the whole theorem is `sorryAx`-free across all branches (dense, mixed, discrete).

---

## Quasimodel/Filtration Infrastructure

Nine files (2,228 lines) under `BXCanonical/` implement a Hintikka-set quasimodel with
defect-discharge to close the Until/Since eventuality obligations. All sorry-free today.

### Quasimodel/ (Hintikka-set quasimodel construction)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SubformulaClosure.lean` | 114 | Finite subformula closure (Sigma-closure) | `subformulas`, `SubformulaClosure`, `ghEnrichment` |
| `HintikkaPoint.lean` | 144 | Hintikka point definition and sigma-signature | `HintikkaPoint`, `sigma_signature`, `sigma_signature_consistent`, `sigma_signature_maximal` |
| `EnrichedClosure.lean` | 158 | Fisher-Ladner enriched closure with G/H negation formulas | `enrichedGNegBigconj`, `enrichedHNegBigconj`, `enrichedClosure` |
| `Construction.lean` | 885 | BX axiom lemmas at MCS level with defect-discharge | `hintikka_step`, `UntilDefect`, `defect_count`, `QuasimodelChain` |
| `Realization.lean` | 576 | Realization lifting from Hintikka chains to BXPoint chains | `until_forward_seed`, `since_backward_seed`, `until_eventuality_resolution`, `since_eventuality_resolution` |
| `LocusControl.lean` | 47 | Delegation layer (primed variants) | `bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'` |

### Filtration/ (Sigma-restricted ordering)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SigmaOrdering.lean` | 167 | Sigma-restricted ordering on BXPoints | `sigma_le`, `sigma_strict`, `sigma_equiv`, `bx_le_implies_sigma_le` |
| `DefectChain.lean` | 137 | Defect-discharge chain via well-founded recursion | `sigma_defect_count`, `until_defect`, `defect_step_phi` |

### CanonicalChain.lean (top-level bridge)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `CanonicalChain.lean` | 160 | MCS-level BX axiom lemmas and delegation bridges | `psi_imp_until_mcs`, `psi_imp_since_mcs`, `F_imp_top_until_mcs` |

---

## Burgess-Xu Until-Induction Technique

### Historical Context

The BX system is named after John P. Burgess and Ming Xu. Active references (cited in the
`Axioms.lean:46-49` comment block):

- **Burgess, J. P. (1982)**. "Axioms for tense logic. I. 'Since' and 'until'."
  *Notre Dame Journal of Formal Logic* 23(4), 367-374.
- **Xu, M. (1988)**. "On some U, S-tense logics." *Journal of Philosophical Logic* 17, 181-202.
  Simplifies Burgess's axiomatization.
- **Venema, Y. (1993)**. Temporal logic survey (cited in `Axioms.lean:48`).

See also the Stanford Encyclopedia of Philosophy:
[Burgess-Xu Axiomatic System for Since and Until](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html),
[Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/).

### Key Result

Burgess (1982), simplified by Xu (1988), gives a complete axiomatization of the Since-Until tense
logic over **all linear orderings**. The BX axioms in `Axioms.lean` are modeled on this
axiomatization, adapted for irreflexive semantics.

### Axiom Roles in the Until-Induction Proof

The proof of the Until case of the truth lemma proceeds by induction on the Until-structure of
formulas, using: **BX10** (extracts an F-witness), **BX7**/**BX11** (linearity of Until/F
witnesses, giving comparability), **BX5** (guard-propagation — the eventuality enriches its own
guard at every intermediate point), **BX6** (prevents nested self-accumulation deferrals), **BX4**
(propagates `¬(φUψ)` forward in the backward direction), **BX1** (seriality — consistency of
`g_content` contradicts `G(bot)` via `F(T)`). BX9 (`until_elim`) was removed (task 113) — not
sound under open-guard semantics.

### Resolution: Option A (Quasimodel with Defect-Discharge)

Task 90 (research) identified two strategies: **Option A** (quasimodel with defect-discharge,
chosen and implemented via tasks 92/98/102 — 2,289 lines of sorry-free infrastructure) vs.
**Option B** (Henkin witness closure, not taken).

---

## Representation Theorem Goal

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

The representation theorem is **general**: for any countable linear order `D` arising from a
chronicle construction, produce a TaskFrame model on an `AddCommGroup D'` that agrees on truth
values, supporting `D' = ℚ` (base/dense) and `D' = ℤ` (discrete).

### Architecture: Natural Inclusion Replaces Cantor Isomorphism

The chronicle construction (Burgess 1982) produces a limit domain `X ⊂ ℚ`. The natural inclusion
`X ⊂ ℚ` (injection, requires nothing) replaces the Cantor order-isomorphism (bijection, requires
density) that was the historical source of the density-case sorry — see
`specs/ROADMAP-ARCHIVE.md` for the retired construction this replaced. `AddCommGroup D` remains
structurally load-bearing: only MF/TF (2 of 40+ axioms) need group structure for soundness; all
other axioms are purely order-theoretic.

### Design Constraints

- The logic is NOT weakened: all axioms (including MF/TF) remain sound.
- `TaskFrame`, `WorldHistory`, `TruthAt`, `valid` — one semantics, one truth definition, one
  validity notion, no parallel layers.
- **Only the algebraic/canonical model approach is pursued for completeness** — the
  representation theorem tells us what TM *is* (a structural correspondence between
  proof-theoretic and semantic notions), which a decidability-based route could never supply, even
  as a bare `valid(φ) → provable(φ)` fact.

---

## Paper Alignment Programme (possible_worlds.tex)

The JPL paper (`PossibleWorlds/JPL/possible_worlds.tex`) is the single source of truth for the
basic semantic definitions; the Lean tree, `latex/` prose, and the `typst/` book are all
downstream. Cite the paper by `\label` and quote verbatim — never by bare line number.

**`def:frame` carries FOUR axioms**: *Compositionality* (biconditional, asserting interpolation),
*Seriality*, *Limit* (formerly "Limit Nullity"), and *Spherical* (condition Sd1 from the
ball-space literature). *Nullity* and *Occurrence* are derived lemmas. Logical consequence
quantifies over **total** world histories (`X = D`), not merely maximal ones.

**Cluster status, corrected 2026-08-25** — the prior record here listed six tasks as
not-started/blocked with no stale banner; all six have in fact landed:

| Task | Prior claim | Actual status (archive, 2026-08-25) |
|---|---|---|
| 420 (four-axiom `TaskFrame`) | blocked | **completed** |
| 414 (total-history semantics refactor) | not started | **completed** |
| 415 (completeness over total-history semantics) | not started | **completed** |
| 417 (semantic FMP over refactored `TruthAt`) | not started | **completed** |
| 419 (CO/Reynolds independence, Q-flow conformance) | not started | **completed** |
| 427 (sync the typst book from the paper) | not started | **expanded** (divided into subtasks) |

Rebased onto the landed 414 semantics: 413 (TM conservativity bridge), 169/170/408/361/362
(completeness programme — see Phase 1), 165/410/411/412 (tableau decidability — see Phase 2). 424
(shift-set representation) also touches `TruthAt` and sits outside the `paper-refactor` topic —
completed (see Phase 1).

**Check grounding**: `specs/archive/state.json` `completed_projects`/`archived_projects`,
cross-checked by `jq` at realignment time (2026-08-25).

---

## Recommended Priority Order

1. **Decidability/tableau spine** (Phase 2): 462 → 463 → 464 → 465 → 428 → 429 → 410 → 411 → 430
   → 412 → 482, plus parallel entries 480 (startable now) and 481 (before/alongside 462).
2. **Consequence-completeness capstone** (task 362, Phase 1) — unblocked; all four weak engines
   it builds on are DONE.
3. **Semantic FMP** (task 476, Phase 4) and **proof-extraction completeness** (task 482, Phase 2)
   — both open mathematics, multi-month, run in parallel with the spine rather than gating it.
4. **Publication/documentation** (Phase 5) — gated on the decidability chain landing (177) or
   independently schedulable (178's propositional-fragment rescope, the monograph tasks).
5. **Dataset/training infrastructure** (Phase 6) — independent front, carried-forward priorities
   per the 2026-08-24 review.
6. **Repository hygiene** (Phase 7) — `state.json` counter repair when a schema decision is made;
   otherwise complete.
