# Research Report: Task #800

**Task**: 800 - Extend the time-reflection transport from BL to the Stability language
**Started**: 2026-10-15T00:00:00Z
**Completed**: 2026-10-15T00:00:00Z
**Effort**: Medium (one implementation phase for the Plus layer, one for the Determined-class layer, one for siting/registration)
**Dependencies**: The base time-reflection task — **LANDED** (verified below)
**Sources/Inputs**:
- Codebase (`FormalSystem/Semantics/`, `FormalSystem/PlusLanguage/`, `FormalSystem/OpenLanguage/`, `FormalSystem/Metalogic/Deterministic/`)
- Compiled Lean probes via `lean_run_code` (four probes, all green; see Findings)
- Literature source: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`, §"The stability logic and its completeness over the deterministic frames", soundness half of the proof of `cor:deterministic-completeness`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (`def:time-reflection`, `lem:time-reflection`, `thm:TR-valid`)

**Artifacts**:
- `specs/800_stability_time_reflection_transport/reports/01_stability-time-reflection-transport.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Deliverable (1) is already done.** `PlusFormula.reflectTime` exists at
  `FormalSystem/PlusLanguage/Formula.lean:218-237`, with the Stability clause already commuting
  (`| stab φ => stab φ.reflectTime`), `reflect_time_involution`, and the full
  `reflect_time_*` push-through family for every derived operator. Nothing to add. The
  dispatch's "check whether it already carries one" instruction resolves to **yes**.
- **Deliverable (2), the one genuinely new semantic step, is already written — at the wrong
  layer.** `OpenLanguage.sameState_rev_iff` (`FormalSystem/OpenLanguage/OpenReversal.lean:82-85`)
  is exactly the carrying lemma, and it is a statement about `WorldHistory` alone with no
  language in it. `OpenLanguage/` imports `PlusLanguage/`, so the Plus layer cannot consume it
  where it sits. The right move is **promotion to `Semantics/Reversal.lean`**, after which both
  the new Plus module and the existing `OpenReversal.lean` consume one copy.
- **Deliverables (2), (3) and (4) all compile.** Four `lean_run_code` probes returned zero
  diagnostics: the carrying lemma in both its pointwise and its paper-faithful *image* form, the
  seven-case `plusTruthAt_rev`, the Plus validity family (`plusValidOn_rev_iff`,
  `plusValidOnFrames_reflectTime`, `plusValidIn_reflectTime`), and the Determined-class closure
  `determinedValid_rev` / `determinedSat_rev` / `plusValidDeterminedIn_reflectTime` by the
  paper's own mirror-image argument. A bonus that also compiles: `deterministic_rev` and
  `detSat_rev`, giving reflection over the *deterministic* frames too.
- **Deliverable (5): keep the present route.** The base layer already carries a three-reason
  decision record (`FormalSystem/Metalogic/Soundness.lean:1252-1307`) for keeping the paired
  companion recursion rather than consuming `thm:TR-valid`, and **reason 2 names the
  Deterministic variant by name** as mirroring it arm for arm. Switching only the Deterministic
  copy would break the stated alignment. Record the second route in the docstring as an
  independent cross-check, exactly as the base layer does.
- **No sorry-free risk anywhere.** Every obligation in the task is a transport over machinery
  that already exists; all of it was compiled before this report was written.
- **Unification finding (reported, not acted on):** the three reversal transports cannot be
  collapsed behind one generic transport without a new "reflectable language" class. The
  achievable deduplication is the promotion in bullet 2 plus optionally promoting `stabClass`.

## Context & Scope

Researched: what remains to be built for the five dispatch deliverables, where each piece
should be sited given the repository's import layering, and whether the Deterministic soundness
proof should be rewired.

Constraints honoured in the recommendations below:
- `lake build FormalSystem` green with no new `sorry` at the end of every phase.
- The `assert_not_exists FormalSystem.ProofSystem.{Axiom,DerivationTree,Derivable,FrameClass}`
  guards at `FormalSystem/Semantics/Truth.lean:156-157` and
  `FormalSystem/Semantics/Reversal.lean:64-65` must stay satisfied. Both promotions recommended
  below (`sameState_rev_iff`, optionally `stabClass`) are statements about `WorldHistory.state`
  with no proof-system dependency, so neither guard is at risk.
