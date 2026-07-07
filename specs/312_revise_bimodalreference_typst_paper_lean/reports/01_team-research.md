# Research Report: Task #312 — Revise BimodalReference.typ to match paper + Lean source

**Task**: Systematically revise `Theories/Bimodal/typst/BimodalReference.typ` to align with the completed paper `possible_worlds.tex`, prioritizing accuracy with the substantially-changed Lean 4 source as the FIRST priority.
**Date**: 2026-07-06
**Mode**: Team Research (4 teammates: Lean-ground-truth, Paper+infrastructure, Critic, Horizons)
**Topic**: publication-quality

---

## Summary

`BimodalReference.typ` and its six chapter files have drifted **multiple project-generations** behind the current Lean 4 source. This is not an edit-pass task: three of six chapters (Syntax, Proof-Theory, Metalogic) require **substantive rewrites**, and one (Notes) contains an internal self-contradiction plus stale historical tables. The drift is deep enough that the four researchers independently converged on the same headline findings.

The single most important structural discovery: **the document contradicts itself** on temporal semantics. `02-semantics.typ` uses strict/irreflexive time (`y < x`) — which matches both the paper AND the current Lean source — while `04-metalogic.typ` and `06-notes.typ` argue at length that *reflexive* semantics is "current." The current Lean source (`Semantics/Truth.lean`, task 93) is **irreflexive/strict**; the reflexive narrative is stale and must go.

The task as literally scoped (one file) also sits inside a **recurring, unsolved structural problem**: this is the third "docs drifted behind Lean" task in project history, there are three-to-four parallel doc surfaces (typst, latex, `docs/reference/`, the external JPL paper), and the JPL paper lives outside the repo and is still being edited. A durable outcome needs an explicit scoping decision and, ideally, a lightweight anti-drift mechanism — but those should not balloon this task's core deliverable.

---

## Key Findings

### 1. Temporal semantics: strict/irreflexive is current (self-contradiction in the doc) — HIGH confidence

- Current Lean ground truth: `Semantics/Truth.lean:10-17` — "Irreflexive Temporal Semantics (A2 Guard Convention)... G and H use STRICT semantics (< instead of ≤)... the T-axioms are NOT valid." Corroborated by `Metalogic/Metalogic.lean:9-16` (task 93).
- `02-semantics.typ:85-90` already encodes strict `<` truth conditions for H/G → **correct, matches paper `possible_worlds.tex:948-949` and current Lean.**
- `06-notes.typ:118-126` ("Reflexive Temporal Semantics (Current)") and `04-metalogic.typ:154` design narrative claim reflexive `≤` is current, and even mis-cite `02-semantics.typ` as supporting it → **wrong; must be rewritten.**
- **Resolution: strict/irreflexive is current.** This fact must be established first, before editing chapters 02/04/06, because it determines which prose survives.

### 2. Syntax primitives changed — HIGH confidence

- Typst `01-syntax.typ:14-18` claims 6 primitives `{atom, bot, imp, box, H, G}`.
- Lean `Syntax/Formula.lean:70-85`: primitives are `{atom, bot, imp, box, untl, snce}` (Until/Since, Burgess convention). H/G/F/P are now **derived `def`s** (`Formula.all_future/all_past/some_future/some_past`, `Formula.lean:109-155`).
- Note tension: the paper's *base* TM language uses H/G/Past/Future as primitives (`possible_worlds.tex:~446`); Lean has moved to Until/Since primitives with H/G derived. **Lean wins per task priority** — present Until/Since as primitive, H/G/F/P as derived, and note the paper uses the H/G presentation.

### 3. Proof system is a different, frame-class-parametrized axiom system — HIGH confidence

- Typst `03-proof-theory.typ:12` claims **14 axiom schemata** (ch04 abstract says 15 — already internally inconsistent).
- Lean `ProofSystem/Axioms.lean:37`: **42 axiom constructors** under the "Burgess-Xu (BX)" system, in 8 layers (Propositional / S5 Modal / BX Temporal ×2 with primed past-mirrors / Modal-Temporal Interaction / Uniformity / Prior / Z1 / Density).
- `DerivationTree` now carries a **`FrameClass` parameter** (Base/Dense/Discrete), `ProofSystem/Derivation.lean:85-93` — an entire structural axis absent from the typst doc. Corresponds to the paper's TM / TM⁺ / TM_F / TM_D / TM_C / TM_DC hierarchy.
- Several old named axioms (TK, T4, TA, TL, TF) **no longer exist as axioms** — now derived theorems (`Theorems/TemporalDerived.lean`, task 116) or replaced by BX axioms. `Axioms.lean:38,74,111-112` confirms temp_k_dist/temp_4 are derived.
- Paper-vs-typst axiom discrepancies (Teammate B): the paper's economical core TM system has 12 schemata (MP, MN, MK, MT, M5, MF, TD, TK, T4, TB, TA, TL); the typst doc adds redundant M4/MB, promotes TF (a paper *theorem*) to an axiom, is **missing TB (seriality)**, and states **TL with the wrong formula** (typst: `always φ → G H φ`; paper `:1103`: future-linearity). All of these must be reconciled against the actual `Axiom` constructors, not guessed from the paper.
- The 7 inference-rule names (axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening) **still match** — this part is accurate.

