# Teammate A Findings: Lean 4 Source as Ground Truth

**Task 312** — Revise `Theories/Bimodal/typst/BimodalReference.typ` to align with the JPL paper and the Lean 4 source, prioritizing fidelity to the **current Lean 4 source** above all else.

**Scope of this report**: I did not read the JPL paper (`possible_worlds.tex`) — that is Teammate B/C's territory per the parallel-research split. This report maps the *current* Lean 4 formalization and cross-references it against every claim in `BimodalReference.typ` and its imports, to produce a ground-truth discrepancy table.

---

## Key Findings

1. **The Typst doc's completeness/metalogic architecture describes a directory structure and theorem set that no longer exists.** `Representation/`, `FMP/`, `Completeness/` (as described), and `Algebraic/` (as a top-level sibling used in the diagrams) do not match the actual `Metalogic/` tree. The actual tree has `Core/`, `Bundle/`, `Algebraic/`, `BXCanonical/` (with `Chronicle/`, `Filtration/`, `Quasimodel/`), `WeakCanonical/` (with `Separation/`, `Kamp/`, `EFGames/`, `IntegerModel/`), `ConservativeExtension/`, `Decidability/` (with `FMP/`), plus `Soundness.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean`, `Completeness.lean`. The primary completeness theorem is **not** `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean` (that file does not exist) — it is `completeness` in `Metalogic/BXCanonical/Completeness.lean`, built on a **Burgess 1982 chronicle construction** (dense case, Rat) plus a **Reynolds/Doets discrete pipeline** (`WeakCanonical/`), with a **mixed-case elimination** lemma. This entire architecture (BXCanonical/Chronicle/WeakCanonical) postdates the Typst doc's description and is completely unmentioned in it.

2. **Completeness is NOT sorry-free.** `Metalogic/Metalogic.lean`'s own module header states plainly: `Completeness | completeness | SORRY (chronicle construction)`, and dense/discrete variants are also marked SORRY. This directly contradicts `04-metalogic.typ`'s repeated claims that "the key result `semantic_weak_completeness` demonstrates that validity implies derivability" is "the primary sorry-free completeness theorem" — that theorem name does not exist in the codebase at all. Concretely: `Metalogic/BXCanonical/Completeness.lean` has 8 sorry occurrences; `Metalogic/WeakCanonical/TruthLemma.lean` has 20; `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` has 20; `Metalogic/WeakCanonical/Transfer.lean` has 17; and more, totaling roughly 38–42 genuine `sorry` tactic occurrences outside `Boneyard/` (plus ~61 more inside explicitly-archived `Boneyard/` paths). This is far more than the Typst doc's claimed "20 sorry statements, all deprecated."

3. **The proof system is a completely different axiom system with a different formula language.** The Typst doc's Syntax chapter claims 6 primitives are `{atom, bot, imp, box, H, G}` (H/G primitive temporal operators) and the Proof Theory chapter claims **14 axiom schemata** (K, S, EFQ, Peirce, MT, M4, MB, M5, MK, TK, T4, TA, TL, MF, TF) with 7 inference rules. The actual current Lean source (`Syntax/Formula.lean`, `ProofSystem/Axioms.lean`) has:
   - **6 primitives are `{atom, bot, imp, box, untl, snce}`** (Until/Since, Burgess convention) — H, G, F, P are now all `def`-derived from `untl`/`snce`, not primitive constructors.
   - **42 axiom constructors** (not 14) under the new "Burgess-Xu (BX) axiom system" with **irreflexive/strict temporal semantics**, organized in 8 layers: Propositional (4), S5 Modal (5), BX Temporal (22, named BX1–BX13 with primed past-mirrors), Modal-Temporal Interaction (1: `modal_future`), Uniformity (5, discreteness-related), Prior (2: `prior_UZ`/`prior_SZ`), Z1 (1), Density (2). Several of the Typst doc's named axioms (`TK`/`temp_k_dist`, `T4`/`temp_4`, `TA`/`temp_a`, `TL`/`temp_l`, `TF`/`temp_future`) **no longer exist as axiom constructors at all** — they are now derived *theorems* (see `Theorems/TemporalDerived.lean`, task 116) or, in the case of TA/TL, appear to have been replaced entirely by the BX axiom set (serial_future/serial_past, connect_future/connect_past, etc.).
   - `DerivationTree` now carries a **`FrameClass` parameter** (`Base`/`Dense`/`Discrete`) controlling which axioms are admissible in a derivation — an entire structural dimension absent from the Typst doc's Proof Theory chapter.
   - The 7 inference-rule *names* (axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening) do still match current Lean source — this part of the Typst doc is accurate.