- Scope limit respected: this is the reflection transport only, not a port of
  `cor:deterministic-completeness` (already in the tree) and not a refactor of
  `OpenLanguage/OpenReversal.lean` beyond deleting the one lemma that gets promoted.

## Literature Proof Structure

**Source**: `JPL/appendix_cut_material.tex`, §"The stability logic and its completeness over the
deterministic frames", proof of `cor:deterministic-completeness`, soundness half, final sentence.
**Strategy**: extend an existing lemma by one clause, then transport; the frame-class closure is
argued by a mirror-image involution rather than re-proved.

The specification, verbatim from the source:

> **\aref{TR}** preserves validity over $\mathsf{C}^{\Stability}$ as in **\ref{thm:TR-valid}}**:
> **\ref{lem:time-reflection}** extends to $\BL^{+}$ by setting
> $(\Stability\varphi)_{\tuple{\textsc{s} | \textsc{u}}} \coloneq \Stability\varphi_{\tuple{\textsc{s} | \textsc{u}}}$,
> since $\tau \mapsto \tau^{-}$ carries $\braket{\tau}_x$ onto $\braket{\tau^{-}}_{n(x)}$, and
> $\F \mapsto \F^{-}$ preserves $\mathsf{C}^{\Stability}$, leaving the temporal order unchanged
> where $\F^{-}$ validates an instance of *Determined* just in case $\F$ validates its mirror
> image, itself an instance of *Determined*.

### Step Map

1. Set the mirror of a Stability formula to be the Stability of its mirror —
   `(⊡φ)_{S|U} := ⊡(φ_{S|U})`. [Source] the clause displayed above. **Already in the tree**:
   `FormalSystem/PlusLanguage/Formula.lean:225`.
2. `τ ↦ τ⁻` carries `⟨τ⟩_x` **onto** `⟨τ⁻⟩_{n(x)}`. [Source] same sentence, the `since` clause.
   This is deliverable (2).
3. `lem:time-reflection` extends to BL⁺. [Source] same sentence. Deliverable (3), from step 2
   plus the base transport's argument at the six shared clauses.
4. `F ↦ F⁻` preserves `C^⊡`, "leaving the temporal order unchanged", because `F⁻` validates an
   instance of *Determined* iff `F` validates its mirror image, itself an instance of
   *Determined*. [Source] same sentence, final clause. Deliverable (4).
5. `thm:TR-valid` for BL⁺ over `C^⊡`. [Source] the appeal to `thm:TR-valid` opening the sentence.
   Deliverable (4)'s consequence.

### Dependencies

- Step 3 depends on steps 1 and 2.
- Step 4 depends on step 3 (it is the Plus-level `plusValidOn_rev_iff` applied at a mirrored
  instance) and on the already-landed `ProofSystem.FrameClass.Sat.rev` for the "temporal order
  unchanged" half.
- Step 5 depends on steps 3 and 4.

### Potential Formalization Challenges

- **Step 2, "onto"**: the paper's word is *onto*, a set-level image claim. The induction in step
  3 consumes only a pointwise biconditional. Both forms were compiled (see Findings); the plan
  should state both so the `onto` wording is honoured on the nose and the induction still has
  the shape it wants.
- **Step 2, siting**: `⟨τ⟩_x` is named in the tree as `OpenLanguage.stabClass`
  (`FormalSystem/OpenLanguage/OpenClasses.lean:74-76`), which is *above* `PlusLanguage/`. Stating
  the image form at the Plus layer therefore needs either a promotion of `stabClass` or a local
  restatement. See Decisions.
- **Step 4, "leaving the temporal order unchanged"**: already a landed theorem —
  `ProofSystem.FrameClass.Sat.rev` (`FormalSystem/Semantics/FrameClassValidity.lean:265-271`),
  with the docstring giving precisely the paper's reason. Do not re-derive it.