### 4. Metalogic chapter describes a deleted/archived architecture — HIGH confidence

- `04-metalogic.typ` names `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean` as "the primary sorry-free completeness theorem," and cites directories `Representation/`, `FMP/`, `Completeness/`, `Soundness/` (as dir).
- Reality: `grep` finds `semantic_weak_completeness` **only inside `Boneyard/`** (archived). None of those directories exist at top level. Actual `Metalogic/` tree: `Core/`, `Bundle/`, `Algebraic/`, `BXCanonical/`, `WeakCanonical/`, `ConservativeExtension/`, `Decidability/`, `Relational/`, `SoundnessLemmas/`, plus loose `Completeness.lean`, `Soundness.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean`.
- **Open conflict to resolve (see Conflicts below): which completeness approach is "primary."** Teammate A found completeness wired through `BXCanonical/Completeness.lean` (Burgess chronicle + Reynolds/Doets discrete). Teammate C found `Metalogic/README.md` designates `Bundle/` (BFMCS, `bmcs_weak_completeness`) as primary, with BXCanonical/WeakCanonical/Algebraic as additional active approaches. The README self-warns it predates task 131.
- **Completeness is NOT sorry-free.** ~38-42 genuine `sorry` occurrences outside `Boneyard/` (Chronicle/ChronicleToCountermodel 20, WeakCanonical/TruthLemma 20, Transfer 17, BXCanonical/Completeness 8, plus Kamp modules). The doc's "20 sorries, all deprecated" is wrong. Soundness and Perpetuity (P1-P6) ARE genuinely sorry-free (confirmed).

### 5. Missing content: Reflection constraint, frame-class axis, Extensions — HIGH/MEDIUM

- Task Frame definition `02-semantics.typ:34-38` lists only Nullity + Compositionality; the paper (`:902-907`) and Lean have a third constraint, **Reflection** (`w ⇒ₓ u ⟹ u ⇒₋ₓ w`). No `leanReflection` notation macro exists yet.
- Frame classes (Base/Dense/Discrete; `FrameConditions/` directory) have **zero** references in `typst/`.
- Paper §3.3 Extensions (discrete/dense/complete time) and §3.1 Restricted Modalities are unrepresented; scope decision needed (document if Lean-formalized, else a one-line "not yet formalized" note).

### 6. Infrastructure is sound; minor doc-hygiene fixes — HIGH

- `template.typ`, `notation/*.typ`, chapter `#include` mechanics are clean and need no structural change — only **additive** notation macros for new content (Reflection, TB, frame-class axioms).
- Stale hygiene: `README.md:43` claims `great-theorems` dependency but `template.typ:10` uses `thmbox`; stray top-level `BimodalReference.pdf` vs documented `build/` output.
- Compile via `typst compile BimodalReference.typ build/BimodalReference.pdf` — a compile smoke-test is a baseline Definition-of-Done item (no CI check exists today).

---

## Synthesis: Conflicts Resolved

1. **Axiom count "14 vs 42 vs 12"** — not a real conflict, different granularities. Lean = 42 constructors (spells out CPL combinators, primed past-mirrors, frame-class axioms). Paper = 12 economical schemata. Typst = stale 14/15. **Ground truth = 42 Lean constructors**; present them organized by the 8 layers, and note the paper's more economical presentation in an exposition aside.
2. **Which completeness theorem is "primary"** (Teammate A: BXCanonical `completeness`; Teammate C: Bundle/BFMCS per README) — **unresolved by research; a planning decision.** Both the Bundle README designation and the actual BXCanonical wiring are real. The planner/implementer must verify the *current* live wiring directly (both the README and the doc are demonstrably capable of being stale) and present the confirmed-primary approach, giving the other active approaches (Bundle, BXCanonical, WeakCanonical, Algebraic) scoped secondary treatment — not dropping any.
3. **Strict vs reflexive semantics** — fully resolved: **strict/irreflexive is current** (task 93). No remaining ambiguity.
4. **Paper vs Lean axiom names (TB, TL, M4/MB, TF)** — resolved in favor of **Lean as ground truth**; every axiom-table cell must be checked against the actual `Axiom` constructors before landing, using the paper only for narrative framing.

## Synthesis: Gaps Identified

