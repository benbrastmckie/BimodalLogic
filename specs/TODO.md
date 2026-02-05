---
next_project_number: 866
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: 2026-02-04T22:16:26Z
task_counts:
  active: 6
  completed: 404
  in_progress: 1
  not_started: 4
  abandoned: 29
  total: 433
technical_debt:
  sorry_count: 90
  axiom_count: 20
  build_errors: 1
  status: good
---

# TODO

## Tasks

### 865. Construct canonical task frame for Bimodal completeness
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Created**: 2026-02-05
- **Researched**: 2026-02-05
- **Research**: [research-001.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-001.md), [research-002.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-002.md), [research-003.md](specs/865_canonical_task_frame_bimodal_completeness/reports/research-003.md)

**Description**: Research and construct a canonical task frame (world-states, task relation, durations) for the Bimodal logic representation theorem. Define a two-place task relation w ⇒ u where: (1) φ ∈ u whenever □G φ ∈ w; (2) φ ∈ w whenever □H φ ∈ u; with witness conditions (GW) and (HW). World histories are functions τ from a totally ordered commutative group of durations to MCSs respecting the task relation. Key challenges: constructing durations from syntax, building a proper three-place task relation matching the semantics, and possibly using the two-place task relation to construct a topology (closeness via possible nearness in time) with durations abstracted as equivalence classes. The construction should culminate in a seed built from a consistent sentence of arbitrary complexity, with the canonical model satisfying the TruthLemma as the guiding North Star.

### 864. Implement recursive seed construction for Henkin model completeness
- **Effort**: 30-44 hours
- **Status**: [PLANNED]
- **Language**: lean
- **Created**: 2026-02-05
- **Researched**: 2026-02-05
- **Research**: [research-001.md](specs/864_recursive_seed_henkin_model/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/864_recursive_seed_henkin_model/plans/implementation-001.md)

**Description**: Improving on task 843 and the various attempts tried there, develop a new strategy which proceeds by taking a consistent formula and using its recursive structure to define a seed which consists of a bundle of indexed families of MCSs. The idea is to start with a singleton CS indexed at 0 for the consistent sentence we start with. If the main operator is a Box, then every CS must include its argument. If the main operator is a negated Box, then some indexed family must have a CS indexed by the present time that includes the negation of its argument. If the main operator is H, then every CS indexed by a present and past time in the family must include the argument. If the main operator is a negated H, then some CS indexed by the present or past time in the family must include the negation of the argument. Similarly for G, but for the future. Negated modal operators require new indexed families to be created, and negated tense operators require new CSs at new indexes to be created. Boolean operators unpack in the usual way. This returns some indexed families with some CSs based on the logical form of the initial sentence. This is then completed to provide an appropriate Henkin model.

### 863. Improve Introduction LaTeX formatting and content
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Language**: latex
- **Created**: 2026-02-04
- **Researched**: 2026-02-04
- **Planned**: 2026-02-04
- **Completed**: 2026-02-04
- **Summary**: [implementation-summary-20260204.md](specs/863_improve_introduction_latex_formatting_content/summaries/implementation-summary-20260204.md)
- **Source**: Theories/Logos/latex/subfiles/01-Introduction.tex (4 FIX: tags)
- **Research**: [research-001.md](specs/863_improve_introduction_latex_formatting_content/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/863_improve_introduction_latex_formatting_content/plans/implementation-001.md)

**Description**: Improve LaTeX content and formatting in 01-Introduction.tex: (1) line 21: Introduce Logos paradigm (modular extensible logic system) before architecture details, explain layers (proof theory, recursive semantics, metalogic), describe dual RL signal (LEAN 4 theorems, Z3 counterexamples); (2) line 27: Add interpreted reasoning explanation from interpreted_reasoning.md; (3) line 113: Make \Cref references appear in italics; (4) line 424: Fix description list formatting (justified blocks without indents)

---

