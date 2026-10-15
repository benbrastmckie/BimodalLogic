# Research Report: Task #798

**Task**: 798 - Port the eleven unported modal-temporal interaction principles Pthm:11 -- Pthm:22 from the paper's companion cut file, together with the duality lemma P8 that two of their proofs consume.
**Started**: 2026-10-15T09:20:00Z
**Completed**: 2026-10-15T09:40:22Z
**Effort**: moderate -- one plan round, one implementation phase plus an aggregator phase
**Dependencies**: None (no `depends_on` edge; see Risks for the aggregator-contention note)
**Sources/Inputs**:
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`, `\subsection*{Twelve further interaction principles}` (lines 883--1060)
- Codebase: `FormalSystem/Theorems/` (Perpetuity cluster, TemporalDerived, ModalS5, Combinators), `FormalSystem/Syntax/Formula.lean`, `FormalSystem/ProofSystem/Axioms.lean`
- lean-lsp MCP (`lean_run_code` against the live built environment; index state `reachable`)
- `scripts/check-module-invariants.sh`, `docs/development/REFERENCE_NORMAL_FORM.md`, `references.bib`
**Artifacts**:
- `specs/798_modal_temporal_interaction_principles/reports/01_modal-temporal-interaction-principles.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All thirteen target declarations were elaborated end-to-end and compile, zero sorry.** A single
  `lean_run_code` probe against the live built environment returned `success: true` with one
  cosmetic `longLine` warning. The eleven Pthm principles, the P8 pair, and two reusable helpers
  (`boxToAlwaysBox`, a general TR mirror of TF) all have verified proof terms, reproduced verbatim
  in the Appendix. Implementation starts from working code, not sketches.
- **Recommended siting: a new module `FormalSystem/Theorems/Interaction.lean`** importing
  `Perpetuity`, `ModalS5` and `TemporalDerived`. This is the only placement that makes all three
  of `ModalS5.iff`, `TemporalDerived.presentToSometimes` and the Perpetuity P1--P6 stock
  simultaneously available, because `ModalS5` imports `Perpetuity` (so `iff` is strictly
  downstream of the Perpetuity cluster) and `TemporalDerived` is a sibling of it, not an ancestor.
  The exact import triple is the one the successful probe used.
- **Two sorry-free path blockers were investigated and neither exists.** No principle needs the
  paper's disjunctive reading of `sometimes`; every paper proof step has a Lean counterpart; and
  no new axiom is required. Zero-debt completion is achievable in one implementation phase.
- **Two gaps in the task description must not be propagated.** (a) DELIVER item (4) attributes
  Pthm:18 to Pthm:15 and Pthm:14, but the cut file proves Pthm:18 *directly*; the 15+14 route is
  the cut file's header redundancy note. (b) P8 cannot "follow the proof shape" of
  `temporalDualityNeg`/`temporalDualityNegRev`: under this tree's definition of `sometimes` it is
  definitionally double negation.
- **"Rewrite lemmas" has no consumer in this tree, and the five biconditionals cannot become
  one.** `Automation/Normalization.lean` holds `rfl`-level `Formula` identities; the Pthm
  biconditionals are *derivability* facts (`⊢[fc] iff A B`), not definitional equalities. The only
  real automation surface is the `@[tmLemma]` label attribute -- and `perpetuity1`--`perpetuity6`
  are deliberately untagged, so the new principles should be too.
- **One gated chore the plan must schedule**: a new module makes the generated inventory block in
  `FormalSystem/Theorems/README.md` stale, and the INV check fails on a stale block. Run
  `bash scripts/check-module-invariants.sh --emit-inventory`.

## Context & Scope

Researched: whether the eleven principles and P8 are genuinely absent; what their derivations look
like in *this* tree's encoding rather than the paper's; where to site them; whether any consumer
can use the five collapsing biconditionals; and which repository gates the addition touches.

Constraints honoured: zero-debt (no sorry, no new axiom, no vacuous definition); literature
fidelity to the cut file's derivations; `## References` in the normal form of
`docs/development/REFERENCE_NORMAL_FORM.md`. No source file was modified during research.

Evidence tier: the lean-lsp server was reachable and `lean_run_code` elaborated against the
project's existing `.olean` cache (fresh; `git status` shows no modified `.lean` files). Absence
claims below rest on repo-wide `grep` over `FormalSystem/`, not on an LSP index whose state could
be `warming`.

## Literature Proof Structure

**Source**: `appendix_cut_material.tex`, `\subsection*{Twelve further interaction principles}`
(cut from after `cor:tm-decidability`; restored by reverting commit `57dc354e` in the paper
repository). Twelve Hilbert-style theorems `Pthm:11`--`Pthm:22` over an arbitrary frame class,
each with a complete derivation.

**Strategy**: direct Hilbert derivation from the TM axioms and the earlier perpetuity principles
P1--P8, with four items derived from siblings inside the block rather than from the axioms.