- No accuracy-verification mechanism exists for `typst/`. A verification pass is essential: extract every backtick-quoted Lean identifier/filename across all 7 chapters and `grep` each under `Theories/Bimodal` **excluding `Boneyard/`**; any name resolving only in Boneyard is a documentation bug.
- The `latex/BimodalReference.tex` mirror is also stale (last touch 2026-03-16) and the typst README asserts parity with it. Fixing only typst silently breaks that contract. **Scope decision required.**
- `docs/reference/{axiom-reference,operators,tactic-reference}.md` is a fourth stale surface — flag, don't silently expand.
- Active task-309/310/311 Kamp-theorem work is NO-GO-gated and in-flux — must NOT be presented as a settled/citable result.

---

## Recommendations (for the planning phase)

**Recommended shape: a ground-truth-inventory phase, then chapter rewrites heaviest-first, then a verification gate.** Concretely:

1. **Phase 0 — Scope decisions (record explicitly in the plan):**
   - BimodalReference.typ = technical companion documenting *only the Lean-formalized core*, using the paper's terminology/notation as the target vocabulary — NOT a mirror of the paper's unformalized philosophy (Objective Modality, 2D Semantics are out of scope).
   - Which completeness approach is primary (verify live wiring; likely Bundle/BFMCS or BXCanonical).
   - Is frame-class parametrization (Base/Dense/Discrete) in scope this pass or deferred? (Large: touches ch03 axioms + ch04 soundness + possibly a new section.)
   - Is `latex/` kept in lockstep, or explicitly declared to diverge (update both READMEs either way)?
   - Kamp/task-311 work = out of scope / "in progress" note only.
2. **Phase 1 — Ground-truth inventory:** extract every backticked Lean name/dir across all 7 chapters; grep-verify against live source (excluding Boneyard); produce a claim → verified/stale/not-found mapping table. This table is a reusable first-class deliverable (Teammate D), e.g. an appendix or `SYNC-MAP.md`.
3. **Phase 2 — Chapter rewrites, heaviest first:**
   - `04-metalogic.typ` (full rewrite: real Metalogic tree, confirmed-primary completeness, honest sorry inventory).
   - `03-proof-theory.typ` (full rewrite: 42-constructor BX system by 8 layers, FrameClass parameter, drop TK/T4/TA/TL/TF as axioms, add TB, fix TL).
   - `01-syntax.typ` (rewrite primitives to Until/Since; H/G/F/P as derived).
   - `02-semantics.typ` (add Reflection constraint + macro; keep strict truth conditions; add untl/snce truth clauses).
   - `06-notes.typ` (delete reflexive-semantics narrative; rewrite discrepancy/axiom-naming tables; correct sorry/status counts).
   - `05-theorems.typ` (spot-fix module table: `Propositional`/`Perpetuity` are subdirectories; add `ContextualProofs.lean`, `TemporalDerived.lean`).
   - `00-introduction.typ` (fix "14 axioms/7 rules" and directory list).
4. **Phase 3 — Verification gate (Definition of Done):** `typst compile` succeeds; every cited Lean name resolves outside Boneyard; axiom-layer counts and sorry counts regenerated from source, not copied forward.
5. **Optional follow-up (spawn, don't scope-creep):** a `typst-sync-check.sh` drift detector and/or Lean doc-comment breadcrumbs; a follow-up for `latex/` and `docs/reference/` sync. Relate to existing tasks 131 (doc-tree reorg) and 177 (docs-after-refactor).

**Do NOT** restructure typst chapters to 1:1-mirror Lean module boundaries — the pedagogical chapter structure is correct; the mapping table gives traceability without fragmenting exposition.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Lean source as ground truth (discrepancy table) | completed | high |
| B | Paper spine + Typst infrastructure | completed | high |
| C | Critic: scope, three-way consistency, verification gaps | completed | high |
| D | Horizons: recurring drift, sync protocol, roadmap | completed | high (facts) / medium (tooling proposals) |

Full per-teammate findings: `01_teammate-a-findings.md` … `01_teammate-d-findings.md` in this directory.

## Key References (file:line)

- `Syntax/Formula.lean:70-85` (primitives), `:109-155` (derived H/G/F/P)
- `ProofSystem/Axioms.lean:37` (42 constructors), `:38,74,111-112` (temp_k/temp_4 derived)
- `ProofSystem/Derivation.lean:85-93` (FrameClass parameter)
- `Semantics/Truth.lean:10-17` (irreflexive/strict — current)
- `Metalogic/Metalogic.lean:9-24` (completeness SORRY; task 93)
- `Metalogic/BXCanonical/Completeness.lean` (chronicle wiring)
- `Metalogic/README.md:11-13,21,23-28` (Bundle/BFMCS primary; 42 axioms, frame classes)
- `possible_worlds.tex:1087-1105` (paper TM 12-schema system), `:902-907` (Reflection), `:948-949` (strict truth clauses), `:1127-1132` (TF derived), `:3286-3294` (completeness deferred to Lean repo)
- Typst: `chapters/01-syntax.typ:14-18`, `03-proof-theory.typ:12`, `04-metalogic.typ:118-122`, `06-notes.typ:118-126`; `template.typ:10`; `notation/bimodal-notation.typ`
