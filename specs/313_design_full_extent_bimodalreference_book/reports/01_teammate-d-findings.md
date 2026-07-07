# Teammate D Findings: Horizons — Strategic Direction for the BimodalReference Book

**Task**: 313 - design_full_extent_bimodalreference_book
**Teammate**: D (Horizons: long-term alignment and strategy)
**Date**: 2026-07-06
**Sources**: specs/ROADMAP.md, README.md, Theories/Bimodal/typst/ (post-task-312 state),
docs/training/PIPELINE.md, Metalogic/Decidability/README.md,
~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex (§Extensions, §Bimodal Logic),
~/Philosophy/Papers/PossibleWorlds/Lk/ (abstract, intro, section map),
~/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex,
~/Projects/Logos/Theory/README.md, ~/Projects/Logos/Theory/typst/manual/LogosManual.typ

---

## Key Findings

### F1. The book arc aligns with the roadmap's endgame, but ROADMAP.md itself is silent about it

ROADMAP.md is a completeness-effort document: its critical path is one sorry chain
(`existPart_succ_n1_bypass` k>0, task 303), followed by sorry cleanup, then "Post-Completeness:
Structural Refactor → Publication" (tasks 175, 180, 131, 161, 183, 185-193, 177-178 —
ROADMAP.md:1423-1431). The book is the natural *deliverable* of that publication phase, yet no
roadmap item names it. Task 312's summary already flags ROADMAP staleness (41 axioms/6 layers vs
actual 42 constructors/8 layers). **Strategic implication**: the book design should be added to
the roadmap as the publication-phase spine, and the book must be engineered to tolerate roadmap
churn (see F5) rather than assuming the completeness numbers are stable.

### F2. The "decidability program / tableau-training / automation" items live in the task list and README, not ROADMAP.md — and the book is the only place they can be unified

- The tableau decision procedure is **already implemented and sorry-free** across 10+ modules
  (`Metalogic/Decidability/README.md`: SignedFormula, Tableau, Saturation, Closure, Correctness,
  ProofExtraction, CountermodelExtraction, FMP/, DecisionProcedure — all "Sorry-free"), with
  fuel-based termination. The current book gives it one subsection (04-metalogic.typ §Decidability).
- The training pipeline is documented (`docs/training/PIPELINE.md`): dual-signal data (proof
  traces → policy network; countermodels → value network), `lake exe dataset_generator`,
  artifact-only integration with BimodalHarness (AlphaZero-style MCTS proof search).
- Open tasks cover both tracks: tableau (290 fuel allocation, 300 abort-aware cancellation),
  datasets (230 benchmark refresh, 231 regeneration automation, 296-298), tactics (196, 199),
  FMP (165, 82).

**The task-313 goal (1) — "decidable fragments for automated reasoning vs training AI to reason
proof-theoretically" — is exactly the dual verification architecture the README already names**
(README.md:183-184: ModelChecker searches for countermodels while ProofChecker constructs
derivations). No document currently tells this story as one story. The book's automation part can
simultaneously be: (a) the *specification* for the tableau/fragment work, (b) the *documentation*
for the dataset pipeline, and (c) the public narrative for BimodalHarness. That is three roadmap
items advanced by one chapter.

### F3. The "vanilla LTL + S5 + Vlach" presentation is not an invention — it is the already-published architecture of the two papers, and the Lk paper supplies the decidability frontier map for free

possible_worlds.tex §Extensions (lines 1162-1262) builds the exact tower the task requests:

1. **TM** over ⟨SL, ⊥, →, □, P̄, F̄⟩ (tense + S5);
2. **TM⁺ / BL⁺** = ⟨SL, ⊥, →, □, since, until⟩ — Kamp's U/S subsume G/H/F/P and define X/Y
   (`Nextφ := ⊥ until φ`), with conservativity (thm:ConservativeExtension) and completeness
   verified in this very repo (the paper says so explicitly);