- **The task description's gloss of `PlusStateLocal` is inaccurate** and should not be followed
  literally: the dispatch calls `PlusStateLocal` "the state-local equivalence the Stability
  clause quantifies over, which is the object the carrying lemma below is about".
  `FormalSystem/PlusLanguage/PlusStateLocal.lean` is in fact the **state-locality fragment of
  L⁺** — a class of *formulas* (`PlusFormula.StateLocal`, `IsPlusStateLocal`) whose headline is
  `φ ↔ ⊡φ`. It is not `⟨τ⟩_x` and the carrying lemma does not mention it. The object the
  carrying lemma is about is the history class `⟨τ⟩_x`, inlined in the `stab` clause at
  `FormalSystem/PlusLanguage/PlusTruth.lean:93` and named only at the Open layer.

## Findings

### Codebase Patterns

**Base layer — fully landed, nothing to redo.**

| Declaration | Location |
|---|---|
| `TaskModel.rev`, `WorldHistory.rev`, `rev_rev_hist`, `rev_surjective` | `FormalSystem/Semantics/Reversal.lean:74-102` |
| `revHistEquiv`, `revAntiIso` | `FormalSystem/Semantics/Reversal.lean:111-128` |
| `truthAt_rev` (`lem:time-reflection`, base language) | `FormalSystem/Semantics/Reversal.lean:141-143` |
| `validOn_rev_iff`, `validOnFrames_reflectTime`, `validIn_reflectTime`, `validIn_reflectTime_iff`, `valid_reflectTime` | `FormalSystem/Semantics/Validity.lean:514-576` |
| `FrameClass.Sat.rev` — every frame class is `rev`-closed, **no hypothesis** | `FormalSystem/Semantics/FrameClassValidity.lean:265-271` |
| `FrameClass.Sat.isRegular` | `FormalSystem/Semantics/FrameClassValidity.lean:225-227` |
| `FrameOver.rev`, `rev_isRegular`, `rev_taskRel`, `rev_taskRel_neg`, `TaskFrame.rev` | `FormalSystem/Semantics/TaskFrame.lean:2799-2860` |

**L⁺ syntax layer — deliverable (1) already satisfied.** `PlusFormula.reflectTime`
(`FormalSystem/PlusLanguage/Formula.lean:218-225`) with `| stab φ => stab φ.reflectTime`;
`reflect_time_involution` (`:228`); and `reflect_time_{top,neg,diamond,some_future,some_past,
all_future,all_past,next,prev,and,or,kPlus,kMinus,…}` (`:241-300+`), plus
`IsPureFuture.reflectTime` / `IsPurePast.reflectTime`. Nothing in deliverable (1) remains.

**L⁺ semantic layer — the gap.** `FormalSystem/PlusLanguage/PlusValidity.lean` has
`TaskFrame.PlusValidOn`, `PlusValidOnFrames` (the primitive, indexed by a bare
`TaskFrame → Prop`), `PlusValidIn`, `PlusValid` and the per-class abbreviations, but **no `rev`
or `reflectTime` lemma of any kind** (`grep -n "rev\|reflect"` on that file returns only
unrelated prose hits). This is the hole deliverables (3) and (4) fill.

**The Open layer already did this work, one language up.** `openTruthAt_rev`
(`FormalSystem/OpenLanguage/OpenReversal.lean:121-181`) is a nine-case induction whose
`atom`/`box`/`untl`/`snce`/`stab` cases are, verbatim, the seven cases `plusTruthAt_rev` needs;
`openValidOn_rev_iff` (`:187-195`) and `openValid_reflectTime` (`:204-208`) are the validity
half. Its `stab` case consumes `sameState_rev_iff` (`:82-85`) — deliverable (2).

**Import direction forbids reuse in place.** `FormalSystem/OpenLanguage/Formula.lean:7` imports
`FormalSystem.PlusLanguage.Formula`; `OpenValidity.lean:8` imports
`FormalSystem.PlusLanguage.PlusValidity`; `OpenClasses.lean:7` imports
`FormalSystem.PlusLanguage.PlusPasting`. L^▷ sits strictly above L⁺, so no `PlusLanguage/` module
may import `OpenLanguage/`.

**Determined layer.** `DeterminedValid F := ∀ φ : PlusFormula, F.PlusValidOn (φ.imp φ.stab)`,
`DeterminedSat fc F := fc.Sat F ∧ DeterminedValid F`, `PlusValidDeterminedIn fc φ :=
PlusValidOnFrames (DeterminedSat fc) φ`, plus `DetSat` / `PlusValidDetIn`, all at
`FormalSystem/Metalogic/Deterministic/Validity.lean:78-108`. `TaskFrame.Deterministic` is at
`FormalSystem/Semantics/FrameProperty.lean:357-358` with `deterministic_iff` at `:364`.