### 843. Remove singleFamily_modal_backward_axiom after Zorn lemma is proven
- **Effort**: 30-40 hours (revised v005)
- **Status**: [IMPLEMENTING]
- **Language**: lean
- **Created**: 2026-02-03
- **Updated**: 2026-02-04
- **Researched**: 2026-02-04
- **Planned**: 2026-02-04
- **Depends**: Task 856
- **Related**: Task 856, Task 857
- **Research**: [research-001.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-001.md), [research-002.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-002.md), [research-003.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-003.md), [research-004.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-004.md), [research-005.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-005.md), [research-006.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-006.md), [research-007.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-007.md), [research-008.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-008.md), [research-009.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-009.md), [research-010.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-010.md), [research-011.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-011.md), [research-012.md](specs/843_remove_singleFamily_modal_backward_axiom/reports/research-012.md)
- **Plan**: [implementation-005.md](specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-005.md)

**Description**: Make Bimodal/Metalogic/ axiom-free and sorry-free for publication-ready completeness. Eliminate 2 completeness-chain axioms (singleFamily_modal_backward_axiom, temporally_saturated_mcs_exists) via temporal Lindenbaum construction and multi-family saturated BMCS. Delete 4 legacy eval_bmcs_truth_lemma sorries.

---

### 793. Fix Claude Code neovim sidebar black screen delay
- **Effort**: S
- **Status**: [RESEARCHED]
- **Language**: general
- **Created**: 2026-02-01
- **Researched**: 2026-02-01
- **Research**: [research-001.md](specs/793_fix_claude_code_neovim_sidebar_black_screen/reports/research-001.md)

**Description**: Investigate and fix issue where running a command in Claude Code sidebar in neovim causes an initial black screen (all text disappears) for approximately 30 seconds before showing activity. Functionality works correctly otherwise. Issue started recently. Root cause may be in hook system or external. Research online and review hook configuration to identify simple and elegant fix.

---

### 394. Research and port causal semantics from paper
- **Effort**: 4-6 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Parent**: Task 381
- **Subtasks**: 398, 399
- **Research**: [research-001.md](specs/394_research_port_causal_semantics_from_paper/reports/research-001.md), [research-002.md](specs/394_research_port_causal_semantics_from_paper/reports/research-002.md)

**Description**: Research and port the correct causal operator semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md first, then to Lean. The causal operator is primitive (like the counterfactual conditional) and requires careful adaptation to the more sophisticated theory of time in Logos.

---

### 398. Port causal semantics to recursive-semantics.md
- **Effort**: 3-4 hours
- **Status**: [PLANNED]
- **Language**: markdown
- **Parent**: Task 394
- **Research**: [research-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/reports/research-001.md)
- **Plan**: [implementation-001.md](specs/398_port_causal_semantics_to_recursive_semantics_md/plans/implementation-001.md)

**Description**: Port the causal semantics from /home/benjamin/Projects/Philosophy/Papers/HypCausation/sn-article.tex (line 626) to recursive-semantics.md. Adapt the 2-place task relation from the paper to the more sophisticated 3-place task relation (with duration) in Logos. Carefully study the counterfactual semantics already included in the recursive-semantics.md in order to adapt existing resources rather than positing additional resources in order to construct the three-condition truth clause for causation.

---

### 399. Implement causal semantics in Lean
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Language**: lean
- **Parent**: Task 394
- **Dependencies**: 398

**Description**: Implement the causal operator semantics in Lean based on the approved recursive-semantics.md specification. Extend CoreFrame with closeness ordering, define Evolution and ExpectedEvolution structures, implement CausalContext with background assumptions, and replace the current counterfactual-based definition in Truth.lean with the three-condition hyperintensional semantics.

---

### 685. Derive world-history and Barcan theorems
- **Effort**: 8-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean
 **Created**: 2026-01-26
 **Source**: Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (2 grouped TODO items)
 **Research**: [research-001.md](specs/685_derive_world_history_and_barcan_theorems/reports/research-001.md)

**Description**: Derive and prove 2 theorem groups in Logos Dynamics system based on TODO items: (1) line 200: Derive as theorem that every time in a world-history gets mapped to a world-state, then include remark discussing which constraints (from Containment subsection of counterfactual_worlds.tex line 1822) play a role in proving this theorem without assuming discreteness. Articulate theorem in Lean source with proof strategy in comments; (2) line 288: Derive Barcan formulas and prove their validity for the unrestricted quantifier and 'all possibly actual' quantifier. Similarly, show that the 'all sometimes actual' quantifier validates temporal analogs of Barcan formulas.

---


