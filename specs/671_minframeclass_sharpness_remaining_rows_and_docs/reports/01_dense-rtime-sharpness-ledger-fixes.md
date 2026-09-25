# Research Report: minFrameClass sharpness for the remaining rows, and the two documentation defects

- **Task**: 671 - Prove the MINIMALITY half of `Axiom.minFrameClass` for `density`, `dense_indicator`, `prior_U_gap` and `sep`, and correct two pre-existing documentation defects in the files that work already edits
- **Started**: 2026-09-25T00:00:00Z
- **Completed**: 2026-09-25T00:00:00Z
- **Effort**: ~3 hours (research only)
- **Dependencies**: the `.ZTime` full-characterization work — **landed** (`FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`, 423 lines, carrying `not_validIn_dense_*`, `not_validIn_rtime_*` and the two `validIn_iff_ztime` biconditionals)
- **Sources/Inputs**:
  - Lean source: `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`, `FormalSystem/Metalogic/Independence/CoNotPriorU.lean`, `FormalSystem/Metalogic/Independence/ClockFrame.lean`, `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, `FormalSystem/Semantics/Correspondence/Indicator.lean`, `FormalSystem/Semantics/FrameClassValidity.lean`, `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/DurationClassification.lean`, `FormalSystem/Metalogic/Soundness.lean`, `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean`, `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Automation/Normalization.lean`
  - Ledgers: `FormalSystem/Metalogic/Independence.lean`, `FormalSystem/Metalogic/Independence/README.md`, `FormalSystem/Metalogic/README.md`, `README.md`
  - Gates: `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`, `scripts/c20-declaration-baseline.txt`, `scripts/module-invariants-manifest.txt`
  - Prior artifacts: `specs/670_minframeclass_sharpness_prior_uz_z1/reports/01_ztime-sharpness-countermodels.md`, `specs/672_ztime_full_characterization_and_axiom_pin/summaries/01_ztime-characterization-axiom-pin-summary.md`
  - Mathlib: `Mathlib/Data/Finsupp/Lex.lean` (probed for the `sep` witness carrier)
  - Elaboration: `lake env lean` against the current built tree (no full rebuild performed)
- **Artifacts**:
  - `specs/671_minframeclass_sharpness_remaining_rows_and_docs/reports/01_dense-rtime-sharpness-ledger-fixes.md`
- **Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: `Semantics/Correspondence/DurationFrames.lean` (`translationFrame`, `translationModel`, `translationHist`, `translation_realizes_allFuture`), `Semantics/Correspondence/Indicator.lean` (`validOn_neg_nextTop_iff`), `Metalogic/Independence/CoNotPriorU.lean` (`priorUGapFormula`, `priorUGapFormula_false`, `clockModel`, `clockHistory`), `Metalogic/Independence/ClockFrame.lean` (`clockFrame`, `clockFrame_isRegular`), `Metalogic/Soundness.lean` (`axiom_validIn_min`, `density_valid`, `dense_indicator_valid`, `soundness_validIn`), `Semantics/DurationClassification.lean` (`duration_dense_or_least_pos`)
- **Downstream Dependents**: `Axiom.minFrameClass`'s docstring; `Metalogic/Independence.lean` and `Metalogic/Independence/README.md` ledgers; four generated inventory blocks
- **Alternative Paths**: none needed for three of the four rows — each has a one-step route through machinery already in the tree
- **Potential Extensions**: full `validIn_iff` characterizations (not merely minimality) for both `.Dense` rows; a `.ZTime`-validity result for `prior_U_gap`; the `sep` row

## Executive Summary

- **Three of the four rows are closed, and the Lean is already written and elaborated.** A single candidate module covering `density`, `dense_indicator` and `prior_U_gap` compiles with zero errors, zero `sorry`, and `#print axioms` exactly `[propext, Classical.choice, Quot.sound]`, against the current built tree. The full verified source is in Appendix A; it can be committed close to as-is.
- **Two of them come out stronger than minimality.** For `density` and `dense_indicator` the four-way case split closes, giving `ValidIn fc φ ↔ FrameClass.Dense ≤ fc` — a full characterization matching what `ZTimeSharpness.lean` achieved for the `.ZTime` row, at no extra cost (the `.ZTime` refutation reuses the very same ℤ witness).
- **The `sep` row is genuinely open, and the obstruction is now proved rather than guessed.** `sep_validOn_of_isLeastPos` (Appendix B, also elaborated) shows `sep` is *vacuously valid* on every frame with a least positive duration, because `K⁺φ` is false everywhere there. With `duration_dense_or_least_pos`, that means **no discrete witness can exist**: any `.Base`/`.Dense` refutation must run over a densely ordered duration group. `sep_valid`'s own docstring then narrows it further (separability rescues `sep`), and `Separability.lean:28-31` already records the exact refuting configuration — the lexicographic square at `t = (0,1)` with region `{(a,0) : 0 < a < 1}` — which is not a group. A group-shaped analogue exists (`Lex (ℚ →₀ ℚ)` with region `{toLex (single γ 1) : γ > 0}`; carrier instances probed and working) but costs ~350-450 new lines. **Recommend: ship the three rows, and close `sep` as a reasoned exclusion carrying `sep_validOn_of_isLeastPos` as the evidence.**
- **Documentation defect 1 is misdiagnosed in the task description, and correcting it as written would introduce an error.** `Axioms.lean:16-29` declares three renderings of `untl`; the prefix form `U(e, g)` is deliberately *event-first*, keyed to `Formula.prettyPrint` (`Automation/Normalization.lean:672`, which prints the constructor's **second** argument first). Under that declared convention `prior_UZ`'s prose `F(φ) → U(φ, ¬φ)` is **correct** for the constructor `untl φ.neg φ`. The same holds for all four axioms this task touches. What *is* wrong is two pieces of **infix/English** prose that reverse guard and event: `Axioms.lean:333` ("then p holds until not-p") and `Axioms.lean:447` ("`¬φ ∨ K⁺(¬φ)` holds until φ"). `ZTimeSharpness.lean:130-133`'s shape-pin note, which is what the task description is quoting, is itself the third item to correct.
- **Documentation defect 2 is bigger than a count mismatch.** The two ledgers enumerate *different result sets* (6 vs 9; their union is 10), `Independence.lean`'s Contents list omits 6 of the 24 imported modules, and `Independence/README.md:126-128` cites two **non-existent** Lean identifiers (`sat_dedekind_ssubset_mod_axiomSet`, `sat_discrete_ssubset_mod_axiomSet`; the real names are `sat_rtime_…` / `sat_ztime_…`).
- **Gate coupling is worse than the dispatch states, in one specific way.** Editing `Axioms.lean` shifts every `ProofSystem/Axioms.lean:NNN` citation in the tree (16 live ones), and C20's declaration-span assertion is enforced against a baseline that currently carries **no** `Axioms.lean` entry. There is a fast escape: `bash scripts/check-module-invariants.sh --no-build` runs the whole structural pass (C4-C34) without `lake build`, so every documentation iteration can be gated for free and the single budgeted full rebuild spent once at the end.

## Context & Scope

Researched: whether each of the four `Axiom.minFrameClass` rows tagged `.Dense` or `.RTime` admits a minimality proof (non-validity at every class strictly below the tag) using machinery already in the tree; the true content of the two documentation defects; and the gate surface a single full-rebuild budget has to clear.

Not researched, by the dispatch's SCOPE clause: the `.ZTime` row (already closed in both directions), the compression/adequacy direction, anything in the ModelChecker repository.

Verification method: every Lean claim below was elaborated with `lake env lean` against the currently-built `.lake/build` tree (`ZTimeSharpness.olean` present and current). No `lake build` was run, so no rebuild budget was consumed.

## Findings

### The frame-class order, and what minimality requires per row

`FrameClass`'s `LE` instance (`Axioms.lean:498-506`) gives `Base < Dense < RTime`, `Base < ZTime`, with `Dense`/`ZTime` and `ZTime`/`RTime` incomparable. So:

| Row | Tag | Classes strictly below | Order fact needed |
|-----|-----|------------------------|-------------------|
| `density`, `dense_indicator` | `.Dense` | `.Base` only | `eq_base_of_lt_dense` |
| `prior_U_gap`, `sep` | `.RTime` | `.Base` and `.Dense` | `base_or_dense_of_lt_rtime` |
| (23 base axioms) | `.Base` | **none** | vacuous — nothing is `< .Base` |

Both new order facts are four-line `cases fc` proofs in `ZTimeSharpness.lean`'s `eq_base_of_lt_ztime` idiom, and both elaborate. The dispatch's warning holds: `by decide` works on `≤` (there is a `DecidableRel` instance at `Axioms.lean:508-509`) but not on `<`, so the shape is `absurd h.le (by decide)`.

Worth recording in the `minFrameClass` docstring: **the `.Base` row is vacuously sharp** — `¬ ∃ fc, fc < FrameClass.Base` (elaborated). With the three rows below closed, only `sep` leaves the ledger incomplete.

### Row 1 — `density` (`GGφ → Gφ`, `.Dense`): closed, and characterized

The route in the dispatch (the `→` direction of `validOn_dn_iff_denselyOrdered`) does **not** compose directly: that biconditional's left side is `∀ (F : FrameOver D) (φ : Formula), …`, whereas `ValidIn .Base ψ` fixes one `ψ`. Rather than adapt it, a direct refutation is shorter and reuses exactly the `ZTimeSharpness.lean` kit:

- `not_validOn_density_of_isLeastPos D hp a` — on `translationFrame D` with `A = {x | x ≠ p}` for `p` the least positive duration: `GGp` holds at `0` because `s > 0` forces `p ≤ s` and then `r > s ≥ p` forces `r ≠ p`; `Gp` fails at `p`. Nine lines, no `omega`, fully generic in `D`.
- Instantiated at `denseSharpOrder := TemporalOrder.of ℤ` (with `isLeast_one_denseSharpOrder`), this gives `not_validIn_base_density`.
- `density_minFrameClass_sharp` follows by `eq_base_of_lt_dense hfc ▸ …`.

**Bonus, free**: the *same* ℤ witness also satisfies `Sat .ZTime` (via `TaskFrame.isZTime_of_instances`, elaborated), so `not_validIn_ztime_density` costs one extra line, and a four-way `cases fc` with `density_valid` and `ValidIn.mono` assembles

```
density_validIn_iff : ValidIn fc (GG p → G p) ↔ FrameClass.Dense ≤ fc
```

This is the `.Dense`-row analogue of `prior_UZ_validIn_iff_ztime`, and unlike the `.ZTime` case the right-hand side is an order condition rather than an equality, because `.Dense ≤ .RTime`.

The atomic-instance caveat is **not** binding here the way it is for `prior_UZ`: `density` is refuted at `Formula.atom p` and the statement is nonetheless stated at an atom, following `ZTimeSharpness.lean`'s practice, because the refuting valuation is built from the chosen set `A`.

### Row 2 — `dense_indicator` (`¬U(⊤,⊥)`, `.Dense`): closed, and characterized

The dispatch's one-step route is real. `Axiom.dense_indicator`'s formula `(Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg` is **definitionally** `(Formula.next Formula.top).neg` (`example … := rfl`, elaborated), so `Indicator.lean`'s

```
validOn_neg_nextTop_iff (F) [F.IsRegular] : F.ValidOn (Formula.next Formula.top).neg ↔ DenselyOrdered F.Duration
```

applies verbatim. With `not_denselyOrdered_of_isLeastPos` (three lines) at the same ℤ witness, `not_validIn_base_dense_indicator` and `not_validIn_ztime_dense_indicator` are each two lines, and `dense_indicator_validIn_iff` assembles as above.

`dense_indicator` carries no `(φ : Formula)` parameter, so the atomic-instance point does not arise at all for this row — the statement is about a single closed formula.

### Row 3 — `prior_U_gap` (`.RTime`): closed, both classes at once

`CoNotPriorU.lean:288`'s `priorUGapFormula_false a : ¬ TruthAt clockModel clockHistory 0 (priorUGapFormula (atom a))` lifts to a frame-level refutation in one step, because `TaskFrame.ValidOn` quantifies over model, history and time:

```
not_validOn_prior_U_gap_clock a := fun h => priorUGapFormula_false a (h clockModel clockHistory 0)
```

and `clockFrame`'s duration group is `ℚ`, which is densely ordered, so the *same* refutation discharges `Sat .Dense` (`⟨inferInstance, inferInstance⟩`) and `Sat .Base` (`inferInstance`). `base_or_dense_of_lt_rtime` then gives `prior_U_gap_minFrameClass_sharp` by an `rcases`. All elaborated.

**The frame-versus-model caveat does not bite, and the criterion the `.ZTime` work established is exactly why.** `CoNotPriorU.lean:28-38` records that *its* statement had to be model-fixed, because it must simultaneously **validate** `CO` while refuting Prior-U, and on a valuation-rich dense flow frame-validity of `CO` already forces Prior-U. The statements here validate nothing: they are bare `¬ ValidOn` / `¬ ValidIn` claims, and a `¬ ValidOn` claim is *weaker* than `CoNotPriorU`'s model-fixed refutation, not stronger — it follows from it. So this row is frame-level for free and no obstruction is in play. This must be said in the new module's docstring, per the dispatch, rather than discovered later.

**Deliberately not claimed**: nothing about `ℚ` specifically, and nothing about `.ZTime`. (`prior_U_gap` looks *valid* at `.ZTime` — on a discrete flow the least future `¬φ` point exists and witnesses the consequent, and `K⁺` is inert — but that is a conjecture here, unproved, and would be the only route to a full `validIn_iff` for this row. It is not needed for minimality.)

### Row 4 — `sep` (`.RTime`): open, with the obstruction now proved

**Proved here (Appendix B, elaborated):**

```
not_kPlus_of_isLeastPos : IsLeast {x : F.Duration | 0 < x} p → ¬ TruthAt M τ t (Formula.kPlus φ)
sep_validOn_of_isLeastPos : IsLeast {x : F.Duration | 0 < x} p → F.ValidOn (Axiom.sep φ's formula)
```

`K⁺φ = ¬U(⊤, ¬φ)` asserts that `φ` recurs in every right-neighbourhood; the immediate successor `t + p` makes `(t, t+p)` empty, so `U(⊤, ¬φ)` is true and `K⁺φ` false at every point. `sep`'s antecedent has `K⁺φ` as its first conjunct, so `sep` is *vacuously* valid on every such frame. Combined with `Semantics.duration_dense_or_least_pos` (`DurationClassification.lean:342`) — every duration group is densely ordered or has a least positive element — this yields:

> **No discrete witness for `sep` can exist.** Any refutation at `.Base` must run over a densely ordered duration group; and since `Sat .Dense F → Sat .Base F`, one dense witness would close both classes at once (exactly the `prior_U_gap` pattern).

**What the tree already knows about the dense side.** `SoundnessLemmas/Separability.lean:26-38` and `Soundness.lean:1035-1046` state, in the repository's own words, that `sep` is false on the lexicographic square `[0,1] ×ₗₑₓ [0,1]` **at `t = (0,1)` with the φ-region `{(a,0) : 0 < a < 1}`**, and that what rescues `sep` on a duration group is `AddCommGroup + IsOrderedAddMonoid + DenselyOrdered + Nontrivial` *plus the LUB hypothesis*, which force Archimedean-ness and hence separability. So the missing witness is a densely ordered duration **group** replaying that configuration.

**Why the recorded configuration does not transfer as-is.** The lex square works because `t = (0,1)` is the *top* of its fibre, so its entire right-neighbourhood is the uncountable fibre family. A group has no fibre tops. Concretely, in `ℝ ×ₗ ℝ` or `ℚ ×ₗ ℚ` at `t = 0`, the antecedent's first conjunct `K⁺φ` forces the φ-region to accumulate inside the infinitesimal fibre `{0} × (0, y)`, which is order-isomorphic to a real/rational interval — so the whole problem collapses back to the separable one-level case, and `sep` survives. **The value group (the set of Archimedean classes) must itself be densely ordered.**

**The witness that does work, and its cost.** Take `D = Lex (ℚ →₀ ℚ)` (finitely supported functions `ℚ → ℚ` under the lexicographic order, which compares at the least differing index, so `toLex (single γ 1)` is *strictly antitone* in `γ` — `Finsupp.Lex.single_strictAnti`). Take the φ-region `S = {toLex (single γ 1) : γ ∈ ℚ, γ > 0}`. Then:

1. `K⁺p` at `0`: for any `ε > 0` with least support index `μ`, any `γ > max(μ, 0)` gives `0 < e_γ < ε`.
2. no point of `S` has an immediate `S`-successor (density of `ℚ` as the *index* set), so `ψ := p ∧ U(p, ¬p)` is false everywhere and the second antecedent conjunct holds.
3. no `u > 0` is a left limit of `S`: with `γ` above every index in `supp u`, the interval `(u - e_γ, u)` is `S`-free — so `K⁻p` fails at every `u > 0` and the consequent `K⁺(K⁺p ∧ K⁻p)` is false at `0`.

Carrier feasibility was probed: `AddCommGroup`, `LinearOrder` and `Nontrivial` synthesize for `Lex (ℚ →₀ ℚ)`; `IsOrderedAddMonoid` does not synthesize but is a three-line instance off Mathlib's `Finsupp.Lex.addLeftMono`/`addRightMono`; and `0 < toLex (single γ 1)` proves in two lines through `Finsupp.Lex.lt_iff` (all elaborated). `TemporalOrder` needs exactly `AddCommGroup + LinearOrder + IsOrderedAddMonoid + Nontrivial` at `Type 0`, which this carrier is.

Estimated cost: ~80 lines of carrier setup (instances, `TemporalOrder.of`, `DenselyOrdered`), ~120 lines of least-support comparison lemmas, ~150 lines of the three semantic facts and assembly — **~350-450 lines**, i.e. one or two dedicated implementation phases, with real risk in the least-support arithmetic.

There is a second, independent route over plain `ℚ` (a bespoke Cantor set all of whose rational points are gap endpoints, so that the φ-region is order-dense in itself with no two-sided limit points) which exploits the *completeness* input to `nested_core` rather than separability. It needs a recursive construction over an enumeration of `ℚ` and is not obviously cheaper.

**Recommendation for this row**: exclude it, with `sep_validOn_of_isLeastPos` shipped as the recorded obstruction and the two routes recorded in the new module's docstring. A `sep` row left open with a *proof* that the obvious witness class is empty is a materially better resting state than the current silence.

### Documentation defect 1 — the diagnosis in the task description does not survive contact with the file

`Axioms.lean:16-29` opens with a notation block declaring three renderings, and it is explicit that they do not agree on argument order:

- `untl(g, e)` — guard first, **constructor order**;
- `φ U ψ` infix — guard first, the paper's order;
- `U(e, g)` prefix — **event first**, "keyed to what the printer emits".

That last claim checks out: `Automation/Normalization.lean:672` is `| .untl ψ φ => "U(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"` — the constructor's first argument is printed second.

Consequently, for the constructor `prior_UZ φ : Axiom (φ.someFuture.imp (Formula.untl φ.neg φ))` — guard `¬φ`, event `φ` — the prefix rendering **is** `U(φ, ¬φ)`, which is exactly what the docstring writes. Checking the neighbours, as the dispatch instructs, the same verdict holds for all of them:

| Axiom | Constructor's `untl` | Prefix rendering it entails | Docstring writes | Verdict |
|-------|----------------------|------------------------------|------------------|---------|
| `prior_UZ` | `untl φ.neg φ` | `U(φ, ¬φ)` | `U(φ, ¬φ)` | correct |
| `dense_indicator` | `untl ⊥ ⊤` | `U(⊤, ⊥)` | `¬U(⊤,⊥)` | correct |
| `density` | (none) | — | `GGφ → Gφ` | correct |
| `prior_U_gap` | `untl φ ⊤`, `untl φ (¬φ ∨ K⁺¬φ)` | `U(⊤, φ)`, `U(¬φ ∨ K⁺(¬φ), φ)` | both, verbatim | correct |
| `sep` | `untl φ.neg φ` | `U(φ, ¬φ)` | `U(φ,¬φ)` | correct |

**So "resolve it in favour of the constructor and correct the prose" must not be executed as written**: rewriting `U(φ, ¬φ)` to `U(¬φ, φ)` would break the file's declared prefix convention and desynchronise the docstring from `prettyPrint` and from `typst/generated/machine-appendix.jsonl`'s `schema_string`.

What is genuinely defective is **infix/English prose that reverses guard and event**, which the notation block does not license:

1. `Axioms.lean:333` (a `--` comment, not the docstring): *"then p holds until not-p (i.e., the first future p-point is reachable)"*. Under the infix convention the formula is `¬φ U φ` — "¬φ holds until φ". The parenthetical is right; the clause before it is backwards. Note the `prior_UZ` **docstring** body immediately below ("there is a nearest future time where φ holds, with ¬φ holding at all intermediate points") is already correct, which is why this reads as a leftover.
2. `Axioms.lean:447` (inside the `prior_U_gap` docstring): *"reading forward, `¬φ ∨ K⁺(¬φ)` holds until φ"*. The constructor is `untl φ (¬φ ∨ K⁺¬φ)`: guard `φ`, event the disjunction. So it is `φ` that holds until `¬φ ∨ K⁺(¬φ)`. Exactly reversed.
3. `ZTimeSharpness.lean:130-133`, the shape-pin note: *"`Axioms.lean`'s prose rendering of `prior_UZ` writes the `untl` arguments in the opposite order to the constructor; the pin resolves the question in favour of the constructor."* Literally true about argument positions, but framed as a conflict when it is the declared prefix convention. This note is the source of the task description's misdiagnosis and should be rewritten to say that the prefix rendering is event-first by design and that the pin confirms it.

No proof, statement or definition changes in any of the three. Item 3 is inside `ZTimeSharpness.lean`, which this task does not otherwise need to edit — but leaving it would leave the trap armed for the next reader.

### Documentation defect 2 — the two ledgers, measured

| Site | Says | Actually |
|------|------|----------|
| `Metalogic/Independence.lean:38` | "Six results are carried here" (list 1-6) | 6 entries |
| `Metalogic/Independence/README.md:6` | "Nine results are carried here" (list 1-9) | 9 entries |

They are not the same six. Mapping them:

- Shared: CO ⊬ Prior-U; the two `Sat ⊊ Mod` non-closure witnesses; TM⁺ incomplete at `.Base`; the `.ZTime` characterization.
- **Only in `Independence.lean`**: `Deterministic` is not L⁺-definable (README mentions `deterministic_not_plusDefinable` only parenthetically, inside its result 6, and gives it no number of its own).
- **Only in `README.md`**: `⊡` not L-definable (`StabUndefinable.lean`); the two pasting schemata not derivable (`PastingIndependence.lean`); store/recall discriminate (`StarDiscrimination.lean`); `sent:det` defines only forward determinism (`ForwardDeterministicFrame.lean`).

So the union is **ten** results, and this task adds an eleventh (the `.Dense`/`.RTime` sharpness row). The reconciliation is therefore not "pick 6 or 9" but "adopt the union, renumber both lists identically, and add this task's entry".

Three further defects in the same two files, found while measuring:

- **Dangling identifiers.** `Independence/README.md:126-128` cites `sat_dedekind_ssubset_mod_axiomSet` and `sat_discrete_ssubset_mod_axiomSet`. Neither exists. The declarations are `sat_rtime_ssubset_mod_axiomSet` (`RationalWitness.lean:185`) and `sat_ztime_ssubset_mod_axiomSet` (`LexIntWitness.lean:190`). This is a broken reference, not a naming-style issue.
- **Superseded class names.** `.Dedekind` at `README.md:12, 107, 126, 127` and `.Discrete` at `README.md:13, 98, 127, 128`. Note that two of these (`:98`, `:107`) are **inside the generated inventory block** — but the generator carries existing descriptions across verbatim (`check-module-invariants.sh:420-434`), so they must be edited in place in the README and will survive regeneration. A tree-wide sweep for surviving occurrences under `FormalSystem/` is required before declaring the rename done; note that `FrameClass.ZTime`/`.RTime` are the current spellings but `TaskFrame.IsDiscrete` is a *live, correct* predicate name that must **not** be renamed (see `Indicator.lean:47-60`, where the Discrete row deliberately splits).
- **Incomplete Contents list.** `Independence.lean` imports 24 modules but its `## Contents` list bullets only 18. Missing: `CoarsenedModels`, `PastingIndependence`, `StarDiscrimination`, `ForwardDeterministicFrame`, `StabUndefinable`, `NaiveSystem`.
- **Mangled generated descriptions.** `Independence/README.md:105` (`PastingIndependence.lean`) begins `` ` — refuting both pasting schemata`` and `:110` (`StarDiscrimination.lean`) begins `` = [3/2, ∞)`)`` — both look like truncated extractions. They are hand-maintained cells, so they can simply be rewritten.