**The TR case as it stands.** `FormalSystem/Metalogic/Deterministic/Soundness.lean` discharges TR
through the paired companion recursion
`det_derivable_valid_and_reflect_time_validDeterminedIn` (`:100-156`), whose `time_reflection`
arm is `⟨h.2, …⟩` plus `reflect_time_involution` (`:141-145`). The base-language decision record
for that shape is `FormalSystem/Metalogic/Soundness.lean:1252-1307`.

### Compiled Probes (evidence of record)

Evidence tier: **LSP-backed, compiled**. `lean-lsp` was registered and reachable; all four
probes ran through `lean_run_code` against the live project and returned
`{"success":true,"diagnostics":[]}`. These are not sketches — the proof bodies below elaborated.

| Probe | Statements proved | Result |
|---|---|---|
| 1 | `sameState_rev_iff'`, `plusTruthAt_rev'` (7-case induction), `plusValidOn_rev_iff'`, `plusValidOnFrames_reflectTime'`, `plusValidIn_reflectTime'` | green, 0 diagnostics |
| 2 | `reflect_determined`, `determinedValid_rev`, `determinedSat_rev`, `plusValidDeterminedIn_reflectTime`, and the `PlusValidDetIn` analogue (probe-1 results stubbed as `axiom`, having been proved for real in probe 1) | green, 0 diagnostics |
| 3 | `deterministic_rev` (needs `[F.IsRegular]`), `detSat_rev` (regularity recovered from `h.1.isRegular`) | green, 0 diagnostics |
| 4 | `image_rev_stabClass` — the paper's "carries **onto**" as a `Set.image` equation | green, 0 diagnostics |

Two mechanical details worth carrying into the plan, both discovered by a failing probe before
the green one:

- `F.rev.TaskRel w x u` is **`F.TaskRel u x w`** definitionally (relation transpose,
  `FrameOver.rev_taskRel`), and equals `F.TaskRel w (-x) u` only through
  `FrameOver.rev_taskRel_neg`, which carries an `[F.IsRegular]` hypothesis. So
  `deterministic_rev` is **not** `fun w d => h w (-d)`; that was probe 3's first, failing form.
  It must route through `TaskFrame.deterministic_iff` and `rev_taskRel_neg`, and it must take
  regularity.
- `deterministic_rev`'s regularity hypothesis is free inside `DetSat fc F`:
  `haveI := h.1.isRegular` discharges it, since every `FrameClass.Sat` value carries
  `TaskFrame.IsRegular`.

### External Resources

- Paper specification: confirmed verbatim at `appendix_cut_material.tex`, inside the soundness
  half of the `cor:deterministic-completeness` proof (the subsection header named by the dispatch
  is at line 437 of that file). The dispatch's `n(x)` is the paper's time-reflection map, i.e.
  `-x`; the Lean rendering is `-t`, consistent with `truthAt_rev` and `openTruthAt_rev`.
- The paper states the extension **only** inside this cut proof, as the dispatch says. Treated as
  a specification to implement, not a theorem to cite.

### Recommendations

A sorry-free path exists end to end, and every step of it has been compiled. Recommended shape,
in dependency order:

**Phase A — promote the carrying lemma, then build the Plus transport.**

1. Promote `sameState_rev_iff` into `FormalSystem/Semantics/Reversal.lean`, in namespace
   `FormalSystem.Semantics`, beside `WorldHistory.rev_surjective`. Body unchanged
   (`change _ ↔ τ.state (- -t) = σ.state (- -t); rw [neg_neg]`). Update that module's
   `## Main Results` block.
2. Delete `OpenLanguage.sameState_rev_iff` and let `OpenReversal.lean`'s two use sites
   (`:165`, `:167`) resolve to the promoted name — `OpenReversal.lean:8` already imports
   `Semantics.Reversal` and `:75` already has `open FormalSystem.Semantics`, so the call sites
   need no edit at all. Update `OpenLanguage/OpenReversal.lean`'s `## Main Results`,
   `FormalSystem/OpenLanguage.lean:56`, and the two `OpenLanguage/README.md` rows (`:38`, `:65`)
   that name the lemma, so none of them claims a declaration the Open layer no longer owns.
