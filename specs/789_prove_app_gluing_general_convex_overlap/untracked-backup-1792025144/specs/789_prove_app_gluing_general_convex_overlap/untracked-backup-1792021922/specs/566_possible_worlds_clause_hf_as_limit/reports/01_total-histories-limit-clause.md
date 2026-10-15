# Research Report: Task #566

**Task**: 566 - Possible worlds clause hf as limit
**Started**: 2026-10-13T09:46:00Z
**Completed**: 2026-10-13T10:34:00Z
**Effort**: 1 implementation round, 3 phases, low risk
**Dependencies**: Task 563 (interval site, behavior presheaf) and Task 565 (Totality, Directed Gluing) — both landed and archived
**Sources/Inputs**:
- `FormalSystem/Semantics/Presheaf/` (Site, Behavior, Sheaf, Ray, Determinism, Directed) read in full at the declaration level
- `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/Extension/Extension.lean`, `FormalSystem/Semantics/IntNormalForm.lean`
- The JPL paper's `app:presheaf-dictionary`, recovered from the paper repository at commit `94f850f6` — the sentinel HEAD pinned in `docs/reference/paper-definitions-of-record.md`
- `specs/archive/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` §5.1
- `specs/archive/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §§1, 3
- Four `lean_run_code` probes against the live tree
**Artifacts**:
- `specs/566_possible_worlds_clause_hf_as_limit/reports/01_total-histories-limit-clause.md`
- `specs/566_possible_worlds_clause_hf_as_limit/total-histories-clause-probe.lean` — the verified,
  choice-free probe the implementation round transcribes
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The clause is fully proved, machine-checked, in a probe.** Both maps, the compatible-family
  condition, task-respect, totality, both round trips, the `Equiv`, and the closing nonemptiness
  tail all elaborate green under `lean_run_code` against the live tree, with no `sorry` and no
  vacuous definition. The implementation round is transcription plus the module-invariant gate,
  not discovery.
- **The iso is choice-free; only its nonemptiness tail is not.** Measured
  `[propext, Quot.sound]` for every declaration on the isomorphism path once two `simpa` calls
  are written as explicit `rwa`. `Classical.choice` enters at exactly one place, the clause's
  `and is nonempty` tail, through `PartialHistory.hF_nonempty` and hence Zorn. The clause
  therefore joins *Germs* and *Sheaf* on the choice-free side of this cluster's recorded split,
  and its tail joins *Totality* and *Directed Gluing*.
- **The clause does not consume Totality, and the task description is wrong about that.** The
  paper's own proof unions a chain of centred windows that already covers the whole temporal
  order, so no extension step is needed. The task's premise that "the limit construction consumes
  Totality" does not hold; the real inputs are the centred cut `secOf`, the presheaf action
  `Beh.restrict`, and `WorldHistory.ofTotal`.
- **`directedSup` is not needed and should not be used.** The canonical window index `|t|` makes
  the union's value at a time definable outright, which is what buys choice-freedom. Routing the
  backward map through `Presheaf.directedSup` would import `Classical.choice` for nothing.
- **The clause is named *Total Histories* in the recorded paper text**, not *Possible Worlds*.
  The repository's `H_F` is `WorldHistory F`; there is no longer any `TaskFrame.HF`.
- **Recommended approach**: one new module `FormalSystem/Semantics/Presheaf/Worlds.lean` carrying
  a concrete `Lim` structure, the two maps, the keystone reading lemma, both round trips, the
  `Equiv`, and the nonempty tail; plus the one-line aggregator import and the generated-root
  regeneration. No new axiom, no `sorry`, no plan decomposition needed beyond three phases.

## Context & Scope

What was researched: whether the *Total Histories* clause of `app:presheaf-dictionary` —
`H_F ≅ lim_{x ∈ D⁺} Beh(F)(2x)` along the central restrictions `Tr (x' − x) : 2x → 2x'` — can be
stated and proved in this tree against the landed interval-site and behavior-presheaf cluster,
and at what cost in axioms, imports and new machinery.

Constraints honoured: the task's declared `file_scope` is its own module
`FormalSystem/Semantics/Presheaf/Worlds.lean` and deliberately excludes the cluster aggregator
`FormalSystem/Semantics/Presheaf.lean`; `lake build FormalSystem` must be green with no new
`sorry` at every phase boundary; the existing adjacency result must be reused rather than
re-derived; the zero-debt policy forbids any deferral.

Out of scope and left alone: the *Reflection* clause (a concurrent sibling task owns
`Presheaf/Reflection.lean`), the `Duration` clause module (another concurrent sibling owns
`Presheaf/Duration.lean`), and the free-category reading of `Path(F)`, which this cluster's
README records as not landed and which must never be cited as landed.

## Findings

### Codebase Patterns

**The clause's exact recorded statement.** From the paper at the pinned sentinel commit,
verbatim:

> **Total Histories:** `H_F ≅ \varprojlim_{x ∈ D^+} Beh(F)(2x)`, the limit along the central
> restrictions `Tr{x' − x} : 2x → 2x'` for `x ≤ x'`, and is nonempty.

The accompanying proof paragraph is a four-step argument: translate each `τ_x` to `[−x, x]`; the
translates form a chain under restriction, each restricting the next because `Tr (x' − x)` places
`[0, 2x]` as `[x' − x, x' + x]` inside `[0, 2x']`; the union is a *total* world history because
every time `t` lies in `[−|t|, |t|]` and any two times lie in a common member of the chain;
conversely every `τ ∈ H_F` arises from its restrictions to the `[−x, x]`, the two assignments
being mutually inverse. Nonemptiness is `cor:occurrence`.

**Everything the proof needs is already in the tree.** No new machinery is required.

| Paper step | Existing declaration | Location |
|---|---|---|
| the centred cut of a world to `[−x, x]`, reindexed to `[0, 2x]` | `secOf w (-x) (x + x)` with reading equation `secOf_states` | `Presheaf/Determinism.lean:193` |
| restriction along the central translation | `Beh.restrict`, `Beh.restrict_states` | `Presheaf/Behavior.lean` |
| the central morphism `Tr (x' − x) : 2x → 2x'` | `Tr`, with fit condition `(x' − x) + (x + x) ≤ x' + x'` | `Presheaf/Site.lean` |
| reading a state out of an equality of sections | `states_eq_of_eq` | `Presheaf/Sheaf.lean:221` |
| moving a state across equal times | `PartialHistory.states_eq_of_time_eq` | `Semantics/PartialHistory.lean:312` |
| the union as a total history | `WorldHistory.ofTotal`, `WorldHistory.ext_state`, `state_congr` | `Semantics/PartialHistory.lean` |
| `H_F ≠ ∅` | `PartialHistory.hF_nonempty`, from `occurrence` | `Semantics/Extension/Extension.lean:357` |

**`|t|` is available on an abstract `F.Duration`.** A temporal order carries `AddCommGroup`,
`LinearOrder`, `IsOrderedAddMonoid` and `Nontrivial` as instance fields, which is enough for
`abs_nonneg`, `le_abs_self`, `neg_abs_le`, `abs_le` and `max`. All five were probed green, and
all five are choice-free.

**The existing adjacency result is a consequence, not an input.** `FrameOver.mem_HF_iff_adjacent`
identifies `H_F` over `D = ℤ` with the bi-infinite step paths. It is declared at
`FormalSystem/Semantics/IntNormalForm.lean:348`, **not** at `FormalSystem/Semantics/IntTransfer.lean`
as the task description states. It is the same identification of `H_F` specialised to discrete
time, so it belongs in the module docstring as the ℤ reading of the general clause, and the
adjacency argument must not be re-derived. The general clause does not depend on it.

**The scope note's aggregator contention is real and unchanged.** Adding `Worlds.lean` requires
one import line in `FormalSystem/Semantics/Presheaf.lean`, which the interval-site task owns and
which every task on this front must touch. Two additional shared touches were found that the
scope note does not name: the generated library root `FormalSystem.lean`, which check C33 asserts
is byte-current and which is regenerated by `lake exe mk_all --lib FormalSystem`, and the
generated inventory block in `FormalSystem/Semantics/Presheaf/README.md`, maintained by
`scripts/readme-inventory.sh`.

### External Resources

- The clause transposes the behavior-sheaf construction of Schultz, Spivak and Vasilakopoulou to
  the positive cone of an arbitrary temporal order; the interval site is their interval site, as
  `lem:interval-twisted-arrow` records.
- The cluster imports no `Mathlib.CategoryTheory` and must not start. `Presheaf/Site.lean`'s
  docstring records the decision explicitly: concrete structures, no `Category` instance. The
  limit must therefore be presented concretely, as the type of compatible families, exactly as
  `sheaf_clause` presents the sheaf condition concretely rather than as a limit in a category.
- The gluing-route seed report's §§1 and 3 confirm that this clause's limit presentation and the
  gluing conception are one statement in two presentations, and that the open decidability
  question is whether the rays can range over path sets. Nothing in that report is re-derived
  here, and nothing here settles a route question.

### Recommendations

**A sorry-free path exists and has been exercised end to end.** The following shape compiled
green, in full, with no `sorry`:

1. `fit` — the central morphism's fit condition `x' − x + (x + x) ≤ x' + x'` from `x ≤ x'`.
2. `centralTr` — the central restriction as a `Tr (2x) (2x')` of the site, with an `rfl` bridge
   lemma `restrictTr_central` showing that restriction along it **is** the raw-data restriction
   the clause is stated with. This mirrors `restrictTr_coverLeft`/`restrictTr_coverRight` and is
   what makes a site-level form of the clause free, as it made `sheaf_clause_site` free.
3. `Lim F` — a structure with one data field `sec : ∀ x : Obj F.Duration, Beh F (x.val + x.val)`
   and one `Prop` field `compat` asserting the central-restriction equation. Extensionality is
   `funext` on `sec` plus proof irrelevance.
4. `lo'`, `hi'` — the two window bounds `0 ≤ t + x` and `t + x ≤ x + x` from `|t| ≤ x`. **Write
   these with explicit `rwa [neg_add_cancel]` and `rwa [add_sub_cancel_right]`, never `simpa`**:
   the `simpa` forms measure `Classical.choice` and the `rwa` forms do not. This was measured
   both ways.
5. `absObj t := ⟨|t|, abs_nonneg t⟩` — the canonical window index, and `readAt`, which reads the
   state at `t` out of that window at position `t + |t|`.
6. `read_eq` — **the keystone**: any window at least as large as `|t|` reads the same state.
   Every later proof goes through it. Its proof is `compat` read at one point through
   `states_eq_of_eq`, then `Beh.restrict_states`, then one `states_eq_of_time_eq` across
   `(x − |t|) + (t + |t|) = t + x`.
7. `respects` — task-respect for `readAt`, by reading both times out of the common window
   `max |s| |t|`; the time difference survives because
   `(t + m) − (s + m) = t − s`.
8. `toWorld := WorldHistory.ofTotal F (readAt L) (respects L)` — the backward map. Totality is
   structural, not proved: `ofTotal` builds a total history by construction, which is the Lean
   form of the paper's "every time `t` lies in `[−|t|, |t|]`".
9. `ofWorld` — the forward map, `sec x := secOf w (-x) (x + x)`, whose `compat` field is
   `Beh.restrict_states` plus two `secOf_states` plus one `state_congr`.
10. `toWorld_ofWorld` and `ofWorld_toWorld` — the two round trips, by `WorldHistory.ext_state`
    and by `Beh.ext`/`partialHistory_ext` respectively. The second needs the bound
    `|r − x| ≤ x` on `[0, 2x]`, which is `abs_le` plus two `sub_le_sub_right`.
11. `worldsEquiv : WorldHistory F ≃ Lim F` — the clause. `noncomputable`, because `secOf` is.
12. `lim_nonempty` — the closing tail, one line from `PartialHistory.hF_nonempty`.

**Recommended phase decomposition** (three phases, each independently green):

- **Phase 1** — the site-side arithmetic and the limit type: `fit`, `centralTr`,
  `restrictTr_central`, `Lim`, `Lim.ext`, `lo'`, `hi'`, `absObj`. Imports `Presheaf.Behavior` and
  `Presheaf.Determinism` only.
- **Phase 2** — the two maps and the keystone: `readAt`, `readAt_def`, `read_eq`, `respects`,
  `toWorld`, `ofWorld`.
- **Phase 3** — the clause and the gate: both round trips, `worldsEquiv`, `lim_nonempty`, the
  measured axiom table in the module docstring, the ℤ reading pointer to
  `FrameOver.mem_HF_iff_adjacent`, the `assert_not_exists` lock, the aggregator import line, the
  generated root regeneration, and the README inventory block.

**Statement fidelity note for the plan.** The plan should carry a
`## Lean Challenge Statements` section pinning `worldsEquiv`'s signature as
`WorldHistory F ≃ Lim F` at **no frame constraint** and `lim_nonempty`'s as requiring
`[F.IsRegular]`. The temptation to weaken is to bundle `[F.IsRegular]` onto the iso because the
tail needs it; that would make the clause claim strictly less than the recorded statement, since
the iso holds at no constraint at all.

## Decisions

- **Present the limit concretely, as a `Lim` structure of compatible families.** Not as a
  `CategoryTheory.limit`. The cluster's recorded decision is concrete structures with no category
  theory, and `sheaf_clause` already sets the precedent of stating a universal property
  concretely. Introducing `Mathlib.CategoryTheory` for one clause would make a dependency
  decision for the whole cluster that the cluster has already made the other way.
- **Index the limit by `Obj F.Duration`, the positive cone**, matching the paper's `x ∈ D⁺` and
  the site's own object type, and write `2x` as `x.val + x.val` because no `OfNat F.Duration 2`
  exists on an abstract temporal order.
- **Use the canonical window index `|t|` rather than `directedSup`.** This is a deliberate
  departure from the generic machinery, not from the paper: the paper's union is the same union,
  and `|t|` is the paper's own witness ("every time `t` lies in `[−|t|, |t|]`"). It is what makes
  the clause choice-free, and routing through `directedSup` would forfeit that for no gain.
- **Reuse `secOf` for the centred cut rather than defining a second cut.** `secOf w m l` cuts a
  world to `[0, l]` based at `m`, and `secOf w (-x) (x + x)` is exactly the paper's centred
  window. Its reading equation is `rfl`, which is what makes the forward map's compatibility
  proof short.
- **State the clause's `compat` in raw-data form and derive the site form.** The raw form is what
  the proofs consume; the site form is one `rfl` bridge away, exactly as `sheaf_clause_site` is
  derived from `sheaf_clause` with no transport and no cast.
- **Do not widen `file_scope`.** The aggregator import line stays an out-of-scope shared touch,
  handled by re-reading the file immediately before editing and committing only that hunk, per
  the territory contract. The same applies to the generated root and the README inventory block.

## Risks & Mitigations

- **Risk**: a sibling task on this front clobbers the aggregator import line, or the generated
  root, in the same cycle. Three concurrent siblings are declared this cycle, two of them on
  sibling modules of the same directory.
  **Mitigation**: re-read `FormalSystem/Semantics/Presheaf.lean` and `FormalSystem.lean`
  immediately before editing; stage only this task's own hunks with an explicit file list; re-run
  the scoped build after the aggregator edit; treat a failure outside `Worlds.lean` as possibly a
  sibling's in-flight edit and report rather than "fix" it.
- **Risk**: an implementation written with `simp`/`simpa` in the arithmetic steps silently
  imports `Classical.choice`, turning a choice-free clause into a choice-dependent one and
  falsifying the module's own recorded axiom table.
  **Mitigation**: the two offending steps are identified above with their choice-free
  replacements. Phase 3 must measure every declaration with `lean_verify` or `#print axioms` and
  write the table, as the three sibling modules do.
- **Risk**: naming drift. The task says *Possible Worlds*; the recorded paper text says *Total
  Histories*; `docs/reference/paper-definitions-of-record.md` lists the clause under the name
  *Possible Worlds*.
  **Mitigation**: use the recorded paper text's name *Total Histories* in the Lean docstring,
  note the record's name in the same sentence, and update the record's row to cite the new
  declarations. The anchor stays `DANGLING` and unpinned; it is unpinnable.
- **Risk**: the appendix containing the clause is absent from the live paper, so a reader cannot
  resolve the citation.
  **Mitigation**: cite it exactly as the three sibling modules do — as a `DANGLING` anchor
  resolving against `docs/reference/paper-definitions-of-record.md` rather than a live `\label{}`
  — and state in the docstring that the statement was taken from the sentinel commit that record
  pins.
- **Non-risk, recorded so it is not re-opened**: the clause needs neither `thm:extension` nor
  Zorn nor *Saturation* for the isomorphism. Only the nonemptiness tail does, and it inherits
  them from `cor:occurrence` where the paper also puts them.

## Tactic Survey Results

Measured on the live tree via `lean_run_code`. The goals are the ones the clause actually
generates; `abel` is the workhorse because every obligation after the structural step is an
abelian-group identity on durations.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `x' - x + (x + x) = x' + x` | `abel` | success | no premises |
| `(t + m) - (s + m) = t - s` | `abel` | success | no premises |
| `x - abs t + (t + abs t) = t + x` | `abel` | success | no premises |
| `x' + x ≤ x' + x'` from `x ≤ x'` | `exact add_le_add (le_refl _) h` | success | `add_le_add`; note `add_le_add_left h a` is `b + a ≤ c + a` in this Mathlib, which misleads |
| `0 ≤ t + abs t` | `simpa using add_le_add (neg_abs_le t) le_rfl` | success **but pulls `Classical.choice`** | avoid |
| `0 ≤ t + abs t` | `rwa [neg_add_cancel]` after `add_le_add` | success, choice-free | preferred form |
| `abs (r - x) ≤ x` on `[0, 2x]` | `abs_le.mpr` + two `sub_le_sub_right` + `rwa` | success, choice-free | `zero_sub`, `add_sub_cancel_right` |
| section equality from pointwise states | `Beh.ext (partialHistory_ext _ _)` | success | the cluster's standard device |
| world equality from pointwise states | `WorldHistory.ext_state` | success | the cluster's standard device |
| rewriting under a dependent `states` witness | `rw [hL]` | **fail** — motive is not type correct | use `states_eq_of_eq hL r h h'` instead |
| unfolding `readAt` in a goal | `rw [readAt]` | **fail** — no equation lemma | state a `readAt_def : ... := rfl` and rewrite with that |

Measured axiom profile of the probe, by `#print axioms`:

| Declaration | Measured axioms |
|---|---|
| `read_eq`, `respects`, `toWorld`, `ofWorld` | `[propext, Quot.sound]` |
| `toWorld_ofWorld`, `abs_le_of_mem`, `ofWorld_toWorld_sec`, `ofWorld_toWorld` | `[propext, Quot.sound]` |
| `worldsEquiv` — the clause itself | `[propext, Quot.sound]` — **choice-free** |
| `lim_nonempty` — the closing tail | `[propext, Classical.choice, Quot.sound]`, attributable to `hF_nonempty` and hence Zorn |

An intermediate probe measured `ofWorld_toWorld` and `worldsEquiv` at
`[propext, Classical.choice, Quot.sound]`. The cause was localised to two `simpa` calls in the
window-bound arithmetic and nowhere else; replacing them with explicit `rwa [neg_add_cancel]`,
`rwa [zero_sub]` and `rwa [add_sub_cancel_right]` returns the whole isomorphism path to
`[propext, Quot.sound]`, which is the table above. Both measurements were taken.

## Context Extension Recommendations

- **Topic**: recovering a cut paper anchor's statement from the pinned sentinel commit.
  **Gap**: `docs/reference/paper-definitions-of-record.md` records that four anchors are
  `DANGLING` and unpinnable, and records the sentinel commit, but no context file tells an agent
  that the sentinel commit is the sanctioned place to *read the statement from* when the live
  file no longer contains it. This round spent several tool calls discovering that.
  **Recommendation**: add a short subsection to the paper-definitions-of-record workflow naming
  `git show <sentinel>:JPL/possible_worlds.tex` as the sanctioned read path for a `DANGLING`
  anchor, and requiring that a module citing one say so.
- **Topic**: `simp`/`simpa` as a silent `Classical.choice` source.
  **Gap**: this cluster's modules carry careful choice attributions, and `lean4.md` encourages
  `simp` freely in first-principles mode, with nothing warning that a one-line `simpa` can move a
  declaration from `[propext, Quot.sound]` to `[propext, Classical.choice, Quot.sound]`.
  **Recommendation**: record the pattern, and the `rwa`-with-named-lemma remedy, in the Lean
  context's choice-measurement guidance.

## Appendix

### Probes run

Four `lean_run_code` probes against the live tree, importing
`FormalSystem.Semantics.Presheaf.Determinism` and `FormalSystem.Semantics.Presheaf.Directed`:

1. API and arithmetic availability — `abs` on an abstract duration, the fit condition, the
   centred cut's type, `secOf_states`. All green.
2. The full construction skeleton. Two syntactic failures, both in rewriting; the mathematics
   compiled.
3. The full clause, both round trips, the `Equiv`, the nonempty tail. **All green, no `sorry`.**
4. Axiom measurement, and the localisation of `Classical.choice` to two `simpa` calls with a
   choice-free replacement measured green.

The final, corrected form of probe 3 — green, `sorry`-free, and choice-free on the whole
isomorphism path — is saved verbatim at
`specs/566_possible_worlds_clause_hf_as_limit/total-histories-clause-probe.lean`, with its
measured axiom table and the two `simpa` prohibitions recorded in its own header. The
implementation round should transcribe that file rather than rebuild the proofs.

### Gate obligations a new module in this cluster incurs

- C24 — transitively import `FormalSystem.Init`.
- C33 — regenerate the library root: `lake exe mk_all --lib FormalSystem`.
- C31 — every bibkey in `## References` resolves in the root `references.bib`.
- C32 — every relative markdown link in a `.lean` comment resolves on disk.
- C34 — a `Constraints consumed:` line per declaration, honest against its binders.
- The cluster's own closing `assert_not_exists FormalSystem.ProofSystem.Axiom
  FormalSystem.ProofSystem.DerivationTree`.
- `scripts/readme-inventory.sh` for the generated inventory block in the cluster README.

### Searches and lookups used

No external search tool was needed: every declaration the clause consumes is local, and
`lean_local_search` was unnecessary because the cluster README and the four module docstrings
name their own exports exhaustively. The paper statement was recovered by
`git show 94f850f6:JPL/possible_worlds.tex` in the paper repository.

## References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  §3.2 Def. 3.2.1 — the behavior sheaf whose task-frame instance `Beh F` is, and §3.1
  Defs. 3.1.1–3.1.5 for the interval site this clause's index category is
* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Total Histories* clause
  this task discharges. **`DANGLING`**: cut from the paper with `app:Structure` and recorded in
  `docs/reference/paper-definitions-of-record.md`
* JPL paper `def:interval-site`, `def:behavior-presheaf`, `app:Structure` — the site, the
  presheaf, and the cut appendix containing all three. **`DANGLING`**, as above
* JPL paper `cor:occurrence` — the nonemptiness of `H_F`, the clause's closing tail
* `FormalSystem/Semantics/Presheaf/README.md` — the cluster's recorded verdicts, including the
  choice split this clause extends
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrict`, `Beh.restrict_states`,
  `Beh.mem_dom`, `partialHistory_ext`
* `FormalSystem/Semantics/Presheaf/Site.lean` — `Obj`, `Tr`, and the recorded decision to use
  concrete structures rather than `Mathlib.CategoryTheory`
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — `states_eq_of_eq`
* `FormalSystem/Semantics/Presheaf/Determinism.lean` — `secOf`, `secOf_states`
* `FormalSystem/Semantics/Presheaf/Directed.lean` — `place`, `ofWorld`, `directedSup`, and the
  measured choice record this clause's own table extends
* `FormalSystem/Semantics/PartialHistory.lean` — `WorldHistory`, `ofTotal`, `ext_state`,
  `state_congr`, `states_eq_of_time_eq`
* `FormalSystem/Semantics/Extension/Extension.lean` — `occurrence`, `hF_nonempty`
* `FormalSystem/Semantics/IntNormalForm.lean` — `FrameOver.mem_HF_iff_adjacent`, the ℤ reading of
  this clause