3. **BL\*** = BL⁺ + indexed store/recall operators ↓ⁱ/↑ⁱ for *both times and worlds* — explicitly
   "generalizing the now and then operators that Vlach introduces", and explicitly
   **outside the scope of the paper** ("extending TM to provide a logic for BL* is outside the
   scope of the present paper").

The Lk paper then positions itself as "a hybrid-lite fragment of BL*": BL*'s full store/recall
apparatus is "the undecidable/hybrid *ceiling*"; L_k "descends from it by four restrictions that
each remove a verified undecidability engine" (Lk abstract + intro). Its results give the book a
complete, citable decidability frontier: L₀ = LTL (conservativity); L₁ ≅ PTL×S5,
EXPSPACE-complete, finitely axiomatizable via time-indexed quasimodels; L₂ undecidable at modal
depth two and non-axiomatizable; alternation-freedom does NOT restore decidability (Minsky
encoding); the flagship decidable fragment ∀-AF-L_k is PSPACE-complete and covers the entire
hardware case study (constant-time, reset convergence, deadlock freedom, SVA/Logos-Hardware
bridge).

**Strategic implication**: the book's "expressive extensions" and "decidable fragments" chapters
should adopt the papers' own *ceiling-and-descent* framing — each operator added buys
expressiveness (LTL → +□ → +↓/↑), each restriction subtracted buys decidability (BL* → L_k →
∀-AF-L_k → tableau-decidable TM). This single picture answers task goals (1), (2), and (3) at
once and requires no new theory, only exposition. One caution: Lk works over discrete,
future-only traces while TM has two-sided group time — the book needs an honest bridging section
(the conservativity results are the bridge).

### F4. Caution: Vlach/store-recall operators do NOT exist in the Lean codebase — the book must adopt a two-status discipline or it will corrupt its own identity as a verified reference

`grep -ri vlach|store|recall Theories/Bimodal/Syntax/` returns nothing; BL* is paper-only. The
book's current identity (post-task-312) is "formal specification *as implemented*", with a
SYNC-MAP.md claim-verification table stamped at git commit `a883361bf`. Adding BL*, L_k, and
counterfactual chapters as if they were reference material would break that contract. The fix is
cheap and already half-built: extend the SYNC-MAP discipline into a per-theorem status legend
(verified sorry-free / stated-with-sorries / paper-proved-unformalized / planned), so
forward-looking chapters are first-class citizens *marked as such*. This turns the gap into a
feature: the book becomes the formalization's forward specification, and each "planned" marker is
a latent roadmap task.

### F5. The book must be a living, part-structured document, not a one-shot expansion

Task 312 proved the failure mode: the previous LaTeX BimodalReference.pdf is now "declared
divergent" and the typst version needed a full 7-phase re-sync because the reference was written
once and the code moved. Meanwhile the metalogic status will keep churning (task 303 will flip
the discrete-completeness status; sorry counts change monthly). The design consequence:

- Volatile facts (sorry inventories, counts, module trees) stay confined to ch. 4 + Notes with
  SYNC-MAP stamps — never scattered through motivational prose.
- The proposed `typst-sync-check.sh` CI drift detector (312's suggested follow-up) becomes a
  precondition for growing the book — create it as a task *before* the expansion.
- A Parts structure gives stable interfaces so later material appends without renumbering.

### F6. The Logos slot-in: TM is the "Dynamical Foundation, temporal/modal slice"; the next chapter's target is precisely the Logos manual's chapters 02-03

Logos Theory/README.md defines the layer diagram: **Constitutive Foundation** (bilateral
verifier/falsifier propositions over a complete lattice, grounding ≤, essence ⊑, identity ≡) is
*required* under the **Dynamical Foundation** (□/◇, H/G/P/F/S/U, store/recall ↓/↑, Act,
counterfactual □→/◇→, causal ○→). LogosManual.typ has chapters 02-constitutive and 03-dynamics.
counterfactual_worlds.tex supplies the semantics the task names: counterfactuals evaluated by
*minimally changing the world-state at the moment of the antecedent* rather than Lewis/Stalnaker
whole-world similarity (the Fine/Nixon argument, counterfactual_worlds.tex ~line 400ff), from
which metaphysical modality is derivable. So the unification narrative writes itself as a
two-axis expansion: **horizontal** (more operators over the same task semantics: U/S, ↓/↑) and
**vertical** (more structure inside world-states: constitutive verifier/falsifier structure →
counterfactuals → derived □). TM is the first fully-verified cell of that grid; the book should
present the grid explicitly so every later volume/chapter has a pre-assigned cell and no rewrite
is needed.

---

## Recommended Approach

### R1. Reframe the book as a four-part living monograph; keep current chapters as Part I

```
Part I  — The Bimodal Core (existing ch. 0-6, lightly restructured)
          Status: verified reference (SYNC-MAP-backed).
Part II — Expressive Power and Its Price
          Ch: From LTL to TM (vanilla LTL + S5; task semantics vs trace semantics;
              conservativity; L1 ≅ PTL×S5 identification)
          Ch: Vlach Operators and BL* (indexed store/recall for times and worlds;
              the hybrid ceiling)                                 [status: paper/planned]
          Ch: The Decidability Frontier (L_k map: what is EXPSPACE, what is PSPACE,
              what is undecidable, and why)                       [status: paper]
Part III — Automated and Neural Reasoning
          Ch: The Tableau Decision Procedure (implemented, sorry-free; proof
              extraction + countermodel extraction)               [status: verified]
          Ch: Training Proof-Theoretic Reasoners (dual-signal pipeline, datasets,
              BimodalHarness; deterministic checkability as the point)
          Ch: Dual Verification (ModelChecker/Z3 countermodels vs ProofChecker
              derivations)
Part IV — Toward the Logos
          Ch: The Unification Grid (horizontal operator axis x vertical
              world-state-structure axis; TM as first verified cell)
          Ch: Constitutive Structure and Tensed Counterfactuals (counterfactual_worlds
              semantics; deriving metaphysical modality)          [status: planned]
```

Rationale: Parts I and III are reference-of-implemented; Parts II and IV are
specification-of-planned. The two-status discipline (R2) keeps them honest side by side.

### R2. Institutionalize the status legend + CI sync check BEFORE writing new chapters

Extend SYNC-MAP.md categories to a visible per-theorem/per-chapter legend
(✓ verified sorry-free / ⧖ stated with sorries / ○ proved in paper, unformalized / ◇ planned).
Create the `typst-sync-check.sh` CI task (already suggested by 312) as a dependency of the
expansion. This is the single highest-leverage move for keeping a growing book truthful.

### R3. Make the decidable-fragments chapter double as the specification for the automation roadmap

Write the Part II decidability chapter so that its final section is a *normative* table: which
fragments the Lean tableau currently decides, which fragment (∀-AF-L_k-style) is the target, and
what termination/completeness statements remain fuel-based rather than verified. Each row that
isn't ✓ becomes a candidate task. This converts book-writing into roadmap grooming for tasks
165/82 (FMP), 290/300 (tableau), and any future verified-termination work.

### R4. Make the AI-training chapter the canonical home of docs/training/PIPELINE.md content

Promote (not duplicate — move and cite) the dual-signal architecture into the book, framed by the
task description's contrast: *decidable fragments give fully automated reasoning; the full logic
trains systems that reason proof-theoretically and solve constraint systems, with every output
deterministically and cheaply checkable*. This is the Logos-labs pitch ("unlimited
self-supervised training data ... proof receipts ... countermodels ... without human annotation",
Logos Theory/README.md) grounded in shipped code.

### R5. Creative/unconventional additions worth adopting

1. **Machine-readable appendix**: export the axiom table, inference rules, and derived-operator
   definitions as JSONL matching the `DatasetExporter` schema, generated from Lean and included
   in the book build. The manual itself becomes a training/eval artifact — uniquely on-brand.
2. **Dual-track chapter style**: each formal claim rendered as (informal motivation paragraph) +
   (Lean-name-anchored statement box). Task 312 already verified 271 backticked Lean names
   resolve; make that pattern the house style for all new chapters.
3. **A "How to read this book if you are an AI" preface section** (2 pages): where the
   machine-readable appendix lives, what the status markers mean, which claims are safe to use as
   ground truth. Low cost, high distinctiveness, aligned with the verified-AI-reasoning mission.
4. **Grid frontispiece**: the horizontal x vertical unification grid (F6) as a single diagram in
   the introduction, with verified cells shaded. Later volumes shade more cells; the diagram is
   the no-rewrite contract.

### R6. Scope task 313's deliverable accordingly

The current task deliverable ("initial design report mapping candidate content to a proposed full
book structure") is right; the follow-on tasks should be sliced *per part*, not one mega
implementation task: (a) roadmap + CI-sync infrastructure task; (b) Part II drafting (paper
transcription, mostly Lk + possible_worlds §Extensions); (c) Part III drafting (mostly promotion
of existing docs); (d) Part IV drafting (counterfactual_worlds + LogosManual alignment — do this
last; it depends on Logos-side stability). Each slice is one agent-run-sized and independently
green.

---

## Evidence/Examples

| Claim | Citation |
|---|---|
| Roadmap publication phase exists but has no book item | specs/ROADMAP.md:1423-1431 ("Post-Completeness: Structural Refactor → Publication") |
| Single remaining completeness sorry chain | specs/ROADMAP.md:34, :1400-1415 (task 303) |
| Decidability excluded from representation theorem, but "of independent interest" | specs/ROADMAP.md:1387-1394 |
| Tableau implemented sorry-free, fuel-based | Theories/Bimodal/Metalogic/Decidability/README.md (module status table) |
| Dual-signal training pipeline + BimodalHarness | docs/training/PIPELINE.md:1-40; README.md:183 |
| Dual verification architecture (Z3 + Lean) | README.md:184 |
| TM → TM⁺ → BL* tower, Vlach generalization, "outside the scope" | possible_worlds.tex:1162-1262 (§Extensions), esp. line 1254 (Vlach) |
| L_k as hybrid-lite fragment of BL*; ceiling-and-descent framing | Lk/sections/00-abstract.tex; Lk/sections/01-intro.tex ("hybrid-lite fragment of BL*") |
| L_k complexity map (EXPSPACE floor, PSPACE fragment, undecidability at k≥2) | Lk/sections/00-abstract.tex; 03-expressiveness.tex, 04-complexity.tex section heads |
| No Vlach/store/recall in Lean | grep of Theories/Bimodal/Syntax/ (no matches) |
| Book just re-synced; SYNC-MAP methodology; LaTeX version divergent | specs/312_*/summaries/01_revise-typst-reference-summary.md; Theories/Bimodal/typst/SYNC-MAP.md |
| Logos layer architecture (constitutive → dynamical → extensions) | ~/Projects/Logos/Theory/README.md (layer diagram) |
| Counterfactuals via minimally-changed moments vs Lewis similarity (Fine/Nixon) | counterfactual_worlds.tex ~lines 400-435 |
| LogosManual chapter slots (02-constitutive, 03-dynamics) | LogosManual.typ:164-188 |
| Open tasks the book chapters would advance | state.json: 290, 300 (tableau); 230, 231, 296-298 (datasets); 165, 82 (FMP); 196, 199 (tactics) |

---

## Risks and Mitigations

1. **Churn risk** — metalogic status flips when task 303 lands. *Mitigation*: volatile facts
   confined to ch. 4 + Notes with SYNC-MAP stamps (R2); motivational chapters written
   status-agnostically.
2. **Spec-implementation gap** — BL*/Vlach chapter describes unimplemented operators.
   *Mitigation*: status legend (R2); optionally spawn a semantics-only Lean formalization task
   for BL* (the paper needs no axiomatization, so a `truth_at` extension with ⟨v⃗, μ⃗⟩ evaluation
   points is feasible and would upgrade the chapter from ○ to ⧖/✓).
3. **Trace-semantics mismatch** — Lk is discrete/future-only; TM is group-time/two-sided.
   *Mitigation*: dedicated bridging section in Part II; lean on the conservativity theorems.
4. **Duplication of the papers** — transcribing possible_worlds.tex wholesale bloats the book and
   creates a third divergence surface. *Mitigation*: the book owns the implementation-grounded
   account and the unification narrative; it cites the papers for philosophical argument.
5. **Logos-side instability** (Part IV depends on Logos Theory/ and LogosManual, a separate
   repo). *Mitigation*: sequence Part IV last (R6); pin cross-repo references by commit.

---

## Confidence Level

**High** for F1-F5 and R1-R4 (grounded directly in repo state, roadmap text, and the two papers'
own framing — the ceiling-and-descent narrative is quoted, not inferred).
**Medium** for F6/R5/R6 details (Logos-side structure was skimmed at README/manual-outline depth;
the counterfactual chapter's exact shape depends on counterfactual_worlds.tex content not read in
full and on Logos Theory maturity).