3. Create `FormalSystem/PlusLanguage/PlusReversal.lean`, importing
   `FormalSystem.PlusLanguage.PlusValidity` and `FormalSystem.Semantics.Reversal`, carrying:
   - `plusTruthAt_rev` — deliverable (3), the seven-case induction, probe 1's body;
   - `plusValidOn_rev_iff`, `plusValidOnFrames_reflectTime`, `plusValidIn_reflectTime` — the L⁺
     `thm:TR-valid` family, probe 1's bodies, mirroring `Semantics/Validity.lean:514-555`
     statement for statement;
   - optionally `plusValid_reflectTime` and a `plusValidIn_reflectTime_iff`, to complete the
     mirror of the base family (`Semantics/Validity.lean:562-576`).

**Phase B — the Determined-class closure.**

4. In `FormalSystem/Metalogic/Deterministic/Validity.lean` (add the
   `FormalSystem.PlusLanguage.PlusReversal` import):
   - `determinedValid_rev` — deliverable (4), by the paper's mirror-image argument:
     `plusValidOn_rev_iff` at the instance `φ.reflectTime → ⊡φ.reflectTime`, whose own
     reflection is `φ → ⊡φ` by `reflect_time_involution`. Probe 2's body.
   - `determinedSat_rev` = `⟨FrameClass.Sat.rev h.1, determinedValid_rev h.2⟩`.
   - `plusValidDeterminedIn_reflectTime` — deliverable (4)'s consequence, the BL⁺ `thm:TR-valid`
     over `C^⊡`.
5. Also land `deterministic_rev` (in `Semantics/FrameProperty.lean`, beside
   `deterministic_iff`) and `detSat_rev` + `plusValidDetIn_reflectTime` (in
   `Deterministic/Validity.lean`). Not named in the dispatch, but it is three lines, it is
   compiled, and without it the reflection story stops one class short of the pair
   `cor:deterministic-completeness` is about. Flagging rather than assuming: if the user wants
   the dispatch's deliverable list honoured to the letter, drop this item — nothing else depends
   on it.

**Phase C — the recorded decision and registration.**

6. Deliverable (5): **keep the present route**; record the decision in
   `det_derivable_valid_and_reflect_time_validDeterminedIn`'s docstring. See Decisions below for
   the reasoning and the wording to mirror.
7. Register the new module: one `import` line in `FormalSystem.lean` (sorted block near
   `:554`) and one in `FormalSystem/PlusLanguage.lean` (`:20` block), a bullet in
   `PlusLanguage.lean`'s `## Semantic modules` list, and a regenerated inventory row in
   `FormalSystem/PlusLanguage/README.md` via `bash scripts/readme-inventory.sh`.