4. **The temporal semantics has flipped from what the Typst doc claims is "current."** `06-notes.typ §Design Choices` asserts "Reflexive Temporal Semantics (Current)" (G/H use ≤/≥, T-axioms `Gφ→φ`/`Hφ→φ` "definitionally valid"). But `Semantics/Truth.lean`'s module header explicitly states: **"Irreflexive Temporal Semantics (A2 Guard Convention)... G and H quantify over STRICT (< instead of ≤)... the T-axioms are NOT valid."** `Metalogic/Metalogic.lean` corroborates: "Under irreflexive semantics (task 93)... The modal T-axiom is valid... but the temporal analogs (Gφ→φ, Hφ→φ) are NOT valid." The Typst doc's own historical table in `06-notes.typ` (task 658 → reflexive, task 991 → strict, task 29 → reflexive again) is now stale by at least one more reversal (task 93 → irreflexive/strict, which is what ships today). This also means `02-semantics.typ`'s truth-condition definitions for H/G (which already use strict `<`) are consistent with the *current* code, while `06-notes.typ`'s "Design Choices" section (claiming reflexive is current) directly **contradicts** `02-semantics.typ` within the same document.

5. **Everything else largely holds up**: `Syntax/TaskFrame.lean` (Nullity/Compositionality via `nullity_identity`/`forward_comp`/`converse`), `Semantics/Truth.lean`'s treatment of atoms/bot/imp/box, and `Soundness.lean` (genuinely sorry-free, confirmed — the "sorry" hits there are only doc-comment mentions of "sorry-free") are broadly consistent with the Typst doc's semantics chapter and soundness claims, modulo the H/G-are-derived correction above. The Perpetuity chapter (`Theorems/Perpetuity/Bridge.lean`, `Principles.lean`) is also genuinely sorry-free per source comments ("zero sorry" repeated throughout), matching the Typst doc's P1–P6 claims — though the underlying axioms feeding those proofs (MF etc.) have been renamed/reorganized as noted above.

---

## Recommended Approach

Given the scope of drift (syntax primitives, axiom count/names, entire completeness architecture, temporal semantics polarity), a section-by-section patch is not sufficient for the Syntax and Proof Theory and Metalogic chapters — they require substantive rewrites, not edits:

1. **01-syntax.typ**: Rewrite the "Formulas" definition to show `{atom, bot, imp, box, untl, snce}` as primitive, and rewrite "Derived Operators" to show G/H/F/P as `def`s built from `untl`/`snce` (matching `Formula.some_future`, `Formula.some_past`, `Formula.all_future`, `Formula.all_past` in `Syntax/Formula.lean:109-155`). Keep the derived propositional/modal/temporal-combinator tables (`neg`/`and`/`or`/`diamond`/`always`/`sometimes`) — these still match Lean exactly.
2. **03-proof-theory.typ**: Full rewrite around the 42-constructor BX axiom system. Needs a new table organized by the 8 layers (Propositional/S5 Modal/BX Temporal ×2/Interaction/Uniformity/Prior/Z1/Density), the `FrameClass` (Base/Dense/Discrete) parameterization of `DerivationTree`, and updated axiom names throughout (drop TK/T4/TA/TL as axioms; note they are now derived theorems; introduce BX1–BX13 series names).
3. **02-semantics.typ**: Minor fix — confirm/keep strict `<` truth conditions for H/G (these already match current code) but reconcile with `06-notes.typ`.
4. **04-metalogic.typ**: Full rewrite of the completeness section. Replace the Representation Theorem / `semantic_weak_completeness` narrative with the actual BXCanonical (Chronicle, dense/Rat) + WeakCanonical (Reynolds/Doets, discrete/Int) + mixed-case-elimination architecture, and honestly report the current (non-trivial) sorry inventory rather than "20 sorries, all deprecated." Update the module-organization diagram/table to match the real `Metalogic/` tree.
5. **06-notes.typ**: Resolve the reflexive-vs-irreflexive contradiction by declaring irreflexive/strict as current (task 93), updating the historical table with the task-93 reversal, and correcting the Sorry Status / Implementation Status tables to reflect real counts.
6. **05-theorems.typ**: Spot-check module names against actual files — `Propositional.lean` doesn't exist as a single file (it's `Theorems/Propositional/{Connectives,Core,Reasoning}.lean`); `ContextualProofs.lean` and `TemporalDerived.lean` exist but aren't listed in the Module Organization table. The theorem statements themselves (P1–P6, S5 theorems, combinators) look consistent with Lean naming but should be spot-verified by whichever teammate owns this section, since axiom renaming upstream (MF still exists, TF is now derived) may affect a few "Key Lemmas" cells.

Given the size of the rewrite needed for chapters 03 and 04, and moderate rewrite for 01 and 06, I recommend the follow-up plan/implementation phase budget these as separate phases, each anchored to specific Lean file:line citations (provided below) rather than attempting a single pass over the whole document.