Also inherited from the `.ZTime` characterization work, and in scope because this task edits the same docstring: `Axiom.minFrameClass`'s "Lower bound, for the ZTime row only" paragraph still describes only *minimality* (`prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp`) although the stronger `prior_UZ_validIn_iff_ztime` / `z1_validIn_iff_ztime` have landed, and its closing sentence — "The Base, Dense and RTime rows carry the upper bound **only** … the corresponding sharpness results do not exist yet" — becomes false the moment this task lands.

### Gate surface for one full-rebuild budget

- **`--no-build` is the lever the dispatch does not mention.** `bash scripts/check-module-invariants.sh --no-build` runs every structural check (C4-C34, C9D, B0-B3) and skips only C1/C2/C6/C16/C24/C25. It completes in well under the 900s timeout and is **currently green** (verified). Every documentation edit can be iterated against it for free; the single full rebuild is then spent once, at the end, on `lake build` + the build-dependent checks.
- **`scripts/readme-lint.sh` is currently PASS** (verified). Its five `STALE DATE` findings are warnings only and do not affect the exit code; `FormalSystem/README.md`'s stamp is already stale.
- **`--emit-inventory` touches four blocks for this task**, not three:
  1. `FormalSystem/Metalogic/Independence/README.md` — the per-file table gains a row for the new module, initially as `<!-- TODO: add description -->`, which **must be filled in** before the final `--emit-inventory --check`.
  2. `FormalSystem/Metalogic/README.md:98` — the aggregators table's `Independence.lean | 140` line count (this is precisely the row that broke during the `.ZTime` work, at 123 → 133).
  3. `FormalSystem/Metalogic/README.md:158` — the subdirs rollup `Independence/ | 24 | 6,585`.
  4. `README.md:19-24` (repository root) — the `rows=totals` block: live file count, lines of code, comment lines. This one moves for the `Axioms.lean` docstring edits alone.
  `FormalSystem/README.md:274`'s `rows=loose` block is **not** affected (it lists only files directly under `FormalSystem/`), and `FormalSystem/ProofSystem/README.md` carries no inventory block at all.
