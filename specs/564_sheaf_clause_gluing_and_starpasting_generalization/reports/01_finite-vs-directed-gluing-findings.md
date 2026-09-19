# Research Report: Task #564 (findings carried over from the stability-completeness research)

- **Task**: 564 - Sheaf clause gluing and `paste` generalization
- **Started**: 2026-09-19T00:30:00Z
- **Completed**: 2026-09-19T01:00:00Z
- **Effort**: 0.5 hours (transfer of existing findings; no new proofs)
- **Dependencies**: None (task 563 remains this task's implementation dependency)
- **Sources/Inputs**:
  - `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, `app:gluing` and its footnote (restored; near line 3069)
  - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/02_review-base-incompleteness.md` (mechanism), `03_axiomatizability-rules-engine.md` §1.2 and §2.1, `04_semantics-first-task-frames.md` §4.1
  - `specs/559_.../probes/03_morphisms-clock-rule-lc-schema.lean` (`omega_limit`, `omega_chain`)
  - `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` (`pasteFun`, `paste_rel_le_lt`, `paste`), `FormalSystem/Semantics/Extension/Extension.lean` (`extension`)
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

This is an advisory note written from the main session, not a full research round. It does not
change this task's status or its deliverables.

## Executive Summary

- **The two-piece gluing this task proves is exactly what the axioms PS and US of TM⁺ express.**
  `paste` is their soundness lemma. Generalizing `paste` off totality, as this task requires, keeps
  that role intact provided the total-history instance is recovered as a corollary.
- **Directed (infinite) gluing is a different principle, and it is where TM⁺ is incomplete.** The
  manuscript's footnote to `app:gluing` already says the upward-directed case "rests on Saturation
  rather than on composition alone", with the `D = ℚ` counterexample. The completeness research
  found the logical counterpart: limit-closure formulas are valid because of directed gluing and
  are not derivable from PS and US.
- **The dependence on Saturation is class-sensitive.** Over integer time, directed gluing of splices
  needs only dependent choice (`omega_limit`, compiled in a probe); report 03 §1.2 argues on paper
  that Saturation makes no difference to ZTime validity. Over Base, Dense and RTime it goes through
  Zorn plus `extension`.
- **Consequence for this task's docstring.** The instruction "record which dictionary clauses are
  choice-free; Sheaf is" is correct for the finite (two-section, hence finite-cover) clause only.
  Say so explicitly, and name the directed case as the one that is not.

## Context & Scope

Research on a complete proof system for the stability modal `⊡` isolated the gap between finite and
directed gluing as the mechanism of incompleteness. This task owns the library's gluing lemma, so
the boundary belongs in its module docstring. Nothing here asks the task to prove the directed case.

## Findings

### 1. Finite gluing = PS/US

- `PlusPasting.lean`: if total histories `ρ`, `σ` share a state at `t`, then `ρ|(-∞,t] ⌢ σ|(t,∞)` is
  a total history (`paste`, via `paste_rel_le_lt`). `paste'_plusValid` and the US arm are the
  validities built on it.
- This task's interval-site step is the same argument (the task description says so). One proof,
  two instances: interval sections and total histories.

### 2. Directed gluing = limit closure

- Report 02 (mechanism): Saturation yields the Extension Theorem, which makes an ω- or transfinite
  limit of splices extend to a world history; PS and US axiomatize only finite splices.
- The formulas: `LC⁺` at ZTime and `BLC` at Base (reports 01-02), and the schema `LC_n` (report 03
  §2.2). Each is valid on the all-histories semantics and refuted on a paste-closed coarsened model,
  so none follows from PS and US.
- Report 04 §4.1 (paper): a paste- and translation-closed set of histories `H` induces a frame
  whose all-histories set is the closure of `H` in the product topology; "PS and US say
  paste-closed, MF says translation-closed, and nothing says closed". Finite restrictions of a
  limit are realised by pasting finitely many witnesses, which is this task's lemma iterated.

### 3. Where choice and Saturation enter

| Gluing | Principle used | Evidence |
|---|---|---|
| two sections at a seam | Compositionality only, choice-free | this task; `glue_seam` in the 553 probe |
| ω-chain of splices, integer time | dependent choice, no Saturation | `omega_limit`, `omega_chain` (probe 03, compiled in a ℤ mirror) |
| upward-directed family, general `D` | Zorn + `extension` (Saturation) | manuscript footnote to `app:gluing`; `Extension.lean` |

- The middle row is NOT a statement about the live `WorldHistory`; it is compiled against a mirror
  in which histories are bi-infinite walks of a digraph.

## Decisions

- None taken on the task's behalf.

## Recommendations

1. In the new module docstring, state the scope of the Sheaf clause as *finite* gluing and add one
   sentence in durable terms: directed gluing rests on Saturation through the Extension Theorem
   (cite `app:gluing`'s footnote and `Semantics/Extension/Extension.lean`), and is not
   choice-free.
2. When generalizing `paste` off its totality hypothesis, keep `paste` for total histories as a
   named corollary with its current signature: `PlusPasting`'s validity proofs, and the planned
   incompleteness theorem (task 560), consume that signature.
3. Optional, only if it falls out: an `n`-fold gluing corollary (finitely many sections along a
   finite chain of seams). The closure argument of report 04 §4.1 and any future directed-gluing
   lemma would both use it. Do not add phases for it.

## Risks & Mitigations

- **Risk**: the docstring overstates by citing probe results as library facts. **Mitigation**: cite
  only the manuscript footnote and `Extension.lean`; the probe rows above are background.

## Appendix

- `app:gluing` footnote, quotable phrase: "Gluing along an upward directed family of domains rests
  on Saturation rather than on composition alone".