---

## Evidence / Examples

### Syntax primitives mismatch
- Typst claim: `01-syntax.typ:14-18` — "six primitive constructors": `p | bot | phi→psi | box phi | H phi | G phi`.
- Lean ground truth: `Syntax/Formula.lean:70-85` — `inductive Formula | atom | bot | imp | box | untl | snce`.
- H/G are derived: `Syntax/Formula.lean:145-155` (`all_future`, `all_past` defined via `some_future`/`some_past` which are defined via `untl`/`snce` at `Syntax/Formula.lean:125,135`).

### Axiom count/name mismatch
- Typst claim: `03-proof-theory.typ:12` — "14 axiom schemata"; table at `03-proof-theory.typ:82-109` names K/S/EFQ/Peirce/MT/M4/MB/M5/MK/TK/T4/TA/TL/MF/TF.
- Lean ground truth: `ProofSystem/Axioms.lean:37` — "Total: 42 axiom constructors"; `ProofSystem/Axioms.lean:76-399` (full `inductive Axiom` listing, layers 1–8).
- TK/T4 now derived, not axioms: `ProofSystem/Axioms.lean:38,74,111-112` ("Note: temp_k_dist and temp_4 are now derived theorems (see TemporalDerived.lean, Task 116)").
- FrameClass parameterization: `ProofSystem/Derivation.lean:85-93` (`inductive DerivationTree (fc : FrameClass) ...`, `axiom` constructor requires `h.minFrameClass ≤ fc`).

