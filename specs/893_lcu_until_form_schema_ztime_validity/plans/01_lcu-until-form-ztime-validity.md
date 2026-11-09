# Implementation Plan: Task #893

- **Task**: 893 - Declare the until-form limit-closure schema LCU and its mirror, with ZTime validity
- **Status**: [COMPLETED]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/893_lcu_until_form_schema_ztime_validity/reports/01_lcu-until-form-ztime-validity.md`
- **Artifacts**: plans/01_lcu-until-form-ztime-validity.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Declare `lcU` — the until-form limit-closure schema `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → (⟐α → ⟐G≤(⟐α ∨ (⟐β U ⟐α)))` — in `FormalSystem/PlusLanguage/PlusLCSchema.lean` beside `lcN`, prove its validity over the `ℤ` fibre and at `.ZTime` by instantiating `omega_chain`, and state the backward schema as the `plusValidIn_reflectTime` corollary. The construction needs one new helper not named in the task description: a **marker bracketing** lemma `int_marker_bracket` giving, for any `s ≥ c 0`, a `k` with `c k ≤ s < c (k + 1)`. The whole mathematical content is already machine-verified sorry-free in `specs/893_lcu_until_form_schema_ztime_validity/probes/01_lcu-ztime-validity.lean`, so the work is transcription plus the documentation and gate surfaces the change trips. Definition of done: four new declarations compile with zero errors, zero sorries and their recorded axiom profiles; the five prose surfaces that currently assert `LCU` is undeclared are repaired without losing the still-true distinctions; and `bash scripts/check-module-invariants.sh`, `bash scripts/typst-sync-check.sh` and `lake build` are all green with no new finding naming a touched file.

### Research Integration

Findings integrated from `reports/01_lcu-until-form-ztime-validity.md`:

- **The construction is verified, not speculative.** The eight-slot `omega_chain` instantiation table in the report's "The verified construction, in detail" section is the implementation spec for Phase 2; the probe is its literal source text.
- **Endpoint correction, load-bearing.** The task description's segment property `P k η s s' := ⟐β` throughout the half-open `(s, s']` is **not derivable** — the `untl` clause supplies `⟐β` only on the open `(s, s')`, carrying `⟐α` rather than `⟐β` at `s'`. The implementation uses the open reading `fun _ η s s' => ∀ r, s < r → r < s' → PlusTruthAt M η r (⟐β)`, which is simultaneously what is provable and what the consequent needs. `omega_chain`'s `hP` agreement window `(s, s']` is a strict superset of the open content window, so `hP` still discharges by state-locality of `⟐`. No change to `PlusOmegaChain.lean`'s signatures is needed.
- **One new helper.** `int_marker_bracket` does not exist in the tree, and `int_marker_exists_gt` cannot serve: the `F`-form's arithmetic gives a marker *beyond* `s` in a prescribed residue class, while the until-witness needs the marker pair that *straddles* `s`, because the segment guard is only available between consecutive markers.
- **The proof is shorter than `lcN`'s, not longer.** No `by_cases` on reachability (`ρ₀ := σ`, `s₀ := t`, so `c 0 = t` and the `[t, c 0)` gap is empty) and no `bigAnd`/residue arithmetic (`A k := ⟐α` is constant in `k`). The consequent's left disjunct `⟐α` is never taken.
- **Five live prose surfaces assert `LCU` is undeclared** and are repaired here: the `PlusLCSchema.lean` module docstring's `## LCU, and the relation to blc` section plus its `## Main Definitions`/`## Main Results` lists; `lcN`'s own docstring; `PlusOmegaChain.lean`'s `stg_step` docstring (which claims every current consumer instantiates `P` trivially); `docs/theorem-index.md`'s `lcN_plusValidZTime` row; and `FormalSystem/PlusLanguage/README.md`'s `PlusLCSchema.lean` inventory description.
- **Gate collisions enumerated in advance** from `.claude/context/project/lean4/patterns/plan-authoring-gate-collisions.md`: Condition 1 (both generated line-count surfaces, with surface (b) blocking at pre-commit), Condition 4 (baseline-delta phrasing for repo-wide lints), and the C14/C15 companion conditions. Conditions 5, 6, 7, 9 and C33 are confirmed out of scope — no new import, no underscore-bearing `def`, both files far under 1500 lines, no module-path-shaped name, no new file.

**Re-derived at plan-authoring time** (not carried from the report): compiling the probe in the foreground (`timeout 540 lake env lean specs/893_lcu_until_form_schema_ztime_validity/probes/01_lcu-ztime-validity.lean`, exit 0) printed `[propext, Classical.choice, Quot.sound]` for all four declarations. This was re-derived specifically because `int_marker_bracket`'s three siblings in the same `PlusOmegaChain.lean` section carry the shorter `[propext, Quot.sound]`, which made the carried uniform-`pcq` claim worth checking before Phase 4 writes it into an exact-string HARD STOP.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context, and `specs/ROADMAP.md` was not consulted. No roadmap phases are added.

## Goals & Non-Goals

**Goals**:

- `int_marker_bracket`, `lcU_plusValidInt`, `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime`
- Declare the schema `lcU` in `PlusLCSchema.lean` after `lcN`, with the exact formula the probe and the programme report both fix (a `def`, not a theorem goal, so it is deliberately not named in the identifier list above)
- Every prose surface asserting `LCU` is undeclared repaired, with each still-true distinction kept and restated on its own merits
- Theorem-index rows in `docs/theorem-index.md` and the `C14` baseline pair extended for all four new declarations, and both generated line-count surfaces reconciled

**Non-Goals**:

- `IsLCUAxiom`, `ExtDerivation`, or any extension of the proof system
- Any derivability or completeness claim: not that `lcU` is a TM⁺ theorem, not that TM⁺ + `IsLCUAxiom` is complete, not that `lcU` follows from `lcN` or `lcN` from `lcU`
- `.Base` validity for `lcU` — the cofinality hypothesis has exactly one discharge in the tree (`intOrder_omega_cofinal`, over `ℤ` alone), so `.Base` stays open and unclaimed, recorded exactly as `lcN`'s is
- Any change to `omega_chain`'s or `stg_step`'s signatures
- Any ingredient of the completeness engine (automata, ban preservation, the cut product)

## Lean Challenge Statements

```lean
import FormalSystem.PlusLanguage.PlusLCSchema

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics
open PartialHistory
open PlusTruth

theorem int_marker_bracket {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1)) {s : ℤ} (h0 : c 0 ≤ s) :
    ∃ k, c k ≤ s ∧ s < c (k + 1) := sorry

theorem lcU_plusValidInt (α β : PlusFormula) : PlusValidInt (lcU α β) := sorry

theorem lcU_plusValidZTime (α β : PlusFormula) : PlusValidZTime (lcU α β) := sorry

theorem lcU_reflectTime_plusValidZTime (α β : PlusFormula) :
    PlusValidZTime (lcU α β).reflectTime := sorry

end FormalSystem.PlusLanguage
```

Note for the snapshot consumer: the three `lcU_*` statements mention `lcU`, which Phase 2 declares in the target module. A standalone Challenge module assembled from this block alone therefore does not elaborate until `lcU` exists; `lcU` is a `def`, not a theorem goal, so it is deliberately absent from the identifier set above and from `- **Goals**:`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pre-commit hook blocks the commit of any phase that changes `.lean` line counts (`.githooks/pre-commit` runs `typst-sync-check.sh --counts-only`, which BLOCKS on a stale `typst/generated/status.typ` `formalsystem-line-count`, currently `394424`) | H | H | Every phase touching a `.lean` file carries `typst/generated/status.typ` in its own file scope and runs `lake build && bash scripts/typst-sync-check.sh --fix` before committing — in that phase, never deferred. Gate-collisions Condition 1, surface (b). |
| C14 fails as a HARD STOP (its two heredocs are compared by exact string equality; divergence is "a HARD STOP, not a new baseline") | H | M | Add the four `#print axioms` lines to `C14LEAN` and the four matching baseline lines to `C14BASE` in the **same order**, at the tail of the `PlusLanguage` block, using the profile text re-derived at plan-authoring time: `[propext, Classical.choice, Quot.sound]` for all four. Confirm with `bash scripts/check-module-invariants.sh`. |
| C15's second assertion fails on the whole batch of new rows at once (every `docs/theorem-index.md` row must be anchored at its declaration, by a resolving paper anchor or a `Paper: —` line) | M | M | All four declarations get `Paper: — (formalization-native; the manuscript states no limit-closure schema)` verbatim, the form all thirteen existing `Paper:` lines in these two files already use. The Paper lines land in Phases 1-2, with the declarations; the rows land in Phase 4. The reverse direction (a declaration with no row) is not checked, so the interim state is safe. |
| The module-inventory generated blocks go stale (`FormalSystem/PlusLanguage/README.md`'s inventory table carries per-file line counts — `PlusLCSchema.lean` 338, `PlusOmegaChain.lean` 404 as of plan authoring — and `README.md` carries the totals block) | M | H | `bash scripts/check-module-invariants.sh --emit-inventory` in Phase 4, verified with `--emit-inventory --check`. **Ordering constraint**: the generator preserves the hand-written Description cell and refreshes only the numbers, so Phase 3's prose edit to the `PlusLCSchema.lean` description must be made by hand and survives regeneration — it must not be deferred to the generator. |
| A verification criterion written as a repo-wide absolute zero turns out unsatisfiable (several gates here are baseline-relative: C16/`nolints.json`, C20, C20_DECL) | M | M | Gate-collisions Condition 4: every phase criterion below is scoped to the files that phase touches, or stated as a delta against the pre-task commit. No phase asserts an absolute repo-wide zero or a bare exit 0. |
| CI builds with `--wfail`, so a lint WARNING is a CI FAILURE | M | L | Gate-collisions Condition 8: treat warning and error identically when judging a phase green. The probe compiles warning-free; no `show` tactic is used anywhere in the transcribed text. |
| Docstring repair accidentally crosses the boundary into a derivability or completeness claim | M | M | The docstrings are the surface where the "no completeness claim" boundary is most likely to be crossed by accident. Phase 3's verification includes an explicit read-back of every edited hunk against the Non-Goals list above. |
| A docstring edit leaves an unbalanced `/-!`…`-/` delimiter, breaking elaboration of a module the diff read-through passes | M | L | Phase 3 declares `local` rather than `prose` for exactly this reason and builds both touched modules. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2 consumes Phase 1's new lemma, Phase 3 restates claims about declarations Phase 2 creates, and Phase 4 indexes and pins all of them.

### Phase 1: `int_marker_bracket` and the `stg_step` consumer note [COMPLETED]

**Goal**: Add the marker-bracketing lemma the until-form's consequent needs, in the `ℤ` discharge section where its three siblings live, and correct `stg_step`'s docstring claim that every current consumer instantiates `P` trivially.

**Tasks**:

- [ ] Insert `int_marker_bracket` in `FormalSystem/PlusLanguage/PlusOmegaChain.lean`'s `/-! ## The ℤ discharge of the cofinality hypothesis -/` section (line 187 as of plan authoring), after `int_marker_exists_gt` (line 238). Body is the probe's `int_marker_bracket'` verbatim with the prime dropped.
- [ ] Give it a doc comment carrying `Paper: — (formalization-native; the manuscript states no limit-closure schema)` and a one-sentence statement of why `int_marker_exists_gt` cannot serve: that lemma gives a marker *beyond* `s` in a prescribed residue class, while the until-witness needs the marker pair that *straddles* `s`, because the segment guard is only available between consecutive markers.
- [ ] Record in the doc comment that the lemma is stated at `ℤ` rather than at `F.Duration` for the reason `int_marker_exists_gt`'s own docstring already gives (`omega` does not see through `↑intOrder = ℤ`), and that it transports to `c : ℕ → F.Duration` by defeq at the application site.
- [ ] Add an `int_marker_bracket` entry to the module docstring's `## Main Results` list.
- [ ] Repair `stg_step`'s docstring: the sentence "Every current consumer in this tree instantiates it trivially (`PlusLCSchema.lean`'s `lcN_plusValidInt` passes `fun _ _ _ _ => True`)" is false once Phase 2 lands. Replace it, and extend the "**Why `P` is carried at all**" paragraph to name its realised consumer and the interval-endpoint discipline a consumer must observe: `P`'s content window must sit strictly inside the `(s, s']` agreement window `hP` offers, so an `untl`-sourced guard is open on the right. Write it in the present tense, with no reference to what the text used to say.
- [ ] Run `lake build FormalSystem.PlusLanguage.PlusOmegaChain` and confirm zero errors and zero warnings.
- [ ] Run `lake build && bash scripts/typst-sync-check.sh --fix`, then `bash scripts/typst-sync-check.sh --counts-only`, and stage `typst/generated/status.typ` with the Lean change in the same commit.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one new declaration and two docstring edits land in one file, and `PlusOmegaChain.lean` ends at roughly 445 lines (carried from `reports/01_lcu-until-form-ztime-validity.md`'s non-risk note, against a re-derived 404-line starting count) — comfortably under the 1500-line `longFile` ceiling, so no `set_option linter.style.longFile` baseline is needed. Confirm at implementation time with `wc -l FormalSystem/PlusLanguage/PlusOmegaChain.lean` after the edit and by the absence of any `longFile` finding in the build output; if the file does approach 1500, apply gate-collisions Condition 7 (baseline within the `N - 200 <= lines < N` acceptance window) rather than splitting the file.

**Tier Justification**: `lake build FormalSystem.PlusLanguage.PlusOmegaChain` covers the edit because the change is purely additive — one new theorem and two doc comments, with no existing signature altered — so no dependent module's elaboration can change.

**Files to modify**:

- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` - add `int_marker_bracket` after `int_marker_exists_gt`; add its `## Main Results` entry; repair `stg_step`'s trivial-consumer claim and extend its `Why P is carried at all` paragraph
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` (Condition 1 surface (b); blocking at pre-commit, so it cannot be deferred). This file exists and currently reads `394424`; if `--fix` reports nothing to change, stage only the Lean file.

**Verification**:

- `lake build FormalSystem.PlusLanguage.PlusOmegaChain` exits 0 with zero errors and zero warnings (warnings count as failures: CI builds with `--wfail`).
- `#print axioms FormalSystem.PlusLanguage.int_marker_bracket` prints `[propext, Classical.choice, Quot.sound]`. Record the literal output; it is Phase 4's C14 input and must not be predicted there.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `grep -n "instantiates it trivially" FormalSystem/PlusLanguage/PlusOmegaChain.lean` returns nothing.
- `bash scripts/check-module-invariants.sh` reports no new finding naming `FormalSystem/PlusLanguage/PlusOmegaChain.lean` relative to the pre-task commit. An `FAIL INV` stale-inventory finding and a C20/C20_DECL baseline finding are expected here and are closed in Phase 4 — record them as pre-existing/deferred, not as blockers.

---

### Phase 2: `lcU` and the three validity theorems [COMPLETED]

**Goal**: Declare `lcU` and prove `lcU_plusValidInt`, `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime`, transcribing the verified probe.

**Tasks**:

- [ ] Declare `lcU (α β : PlusFormula) : PlusFormula` in `FormalSystem/PlusLanguage/PlusLCSchema.lean`'s `/-! ## The schema -/` section (line 186 as of plan authoring), after `lcN` (line 209). Formula verbatim from the probe — identical to the task description's and to the 879 report's: `(stab (gle ((dstab α).imp (dstab (untl (dstab β) (dstab α)))))).imp ((dstab α).imp (dstab (gle ((dstab α).or (untl (dstab β) (dstab α))))))`. No design freedom remains on the statement.
- [ ] Transcribe `lcU_plusValidInt`, `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime` into the `/-! ## Validity at the ℤ fibre, and at .ZTime -/` section (line 211), after the `lcN` trio (which ends at line 334). Bodies verbatim from the probe; drop the prime from `int_marker_bracket'`.
- [ ] Confirm the `omega_chain` instantiation matches the report's eight-slot table, in particular that `P` is instantiated on the **open** interval — `fun _ η s s' => ∀ r, s < r → r < s' → PlusTruthAt M η r (PlusFormula.dstab β)` — and **not** on the half-open `(s, s']` the task description names. The half-open reading is not derivable from the antecedent: the `untl` clause carries `⟐α`, not `⟐β`, at the right endpoint.
- [ ] Give each of the four new declarations its own doc comment with a `Paper: — (formalization-native; the manuscript states no limit-closure schema)` line.
- [ ] Mirror `lcN`'s docstring discipline on the three theorems: state what is claimed (the `ℤ` fibre, then `.ZTime` by carrier normalization, then the `reflectTime` mirror); state that `.Base` validity is **open and unclaimed**, naming the cofinality obstruction (`omega_chain`'s hypothesis has exactly one discharge in this tree, `intOrder_omega_cofinal`, over `ℤ` alone); and state that **no derivability or completeness claim is made** — neither that `lcU` is a TM⁺ theorem nor that it follows from `lcN`.
- [ ] Add `lcU` to the module docstring's `## Main Definitions` list and the three theorems to its `## Main Results` list.
- [ ] Confirm no new `import` is required: `PlusLCSchema.lean` already imports `PlusOmegaChain` and `PlusReversal`, which supply `omega_chain`, `intOrder_omega_cofinal`, `int_marker_bracket`, `plusValidZTime_iff_plusValidInt` and `plusValidIn_reflectTime`.
- [ ] Run `lake build && bash scripts/typst-sync-check.sh --fix`, then `--counts-only`, and stage `typst/generated/status.typ` with the Lean change.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Four new declarations land in one file and `PlusLCSchema.lean` ends at roughly 450 lines (carried from `reports/01_lcu-until-form-ztime-validity.md`'s non-risk note, against a re-derived 338-line starting count) — under the 1500-line `longFile` ceiling, so no baseline is needed. `lcU` is the only new `def` in the task and carries no underscore, so C26 does not fire; `theorem` names are exempt from C26 regardless. Confirm with `wc -l FormalSystem/PlusLanguage/PlusLCSchema.lean` and the absence of any `longFile` or C26 finding naming this file.

**Tier Justification**: `lake build FormalSystem.PlusLanguage.PlusLCSchema` covers the edit because all four declarations are additive with no existing signature altered and no new import added, so no module outside this one changes elaboration.

**Files to modify**:

- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - add `lcU` after `lcN` in the schema section; add the three validity theorems after the `lcN` trio; extend the module docstring's `Main Definitions` and `Main Results` lists
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` (Condition 1 surface (b), blocking at pre-commit). Exists; stage only if `--fix` changes it.

**Verification**:

- `lake build` exits 0 with zero errors, zero warnings and zero sorries.
- `#print axioms` on each of `FormalSystem.PlusLanguage.lcU_plusValidInt`, `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime` prints `[propext, Classical.choice, Quot.sound]`. Record the literal output for Phase 4; do not predict it there.
- `grep -c "sorry" FormalSystem/PlusLanguage/PlusLCSchema.lean` returns 0. *(deviation: altered — the literal criterion is unsatisfiable and was already false at the pre-task commit: line 32's module docstring contains the phrase "`sorry`-free" in prose. The substantive check was run instead and is green: `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` reports `sorry_count: 0`, and the full `lake build` emitted zero `declaration uses 'sorry'` warnings.)*
- Exact-name absence check before the edit, then presence after: `grep -n "^def lcU\b\|^theorem lcU_" FormalSystem/PlusLanguage/PlusLCSchema.lean` finds exactly the four new declarations. Use exact names, never a shared prefix (gate-collisions Condition 3(b)).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `bash scripts/check-module-invariants.sh` reports no new finding naming `FormalSystem/PlusLanguage/PlusLCSchema.lean` relative to the pre-task commit, with the expected C14/`FAIL INV` deferrals recorded as in Phase 1.

---

### Phase 3: Prose repair across the four remaining undeclared-ness surfaces [COMPLETED]

**Goal**: Remove every live assertion that `LCU` is undeclared, keeping each genuinely substantive distinction and restating it on its own merits, in the present tense, with no record-versioning language.

**Tasks**:

- [ ] `FormalSystem/PlusLanguage/PlusLCSchema.lean` module docstring, `## LCU, and the relation to blc` section (lines 49-76 as of plan authoring): delete the undeclared-ness assertion "**`LCU` itself is not declared anywhere in this tree**: there is no `LCU` definition, and no claim whatsoever about its validity at any frame class. It waits on the oriented-forest `Saturation` lemma and on separation over `ℤ`." Replace with a present-tense statement of what `lcU` now is and what is claimed for it (the `ℤ` fibre and `.ZTime`), and what is not (`.Base`, and any derivability or completeness claim). Also repair line 70's "already cover `LCU` is told the until-form ingredient is present in this tree when it is not."
- [ ] Keep, restated on their own merits: that `LCU` is **not** an instance of `lcN` and `lcN 1` is **not** `LCU` (two parameters and `untl` against one parameter and `F`); that the consequents differ in shape, `LCU`'s being an implication `⟐α → ⟐G≤ …` with the guard outside the `⟐`; that neither `lcU` nor `blc_plusValid` subsumes the other; and that `.Base` validity is open for both.
- [ ] `FormalSystem/PlusLanguage/PlusLCSchema.lean`, `lcN`'s own docstring (lines 203-205): remove "`LCU` is not declared in this tree." and point to `lcU` and its validity theorems instead, keeping the not-an-instance distinction.
- [ ] `docs/theorem-index.md` line 502, the `lcN_plusValidZTime` row: remove "and is not declared in this tree" from the clause "The until-form `LCU` is **not** an instance of this schema (two parameters and `untl`, against one parameter and `F` at `lcN 1`) and is not declared in this tree". Keep the not-an-instance distinction and the neither-subsumes-the-other clause verbatim. Do **not** add the four new rows here — those are Phase 4.
- [ ] `FormalSystem/PlusLanguage/README.md` line 41, the `PlusLCSchema.lean` inventory Description cell: remove "and is not declared in this tree" and add `lcU` plus `lcU_plusValidInt`/`lcU_plusValidZTime`/`lcU_reflectTime_plusValidZTime` to the declaration list. **This edit is made by hand**: `check-module-invariants.sh --emit-inventory` preserves the Description cell and refreshes only the line-count numbers, so this change survives Phase 4's regeneration and must not be deferred to it. Leave the stale `338` count alone — Phase 4's generator owns it.
- [ ] Read every edited hunk back against this plan's Non-Goals: no sentence may assert or imply that `lcU` is derivable in TM⁺, that TM⁺ + `IsLCUAxiom` is complete, that `lcU` follows from `lcN`, or that `lcU` is valid at `.Base`.
- [ ] Confirm no record-versioning language was introduced: no "previously", "no longer", "formerly", "used to", "now declared" framing relative to an unstated past. State the current design only.
- [ ] Run `lake build && bash scripts/typst-sync-check.sh --fix`, then `--counts-only`, and stage `typst/generated/status.typ` — this phase touches a `.lean` path, so the pre-commit hook fires even though every Lean edit is inside a comment.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly four surfaces are edited here — two docstring regions in `PlusLCSchema.lean`, one `docs/theorem-index.md` row, one `README.md` inventory Description cell — the fifth surface (`stg_step`) having been repaired in Phase 1. All four are confirmed to exist at plan authoring time by `grep -rn "LCU" --include=*.lean --include=*.md`, which returned exactly these surfaces plus `stg_step`'s and nothing else outside `specs/`. Confirm at implementation time by re-running that grep after the edits: it must return only descriptive, still-true `LCU` mentions and no undeclared-ness assertion. If a surface has moved or been repaired by other work in the interim, repair whatever the re-run grep actually finds and record the divergence rather than editing a line number that no longer matches.

**Tier Justification**: `lake build FormalSystem.PlusLanguage.PlusLCSchema` is the cheapest check that covers this edit, and `prose` does not: the edit rewrites a `/-!`-delimited module docstring region, where an unbalanced `-/` silently moves the comment boundary and breaks elaboration — precisely the `prose` tier's named blind spot.

**Files to modify**:

- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - module docstring `## LCU` section and `lcN`'s docstring: remove the undeclared-ness assertions, keep the distinctions
- `docs/theorem-index.md` - the `lcN_plusValidZTime` row: remove "and is not declared in this tree"
- `FormalSystem/PlusLanguage/README.md` - the `PlusLCSchema.lean` inventory Description cell: remove the undeclared-ness clause, add the four new declaration names by hand
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`; the hook fires on any staged `.lean` path, comment-only or not

**Verification**:

- `lake build` exits 0 with zero errors and zero warnings — the docstring edits did not cross a comment boundary.
- `timeout 60 grep -rn "not declared in this tree\|is not declared anywhere in this tree" --include=*.lean --include=*.md . | grep -v '^./specs/'` returns nothing.
- `timeout 60 grep -rn "LCU" --include=*.lean --include=*.md . | grep -v '^./specs/'` returns only still-true descriptive mentions; read each hit and confirm it asserts no undeclared-ness.
- `grep -n "not.*instance of" FormalSystem/PlusLanguage/PlusLCSchema.lean docs/theorem-index.md FormalSystem/PlusLanguage/README.md` still finds the not-an-instance distinction on all three surfaces — it was kept, not collaterally deleted.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- Each file this phase modifies individually passes `bash .claude/scripts/validate-artifact.sh`-independent lints that name it; the repo-wide `check-module-invariants.sh` count does not increase relative to the pre-task commit (baseline delta, per gate-collisions Condition 4).

---

### Phase 4: Theorem-index rows, the C14 pins, and the generated surfaces [COMPLETED]

**Goal**: Index and pin all four new declarations and reconcile both generated line-count surfaces, leaving the full gate set green.

**Tasks**:

- [ ] Add four rows to `docs/theorem-index.md`, one each for `int_marker_bracket`, `lcU_plusValidInt`, `lcU_plusValidZTime` and `lcU_reflectTime_plusValidZTime`. Place the `int_marker_bracket` row with its `PlusOmegaChain.lean` siblings and the three `lcU_*` rows after the `lcN` rows (491-503 as of plan authoring). Each row's `Axioms` cell reads `pcq pinned:C14`.
- [ ] Each `lcU_*` row states the claim and the limit: validity at the `ℤ` fibre / at `.ZTime` / for the `reflectTime` mirror, `.Base` **OPEN** with the cofinality obstruction named, and no derivability or completeness claim. Mirror the `lcN_plusValidZTime` row's shape.
- [ ] Extend the `C14` baseline pair in `scripts/check-module-invariants.sh`: four `#print axioms FormalSystem.PlusLanguage.{name}` lines at the tail of the `PlusLanguage` block in the `C14LEAN` heredoc (after `lcN_reflectTime_plusValidZTime`), and four matching `'FormalSystem.PlusLanguage.{name}' depends on axioms: [propext, Classical.choice, Quot.sound]` lines at the tail of the same block in `C14BASE` — in the **same order** in both heredocs. The two heredocs are compared by exact string equality and divergence is a HARD STOP.
- [ ] Use the axiom-profile text recorded in Phases 1 and 2 from the actual `#print axioms` output. Do not predict it: `int_marker_bracket`'s three siblings in the same section (`int_marker_add_le`, `intOrder_omega_cofinal`, `int_marker_exists_gt`) all carry the shorter `[propext, Quot.sound]`, so the uniform `pcq` profile is a measured fact about these four declarations, not a pattern to infer. (Re-derived at plan-authoring time by compiling the probe: all four are `[propext, Classical.choice, Quot.sound]`.)
- [ ] Regenerate the module-inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`, then verify with `bash scripts/check-module-invariants.sh --emit-inventory --check`. Confirm Phase 3's hand-written `PlusLCSchema.lean` Description cell survived and only the numbers changed.
- [ ] Regenerate `typst/generated/status.typ`: `lake build && bash scripts/typst-sync-check.sh --fix`, then `bash scripts/typst-sync-check.sh` in full (not only `--counts-only`).
- [ ] Confirm the out-of-scope conditions stayed out of scope: no new file was added, so `lake exe mk_all --lib FormalSystem` (C33) is not needed; no new import was added, so `scripts/check-metalogic-cycles.sh` assertion B is untouched; no new name resembles a module path, so no `scripts/module-invariants-allowlist.txt` entry is needed. Verify rather than assume — if any turns out to be needed, add it here with its companion file in this phase's scope.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Four theorem-index rows and four matched `C14` heredoc pairs (eight lines total across the two heredocs) land here, plus two regenerated surfaces. The `C14` insertion point is the tail of the `PlusLanguage` block in each heredoc, located at plan authoring immediately after the `lcN_reflectTime_plusValidZTime` entries. Confirm at implementation time by `grep -n "lcN_reflectTime_plusValidZTime" scripts/check-module-invariants.sh` returning exactly two hits, one in each heredoc, and by `bash scripts/check-module-invariants.sh` reporting C14 PASS after the edit.

**Files to modify**:

- `docs/theorem-index.md` - four new rows, each with `Axioms` cell `pcq pinned:C14`
- `scripts/check-module-invariants.sh` - four `#print axioms` lines in the `C14LEAN` heredoc and four matching baseline lines in `C14BASE`, same order, at the tail of the `PlusLanguage` block
- `FormalSystem/PlusLanguage/README.md` - regenerated inventory line counts (Description cell preserved from Phase 3)
- `README.md` - regenerated totals block
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`

**Verification**:

- The complete gate set for this repository runs and is observed green in this dispatch, not trusted on sight: `lake build` (zero errors, zero warnings, zero sorries), `bash scripts/check-module-invariants.sh` (C14 PASS, C15 PASS, C5/C26/C33 PASS, no `FAIL INV`), `bash scripts/check-module-invariants.sh --emit-inventory --check`, `bash scripts/typst-sync-check.sh` in full, and `bash scripts/check-metalogic-cycles.sh`.
- `bash .claude/scripts/verify-deploy.sh` — findings are read against the tree's standing baseline, never as a bare "the gate passes": the phase is green when no finding names a file this task touched (gate-collisions Condition 2). Enumerate any pre-existing finding explicitly rather than editing an out-of-scope file to force an absolute zero (Condition 4).
- C14's own output confirms the four new pins: `bash scripts/check-module-invariants.sh 2>&1 | grep -n "C14"` shows PASS with the new declaration count, not a HARD STOP.
- Every one of the four new `docs/theorem-index.md` rows is anchored at its declaration, per C15's second assertion — confirmed by C15 PASS, which reports the total row count it checked.
- `git status --short` and `git diff --staged` are reviewed before the commit; no file outside this phase's declared scope is staged.

**Verification notes (recorded at implementation time)**:

- **Batch gate deferral did not bite.** This dispatch's directive permitted discharging this
  phase's `full` tier against a scoped subset, with the complete set deferred to the batch stage.
  That allowance was not used: the complete gate set named above was run independently and in
  full in this dispatch, and every one of it is green. Nothing was deferred.
- `lake build` (full, through `lake-build-guard.sh`): exit 0, 2966 jobs, zero `error:` and zero
  `warning:` lines.
- `bash scripts/check-module-invariants.sh`: **exit 0, ALL CHECKS PASSED**. C14 PASS on both
  assertions — the four new pins matched their baseline, no HARD STOP. C15 PASS with 436
  theorem-index rows carrying their anchor (432 before this task, +4). C21, C26, C33 PASS. The
  `FAIL INV` stale-inventory deferral carried from Phases 1-3 is closed.
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: exit 0,
  `PASS INV every generated inventory block is current, every hand-maintained one is exhaustive`.
  Phase 3's hand-written `PlusLCSchema.lean` Description cell survived the regeneration; only the
  line count changed (338 → 490).
- `bash scripts/typst-sync-check.sh` (full, not `--counts-only`): exit 0, all 4 checks green.
- `bash scripts/check-metalogic-cycles.sh`: exit 0.
- `bash .claude/scripts/verify-deploy.sh --findings --skip-slow`: exit 0. One standing
  WARN-FINDING, `gate16 lean still declares routing_hard/routing_agents_hard`, which names no
  file this task touched. No finding names any of `PlusLCSchema.lean`, `PlusOmegaChain.lean`,
  `docs/theorem-index.md`, `scripts/check-module-invariants.sh`, `typst/generated/status.typ`, or
  either `README.md`.
- Out-of-scope conditions verified rather than assumed: `git diff 17399bdd5 -- FormalSystem/`
  shows no added or removed `import` line, so `check-metalogic-cycles.sh` assertion B is
  untouched; `--name-status` over the same range shows three modified files and no added file, so
  `lake exe mk_all --lib FormalSystem` is not needed and C33 PASS confirms `FormalSystem.lean` is
  still byte-for-byte the generated root at 747 imports; C26 PASS, so no
  `scripts/module-invariants-allowlist.txt` entry is needed.
- `bash .claude/scripts/lean-plan-compliance-check.sh` reports `COMPLIANCE_CHECK: failed`. The
  verdict is driven entirely by two harvested tokens that are not Lean declarations: `C14` (a
  gate identifier, from the Goals bullet "the `C14` baseline pair extended") and `LCU` (the
  schema's prose display name; its Lean identifier `lcU` is reported `[OK]`). All four
  identifiers this plan's `## Lean Challenge Statements` block names —
  `int_marker_bracket`, `lcU_plusValidInt`, `lcU_plusValidZTime`,
  `lcU_reflectTime_plusValidZTime` — are reported `[OK]`, as is `lcU` itself. The script's
  verdict is recorded as measured, not reinterpreted, and the plan's Goals prose was deliberately
  NOT edited to make the harvest pass.

---

## Testing & Validation

- [ ] `lake build` exits 0 with zero errors, zero warnings (CI builds with `--wfail`, so a warning is a failure) and zero sorries across the whole library.
- [ ] All four new declarations print `[propext, Classical.choice, Quot.sound]` under `#print axioms`, matching the profile re-derived from the probe at plan-authoring time.
- [ ] `bash scripts/check-module-invariants.sh` is green, with C14 and C15 both PASS and no `FAIL INV`.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash scripts/typst-sync-check.sh` (full, not `--counts-only`) exits 0.
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0 — no new upward import was introduced.
- [ ] No live deliverable surface asserts that `LCU` is undeclared; every not-an-instance / neither-subsumes / `.Base`-open distinction is still present and stated on its own merits.
- [ ] No deliverable file asserts or implies that `lcU` is derivable in TM⁺, that TM⁺ + `IsLCUAxiom` is complete, or that `lcU` follows from `lcN`.
- [ ] `bash .claude/scripts/verify-deploy.sh` produces no finding naming a file this task touched; any pre-existing finding is enumerated as the standing baseline.

## Artifacts & Outputs

- `FormalSystem/PlusLanguage/PlusOmegaChain.lean` — `int_marker_bracket`; `stg_step` docstring repaired with its realised consumer and the interval-endpoint discipline
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` — `lcU`, `lcU_plusValidInt`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime`; `## LCU` and `lcN` docstrings repaired
- `docs/theorem-index.md` — four new rows; the `lcN_plusValidZTime` row's undeclared-ness clause removed
- `scripts/check-module-invariants.sh` — four matched `C14` baseline pairs
- `FormalSystem/PlusLanguage/README.md` — inventory Description cell updated by hand, line counts regenerated
- `README.md`, `typst/generated/status.typ` — regenerated line-count surfaces
- `specs/893_lcu_until_form_schema_ztime_validity/summaries/01_lcu-until-form-ztime-validity-summary.md` — execution summary at completion

## Rollback/Contingency

The change is additive: four new declarations, four new index rows, four new baseline pairs, and prose edits. Nothing existing is removed or renamed, so a revert is a plain `git revert` of the phase commits in reverse order, with `typst/generated/status.typ` and the inventory blocks regenerated afterwards (`bash scripts/typst-sync-check.sh --fix`, `bash scripts/check-module-invariants.sh --emit-inventory`) so the generated surfaces match the reverted tree.

Because each phase commits its own green state, a failure in a later phase never requires discarding an earlier phase's work. If an intermediate phase must be abandoned mid-edit with uncommitted changes in the tree, take a durable, non-reverting checkpoint first — `bash .claude/scripts/git-snapshot.sh 893 --no-revert` — rather than any reverting form; see `context/contracts/recovery.md`'s rollback rung for the invocation shape of a genuine rollback, including its out-of-scope override flag, and never emit the bare reverting form as a precaution.

Contingency on an unexpected `C14` HARD STOP: the two heredocs diverged, which means either an ordering mismatch between them or a profile text that does not match the measured `#print axioms` output. Fix by re-reading the actual output and correcting the baseline line — never by relaxing the check or treating the divergence as a new baseline.

Contingency if the open-interval `P` instantiation fails to discharge `hP` on arrival: the endpoint reading is the one piece of this construction that is not a transcription, and the report records the open reading as both what is provable and what the consequent needs. Re-read the `untl_iff` clause's guard conjunct before changing the instantiation, and do not widen `P` to the half-open `(s, s']` — that reading is not derivable from the antecedent.
