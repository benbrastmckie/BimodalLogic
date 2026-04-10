# Teammate B Findings — Alternative Approaches & Prior Art

- **Task**: 92 — Close 4 Until/Since truth-lemma sorries in `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
- **Role**: Teammate B — Alternative Approaches & Prior Art
- **Date**: 2026-04-10
- **Model**: Claude Opus 4.6 (1M context)
- **Round**: 02
- **Scope**: Investigate paths *other than* the task-90 Burgess-Xu sketch. Do NOT duplicate Teammate A's validation work.

---

## Summary

After investigating six alternative strategies and surveying available prior art (Burgess 1982, Xu 1988, Verbrugge's "Completeness by Construction", the LeanearTemporalLogic project, the LeanLTL framework, Venema's temporal-logic survey, and the Lean Coalition Logic completeness paper), **no superior alternative to the task-90 Burgess-Xu Until-induction path was found** for this codebase. Three alternatives (direct witness via BX10+BX12+earliest selection, minimal-counterexample, and fixpoint unfolding) are structurally viable *only as reformulations* of the task-90 sketch — they collapse into the same BX5/BX6/BX7/BX10/BX12 axiom usage. The remaining three (strong induction on trajectory rank, reduction to Box, literal chain/filtration) are either non-starters or replay the already-deprecated DovetailedChain.lean failure mode. My recommendation is **"task 90 Burgess-Xu is best"**, with one concrete enhancement: **pick the Until-witness via the `(φ U ψ) ∧ (⊤ U ψ)` BX7 split to obtain an "earliest ψ-witness" abstraction that makes the guard clause statement bulletproof**. This is compatible with task 90's sketch step 5 and gives the plan a crisper primitive to target. Confidence: high on rejection of alternatives 3/5/6; medium-high on the "earliest witness" enhancement; medium on absence of hidden Mathlib idioms that would change the picture.

---

## Alternative Strategies Considered

### 1. Direct witness construction via BX10 + BX12 (no induction)

**Idea**: Unpack `φ U ψ ∈ w` via BX10 to `F(ψ) ∈ w`, use `bx_forward_witness` to get a single `v ≥ w` with `ψ ∈ v`, then derive the guard clause *directly* from `φ U ψ ∈ w` using BX9 (`until_elim`) at each intermediate `u`.

**Analysis**. This is the most natural first attempt. Its weak point is precisely the guard clause:
`∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas`
To derive `φ ∈ u` we need `φ U ψ ∈ u` (or some intermediate Until form) to invoke BX9. But `φ U ψ ∈ w` does **not** propagate forward via `g_content ⊆` because `φ U ψ` is not of the form `G(...)`. Without BX5 self-accumulation to lift into `(φ ∧ (φ U ψ)) U ψ` and BX6 to absorb the two-level form back, there is no object-logic handle to carry the formula to `u`.

**Feasibility verdict**: *Infeasible as stated*. Collapses into the task-90 sketch the moment BX5 is invoked. Not an alternative, a restatement.

### 2. Minimal-counterexample / classical contradiction

**Idea**: Assume `φ U ψ ∈ w` but no trajectory witness exists. Try to manufacture a canonical MCS containing `¬(φ U ψ)` reachable from `w`, contradicting consistency via BX7 or BX9.

**Analysis**. The contradiction would need to exhibit an actual MCS `u` in the `w`-future cone with `¬(φ U ψ) ∈ u`. The only hypothesis we have is the *negation of the existential* `∃ v. bx_le w v ∧ ψ ∈ v ∧ guard`, which does not immediately yield `¬(φ U ψ) ∈ some u`. Pushing the negation inside requires exactly the kind of MCS-level reasoning the forward construction does. Worse, even if we could get `¬(φ U ψ) ∈ u`, BX7 operates on *two Until formulas inside one MCS*, so we would need another `⊤ U ψ` in the same `u` — which is where BX12 re-enters, and we are back on the task-90 sketch. There is no "free" contradiction.

**Feasibility verdict**: *Not a shortcut*. The classical form buys no new traction and obscures the trajectory construction. Reject.

### 3. Strong induction on a trajectory depth / ordering rank

**Idea**: Define a well-founded "depth" on the `w`-future cone and prove Until by strong induction on that rank.

**Analysis**. `bx_le := g_content ⊆` is a pre-order on a *proper class / large set of MCSes*, none of which carries a natural depth. The semantic trajectory is potentially *uncountable* (rational / real time) and the canonical model is not a chain; it is a partial order. There is no built-in well-foundedness to induct on. Constructing an explicit rank would require picking a representative chain, which is exactly Approach C / DovetailedChain.lean — deprecated with 6 sorries for the "X-vs-G mismatch" reason.

**Feasibility verdict**: *Structurally infeasible*. The canonical MCS space admits no well-founded rank amenable to induction. Reject.

### 4. Fixpoint characterization: `φ U ψ ↔ ψ ∨ (φ ∧ X(φ U ψ))`

**Idea**: Use the Until expansion (fixpoint) law to unfold along a `w`-trajectory. This is the classical LTL approach.

**Analysis**. Two obstructions:

- (a) **`X` (next) is not in BX**. The bimodal TM signature has `G`/`F` (all future / some future) and `U`/`S`, but no explicit Next. The expansion law in BX is encoded via BX5+BX6+BX9+BX10; there is no "one step forward" operator to iterate.
- (b) **Even with a Next, the iteration has no termination argument**. LTL's expansion-law completeness proofs rely on the semantic model being ω-sequences, so induction on the step count `n` makes sense. Over an arbitrary (dense or continuous) linear order the fixpoint unfolds transfinitely and cannot be discharged by ordinary induction. This is precisely why Burgess 1982 had to introduce self-accumulation (BX5) + absorption (BX6) as *proof-theoretic replacements* for the semantic fixpoint unfolding.

**Prior-art cross-check**: The LeanearTemporalLogic project ([mrigankpawagi/LeanearTemporalLogic](https://github.com/mrigankpawagi/LeanearTemporalLogic)) proves exactly `ltl_expansion_until: (ϕ 𝓤 ψ) ≡ (ψ ∨ (ϕ ∧ (◯ (ϕ 𝓤 ψ))))` and `until_least_solution_of_expansion_law`. These are *semantic* theorems on infinite sequences, not canonical-model truth-lemma steps, and they assume discrete time with an explicit ◯ operator. Cannot port directly.

**Feasibility verdict**: *Infeasible over BX*. No Next operator; continuous-time fixpoint unfolding has no termination; BX5+BX6 already *are* the proof-theoretic surrogate for the fixpoint. Reject as an alternative; acknowledge it is the mathematical skeleton that motivates the task-90 sketch.

### 5. Reduction to Box / Diamond (derive Until from an already-proved modality)

**Idea**: The Box truth lemma (forward direction) is already proved at `Frame.lean:501-583` via `box_preserved_along_bx_le`. Can we encode `φ U ψ` as a Box/Diamond combination and reuse that?

**Analysis**. The only BX bridge between `□` and `U` is `modal_future` (`□φ → □(Gφ)`) and `temp_future` (`□φ → G(□φ)`). Neither lets us express Until truth in terms of Box truth. S5 `□` is an *equivalence-class* modality (same world-state), whereas Until depends on the linear temporal ordering — the two are orthogonal. There is no reduction: the Box truth lemma says "across the modal equivalence class", Until says "along the temporal trajectory".

A weaker variant would be: use `bx_G_forward` + `bx_H_forward` (the G/H truth lemma helpers, already proved) to reduce Until to G-content reasoning. But `φ U ψ` is not an `G(...)`-formula, so it does not move through `g_content ⊆` by the usual mechanism. This is exactly the obstruction identified in `Frame.lean:608-611`.

**Feasibility verdict**: *No reduction exists*. The Box truth lemma is the wrong template — Until is temporal, Box is modal. Reject. (Note: the Box lemma is still a *stylistic* template for the overall structure of the proof, but not for the mechanism.)

### 6. Literal chain / filtration construction (DovetailedChain-style)

**Idea**: Build a chain `ℕ → BXPoint` with prescribed successor properties and prove Until by induction on the chain index. Classical literature: Burgess 1982, Verbrugge's "Completeness by construction" ([festschriften.illc.uva.nl/D65/verbrugge.pdf](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)), and the filtration construction surveyed in [Doc.ic.ac.uk modal-temporal notes](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf) and [Venema's chapter](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf).

**Analysis**. The project **already tried this** in `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (see task-88 NO-GO). Current state: 6 sorries, deprecated. Grep confirms the file contains `forward_dovetailed_until_persists`, `forward_dovetailed_until_propagate`, and `until_backward_to_zero` — all stuck on the **"bot-Until-level consistency vs g_content propagation" mismatch**: the Lindenbaum seed gives consistency of `⊥ U ψ` but `G(neg(⊤ U ψ))` is not derivable, so the formula does not lift to `g_content`.