### Completeness architecture / sorry status mismatch
- Typst claim: `04-metalogic.typ:12,118-121,304-324` — primary theorem is `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean`, sorry-free; `06-notes.typ:488-489` — "20 sorry statements, all deprecated."
- Lean ground truth: `Metalogic/Metalogic.lean:16-24` — table states `Completeness | completeness | SORRY (chronicle construction)`; module structure diagram at `Metalogic/Metalogic.lean:38-56` lists `BXCanonical/`, `WeakCanonical/`, `Bundle/`, `ConservativeExtension/`, `Decidability/FMP/` — no `Representation/` or `FMP/SemanticCanonicalModel.lean`.
- Actual completeness theorem: `Metalogic/BXCanonical/Completeness.lean:1-45` (module docstring: "The completeness proof is wired through `countermodel_dense` from Chronicle/ChronicleToCountermodel.lean... Remaining leaf sorries are in the Chronicle/ modules").
- Sorry counts (verified via grep, excluding `Boneyard/`): `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (20), `Metalogic/WeakCanonical/TruthLemma.lean` (20), `Metalogic/WeakCanonical/Transfer.lean` (17), `Metalogic/BXCanonical/Completeness.lean` (8), plus `Metalogic/WeakCanonical/Kamp/*` (dozens more in the Kamp/Prior translation modules). `Metalogic/Soundness.lean` and `Theorems/Perpetuity/Bridge.lean` are confirmed genuinely sorry-free (only doc-comment mentions of "sorry-free"/"zero sorry").

### Temporal semantics polarity contradiction
- Typst claim ("current" is reflexive): `06-notes.typ:118-126` ("Reflexive Temporal Semantics (Current)... temporal T-axioms Gφ→φ and Hφ→φ are definitionally valid").
- Lean ground truth (irreflexive/strict is current): `Semantics/Truth.lean:10-17` ("Irreflexive Temporal Semantics (A2 Guard Convention)... G and H use STRICT semantics... the T-axioms are NOT valid"); `Metalogic/Metalogic.lean:9-16` ("Under irreflexive semantics (task 93)... NOT valid under irreflexive semantics").
- Internal Typst contradiction: `02-semantics.typ:85-89` already encodes strict `<` truth conditions for H/G (matching current Lean), directly conflicting with `06-notes.typ:118-126`'s claim that reflexive `≤` is current.

### Minor: Theorems/ module-table gaps
- Typst table: `05-theorems.typ:176-196` lists `Perpetuity.lean`, `ModalS5.lean`, `ModalS4.lean`, `Propositional.lean`, `Combinators.lean`, `GeneralizedNecessitation.lean`.
- Actual directory: `Theorems/Propositional/{Connectives,Core,Reasoning}.lean` (subdirectory, not a single file); also present but unlisted: `Theorems/ContextualProofs.lean`, `Theorems/TemporalDerived.lean`, `Theorems/Perpetuity/{Bridge,Helpers,Principles}.lean` (subdirectory structure, not a flat `Perpetuity.lean`).

---

## Discrepancy Table (by Typst section)

| Typst Section | Status | Notes |
|---|---|---|
| `00-introduction.typ` (Project Structure bullets) | Outdated | Understates axiom count ("14 axioms/7 rules") and directory list omits `FrameConditions/`, `Metalogic/{Core,Bundle,Algebraic,BXCanonical,WeakCanonical,ConservativeExtension,Decidability}/` substructure. |
| `01-syntax.typ` Formulas/primitives | **Outdated (major)** | Primitives should be `{atom,bot,imp,box,untl,snce}` not `{atom,bot,imp,box,H,G}`. |
| `01-syntax.typ` Derived Operators (neg/and/or/diamond/always/sometimes) | Matches | Definitions align with `Formula.neg/and/or/diamond/always/sometimes`. |
| `01-syntax.typ` Temporal Duality (`swap_temporal`) | Matches | `Formula.swap_temporal` + `swap_temporal_involution` present verbatim. |
| `02-semantics.typ` Task Frames | Matches | `TaskFrame` nullity/compositionality present (modulo internal encoding via `nullity_identity`/`forward_comp`/`converse`, worth a footnote). |
| `02-semantics.typ` Truth Conditions | Matches (strict `<`) | Consistent with current `Truth.lean`, but silently omits `untl`/`snce` truth clauses (the actual primitives) and the `Omega`-restricted box. |
| `02-semantics.typ` Time-Shift / Validity | Mostly matches | `WorldHistory.time_shift`, `ShiftClosed` present; validity/consequence definitions align with `Validity.lean`. |
| `03-proof-theory.typ` Axiom Schemata | **Outdated (major)** | 14 vs 42 constructors; several named axioms (TK/T4/TA/TL) no longer exist as axioms. Missing `FrameClass` dimension entirely. |
| `03-proof-theory.typ` Inference Rules | Matches | All 7 rule names/semantics still current. |
| `03-proof-theory.typ` Derivation Trees / Height | Matches (partially) | Correct in spirit but doesn't mention `FrameClass` parameter or `lift`. |
| `04-metalogic.typ` Soundness | Mostly matches | Soundness genuinely sorry-free; axiom-validity table references some now-derived-not-axiom names (TA/TL) that need renaming. |
| `04-metalogic.typ` Core Infrastructure (Deduction, MCS, Lindenbaum) | Likely matches | Not directly verified in this pass but these are stable, long-standing components; low risk. |
| `04-metalogic.typ` Representation Theory / Completeness | **Outdated (major)** | Entire subsection describes a deleted/renamed architecture (`Representation/`, `FMP/SemanticCanonicalModel.lean`, `semantic_weak_completeness`) that doesn't exist; actual architecture is BXCanonical/Chronicle + WeakCanonical, and completeness is NOT sorry-free. |
| `04-metalogic.typ` Decidability | Not verified this pass | Teammate should re-check `Decidability/DecisionProcedure.lean` sorry status directly; deferred due to scope. |
| `04-metalogic.typ` Sorry Status table | **Outdated (major)** | Claims 20 sorries all deprecated; actual is ~40+ active-path sorries (Chronicle, WeakCanonical/TruthLemma, Transfer, Kamp) plus ~61 in explicit Boneyard. |
| `05-theorems.typ` Perpetuity P1-P6 | Matches (sorry-free confirmed) | Axiom names feeding proofs (MF etc.) need updated cross-references per proof-theory rewrite. |
| `05-theorems.typ` Module Organization table | Minor drift | `Propositional.lean` and `Perpetuity.lean` are actually subdirectories with multiple files; `ContextualProofs.lean`/`TemporalDerived.lean` unlisted. |
| `06-notes.typ` Implementation Status | Outdated | "14 axioms, 7 inference rules" repeated; Completeness listed as "Proven (Semantic)" — should be "Proven (BX/Chronicle), sorry-bearing". |
| `06-notes.typ` Design Choices (reflexive vs irreflexive) | **Outdated (major), self-contradictory** | Declares reflexive "Current" against both the Lean source and against the doc's own `02-semantics.typ` chapter. |

---

## Confidence Level

**High** for: syntax primitives mismatch, axiom count/architecture mismatch, FrameClass dimension, completeness architecture/theorem-name mismatch, non-trivial sorry count, and the reflexive/irreflexive contradiction — all directly grounded in current file contents with line citations.

**Medium** for: exact current sorry counts (grep-based; some `sorry` occurrences in doc comments vs. actual tactic sites were manually distinguished but a full `lake build`/`lean_verify` axiom sweep would be more authoritative than grep), and for chapters/sections I did not deeply verify this pass (Decidability implementation status, Core Infrastructure/Lindenbaum, exact FrameConditions/ content, full Theorems/ theorem-count of "228").

**Not covered** (left to other teammates per parallel split): alignment against the JPL paper `possible_worlds.tex` itself; this report only established the Lean-source ground truth and its divergence from the existing Typst text.