- **C33 requires regenerating the library root.** `scripts/module-invariants-manifest.txt` is deliberately empty and must stay empty, so the new module must be imported from `Metalogic/Independence.lean`, and `FormalSystem.lean` must be regenerated with `lake exe mk_all --lib FormalSystem` (C33 is enforced and compares byte-for-byte).
- **C20 is the sharpest new risk, and the dispatch does not name it.** There are 16 live `ProofSystem/Axioms.lean:NNN` citations (in `Expressiveness/PriorDefsDense.lean`, `Expressiveness/Kamp/KPlusFaithful.lean`, `Expressiveness/Kamp/PriorINF.lean`, `BXCanonical/Chronicle/ChronicleMonadicBridge.lean`, `WeakCanonical/DenseModelSurgery/{Singletons,NoGaps}.lean`, `Decidability/Tableau.lean`). `scripts/c20-declaration-baseline.txt` carries **no** `Axioms.lean` entry, and the baseline file "only ever SHRINKS" — a new violation cannot be quieted by adding a key. Growing `Axioms.lean` shifts all 16. Remedy, already in the tree: `python3 scripts/reanchor-lean-citations.py --by-name --files FormalSystem/ProofSystem/Axioms.lean`, then re-read the diff. Also note **C20 tier 2 is enforced**: the new module's docstrings must cite declaration names and file paths *without* `:NNN`, exactly as `ZTimeSharpness.lean` does.
- **C17 (dead-declaration scan)** counts identifiers with zero occurrences outside their declaring line, across `FormalSystem/`, markdown, `typst/**/*.typ` and `scripts/*.sh`. Every new public theorem therefore needs at least one mention outside its own file — which the `minFrameClass` docstring update and the two ledger entries supply naturally, provided the names actually written there match.
- **C19** enforces a 90% docstring-coverage floor (reported, not gated) — the `ZTimeSharpness.lean` practice of a docstring on every theorem keeps this safe.