8. Verify with `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
   detached, per `context/project/lean4/operations/long-builds.md`.

**On stating "onto" faithfully.** Deliverable (2)'s paper wording is an image claim. Two options:
- *Pointwise only* (`sameState_rev_iff`): what the induction consumes, lowest cost, promotable.
- *Pointwise plus image*: additionally state `image_rev_stabClass` (probe 4). This requires
  `stabClass`, currently `OpenLanguage.stabClass`
  (`FormalSystem/OpenLanguage/OpenClasses.lean:74-76`), above the Plus layer.
  `stabClass` mentions only `WorldHistory.state` and could be promoted to `Semantics/` on the
  same argument as `sameState_rev_iff`; its two siblings `openFutureClass` / `openPastClass`
  could **not** follow it, since they rest on `AgreeUpTo` / `AgreeFrom` from
  `PlusLanguage/PlusPasting.lean`, so the promotion splits a module that currently reads as one
  subject.

Recommendation: state the pointwise form in `Semantics/Reversal.lean` and the image form
**in the Open layer beside `stabClass`**, where `stabClass` already lives and where
`OpenClasses.lean`'s subject matter is exactly these three classes. That honours the paper's
"onto" on the nose, needs no module split, and keeps the Plus layer's induction fed by the
pointwise lemma. If a future task wants the image form at the Plus layer, promoting `stabClass`
is the move — and then `OpenClasses.lean` keeps only the two agreement classes.

## Decisions

1. **Deliverable (1) is closed as already-present**, not re-implemented.
   `PlusFormula.reflectTime` and its simp family are in the tree with the Stability clause
   already commuting. Re-adding or re-stating them would duplicate
   `FormalSystem/PlusLanguage/Formula.lean:218-300`.
2. **Deliverable (2) is delivered by promotion, not by a second copy.** Writing a Plus-local
   `sameState_rev_iff` would make three copies of a three-line, language-free fact. Promoting to
   `Semantics/Reversal.lean` leaves one.
3. **A new module `PlusLanguage/PlusReversal.lean`, not an extension of `PlusValidity.lean`.**
   `PlusValidity.lean` already transitively imports `Semantics.Reversal` (through
   `Semantics.Validity`), so merging would compile. A separate module is recommended anyway: it
   mirrors `OpenLanguage/OpenReversal.lean` one-for-one, which is what makes the two layers
   readable side by side, and it keeps `PlusValidity.lean` on its stated subject (the validity
   predicates and the `ofFormula` conservativity bridge).
4. **Deliverable (5): the Deterministic soundness TR case KEEPS its present route**, and the
   availability of (4) is recorded in the docstring as an independent second route.
   `FormalSystem/Metalogic/Soundness.lean:1294-1307` already decided this question for the base
   layer and gave three reasons; the second reads, in the tree's own words, that
   *"Three sibling language layers — `plus_derivable_valid_and_reflect_time_validIn`,
   `star_derivable_valid_and_reflect_time_validIn` and the Deterministic variant — describe
   themselves as mirroring this recursion arm for arm."* Switching only the Deterministic copy
   to consume (4) would falsify that sentence and leave the four recursions in three different
   shapes. The third reason — that the two routes are independent derivations and keeping both
   is a genuine cross-check — applies verbatim here: `detAxiom_validDeterminedIn` plus
   `plusValidDeterminedIn_reflectTime` derives
   `detAxiom_reflect_time_validDeterminedIn` on its own, and that is worth recording precisely
   because it is a second path to the same validities.
   The docstring should say so in the shape
   `Metalogic/Soundness.lean:1252-1259` uses for `axiom_reflect_time_validIn_min`: name the
   second route, name what it discharges, and point at the base-layer record for why the paired
   shape is kept.
5. **`PlusStateLocal` is not involved.** The dispatch's gloss is corrected in Literature Proof
   Structure above; no edit to `PlusStateLocal.lean` is recommended or needed.

## Risks & Mitigations

- **Territory collision with concurrent sibling 798.** 798's declared `file_scope` includes
  `FormalSystem.lean`, `FormalSystem/README.md` and `README.md`; this task must add one `import`
  line to `FormalSystem.lean`. *Mitigation*: sequence that edit last, re-read `FormalSystem.lean`
  immediately before editing it, and stage only this task's hunk — never a directory or glob
  `git add`. Recorded in the issue log.
- **Generated-artifact overlap.** `FormalSystem/PlusLanguage/README.md` carries a
  `<!-- BEGIN GENERATED: inventory -->` block, regenerated by `scripts/readme-inventory.sh`; 798
  also touches generated artifacts (`typst/generated/status.typ`). *Mitigation*: run
  `readme-inventory.sh` scoped and commit only the `PlusLanguage/README.md` diff.
- **`deterministic_rev` needs regularity and the obvious one-liner is wrong.** Documented under
  Compiled Probes with the working route. *Mitigation*: the plan should carry the working body,
  not the shape that reads natural.
- **Cycle and invariant checkers.** `scripts/check-metalogic-cycles.sh` enforces the
  per-file layering inside `PlusLanguage/` (syntax modules import nothing from `Semantics/`;
  semantic modules may). `PlusReversal.lean` is a semantic module importing `Semantics/`, which
  is the permitted direction. *Mitigation*: run `check-metalogic-cycles.sh` and
  `check-module-invariants.sh` in the verification phase.
- **No zero-debt risk.** Every deliverable was compiled before this report was written. No
  `sorry`, no new axiom, no `[BLOCKED]` candidate.

## Unification Finding (reported, not acted on)

The dispatch asks whether the base, Plus and Open reversals can be unified behind one transport.
**Not with the current layers.** The detail:

- The base transport is generic *within* its language: `truthAt_rev` is
  `Truth.truthAt_of_truthAntiIso (revAntiIso M)` and runs no induction of its own
  (`Semantics/Reversal.lean:141-143`). But `TruthAntiIso` and `truthAt_of_truthAntiIso`
  (`Semantics/TruthTransport.lean:428-504`) are **`Formula`-only**: the structure's `atom` field
  is `Formula`'s atom and the induction is over `Formula`'s six constructors.
- `Semantics/Reversal.lean:29-31` already records why the generic route stops at L: a clause
  quantifying over a *class* of histories "is not what an atom-level `TruthAntiIso` does". That
  diagnosis names `⊡` explicitly, so it applies to L⁺ exactly as it does to L^▷.
- A generic transport would need a `TruthAntiIso` variant carrying one extra field —
  `∀ τ σ t, τ.state t = σ.state t ↔ (hist τ).state (dur t) = (hist σ).state (dur t)`, which is
  precisely the promoted `sameState_rev_iff` in abstract form — **and** an induction principle
  for an arbitrary language. The clause layer `Semantics/TruthClauses.lean` supplies clause
  *lemmas* through `TruthEnv` / `BotClause` / … / `StabClauses` (`:187-301`) but **no recursor
  and no `reflectTime`**. So the generic lemma is not expressible against the existing classes:
  it needs a new `ReflectableLanguage L` class carrying `reflectTime : L → L` plus an induction
  principle, with each language supplying its own instance.
- Nor can the three be reduced pairwise. L^▷ cannot be derived from L⁺ via `ofPlus`: `ofPlus`
  only reaches the image of L⁺ in L^▷, and `openTruthAt_rev` must hold for arbitrary
  `OpenFormula`, so all nine cases stay. The reverse derivation is barred by import direction.
- Also relevant to a future attempt: only two of the five object languages have a reversal
  transport today. `MinusLanguage/` and `StarLanguage/` have none, and L⋆ would not inherit one
  for free — `starTruthAt_timeShift` already shifts the stored-time vector separately
  (`Metalogic/Soundness.lean:120-130`), so a reflection there is its own problem.

**Verdict**: a `ReflectableLanguage` class is a design change with four or five instances to
write, not a refactor, and it is correctly out of scope here. The deduplication that *is*
available now — one copy of the carrying lemma instead of two, and optionally `stabClass`
promoted — is folded into the recommendations above.

## Tactic Survey Results

Tactics were exercised through full compiled probes rather than `lean_multi_attempt` at a goal
position, because every obligation here is a transport whose body is a known structural
argument. No search tactic (`aesop`, `omega`, `decide`, `simp`) was needed or used; all five
candidate declarations closed by explicit structural terms.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `sameState_rev_iff` | `change` + `rw [neg_neg]` | success | `WorldHistory.rev_state` by `rfl` |
| `plusTruthAt_rev` | `induction φ generalizing τ t` + explicit terms | success | `WorldHistory.rev_surjective`, `neg_lt_neg`, `neg_lt_neg_iff`, `sameState_rev_iff` |
| `plusValidOn_rev_iff` | `constructor` + `rw [neg_neg]` | success | `plusTruthAt_rev`, `WorldHistory.rev_surjective` |
| `plusValidIn_reflectTime` | term-mode | success | `FrameClass.Sat.rev` (no closure hypothesis needed) |
| `reflect_determined` | `simp only [PlusFormula.reflectTime, reflect_time_involution]` | success | the `reflect_time_*` family |
| `determinedValid_rev` | `rwa [reflect_determined]` | success | `plusValidOn_rev_iff` at the mirrored instance |
| `deterministic_rev` | `fun w d => h w (-d)` | **fail** | `F.rev.TaskRel` is the transpose, not the negation |
| `deterministic_rev` | `rw [deterministic_iff]` + `rev_taskRel_neg` | success | needs `[F.IsRegular]` |
| `image_rev_stabClass` | `ext` + `rintro`/`obtain` | success | `sameState_rev_iff`, `WorldHistory.rev_surjective` |

## Context Extension Recommendations

- **Topic**: where a language-free semantic lemma belongs when it is first needed by an upper
  language layer.
  **Gap**: the tree has no recorded rule for this, and the result is visible —
  `sameState_rev_iff` and `stabClass` are both language-free `WorldHistory` facts that live in
  `OpenLanguage/` because L^▷ needed them first, and the Plus layer cannot reach either. The same
  shape will recur the next time a lower language layer needs something an upper one already
  has.
  **Recommendation**: add a short section to `context/project/lean4/patterns/` (or a note in
  `FormalSystem/Semantics/README.md`) stating the test — *does the statement mention any
  `Formula` type? if not, it belongs at the lowest layer that can state it* — and naming this
  promotion as the worked example.
- **Topic**: the paired-companion-recursion convention across the five language layers.
  **Gap**: the decision record is a long docstring buried at
  `FormalSystem/Metalogic/Soundness.lean:1294-1307`, and each of the four sibling recursions
  restates only that it "mirrors" the base one. A sixth layer would have to find that docstring
  to learn why.
  **Recommendation**: a one-page note in `context/project/lean4/domain/` naming the convention,
  the three reasons, and the four current sites, so the next language layer inherits the
  decision rather than re-deriving it.

## Appendix

### Probe sources

All four probes ran against the live project through `lean_run_code`; bodies are reproduced in
the Recommendations and Tactic Survey sections at the level of detail the plan needs. Probe
imports used: `FormalSystem.PlusLanguage.PlusValidity` + `FormalSystem.Semantics.Reversal`
(probe 1), `FormalSystem.Metalogic.Deterministic.Validity` (probes 2, 3),
`FormalSystem.Semantics.Reversal` (probe 4).

### Searches and commands used

- `grep -rn "reflectTime\|reflect_time" --include=*.lean FormalSystem/` — established deliverable
  (1) is present
- `grep -rln "truthAt_rev\|revAntiIso\|revHistEquiv\|validOn_rev_iff"` — established the base
  dependency has landed and found the two existing reversal modules
- `grep -rn "sameState_rev_iff"` — found the duplicate-to-be and every doc site naming it
- `grep -n "^import" FormalSystem/OpenLanguage/*.lean` — established the L^▷ > L⁺ layering that
  forbids reuse in place
- `grep -rn "Determined\|Deterministic" | grep "def \|structure \|abbrev "` — located
  `DeterminedValid`, `DeterminedSat`, `Deterministic`
- `sed -n '437,520p' appendix_cut_material.tex` — the verbatim specification
- `mcp__lean-lsp__lean_local_search` on `FrameClass.` returned `index: error`; per the
  readiness-context interpretation rule that is **not** proof of absence, so the
  `FrameClass.Sat.isRegular` name was confirmed by `grep` and then by a compiling probe instead.
  This is the one place where the evidence tier degraded from LSP-backed lookup to grep plus
  compiled probe — and the probe is the stronger evidence of the two.

### References

- `FormalSystem/Semantics/Reversal.lean` — base `lem:time-reflection`, and the recorded reason
  the generic `TruthAntiIso` route stops at L
- `FormalSystem/Semantics/TruthTransport.lean` — `TruthCorr`, `TruthIso`, `TruthAntiIso`,
  `truthAt_of_truthAntiIso`
- `FormalSystem/Semantics/Validity.lean:498-576` — the base `thm:TR-valid` family to mirror
- `FormalSystem/Semantics/FrameClassValidity.lean:225-271` — `Sat.isRegular`, `Sat.rev`
- `FormalSystem/OpenLanguage/OpenReversal.lean` — the one-language-up precedent, body for body
- `FormalSystem/OpenLanguage/OpenClasses.lean:74-76` — `stabClass`, the named `⟨τ⟩_x`
- `FormalSystem/PlusLanguage/Formula.lean:214-300` — `PlusFormula.reflectTime` and its family
- `FormalSystem/PlusLanguage/PlusTruth.lean:84-93` — the `stab` clause, the inlined `⟨τ⟩_x`
- `FormalSystem/Metalogic/Deterministic/Validity.lean`, `.../Soundness.lean` — the Determined
  class and the TR route deliverable (5) rules on
- `FormalSystem/Metalogic/Soundness.lean:1252-1307` — the base-layer decision record deliverable
  (5) follows