### Step Map

| Label | Statement | Cut-file derivation (verbatim premises) |
|---|---|---|
| Pthm:11 | `▽◇φ → ◇φ` | TF at `¬φ`, then TR applied to TF, then contraposition; case split on the three disjuncts of `sometimes` |
| Pthm:12 | `△◇φ → ◇φ` | conjunction elimination on `always` |
| Pthm:13 | `▽□φ ↔ □φ` | fwd: P6 then MN+MK on `△φ → φ`. rev: disjunction introduction on `sometimes` |
| Pthm:14 | `△□φ ↔ □φ` | fwd: conjunction elimination. rev: identity, TF, TR-applied-to-TF |
| Pthm:15 | `□△φ ↔ △□φ` | fwd: MN+MK then Pthm:14-rev. rev: Pthm:14-fwd then P3 |
| Pthm:16 | `◇▽φ ↔ ▽◇φ` | P8, MN+MK, Pthm:15 at `¬φ`, P7 at `□¬φ`, transitivity of biconditionals |
| Pthm:17 | `◇▽φ → ◇φ` | "immediately from Pthm:11 and Pthm:16" |
| Pthm:18 | `□△φ ↔ □φ` | fwd: MN+MK. rev: P1, MN+MK, then MT+M5+MK for `□φ → □□φ` |
| Pthm:19 | `◇△φ → ◇φ` | contraposition, MN+MK, contraposition |
| Pthm:20 | `◇φ ↔ ◇▽φ` | Pthm:18 at `¬φ`, P8, MN+MK, transitivity of biconditionals |
| Pthm:21 | `▽◇φ → ◇▽φ` | "immediately from Pthm:11 and Pthm:20" |
| Pthm:22 | `◇▽φ → ▽◇φ` | P5, then conjunction elimination, then definition of `sometimes` |

### Dependencies

- Pthm:13 depends on P6; Pthm:15 depends on Pthm:14 and P3; Pthm:16 depends on P7, P8 and Pthm:15
- Pthm:17 depends on Pthm:11 and Pthm:16; Pthm:20 depends on Pthm:18 and P8
- Pthm:21 depends on Pthm:11 and Pthm:20; Pthm:22 depends on P5
- Pthm:11, Pthm:12, Pthm:14, Pthm:18, Pthm:19 depend only on axioms and P1/P3
- The graph is acyclic in both the paper's routing and the routing recommended below

### Potential Formalization Challenges

- **Pthm:11, Pthm:13-rev, Pthm:22's last step**: all three appeal to the paper's *disjunctive*
  definition `▽φ := ▽⁻φ ∨ φ ∨ ▽⁺φ`. This tree defines `sometimes φ = (always φ.neg).neg`
  (`FormalSystem/Syntax/Formula.lean:612`), so "disjunction introduction on `sometimes`" has no
  literal counterpart. Resolved without a De Morgan detour -- see Findings.
- **Pthm:16, Pthm:20**: "transitivity of biconditionals" is informal; in Lean each half is
  composed separately and the pair assembled with `Propositional.iffIntro`.
- **TR applied to TF** (needed by Pthm:11 and Pthm:14-rev): the tree has TF
  (`Combinators.temporalFutureDerived : □φ → G□φ`) but its past mirror `□φ → H□φ` exists only
  *instantiated at* `◇φ`, as `Perpetuity.boxDiamondToPastBoxDiamond`. A general version must be
  added; the generalization is mechanical.

## Findings

### Codebase Patterns

**Operator encodings** (`FormalSystem/Syntax/Formula.lean`). `always φ = Hφ ∧ (φ ∧ Gφ)` (:456),
`sometimes φ = ¬△¬φ` (:612), `diamond φ = ¬□¬φ` (:439), `allFuture φ = ¬▽⁺¬φ` (:168),
`allPast φ = ¬▽⁻¬φ` (:178). The duals are definitional, not axiomatized -- this is the single most
consequential fact for this port and it is what collapses several paper steps to one-liners.

**What is already present.** `perpetuity1`--`perpetuity5` (`Perpetuity/Principles.lean`),
`perpetuity6` (`Perpetuity/MonotonicityDuality.lean`). `perpetuity4 : ◇▽φ → ◇φ` is Pthm:17
verbatim. The P7 pair is `temporalDualityNeg` (`▽¬φ → ¬△φ`) and `temporalDualityNegRev`
(`¬△φ → ▽¬φ`). Monotonicity stock: `boxMono`, `diamondMono`, `futureMono`, `pastMono`,
`alwaysMono`; decomposition stock: `alwaysToPast`, `alwaysToPresent`, `alwaysToFuture`.

**Confirmed absent** (repo-wide `grep` over `FormalSystem/`, `Boneyard/` excluded from relevance):
no declaration of any of the eleven shapes; no P8 in either direction; no general `□φ → H□φ`; no
`▽φ → ◇φ`-shaped nesting lemma beyond `perpetuity1`--`perpetuity6`. The only modal-analogue duality
present is `modalDualityNeg`/`modalDualityNegRev` (`¬□φ ↔ ◇¬φ`), exactly as the task states.