### Verification performed

Every Lean fragment cited above was elaborated with `lake env lean` against the current build. Specifically, the candidate module in Appendix A elaborated with **zero errors, zero warnings, zero `sorry`**, and

```
'…density_validIn_iff'              depends on axioms: [propext, Classical.choice, Quot.sound]
'…dense_indicator_validIn_iff'      depends on axioms: [propext, Classical.choice, Quot.sound]
'…prior_U_gap_minFrameClass_sharp'  depends on axioms: [propext, Classical.choice, Quot.sound]
```

matching the set `MainResults.lean` pins. Appendix B elaborated the same way. No `lake build` was run; no rebuild budget was consumed by research.

## Decisions

- **Direct refutations, not the `iff`s.** `validOn_dn_iff_denselyOrdered`'s `∀ F ∀ φ` shape does not compose with `ValidIn`'s single-formula shape, so the `density` row uses a nine-line direct `translationFrame` refutation instead. `dense_indicator` does go through `validOn_neg_nextTop_iff`, because that one is stated per-frame.
- **One new module, not two.** `density`, `dense_indicator` and `prior_U_gap` share the order facts, the ℤ witness and the docstring apparatus; splitting them would double the inventory churn and the ledger entries for no gain. Proposed name: `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean`.
- **Claim the characterizations where they are free, and only there.** `density` and `dense_indicator` get `validIn_iff` (`Dense ≤ fc`); `prior_U_gap` gets minimality only, because its `.ZTime` status is unproved and claiming it would be an upgrade the evidence does not support.
- **State each result's form explicitly.** All three are frame-level `¬ ValidOn` lifted to `¬ ValidIn`, and the module docstring must say why the `CoNotPriorU` model-fixed obstruction does not apply (a bare non-validity claim validates nothing) rather than leaving it to be rediscovered.
- **Defect 1 is re-scoped.** The formula renderings are correct and must be left alone; the three prose items listed above are the actual corrections, and `ZTimeSharpness.lean`'s shape-pin note is one of them.
- **Defect 2 is reconciled to the union.** Ten pre-existing results, renumbered identically in both ledgers, plus this task's new entry — not a choice between 6 and 9.
- **`sep` is excluded, with evidence.** `sep_validOn_of_isLeastPos` ships as part of the deliverable so the exclusion is a proved boundary rather than an absence.