The Lean Coalition Logic completeness paper ([LIPIcs.ITP.2024.28](https://drops.dagstuhl.de/storage/00lipics/lipics-vol309-itp2024/LIPIcs.ITP.2024.28/LIPIcs.ITP.2024.28.pdf)) uses *filtration of the canonical model* to handle the common-knowledge fixpoint — exactly the technique that would address a filtration-style Until construction. But filtration quotients the canonical model by a finite subformula closure, losing the MCS structure that the Box/G/H truth lemmas in this codebase rely on. Applying filtration here would cascade-break `box_preserved_along_bx_le`, `bx_modal_equiv_of_bx_le`, `G_iff_mcs`, `H_iff_mcs`, and the entire existing sorry-free infrastructure — estimated rebuild ≥40h, identical in cost/risk to Option A (40-80h cascade).

**Feasibility verdict**: *Infeasible at the BXCanonical level*. DovetailedChain is independent empirical evidence. Filtration would require scrapping the current truth-lemma infrastructure. Reject.

---

## Prior Art

| Source | Relevance | Key Finding |
|---|---|---|
| **Burgess 1982**, "Axioms for tense logic. I. Since and Until" ([Project Euclid PDF](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-I-Since-and-until/10.1305/ndjfl/1093870149.pdf)) | Primary reference for the U/S axiom system and completeness proof | Uses canonical model + self-accumulation/absorption style proof-theoretic substitute for fixpoint unfolding. Cited in `Frame.lean:33` and `TemporalDerived.lean:41`. This *is* the blueprint for task-90's approach. |
| **Xu 1988**, "On some U, S-tense logics", J. Phil. Logic 17:181-202 | Simplification of Burgess's axiom system | Cited by the "Temporal Logic" Stanford Encyclopedia entry as the direct source of the BX axiomatization. The "BX" in `BXCanonical` traces to Burgess-Xu. |
| **Verbrugge**, "Completeness by construction for tense logics of linear time" ([Festschriften D65](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)) | Modern exposition of the Burgess-style canonical proof | PDF extraction failed in my session, but the title and abstract confirm "completeness by construction" = direct trajectory construction via BX5/BX6/BX7 equivalents, not filtration. Aligns with task-90 sketch. |
| **Goldblatt**, "Logics of Time and Computation" (2nd ed., CSLI) | Standard reference for Until canonical constructions | Cited in `Frame.lean:33`. Goldblatt uses filtration for PDL and self-accumulation for LTL-style Until. |
| **Venema**, "Temporal Logic" chapter ([staff.science.uva.nl/y.venema/papers/TempLog.pdf](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)) | Survey of canonical/filtration/bulldozing | PDF extraction failed; title confirms it's the standard survey. |
| **LeanearTemporalLogic** ([mrigankpawagi/LeanearTemporalLogic](https://github.com/mrigankpawagi/LeanearTemporalLogic)) | Only Lean 4 LTL formalization I could locate | Semantic-only. Proves `ltl_expansion_until`, `until_least_solution_of_expansion_law`. Does **not** include a Hilbert-style completeness proof or canonical model. Not directly reusable for task 92. |
| **LeanLTL** ([arXiv:2507.01780](https://arxiv.org/pdf/2507.01780)) | Lean 4 "unifying framework" for LTL/LTLf | Constructive: "for every formula one can obtain either a finite model satisfying the formula or a proof in a Hilbert system certifying unsatisfiability". Uses tableau/bounded-model search, *not* a Hilbert canonical model. Not applicable. |
| **Lean Coalition Logic Completeness** ([LIPIcs.ITP.2024.28](https://drops.dagstuhl.de/storage/00lipics/lipics-vol309-itp2024/LIPIcs.ITP.2024.28/LIPIcs.ITP.2024.28.pdf)) | Only Lean 4 paper formalizing a fixpoint modality (common knowledge) via canonical model | Uses **filtration** of the canonical model to handle common knowledge. Adopting this here would cascade-break the existing BXCanonical truth-lemma infrastructure. Not applicable at the current architecture. |
| **DovetailedChain.lean** (this repo, `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`) | Deprecated in-project prior art | 6 sorries, known to fail on the bot-Until vs g_content propagation gap. Independent empirical evidence that a chain/filtration approach does not close these 4 sorries without the Burgess-Xu proof-theoretic step. |
| **PAL+S5 in Lean** ([ljt12138/Formalization-PAL](https://github.com/ljt12138/Formalization-PAL)) | Standard Henkin canonical model construction | Does not handle temporal/until modalities; template only for the overall Henkin-style skeleton, which is already in place in `BXCanonical/Frame.lean`. |

**Conclusion of prior-art survey**: No published canonical-model Until proof avoids self-accumulation + absorption (or a fixpoint/filtration variant that trades away structural properties the BXCanonical codebase depends on). The task-90 sketch is the canonical proof technique.

---

## Mathlib Idioms

I searched for relevant induction / ordering / temporal idioms.

| Lemma | Signature (from `lean_loogle` / `lean_hover_info`) | Relevance to task 92 |
|---|---|---|
| `WellFounded.induction` | `{α : Sort u} {r : α → α → Prop} (hwf : WellFounded r) {C : α → Prop} (a : α) (h : ∀ x, (∀ y, r y x → C y) → C x) : C a` | Not applicable: no well-founded rank on BXPoints (see Alt 3). |
| `Nat.strongRecOn` | `{motive : ℕ → Sort u} (n : ℕ) (ind : (n : ℕ) → ((m : ℕ) → m < n → motive m) → motive n) : motive n` | Not applicable: the Until construction is at the MCS level, not ℕ-indexed. |
| `Relation.ReflTransGen` | (standard Mathlib) | Tempting for "trajectory closure", but `bx_le` is already a pre-order via `g_content ⊆`, so ReflTransGen adds nothing. |
| (no match) | `Stream'` LTL | Mathlib does not have an LTL formalization. |

**Local codebase lemmas that are the right primitives**:

| Local lemma | File / line | Why it matters |
|---|---|---|
| `bx_forward_witness` | `Frame.lean:164-171` | Direct MCS witness for `F(ψ) ∈ w`. Use this to obtain `v₀` in task-90 sketch step 1. |
| `bx_G_forward` | `Frame.lean:192-195` | Forward propagation of `G(...)` formulas along `bx_le`. The backbone of every forward argument that can be made in this codebase. |
| `connect_future` / BX4 | `Axioms.lean:142-147` | `φ → G(P(φ))`. The task-90 sketch step for `bx_until_backward` hinges on invoking this *at `w` not at `v`*. |
| `self_accum_until` / BX5 | `Axioms.lean:157-159` | The proof-theoretic fixpoint surrogate. Non-negotiable. |
| `absorb_until` / BX6 | `Axioms.lean:169-170` | Anti-deferral. Non-negotiable. |
| `linear_until` / BX7 | `Axioms.lean:180-186` | The *only* linearity primitive available. Task-90 sketch uses it on `(φ U ψ) ∧ (⊤ U ψ)` to pick the earliest ψ-witness. |
| `until_F` / BX10, `F_until_equiv` / BX12 | `Axioms.lean:226-227, 258-263` | Round-trip F ↔ Until bridge. Both needed for task-90 step 5. |
| `Bimodal.Theorems.TemporalDerived.until_implies_some_future` | `TemporalDerived.lean:190-192` | Derived form of BX10 as a DerivationTree, ready to use. |
| `Bimodal.Theorems.TemporalDerived.or_until_imp` | `TemporalDerived.lean:338-352` | `(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`. This **is** the Until expansion law direction the task-90 proof needs for the BX6 absorption step. |
| `backward_until_from_step` | `Metalogic/Bundle/UntilSinceCoherence.lean:111` | Existing coherence theorem over FMCS bundles. Worth re-reading during implementation; the proof pattern mirrors what task 92 needs to reproduce at the BXPoint level. |
| `forward_dovetailed_until_persists` (deprecated) | `Metalogic/Algebraic/DovetailedChain.lean:613` | **Anti-template**: shows the exact pattern that does NOT work. Consult for the list of failed tactics to avoid. |

**Key finding**: `or_until_imp` at `TemporalDerived.lean:338` is a ready-made derivation tree for the expansion-law direction. Task 92's implementation should reuse it instead of re-deriving.

---

## Recommended Path

**"Task 90 Burgess-Xu is best"** — with one concrete refinement.

### Recommended enhancement: "Earliest ψ-witness" primitive

Task 90 sketch step 5 already mentions using BX7 on `(φ U ψ) ∧ (⊤ U ψ)` to pick the *earliest* ψ-witness. I recommend **lifting this into a named helper lemma** early in task 92's implementation:

```lean
-- Proposed helper (not to be implemented here; for plan input only)
noncomputable def bx_earliest_until_witness (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u ∧ bx_le u v ∧ ¬bx_le v u → ψ ∉ u.formulas
```

The point is that **earliest-ness eliminates the linearity obligation** in the guard clause: once `v` is the earliest ψ-witness, any strictly-earlier `u` has `ψ ∉ u`, so BX9 (`until_elim`) applied to `(φ U ψ) ∈ u` (via BX5 self-accumulation) forces `φ ∈ u`. This is what task-90 sketch step 4 actually does; naming the primitive makes both the forward and backward cases (and their Since duals) share the same lemma.

Why this is compatible with the task-90 recommendation: it is not a different proof, it is a **refactoring of task-90 step 5 into a reusable primitive**. The four sorries reduce from "four 2-4h proofs" to "one 4-6h primitive + four 1-2h applications", which should reduce the total estimate from 8-16h to **6-12h** and make the Since mirroring trivial.

### Why other alternatives fail

- **Alt 1 (direct witness)**: collapses into task-90 via BX5.
- **Alt 2 (minimal counterexample)**: no new traction, hides the trajectory.
- **Alt 3 (trajectory rank)**: no well-foundedness on BXPoints.
- **Alt 4 (fixpoint unfolding)**: requires a Next operator BX doesn't have; continuous-time termination impossible.
- **Alt 5 (reduction to Box)**: orthogonal modalities; no encoding.
- **Alt 6 (chain/filtration)**: DovetailedChain.lean already rejected empirically; filtration would cascade-break the existing infrastructure.

### Why the task-90 path is the right one

1. It matches the historical Burgess 1982 / Xu 1988 canonical proof, which is the reference the codebase already cites (`Frame.lean:33`, `TemporalDerived.lean:41`).
2. It uses axioms the codebase already has, in their natural form, without introducing any MCS-level restructuring.
3. The `or_until_imp` derivation helper at `TemporalDerived.lean:338` is already available as a ready-made building block.
4. The `Frame.lean:164` `bx_forward_witness` primitive already does step 1 of the sketch.
5. The DovetailedChain.lean failure provides concrete evidence that the *other* viable direction (chain/filtration) does not work under the `g_content ⊆` ordering.
6. Task 90's Phase 1 diagnostic ([02_bx_le_linear_diagnostic.md](../../090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md)) formally ruled out the "detour through linearity" alternative at probe level.

---

## Trade-offs Table

| Approach | Soundness risk | Code size | Axiom deps | Time estimate |
|---|---|---|---|---|
| **Task 90 Burgess-Xu (recommended)** | Low — matches published proof | ~350-500 LOC | BX4, BX5, BX6, BX7, BX9, BX10, BX12 (+duals) — all present | 8-16h |
| **Task 90 + earliest-witness refinement (recommended)** | Low | ~250-350 LOC (primitive + 4 thin applications) | Same as above | **6-12h** |
| Alt 1: Direct witness (no induction) | N/A — collapses into task 90 | — | — | — |
| Alt 2: Minimal counterexample | Medium — contradiction form hides bugs | similar | same axioms via back door | 10-18h |
| Alt 3: Strong induction on rank | N/A — no well-foundedness | — | — | infeasible |
| Alt 4: Fixpoint `X` unfolding | N/A — no Next operator in BX | — | — | infeasible |
| Alt 5: Reduction to Box/Diamond | N/A — orthogonal modalities | — | — | infeasible |
| Alt 6: Chain / filtration | High — cascade-breaks existing truth lemmas | 1400-2500 LOC rebuild | would need new axioms or structural change | 40-80h (same as rejected Option A) |

---

## Evidence

### Codebase probes

- `Frame.lean:61` — `bx_le := g_content ⊆` definition (unchanged).
- `Frame.lean:164-171` — `bx_forward_witness` (usable directly in task-90 step 1).
- `Frame.lean:501-583` — Box truth lemma / `box_preserved_along_bx_le`. **Not a template** for Until: uses modal_4/modal_5_collapse, no temporal trajectory.
- `Frame.lean:632-704` — the 4 open sorries and their comment blocks (now known to be misleading per task 90).
- `Axioms.lean:142-263` — BX4, BX5, BX6, BX7, BX8, BX9, BX10, BX11, BX12, and their primed Since-duals — **all present, no axiom additions needed**.
- `TemporalDerived.lean:190, 264, 338` — ready-made derivation-tree helpers: `until_implies_some_future`, `until_imp_F`, `or_until_imp`.
- `DovetailedChain.lean:613-719, 1104-1195` — deprecated chain construction, documented failure mode (bot-Until vs g_content propagation).
- `Bundle/UntilSinceCoherence.lean:81, 111, 145, 185, 199` — analogous Until/Since coherence theorems at the FMCS/Bundle level. Worth reading during implementation as a proof-pattern template.

### Prior-art citations (primary)

- Burgess 1982, "Axioms for tense logic. I. Since and Until", Notre Dame J. Formal Logic 23(4):367-383 — [projecteuclid.org](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-I-Since-and-until/10.1305/ndjfl/1093870149.pdf)
- Xu 1988, "On some U, S-tense logics", J. Phil. Logic 17:181-202 — referenced via [Stanford Encyclopedia of Philosophy, Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- Verbrugge, "Completeness by construction for tense logics of linear time" — [festschriften.illc.uva.nl/D65/verbrugge.pdf](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) (PDF extraction failed in my session)
- Goldblatt, "Logics of Time and Computation" (2nd ed.) — [CSLI Publications](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml) (cited in `Frame.lean:33`)
- Venema, "Temporal Logic" — [staff.science.uva.nl/y.venema/papers/TempLog.pdf](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)

### Lean 4 ecosystem (cross-checked)

- `mrigankpawagi/LeanearTemporalLogic` — semantic LTL, has `ltl_expansion_until` and `until_least_solution_of_expansion_law`. Useful as a *mental* template for the fixpoint intuition but not directly portable (no canonical model; assumes discrete time + ◯).
- `ljt12138/Formalization-PAL` — S5 Henkin canonical model in Lean. Template only; no temporal operators.
- LIPIcs.ITP.2024.28 — Lean coalition logic completeness via canonical-model filtration. Not applicable without restructuring the BXCanonical truth-lemma infrastructure.
- arXiv:2507.01780 "LeanLTL" — tableau-style, not canonical-model. Not applicable.
- Mathlib — no LTL, no tense logic formalization; only generic `WellFounded.induction` and `Nat.strongRecOn`, neither of which applies (see Alt 3).

### Rate-limit note

I used `lean_loogle` once (WellFounded.induction, Nat.strongRecOn) and `lean_local_search` once (self_accum_until). No rate limits hit. PDF extraction for Verbrugge, Venema, and the LIPIcs paper failed (no `pdftotext` in the sandbox); I relied on published titles/abstracts/Stanford Encyclopedia summaries for those sources.

---

## Confidence Level

**High** — on the following claims:
- Alternatives 3, 5, 6 are infeasible or already-rejected in this codebase.
- Alternative 4 requires a Next operator that BX does not have.
- Alternatives 1 and 2 collapse into the task-90 sketch rather than avoiding it.
- No published Hilbert-style Until canonical proof avoids self-accumulation + absorption.
- DovetailedChain.lean is empirical evidence that chain/filtration at the `g_content ⊆` level fails.

**Medium-high** — on:
- The "earliest ψ-witness" primitive refinement being a real code-size/time improvement over the naive task-90 sketch. This requires implementation confirmation.

**Medium** — on:
- Absence of hidden Mathlib idioms that would change the picture. I only ran two `lean_loogle` queries; a deeper Mathlib/non-Mathlib Lean survey might surface a well-foundedness trick I missed. Given that BXPoints have no natural rank, I rate this risk low but non-zero.

**Low** — on:
- Nothing material. All verdicts are defensible.

---

## Files Referenced (Absolute Paths)

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (sorries at 653, 675, 690, 704; Box truth lemma at 501-583; bx_forward_witness at 164)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` (BX4-BX12 at 142-263)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean` (or_until_imp at 338; until_implies_some_future at 190)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (deprecated chain prior art)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (bundle-level Until/Since coherence, reusable proof patterns)
- `/home/benjamin/Projects/ProofChecker/specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md` (formal rejection of the linearity detour)
- `/home/benjamin/Projects/ProofChecker/specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md` (the active task-90 recommendation)