**P8 is definitionally double negation, unlike P7.** `(sometimes φ).neg` *is*
`((always φ.neg).neg).neg` syntactically, so:

- `¬▽φ → △¬φ` is `Propositional.doubleNegation (φ.neg.always)`
- `△¬φ → ¬▽φ` is `Combinators.notNotIntro (φ.neg.always)`

P7 needs real work (`alwaysDni`/`alwaysDne`, lifting double negation through `H`, `G` and the
present) only because its `always` sits on the *outside* of the negation. The house precedent for a
duality that collapses this way is `TemporalDerived.fNegG` / `pNegH`, each a bare `notNotIntro`
with a docstring saying why. P8 should follow *that* precedent, not P7's, and its docstring should
say which and why. This contradicts the task's "following their proof shape" instruction, and the
instruction should not be followed literally: writing `contraposition (alwaysD…)` scaffolding
around a term that is already the identity-shaped DNE would be ornamental.

**The disjunctive-`sometimes` obstacle dissolves.** No De Morgan chain is needed. Pthm:11 goes
through its own contrapositive instead:

1. `(◇φ).neg → □¬φ` by `doubleNegation (φ.neg.box)` (definitional: `(◇φ).neg = (□¬φ).neg.neg`)
2. `□¬φ → △□¬φ` by the new `boxToAlwaysBox` (which is Pthm:14's reverse half)
3. `△□¬φ → △((◇φ).neg)` by `alwaysMono (notNotIntro φ.neg.box)`
4. contrapose, then `doubleNegation φ.diamond`

Pthm:13-rev and Pthm:22's last step both reduce to `TemporalDerived.presentToSometimes : φ → ▽φ`,
which already exists and is itself derived the same contrapositive way.

A consequence worth recording in the plan: this makes **Pthm:11 depend on Pthm:14's reverse half**,
where the paper has them independent. That is a forced encoding artefact, not a shortcut -- the
paper's Pthm:14-rev *is* "identity, TF, TR-applied-to-TF", i.e. precisely the three components
Pthm:11's paper proof invokes, repackaged. Factoring them into one named `boxToAlwaysBox` and
citing it twice is faithful; it is also what the repository's own placement doctrine
(`FormalSystem/Theorems/README.md`, "Where a derived schema lives") prescribes.

**Import-graph constraint on siting.** `ModalS5` imports `Perpetuity` (`ModalS5.lean:10`), so
`ModalS5.iff` and the S5/S4 collapse biconditionals (`s5DiamondBox : ⊢ iff (◇□A) □A`,
`s4DiamondBoxDiamond`) are strictly *downstream* of the Perpetuity cluster. `TemporalDerived`
neither imports nor is imported by Perpetuity -- it is a sibling reached through
`ConnectDerived`/`GeneralizedNecessitation`. Therefore:

| Siting | `ModalS5.iff` | `presentToSometimes` | P1--P6 | Verdict |
|---|---|---|---|---|
| Extend `Perpetuity/MonotonicityDuality.lean` | unavailable | unavailable (re-derivable in 1 line) | yes | workable, degraded |
| Extend `Perpetuity/Principles.lean` | unavailable | unavailable | P1--P5 only (no P6) | unworkable for Pthm:13 |
| New `FormalSystem/Theorems/Interaction.lean` | yes | yes | yes | **recommended** |

`Propositional.iffIntro` returns `(A.imp B).and (B.imp A)`, which is *definitionally* `ModalS5.iff A B`,
so the Perpetuity-internal option can still state biconditionals -- it just cannot name them with
the `iff` alias the S5/S4 collapse theorems use. The readability cost is real but small; the
`presentToSometimes` duplication cost is the stronger argument against it.

A further argument for the new module: `MonotonicityDuality.lean` opens a `noncomputable section`
at line 57 that runs to line 661. Siting P8 "beside `temporalDualityNeg`" therefore makes it
`noncomputable`, even though its proof term is a computable one-liner. `TemporalDerived`'s own
docstring maintains a "Computability Summary" distinguishing lemmas usable by the proof extractor
from those that are not, so this is a tracked property, not an incidental one. In a fresh module
P8 can be a plain `def`, matching `fNegG`/`pNegH`.

**`@[tmLemma]` convention.** `perpetuity1`--`perpetuity6` are *not* tagged; only the helpers
(`boxToFuture`, `boxToPast`, `boxToPresent`, `diamond4`, `modal5`, `boxToBoxPast`, `mbDiamond`) are.
`Automation/Tactics/Search.lean:297` collects the label set via ``Lean.labelled `tmLemma`` and
`tryLemmaMatch` applies each constant with `apply`, recursing into remaining premises. Recommend
leaving the eleven principles untagged (matching P1--P6) and tagging only `boxToAlwaysBox` and the
general TR mirror if either is reused.

### External Resources

No Mathlib search was needed: every premise is a TM proof-system declaration in this repository.
`lean_leansearch` / `lean_loogle` / `lean_leanfinder` were not consulted, and no rate limit was hit.

Relevant axioms and derived axioms, all confirmed present:

- MT = `Axiom.modal_t`, MK = `Axiom.modal_k_dist`, M5 = `Axiom.modal_5_collapse`,
  MF = `Axiom.modal_future` (`FormalSystem/ProofSystem/Axioms.lean`)
- MN = `DerivationTree.necessitation`, TN = `DerivationTree.temporal_necessitation`,
  TR = `DerivationTree.time_reflection` (rules, not axioms)
- `ProofSystem.DerivedAxioms.modal4 : □φ → □□φ` and `modalB : φ → □◇φ`
  (`FormalSystem/Theorems/Combinators.lean:751`, :765)
- TF = `Theorems.Combinators.temporalFutureDerived : □φ → G□φ`
  (`FormalSystem/Theorems/Combinators.lean:910`)

Bibliographic anchor for the `## References` blocks: `thomason1984` §4 is the settled key for
modal-temporal interaction in this tree, already cited in that exact form by
`FormalSystem/Metalogic/Independence/PlusIncompleteness.lean:56`,
`FormalSystem/OpenLanguage/OpenOckhamist.lean:71` and
`FormalSystem/PlusLanguage/PlusLimitClosure.lean:77`.

**Gate hazard checked and cleared**: C15's citation regex is
`\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*`. The `\b` word boundary means `Pthm:11`
does *not* match `thm:11` (`P` and `t` are both word characters), so cut-file labels can be written
verbatim in docstrings without needing rows in `docs/reference/paper-definitions-of-record.md`.
Verified empirically against the live regex. The two paper anchors worth citing --
`cor:tm-decidability` (where the block stood) and `sub:Logic` (where P4 lives) -- are respectively
a recorded manifest row and one of the six ungated `sub:` anchors, so both are safe.

### Recommendations

**A sorry-free path exists for every item.** All thirteen declarations below elaborated in one
probe with `success: true`. Recommended routing, with the one deliberate departure from the task
description flagged:

| Item | Statement | Route | Premises |
|---|---|---|---|
| P8 fwd | `¬▽φ → △¬φ` | definitional DNE | `doubleNegation (φ.neg.always)` |
| P8 rev | `△¬φ → ¬▽φ` | definitional DNI | `notNotIntro (φ.neg.always)` |
| *helper* | `□φ → H□φ` | TR on TF | `temporalFutureDerived`, `time_reflection`, `reflect_time_involution` |
| *helper* | `□φ → △□φ` (`boxToAlwaysBox`) | Pthm:14-rev, factored | the helper above, `identity`, TF, `combineImpConj3` |
| Pthm:11 | `▽◇φ → ◇φ` | contrapositive of `boxToAlwaysBox` at `¬φ` | `doubleNegation`, `alwaysMono`, `notNotIntro`, `contraposition` |
| Pthm:12 | `△◇φ → ◇φ` | conjunction elimination | `alwaysToPresent φ.diamond` |
| Pthm:13 | `▽□φ ↔ □φ` | paper's route | `perpetuity6`, `boxMono`, `alwaysToPresent`, `presentToSometimes` |
| Pthm:14 | `△□φ ↔ □φ` | paper's route | `alwaysToPresent`, `boxToAlwaysBox` |
| Pthm:15 | `□△φ ↔ △□φ` | paper's route | `boxMono`, `alwaysToPresent`, `boxToAlwaysBox`, `perpetuity3` |
| Pthm:16 | `◇▽φ ↔ ▽◇φ` | paper's route (P8, Pthm:15 at `¬φ`, P7 at `□¬φ`) | `p8`/`p8rev`, `perpetuity3`, `temporalDualityNeg`/`…Rev`, `boxToAlwaysBox` |
| Pthm:17 | `◇▽φ → ◇φ` | **not restated** -- docstring cross-reference on `perpetuity4` | n/a |
| Pthm:18 | `□△φ ↔ □φ` | **cut file's direct route**, not 15+14 | `boxMono`, `DerivedAxioms.modal4`, `perpetuity1` |
| Pthm:19 | `◇△φ → ◇φ` | contraposed `boxMono`, i.e. `diamondMono` | `diamondMono (alwaysToPresent φ)` |
| Pthm:20 | `◇φ ↔ ◇▽φ` | fwd paper's route; rev cites `perpetuity4` | `p8`/`p8rev`, `boxMono`, `alwaysToPresent`, `perpetuity3`, `perpetuity4` |
| Pthm:21 | `▽◇φ → ◇▽φ` | Pthm:11 then Pthm:20-fwd | the two above |
| Pthm:22 | `◇▽φ → ▽◇φ` | P5, conjunction elimination, definition | `perpetuity5`, `alwaysToPresent`, `presentToSometimes` |

**Expose Pthm:20's forward half as its own named `def` (`pthm20Fwd`).** Pthm:21 consumes it, and it
cannot be projected out of a `.and`-shaped biconditional without a conjunction-elimination step
that obscures the dependency. Pairing it with `perpetuity4` under `iffIntro` then discharges both
DELIVER item (3) (the cross-reference that `perpetuity4` is Pthm:17 *and* the reverse half of
Pthm:20) and DELIVER item (4)'s Pthm:21 clause in one place.

**Follow the cut file's own Pthm:18 proof, not item (4)'s "from Pthm:15 and Pthm:14".** See
Decisions. Record the 15+14 composition in Pthm:18's docstring as the redundancy observation it is.

**Follow the cut file's own Pthm:16 proof, not the cheaper 21+22 composition.** The paper's route
(P8, MN+MK, Pthm:15 at `¬φ`, P7 at `□¬φ`) is the only consumer of Pthm:15 and of the existing P7
pair in the whole block; routing Pthm:16 through `iffIntro pthm22 pthm21` instead would leave
Pthm:15 referenced by nothing. Both routes were verified to compile; the plan should note the
alternative in Pthm:16's docstring.

**Do not claim the five biconditionals are rewrite lemmas.** Pthm:13, 14, 15, 18 and 20 do collapse
modal-temporal nesting, but this tree has no mechanism that can consume a *derivability*
biconditional as a rewrite. Checked, all negative:

- `FormalSystem/Automation/Normalization.lean` holds 21 `_unfold` and 10 `_fold` lemmas, all `rfl`,
  tagged `@[formula_unfold]`/`@[formula_fold]`. These are `Formula`-level definitional identities.
  `⊢[fc] iff (□△φ) (□φ)` is a derivation, not an equality of formulas, so it is not registrable
  there and `simp` cannot use it.
- `FormalSystem/Metalogic/Expressiveness/NormalForm.lean` is Doets monadic-FO normal form theory
  (`AtomKind`, `NormalForm`, `doets_lemma_1_1`); unrelated to operator nesting.
- `FormalSystem/Semantics/IntNormalForm.lean` is the ℤ-frame one-step normal form; semantic.
- `FormalSystem/Metalogic/Decidability/` computes `Closure` syntactically over subformulas; a
  provable biconditional does not shrink a syntactic closure, so the tableau cannot consume it.
- The one genuine automation surface is `@[tmLemma]` -- and the existing precedent
  (`perpetuity1`--`perpetuity6` untagged) says not to use it for principles.

The honest docstring claim is the **precedent** one: these five are the modal-temporal counterparts
of `ModalS5.s5DiamondBox` and `ModalS4.s4DiamondBoxDiamond`, which are stated as `⊢ iff A B`,
recorded for their own sake, and consumed by no rewriting framework either. Say that; do not
promise a consumer that does not exist.

## Decisions

1. **New module `FormalSystem/Theorems/Interaction.lean`**, importing
   `FormalSystem.Theorems.Perpetuity`, `FormalSystem.Theorems.ModalS5` and
   `FormalSystem.Theorems.TemporalDerived`, namespace `FormalSystem.Theorems.Interaction`.
   Reason: the only placement giving simultaneous access to `ModalS5.iff`,
   `TemporalDerived.presentToSometimes` and the full P1--P6 stock; avoids duplicating
   `presentToSometimes`; keeps P8 computable (outside `MonotonicityDuality`'s `noncomputable
   section`); creates no import cycle (nothing imports `Interaction`). Verified: the exact import
   triple is what the successful probe used.
2. **P8 is sited in the new module, not beside `temporalDualityNeg`.** Overrides the task's
   "sited beside … and following their proof shape" on two grounds: the proof shape is not
   applicable (P8 is definitional DNE/DNI, P7 is not), and siting it inside
   `MonotonicityDuality`'s `noncomputable section` would make a computable lemma noncomputable.
   Its docstring cites both the P7 pair (as the contrast) and `fNegG`/`pNegH` (as the precedent).
   **Flagged for the user**: this is a deliberate departure from an explicit task instruction.
3. **Pthm:18 follows the cut file's direct derivation** (`boxMono (alwaysToPresent φ)` and
   `impTrans (DerivedAxioms.modal4 φ) (boxMono (perpetuity1 φ))`), not DELIVER item (4)'s
   15+14 route. The cut file's Pthm:18 proof does not mention Pthm:15 or Pthm:14; the 15+14 claim
   is from the block's header redundancy comment. Literature fidelity tracks the derivation.
   Note for the plan: the reverse half is *extensionally* `perpetuity3`, whose own proof is the
   same `modal4`-then-`boxMono(perpetuity1)` composition, so citing `perpetuity3` directly would
   also be faithful; the plan should pick one and say which.
4. **Pthm:17 gets a docstring cross-reference on `perpetuity4`, not a restatement.** DELIVER
   item (4)'s "Pthm:17 from Pthm:11 and Pthm:16" is therefore moot -- `perpetuity4` is already
   proved independently in `Principles.lean` and item (3) forbids restating it. No declaration is
   added for Pthm:17.
5. **Biconditionals are stated as `⊢[fc] iff A B`** using `ModalS5.iff`, matching
   `s5DiamondBox`/`s4DiamondBoxDiamond`, and assembled with `Propositional.iffIntro`. Each
   biconditional whose halves are consumed separately also gets named halves (`pthm20Fwd` at
   minimum).
6. **Eleven principles left untagged; helpers may carry `@[tmLemma]`.** Matches P1--P6.
7. **Cite declaration names, never line numbers.** `REFERENCE_NORMAL_FORM.md` §2 prefers names,
   and C20's third assertion gates a `file.lean:NNN` citation that lands outside the span of the
   declaration it names. Nothing in this port needs a line number.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| **Aggregator contention on `FormalSystem/Theorems.lean`.** A new module needs a one-line import there. Siblings 795, 796, 797, 799 are dispatched this cycle with *undeclared* `file_scope` and could touch it. | medium | All four siblings are in the *research* phase this cycle, which writes no `.lean` file -- the collision window is plan/implement, not now. Mitigation for the plan: isolate the import edit in its own terminal phase, re-read `Theorems.lean` immediately before editing, stage only that file, and re-run the build after. Do not dispatch this task's implement phase concurrently with another task adding to that aggregator. |
| **Generated inventory goes stale.** `FormalSystem/Theorems/README.md` wraps its module table in `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Theorems -->`; the INV check in `check-module-invariants.sh` fails on a stale block. | low | Run `bash scripts/check-module-invariants.sh --emit-inventory` in the same phase as the import edit, then `--emit-inventory --check` to verify. `scripts/readme-inventory.sh` is a deprecated shim and must not be used. |
| **Unreachable-module trap.** A module not transitively imported by `FormalSystem.lean` becomes a C6 "known-unreachable live module" and opts out of C24's `FormalSystem.Init` inheritance. | low | The `Theorems.lean` import line is mandatory, not cosmetic. Verify with `lake exe checkInitImports` (C24) after the edit. |
| **Line-length lint.** The probe's only warning was a `longLine` over the 100-character limit; C28 budgets compiler warnings per file and a new file has no baseline entry. | low | Keep every line ≤ 100 characters. Do not add a `scripts/warning-budget.txt` entry -- fix the lines. |
| **`longFile` linter if the Perpetuity option is chosen instead.** `Principles.lean` is already 814 lines and `MonotonicityDuality.lean` 663; neither carries a `longFile` baseline. | low | Moot under the recommended new-module decision. If the plan overrides it, ~250 added lines still leaves both under the 1500 default. |
| **Dead-declaration census inflation.** Pthm:12, 14, 19 and (under the paper's Pthm:16 routing) 21 and 22 are referenced by nothing, so C17 will count them as having no occurrence outside their declaring line. | low | C17 is explicitly reporting-only ("No ENFORCE_C17 flag"), so it cannot fail a gate. Keeping the count flat is still cheap: name each new declaration in the module docstring's `## Main Theorems` inventory, which is inside C17's markdown scope. |
| **`alwaysToPresent` name collision.** The identifier exists in both `Perpetuity` (a `def` inside a `noncomputable section`) and `TemporalDerived` (a `noncomputable def`). A module opening both namespaces gets an ambiguity. | low | The probe opened only `Perpetuity` and selectively imported `presentToSometimes` from `TemporalDerived` via `open … (presentToSometimes)`. Reproduce that exact open-list in the new module. |
| **Everything in the new module becomes `noncomputable`** because the Perpetuity premises are. | none | Already true of the probe, which marked all thirteen `noncomputable def` and compiled. Expected, not a defect; note it in the module docstring. |

## Tactic Survey Results

Automation tactics were surveyed and found inapplicable, which is itself the finding: TM
derivations are proof *terms* over `DerivationTree`, not goals that `simp`/`omega`/`aesop` can
close. Every item below was discharged by explicit combinator composition, which is what the
repository's existing P1--P6 proofs do.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| all thirteen declarations | explicit combinator terms (`impTrans`, `contraposition`, `iffIntro`, `combineImpConj3`, `boxMono`, `diamondMono`, `alwaysMono`) | success | verified by `lean_run_code`, `success: true`, zero sorry |
| `□φ → H□φ` (TR mirror of TF) | `simp only [Formula.reflectTime, Formula.reflect_time_all_future, Formula.reflect_time_involution]` | success | the only tactic step needed anywhere; mirrors `boxDiamondToPastBoxDiamond` and `boxToPast` exactly |
| any item | `simp` / `aesop` / `omega` / `decide` | not attempted (inapplicable) | goals are `⊢[fc] φ.imp ψ` over an inductive `DerivationTree`; no simp set or decision procedure targets them, and `lean4.md`'s literature-fidelity rule forbids using them to bypass steps the source handles explicitly |
| premise discovery | `lean_hammer_premise` | not needed | every premise was located by `grep` and confirmed by elaboration; no search-tool rate limit was consumed |

## Context Extension Recommendations

- **Topic**: the `\b`-protection of `Pthm:`-style labels against C15's paper-anchor regex.
  **Gap**: `docs/development/REFERENCE_NORMAL_FORM.md` lists the six gated anchor prefixes and the
  six ungated `sub:` anchors, but says nothing about labels that *contain* a gated prefix as a
  substring. A future author porting from the cut file has no way to know whether `Pthm:11` is
  gated without reading the regex.
  **Recommendation**: add one sentence to that document's "Paper anchor" subsection recording that
  the regex is word-boundary-anchored, so a label like `Pthm:11` or `Rthm:3` is outside C15's
  scope and needs no record row.
- **Topic**: derivability biconditionals are not rewrite lemmas in this tree.
  **Gap**: nothing in `.claude/context/project/lean4/` or `FormalSystem/Theorems/README.md` states
  that `⊢[fc] iff A B` cannot be registered in `Automation/Normalization.lean`'s simp sets, which
  hold only `rfl`-level `Formula` identities. The distinction cost real research time here and the
  task description itself assumed otherwise.
  **Recommendation**: add a short subsection to `FormalSystem/Theorems/README.md` (beside "Where a
  derived schema lives") naming the two kinds -- definitional identity versus derivability
  biconditional -- and stating that only the former is simp-registrable and that `@[tmLemma]` is
  the sole automation surface for the latter.

## Appendix

### A. Verified proof terms

Reproduced from the `lean_run_code` probe that returned `success: true`. Namespace and `open` lines
are part of the verified configuration. The one warning was a `longLine` on the `pthm20` signature;
wrap it.

```lean
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.TemporalDerived

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.ModalS5 (iff)
open FormalSystem.Theorems.Propositional (doubleNegation iffIntro)
open FormalSystem.Theorems.TemporalDerived (presentToSometimes)

-- P8, both directions
noncomputable def p8 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.sometimes.neg.imp φ.neg.always :=
  doubleNegation (φ.neg.always)
noncomputable def p8rev {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.neg.always.imp φ.sometimes.neg :=
  notNotIntro (φ.neg.always)

-- TR mirror of TF, generalised from boxDiamondToPastBoxDiamond
noncomputable def tpd {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.box.imp φ.box.allPast := by
  have tf : ⊢[fc] φ.reflectTime.box.imp φ.reflectTime.box.allFuture :=
    temporalFutureDerived φ.reflectTime
  have td : ⊢[fc] (φ.reflectTime.box.imp φ.reflectTime.box.allFuture).reflectTime :=
    DerivationTree.time_reflection _ tf
  simp only [Formula.reflectTime, Formula.reflect_time_all_future,
    Formula.reflect_time_involution] at td
  exact td

-- Pthm:14's reverse half, factored out because Pthm:11 and Pthm:15 also consume it
noncomputable def boxToAlwaysBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.box.imp φ.box.always :=
  combineImpConj3 (tpd φ) (identity φ.box) (temporalFutureDerived φ)

noncomputable def pthm11 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.sometimes.imp φ.diamond :=
  impTrans (contraposition (impTrans (doubleNegation φ.neg.box)
    (impTrans (boxToAlwaysBox φ.neg) (alwaysMono (notNotIntro φ.neg.box)))))
    (doubleNegation φ.diamond)

noncomputable def pthm12 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.always.imp φ.diamond := alwaysToPresent φ.diamond

noncomputable def pthm13 {fc : FrameClass} (φ : Formula) : ⊢[fc] iff φ.box.sometimes φ.box :=
  iffIntro _ _ (impTrans (perpetuity6 φ) (boxMono (alwaysToPresent φ)))
    (presentToSometimes φ.box)

noncomputable def pthm14 {fc : FrameClass} (φ : Formula) : ⊢[fc] iff φ.box.always φ.box :=
  iffIntro _ _ (alwaysToPresent φ.box) (boxToAlwaysBox φ)

noncomputable def pthm15 {fc : FrameClass} (φ : Formula) : ⊢[fc] iff φ.always.box φ.box.always :=
  iffIntro _ _ (impTrans (boxMono (alwaysToPresent φ)) (boxToAlwaysBox φ))
    (impTrans (alwaysToPresent φ.box) (perpetuity3 φ))

noncomputable def pthm18 {fc : FrameClass} (φ : Formula) : ⊢[fc] iff φ.always.box φ.box :=
  iffIntro _ _ (boxMono (alwaysToPresent φ))
    (impTrans (DerivedAxioms.modal4 φ) (boxMono (perpetuity1 φ)))

noncomputable def pthm19 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.always.diamond.imp φ.diamond := diamondMono (alwaysToPresent φ)

noncomputable def pthm20Fwd {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.imp φ.sometimes.diamond :=
  contraposition (impTrans (boxMono (p8 φ)) (boxMono (alwaysToPresent φ.neg)))

noncomputable def pthm20 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.diamond φ.sometimes.diamond :=
  iffIntro _ _ (pthm20Fwd φ) (perpetuity4 φ)

noncomputable def pthm21 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.sometimes.imp φ.sometimes.diamond :=
  impTrans (pthm11 φ) (pthm20Fwd φ)

noncomputable def pthm22 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.sometimes.diamond.imp φ.diamond.sometimes :=
  impTrans (perpetuity5 φ) (impTrans (alwaysToPresent φ.diamond) (presentToSometimes φ.diamond))

-- Pthm:16 by the cut file's own route: P8, Pthm:15 at ¬φ, P7 at □¬φ
noncomputable def pthm16 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.sometimes.diamond φ.diamond.sometimes :=
  iffIntro _ _
    (impTrans
      (contraposition (impTrans (impTrans (alwaysToPresent φ.neg.box) (perpetuity3 φ.neg))
        (boxMono (p8rev φ))))
      (temporalDualityNegRev φ.neg.box))
    (impTrans (temporalDualityNeg φ.neg.box)
      (contraposition (impTrans (boxMono (p8 φ))
        (impTrans (boxMono (alwaysToPresent φ.neg)) (boxToAlwaysBox φ.neg)))))

-- The 21+22 shortcut, verified but NOT recommended: it leaves Pthm:15 unused
noncomputable def pthm16Alt {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.sometimes.diamond φ.diamond.sometimes :=
  iffIntro _ _ (pthm22 φ) (pthm21 φ)
```

Final names are a plan-time choice; `pthm11`-style identifiers are probe scaffolding, and a reader
of the library will be better served by semantic names (`sometimesDiamondToDiamond`,
`alwaysBoxIffBox`, …) with the cut-file label in the docstring. The repository's own naming is
semantic throughout (`boxToFuture`, `alwaysToPresent`, `s5DiamondBox`).

### B. Searches and probes run

- `grep -rn` over `FormalSystem/` for each of the eleven shapes, for `sometimes`/`always`
  interaction declarations, for `box.allPast`, and for the P7/P8 duality pairs -- all absence
  claims rest on these
- import-graph enumeration over `FormalSystem/Theorems/*.lean` and `Perpetuity/*.lean`
- `lean_run_code` x3: an easy-items probe (4 declarations), a hard-items probe (9), and the
  consolidated probe in Appendix A (16, `success: true`)
- live-regex check of C15's anchor pattern against the literal strings `Pthm:11`,
  `thm:extension`, `cor:tm-decidability`
- gate reconnaissance: `scripts/check-module-invariants.sh` headers for C6, C8, C14, C15, C16,
  C17, C20, C24, C28, C30, C31 and the `--emit-inventory` INV check;
  `scripts/warning-budget.txt`; `scripts/lean-citation-manifest.json` and
  `docs/reference/API_REFERENCE.md` (neither indexes `FormalSystem/Theorems/`, so neither is a
  registration obligation and neither collides with the sibling task holding them this cycle)
- no rate-limited search tool was called; no MCP failure or fallback occurred

## References

* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4 — modal-temporal
  interaction principles in combined tense-modal systems
* [J. P. Burgess, *Axioms for Tense Logic. I. "Since" and "Until"*][burgess1982], §1.3 — the BX
  temporal basis the `always`/`sometimes` operators are defined over
* JPL paper `cor:tm-decidability` — the result the cut block stood after
* JPL paper `sub:Logic` — where P4, the already-present Pthm:17, is stated
* `FormalSystem/Syntax/Formula.lean` — the `always`, `sometimes` and `diamond` encodings this
  port's derivations turn on
* `FormalSystem/Theorems/Perpetuity/Principles.lean` — P1--P5, `contraposition`, `modal5`,
  `perpetuity4` (the already-present Pthm:17)
* `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean` — P6, the P7 pair
  (`temporalDualityNeg`, `temporalDualityNegRev`), `alwaysMono`, `alwaysToPresent`
* `FormalSystem/Theorems/TemporalDerived.lean` — `presentToSometimes`, and `fNegG`/`pNegH` as the
  precedent for a definitional duality proved by bare double negation
* `FormalSystem/Theorems/ModalS5.lean` — the `iff` connective and `s5DiamondBox`, the modal-only
  collapse biconditional these eleven are the modal-temporal counterparts of
* `FormalSystem/Theorems/README.md` — the "Where a derived schema lives" placement doctrine and
  the generated module inventory a new module makes stale
* `docs/development/REFERENCE_NORMAL_FORM.md` — the three `## References` forms this block follows