## Recommendations

Prioritized, and ordered to respect the dispatch's load-bearing constraint (proof work first, ledger reconciliation last, one full rebuild):

1. **Land the new module first, on the cheap path.** Write `Independence/DenseRTimeSharpness.lean` from Appendix A (plus `sep_validOn_of_isLeastPos` from Appendix B and the `.Base`-vacuity remark), add the import to `Metalogic/Independence.lean`, regenerate `FormalSystem.lean` (`lake exe mk_all --lib FormalSystem`), and verify with `lake env lean` on the single file — **not** `lake build`. Nothing here touches `Axioms.lean`, so no full rebuild is owed yet.
2. **Scoped build of the Independence closure.** `lake build FormalSystem.Metalogic.Independence` via the detached `bash .claude/scripts/lake-build-guard.sh --timeout 1800` shape. This is cheap relative to the full tree and catches import/namespace problems before any `Axioms.lean` edit.
3. **Then batch every `Axioms.lean` edit into one pass**: the two prose corrections (`:333`, `:447`), the `minFrameClass` docstring rewrite (cite the new sharpness theorems and the two `.ZTime` `validIn_iff`s; record the `.Base` row as vacuously sharp; leave `sep` named as the one open row). Correct `ZTimeSharpness.lean:130-133` in the same pass — it is a separate file but costs nothing extra and closes the misdiagnosis at its source.
4. **Reconcile the two ledgers, after every new entry exists.** Adopt the ten-result union, renumber both lists identically, add the eleventh entry, complete `Independence.lean`'s Contents list (six missing modules), fix the two dangling identifiers, sweep `.Dedekind`/`.Discrete` (tree-wide; do **not** touch `TaskFrame.IsDiscrete`), and repair the two mangled generated descriptions.
5. **Gate, in this order.** `bash scripts/check-module-invariants.sh --no-build` (free, iterate until green) → `python3 scripts/reanchor-lean-citations.py --by-name --files FormalSystem/ProofSystem/Axioms.lean` if C20 flags → **only then** `bash scripts/check-module-invariants.sh --emit-inventory` (fill the new module's TODO description) → the single detached full rebuild → `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh`. Regenerating inventories *after* the last docstring edit is what the `.ZTime` incident (123 → 133 lines) teaches.
6. **Close `sep` as `[COMPLETED WITH EXCLUSIONS]`**, recording `sep_validOn_of_isLeastPos` as the proved obstruction, the lex-square configuration already in `Separability.lean:26-38`, the `Lex (ℚ →₀ ℚ)` route with its ~350-450-line estimate, and the plain-`ℚ` Cantor route as the alternative. Spawn it as its own task rather than attempting it inside this one.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| C20 fails after `Axioms.lean` grows (16 live citations shift, empty baseline) | M | H | Run `--no-build` before the full rebuild; `reanchor-lean-citations.py --by-name --files FormalSystem/ProofSystem/Axioms.lean`; never add a baseline key |
| INV fails because a docstring edit grew a file after `--emit-inventory` ran | M | M | Regenerate inventories strictly after the last docstring edit; re-run `--emit-inventory --check` as the last structural step |
| New module's inventory row ships as `<!-- TODO: add description -->` | M | L | Write the description immediately after the first `--emit-inventory`, then re-run `--check` |
| C17 flags a new theorem as dead | L | M | Name every new public theorem in the `minFrameClass` docstring and in both ledgers, with exactly matching spellings |
| C33 fails (library root not regenerated for the new module) | M | M | `lake exe mk_all --lib FormalSystem` as part of step 1, before any gate run |
| The prose "corrections" reverse a *correct* prefix rendering | M | H | The notation block at `Axioms.lean:16-29` and `Normalization.lean:672` are the authority; only infix/English readings are in scope (`:333`, `:447`, `ZTimeSharpness.lean:130-133`) |
| A second full rebuild is incurred | M | M | No `lake build` during authoring — `lake env lean` on the single file, then one scoped Independence build, then one full rebuild at the end |
| `sep` attempted inside this task and overruns | M | H | Exclude it up front with `sep_validOn_of_isLeastPos` as the evidence; spawn a separate task |
| The `.Dense` `validIn_iff` bonus is mistaken for required scope and blocks the row | L | M | It is already elaborated (Appendix A); if it ever resists, drop to `*_minFrameClass_sharp` alone, which is the deliverable the dispatch names |

## Tactic Survey Results

No tactic-portfolio survey was performed: every goal in this task is a small hand-written refutation or a four-way `cases` on a four-constructor inductive, and all of them were closed by explicit term/tactic proofs on the first pass (Appendices A and B, elaborated). The two tactic facts that did matter are recorded as findings rather than as a survey:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `¬ (fc ≤ FrameClass.Dense)` etc. (closed `FrameClass` order goals on `≤`) | `decide` | success | `DecidableRel` instance at `Axioms.lean:508-509` |
| `fc < FrameClass.Dense` directly | `decide` | fail | no `Decidable` instance for `<`; must route through `absurd h.le (by decide)` |
| `r ≠ 1` over `↑(TemporalOrder.of ℤ)` | `omega` | fail | `omega` does not see through the `TemporalOrder.carrier` coercion; either `show (… : ℤ) …` first, or state the lemma generically over `IsLeast {x | 0 < x} p` and use `ne_of_gt` (the route taken) |
| `Sat FrameClass.ZTime (translationFrame (TemporalOrder.of ℤ))` | `⟨inferInstance, TaskFrame.isZTime_of_instances _⟩` | success | bare `constructor`/`refine ⟨…⟩` fails — `IsZTime` is a nested four-component existential |
| `0 < toLex (Finsupp.single γ 1)` in `Lex (ℚ →₀ ℚ)` | `Finsupp.Lex.lt_iff` + `simp` | success | needs the hand-written `IsOrderedAddMonoid` instance off `Finsupp.Lex.addLeftMono`/`addRightMono` |

## Context Extension Recommendations

- **Topic**: the `untl`/`snce` three-rendering convention.
  **Gap**: the convention lives only in `Axioms.lean`'s header, and a reader who meets a rendering anywhere else — or an agent reading a task description written from a partial quote — reconstructs it wrongly. This task's own dispatch inherited exactly that error, and so did `ZTimeSharpness.lean`'s shape-pin note.
  **Recommendation**: a short note in `.claude/context/project/lean4/` (or the logic domain context) stating the rule — constructor and infix are guard-first, prefix `U(e,g)` is event-first because it tracks `Formula.prettyPrint` — with the pointer that a shape-pin `example` is the only reliable arbiter.
- **Topic**: the frame-versus-model refutation criterion.
  **Gap**: recorded in three module docstrings (`CoNotPriorU.lean`, `ZTimeSharpness.lean`, and now a fourth) but nowhere an agent reads before starting. The `670` report already recommended this and it has not landed.
  **Recommendation**: one paragraph stating that frame-level refutation is obstructed only when a statement must *simultaneously validate* something on a valuation-rich flow; a bare non-validity claim is never obstructed.
- **Topic**: the gate-ordering recipe for an `Axioms.lean`-touching change.
  **Gap**: `--no-build`, the C20 re-anchoring script, the C33 `mk_all` requirement and the four inventory sites are each discoverable only by reading `check-module-invariants.sh`'s 5,000-line header.
  **Recommendation**: a short runbook under `.claude/context/project/lean4/operations/` giving the order in Recommendation 5 above.

## Appendix

### A. Verified source for the three closed rows

Elaborated with `lake env lean` against the current build: zero errors, zero warnings, zero `sorry`; `#print axioms` returns `[propext, Classical.choice, Quot.sound]` for the three headline results. Module docstrings are omitted here and are the implementer's to write; the `open`s and imports are exactly what was tested.

```lean
import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Semantics.Correspondence.Indicator
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Independence.CoNotPriorU

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

/-! ## Shape pins -/
example (φ : Formula) : Axiom (φ.allFuture.allFuture.imp φ.allFuture) := Axiom.density φ
example : Axiom (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  Axiom.dense_indicator
example (φ : Formula) :
    Axiom ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
      (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) := Axiom.prior_U_gap φ

/-! ## Order facts -/

theorem eq_base_of_lt_dense {fc : FrameClass} (h : fc < FrameClass.Dense) :
    fc = FrameClass.Base := by
  cases fc with
  | Base => rfl
  | Dense => exact absurd rfl h.ne
  | ZTime => exact absurd h.le (by decide)
  | RTime => exact absurd h.le (by decide)

theorem base_or_dense_of_lt_rtime {fc : FrameClass} (h : fc < FrameClass.RTime) :
    fc = FrameClass.Base ∨ fc = FrameClass.Dense := by
  cases fc with
  | Base => exact Or.inl rfl
  | Dense => exact Or.inr rfl
  | ZTime => exact absurd h.le (by decide)
  | RTime => exact absurd rfl h.ne

/-! ## Generic machinery -/

theorem not_denselyOrdered_of_isLeastPos {D : TemporalOrder} {p : (D : Type)}
    (hp : IsLeast {x : (D : Type) | 0 < x} p) : ¬ DenselyOrdered (D : Type) := by
  intro h
  obtain ⟨c, h1, h2⟩ := h.dense 0 p hp.1
  exact absurd (hp.2 h1) (not_le.mpr h2)

theorem not_validOn_density_of_isLeastPos (D : TemporalOrder) {p : (D : Type)}
    (hp : IsLeast {x : (D : Type) | 0 < x} p) (a : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) := by
  intro h
  set A : Set (D : Type) := {x | x ≠ p} with hA
  have hval := h (translationModel D A) (translationHist D) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel D A) (translationHist D) 0
      (Formula.atom a).allFuture.allFuture := by
    rw [Truth.future_iff]
    intro s hs
    rw [translation_realizes_allFuture]
    intro r hsr
    exact ne_of_gt (lt_of_le_of_lt (hp.2 hs) hsr)
  exact (translation_realizes_allFuture D A a 0).mp (hval hant) p hp.1 rfl

theorem not_validOn_dense_indicator_of_isLeastPos (D : TemporalOrder) {p : (D : Type)}
    (hp : IsLeast {x : (D : Type) | 0 < x} p) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun h => not_denselyOrdered_of_isLeastPos hp
    ((validOn_neg_nextTop_iff (translationFrame D).toTaskFrame).mp h)

/-! ## The integer carrier -/

noncomputable abbrev denseSharpOrder : TemporalOrder := TemporalOrder.of ℤ

theorem isLeast_one_denseSharpOrder : IsLeast {x : (denseSharpOrder : Type) | 0 < x} 1 := by
  refine ⟨show (0 : ℤ) < 1 by omega, fun x hx => ?_⟩
  show (1 : ℤ) ≤ x
  have : (0 : ℤ) < x := hx
  omega

theorem sat_base_denseSharpFrame :
    FrameClass.Sat FrameClass.Base (translationFrame denseSharpOrder).toTaskFrame :=
  inferInstance

theorem sat_ztime_denseSharpFrame :
    FrameClass.Sat FrameClass.ZTime (translationFrame denseSharpOrder).toTaskFrame :=
  ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩

/-! ## Row 1: density -/

theorem not_validIn_base_density (a : Atom) :
    ¬ ValidIn FrameClass.Base
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  fun h => not_validOn_density_of_isLeastPos denseSharpOrder isLeast_one_denseSharpOrder a
    (h _ sat_base_denseSharpFrame)

theorem not_validIn_ztime_density (a : Atom) :
    ¬ ValidIn FrameClass.ZTime
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  fun h => not_validOn_density_of_isLeastPos denseSharpOrder isLeast_one_denseSharpOrder a
    (h _ sat_ztime_denseSharpFrame)

theorem density_minFrameClass_sharp (a : Atom) {fc : FrameClass} (hfc : fc < FrameClass.Dense) :
    ¬ ValidIn fc ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  eq_base_of_lt_dense hfc ▸ not_validIn_base_density a

theorem density_validIn_iff (a : Atom) (fc : FrameClass) :
    ValidIn fc ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture)
      ↔ FrameClass.Dense ≤ fc := by
  refine ⟨fun h => ?_, fun h => ValidIn.mono h (density_valid (Formula.atom a))⟩
  cases fc with
  | Base => exact absurd h (not_validIn_base_density a)
  | Dense => exact le_refl _
  | ZTime => exact absurd h (not_validIn_ztime_density a)
  | RTime => exact (by decide : FrameClass.Dense ≤ FrameClass.RTime)

theorem not_derivable_base_density (a : Atom) :
    ¬ Derivable FrameClass.Base []
      ((Formula.atom a).allFuture.allFuture.imp (Formula.atom a).allFuture) :=
  fun ⟨d⟩ => not_validIn_base_density a (soundness_validIn d)

/-! ## Row 2: dense_indicator -/

theorem not_validIn_base_dense_indicator :
    ¬ ValidIn FrameClass.Base (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun h => not_validOn_dense_indicator_of_isLeastPos denseSharpOrder
    isLeast_one_denseSharpOrder (h _ sat_base_denseSharpFrame)

theorem not_validIn_ztime_dense_indicator :
    ¬ ValidIn FrameClass.ZTime (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun h => not_validOn_dense_indicator_of_isLeastPos denseSharpOrder
    isLeast_one_denseSharpOrder (h _ sat_ztime_denseSharpFrame)

theorem dense_indicator_minFrameClass_sharp {fc : FrameClass} (hfc : fc < FrameClass.Dense) :
    ¬ ValidIn fc (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  eq_base_of_lt_dense hfc ▸ not_validIn_base_dense_indicator

theorem dense_indicator_validIn_iff (fc : FrameClass) :
    ValidIn fc (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg
      ↔ FrameClass.Dense ≤ fc := by
  refine ⟨fun h => ?_, fun h => ValidIn.mono h dense_indicator_valid⟩
  cases fc with
  | Base => exact absurd h not_validIn_base_dense_indicator
  | Dense => exact le_refl _
  | ZTime => exact absurd h not_validIn_ztime_dense_indicator
  | RTime => exact (by decide : FrameClass.Dense ≤ FrameClass.RTime)

theorem not_derivable_base_dense_indicator :
    ¬ Derivable FrameClass.Base []
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun ⟨d⟩ => not_validIn_base_dense_indicator (soundness_validIn d)

/-! ## Row 3: prior_U_gap -/

theorem not_validOn_prior_U_gap_clock (a : Atom) :
    ¬ clockFrame.toTaskFrame.ValidOn (priorUGapFormula (Formula.atom a)) :=
  fun h => priorUGapFormula_false a (h clockModel clockHistory 0)

theorem not_validIn_dense_prior_U_gap (a : Atom) :
    ¬ ValidIn FrameClass.Dense (priorUGapFormula (Formula.atom a)) :=
  fun h => not_validOn_prior_U_gap_clock a
    (h clockFrame.toTaskFrame ⟨inferInstance, inferInstance⟩)

theorem not_validIn_base_prior_U_gap (a : Atom) :
    ¬ ValidIn FrameClass.Base (priorUGapFormula (Formula.atom a)) :=
  fun h => not_validOn_prior_U_gap_clock a (h clockFrame.toTaskFrame inferInstance)

theorem prior_U_gap_minFrameClass_sharp (a : Atom) {fc : FrameClass}
    (hfc : fc < FrameClass.RTime) : ¬ ValidIn fc (priorUGapFormula (Formula.atom a)) := by
  rcases base_or_dense_of_lt_rtime hfc with rfl | rfl
  · exact not_validIn_base_prior_U_gap a
  · exact not_validIn_dense_prior_U_gap a

theorem not_derivable_dense_prior_U_gap (a : Atom) :
    ¬ Derivable FrameClass.Dense [] (priorUGapFormula (Formula.atom a)) :=
  fun ⟨d⟩ => not_validIn_dense_prior_U_gap a (soundness_validIn d)

end FormalSystem.Metalogic.Independence
```

### B. Verified source for the `sep` obstruction

Elaborated the same way (imports: `Semantics.Correspondence.DurationFrames`, `Metalogic.Soundness`).

```lean
/-- On a frame whose durations have a least positive element, `K⁺φ` is false everywhere:
    the immediate successor `t + p` makes the open interval `(t, t+p)` empty. -/
theorem not_kPlus_of_isLeastPos {F : TaskFrame} {p : F.Duration}
    (hp : IsLeast {x : F.Duration | 0 < x} p) (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : Formula) : ¬ TruthAt M τ t (Formula.kPlus φ) := by
  intro h
  refine h ⟨t + p, lt_add_of_pos_right t hp.1, fun hb => hb, ?_⟩
  intro r htr hrp
  exfalso
  have h1 : 0 < r - t := sub_pos.mpr htr
  have h2 : p ≤ r - t := hp.2 h1
  have : t + p ≤ r := by
    have := le_sub_iff_add_le.mp h2
    rwa [add_comm] at this
  exact absurd hrp (not_lt.mpr this)

/-- Hence Sep is valid, vacuously, on every such frame: its antecedent's first conjunct fails. -/
theorem sep_validOn_of_isLeastPos {F : TaskFrame} {p : F.Duration}
    (hp : IsLeast {x : F.Duration | 0 < x} p) (φ : Formula) :
    F.ValidOn ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  intro M τ t hant
  exact absurd ((Truth.and_iff _ _).mp hant).1 (not_kPlus_of_isLeastPos hp M τ t φ)
```

### C. References consulted

- `Axioms.lean` notation block (lines 16-29) and `Automation/Normalization.lean:666-676` — the three renderings and the printer that fixes the prefix order.
- `Semantics/FrameClassValidity.lean:150-154` — `FrameClass.Sat`'s per-tag interpretation, and why it is `@[reducible]`.
- `Semantics/DurationClassification.lean:342-344` — `duration_dense_or_least_pos`.
- `Metalogic/Soundness.lean:1035-1046` and `Metalogic/SoundnessLemmas/Separability.lean:26-47` — the recorded lex-square refutation of `sep` and the separability input.
- `Metalogic/Independence/CoNotPriorU.lean:28-38, 196-292` — the frame-versus-model caveat and `priorUGapFormula_false`.
- `scripts/check-module-invariants.sh` header (lines 8-150) and `:415-475` — the check roster, `--no-build`, and the `--emit-inventory` description-carry-over rule.
- `scripts/c20-declaration-baseline.txt` header — "This file only ever SHRINKS".
