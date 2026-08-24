# Research: delete the quarantined vacuous Kamp Prop 4.2 pair

**Task type**: lean4
**Session**: sess_1787608533_153fad_473
**Date**: 2026-08-24
**Grounding**: `specs/reviews/review-2026-08-24.md` Addendum A-3; task description deliverables (a)-(e)

---

## 1. Verdict up front

**The zero-consumer claim is CONFIRMED. The deletion is safe. Proceed.**

Re-verified independently this dispatch by word-boundary grep (`grep -rnw`) over every `.lean`
file in `FormalSystem/` and `Tests/`, and over every `.md` file outside `specs/`:

| Symbol | Code consumers (non-Boneyard) | Verdict |
|---|---|---|
| `neg_2var_vec_ea` | exactly **1** — `NavigatedSpine.lean:212`, the body of `reflatten_neg_step` | deletable once its one consumer goes |
| `reflatten_neg_step` | **0** | deletable |

No hit in `Tests/`. No hit in any non-`specs/` markdown. Every other repository-wide occurrence of
either symbol is prose or lives under a `Boneyard/` directory.

**Boneyard is provably not compiled**: `lakefile.lean` declares `lean_lib FormalSystem` with
`roots := #[FormalSystem]`, and the build tree contains 452 `.olean` files of which **zero** are
under any `Boneyard/` path. So `FormalSystem/Boneyard/KampNegationClosure/NegationClosureProp42.lean:161`,
which declares a *same-named* `neg_2var_vec_ea`, is not a name clash and not a consumer — it is
archived source that never reaches the compiler.

**Baseline build state**: `lake build` was run at the start of this dispatch and exits **0**
(`Build completed successfully (2458 jobs)`), so the implementer starts from a green tree and any
post-deletion failure is attributable to the deletion.

No surprise consumer was found. The STOP condition in deliverable (b) is **not** triggered.

---

## 2. Exact deletion targets

### 2a. `neg_2var_vec_ea` — `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean`

- Docstring: lines **725-754** (opens `/-- **WARNING — THIS THEOREM'S CONCLUSION IS VACUOUS...`)
- Declaration: lines **755-764** (`theorem neg_2var_vec_ea` … `exact neg_disjunct_list h_INF z0 z1 h_lt v.disjuncts h_neg`)
- Line 765 is blank; line 766 opens the next docstring (`/-- **List.permutations head-coverage**`).

Delete **725-765** (block plus its trailing blank line). The file is 799 lines; after deletion it is 758.

### 2b. `reflatten_neg_step` — `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedSpine.lean`

- Docstring: lines **182-205** (opens `/-- **WARNING — THIS RE-EXPORTS A VACUOUS STATEMENT...`)
- Declaration: lines **206-212** (body is the single term `neg_2var_vec_ea h_INF v z0 z1 h_lt h_neg`)
- Line 213 is blank; line 214 opens `reflatten_prop43`'s docstring.

Delete **182-213**.

**Ordering note**: delete `reflatten_neg_step` (2b) first or in the same commit as (2a). Deleting
`neg_2var_vec_ea` alone would break `NavigatedSpine.lean:212`.

**Imports**: no import edge changes. `NavigatedSpine` reaches `neg_2var_vec_ea` transitively via
`SubBracket2V`, and that import is needed for many other declarations. `EANegationClosure`'s own
imports are all still consumed. Do not touch any `import` line.

---

## 3. Collateral finding — a private orphan chain (report, do NOT act on)

Deleting `neg_2var_vec_ea` orphans a ~110-line chain inside `EANegationClosure.lean`:

- `neg_disjunct_list` (`:697`, **`private`**) — its ONLY consumer is `neg_2var_vec_ea` (`:764`).
- `neg_vecEA2` (`:655`, public) — its ONLY consumer is `neg_disjunct_list` (`:719`).

**This does not break the build.** Lean 4 has no default linter for unused declarations (the
`unusedVariables` linter that fires elsewhere in this repo targets binders, not decls), and unused
`private` theorems are not diagnosed. Verified: the current build emits `unusedVariables` warnings
and still exits 0, so warnings are not errors here.

Broader (also informational): after this deletion the **only** declaration in
`EANegationClosure.lean` with an external code consumer is `exists_permutation_cons_head`
(consumed at `SubBracket2V.lean:374`). `neg_interval_formula`, `neg_bounded_exists`,
`VBracketFormula.toVVecEA2WithEndpoints`(`_holds`), `inf_bracket_formula_holds` and
`exists_permutation_head?_eq` all have zero external consumers already — that is pre-existing, not
caused by this task.

**Recommendation**: leave every one of these in place. Deliverable (a) names exactly two
declarations. Removing the orphan chain is a separate scoping decision with its own build surface
and belongs in a follow-up task, not here.

---

## 4. Prose sweep inventory (deliverable (d) + (e))

Fourteen distinct sites outside the two deleted blocks, all inside `file_scope`. Grouped by file,
with the required action. Anchors marked **ROT** are line numbers that are already wrong today.

### `Kamp/EANegationClosure.lean`

| Line | Current text | Action |
|---|---|---|
| 22 | `- \`neg_2var_vec_ea\` is model-dependent Prop 4.2 (existential output)` | **Delete the bullet.** Lines 19-26 then read as a claim about `neg_interval_formula` alone; keep 23-26's mention of `neg_2var_vec_ea_indep` only if the sentence is re-worded so it no longer implies a live model-dependent counterpart exists. |
| 34 | `- \`neg_2var_vec_ea\`: Prop 4.2 -- negation of VVecEA2 produces VVecEA2 (model-dependent).` | **Delete the bullet** from the `## Key Theorems` list. |

(Lines 744 and 747, inside the deleted docstring, carry two more rotted anchors —
`Boneyard/NegationIndep.lean:315` and `NfMultiAnchorBridge/NavigatedSpine.lean:178`. Both vanish
with the block; no separate action.)

### `Kamp/NfMultiAnchorBridge/NavigatedSpine.lean`

| Line | Current text | Action |
|---|---|---|
| 21 | `- **Prop 4.2** negation step (md:100-101) → \`reflatten_neg_step\`.` | **Rewrite** to record that the Prop 4.2 negation step is **not** discharged, pointing at `Prop42Vacuity.prop42_conclusion_is_vacuous` (refutation) and `Prop42Contentful.Prop42Contentful` (the target shape). Symbol names only — no line numbers. |
| 59 | `- \`neg_2var_vec_ea\` (EANegationClosure.lean:722, Prop 4.2) — landed negation closure.` **ROT** (it was at `:755`) | **Delete the bullet.** It sits in a "Consumed-asset signatures confirmed present (do NOT rebuild)" list; the asset no longer exists and was never a real consumed asset. |
| 132-136 | `The codebase already had the two hardest halves landed:` / `- **negation** (Prop 4.2): \`neg_2var_vec_ea\` (EANegationClosure.lean:722);` **ROT** | **Rewrite the whole claim**, not just the bullet. "already had the two hardest halves landed" is the exact false statement the vacuity record exists to stop. Remove the negation bullet and re-word the lead-in to name only what is genuinely landed (`VVecEA2.disj_holds`, `VVecEA2.conj_holds_vvecEA2`), stating that the negation half is open and pointing at `Prop42Vacuity`. |
| 218 | `... the negation case rides Prop 4.2 (\`reflatten_neg_step\`).` — inside `reflatten_prop43`'s docstring | **Rewrite.** This is a *dangling reference to a deleted declaration* after (a). Replace with a statement that `reflatten_prop43` covers only the `∨`-collapse and that the negation case is **not** supplied, citing `Prop42Vacuity` / `Prop42Contentful` by symbol name. `reflatten_prop43` itself is retained — it has three live prose consumers (`:22`, `:143`, `:238`, `:436`) and is unaffected by the deletion. |

### `Kamp/NfMultiAnchorBridge.lean`

| Line | Current text | Action |
|---|---|---|
| 102-103 | `Prop42Vacuity proves that \`neg_2var_vec_ea\`'s conclusion — re-exported by this file's neighborhood via \`NavigatedSpine.reflatten_neg_step\` — follows from NO hypotheses, and so carries no content about negation.` | **Rewrite in past tense.** The import-edge NOTE's *purpose* (making the guard root-reachable) is unchanged and must survive verbatim in substance; only the "is re-exported by" present-tense clause is now false. Suggested shape: "…proves that the conclusion the now-deleted `neg_2var_vec_ea` / `reflatten_neg_step` pair carried follows from NO hypotheses…". |
| 111-114 | EANegationClosure import NOTE: `…and the Lemma 5.1/Cor 5.4/Prop 4.2 negation-stack assets consumed by Phases 13.2-13.4.` | **Secondary, recommended.** Drop "`/Prop 4.2`" from the list. The rest of the NOTE stays true: the edge still transitively supplies `PriorINF` (`HasAttainedINF`/`prior_hasAttainedINF`), and the import must NOT be removed. |

### `Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean`

| Line | Current text | Action |
|---|---|---|
| 55 | `…and the Prop 4.2 negation closure (\`neg_2var_vec_ea\`, EANegationClosure.lean:722) is MODEL-DEPENDENT (existential \`∃ v'\`, not a fixed syntactic object)…` **ROT** | **Rewrite to a symbol-name reference.** This paragraph's *verdict* is correct and load-bearing (it explains why the k=0 aggregate was built via the depth-1 fold engine instead), so keep the reasoning; replace the named declaration with a pointer to `Prop42Vacuity` — the conclusion "no negation closure is needed" is strengthened, not weakened, by the deletion. |

### `Kamp/NfMultiAnchorBridge/SubBracket2V.lean`

| Line | Current text | Action |
|---|---|---|
| 29 | `**Lemma 3.2(2)** 2-var reduction (md:78) → \`neg_2var_vec_ea\` (\`EANegationClosure.lean:722\`)` **ROT** | **Rewrite.** This is a "Cross-references (external combinators, not in this file)" list entry presenting a landed deliverable. Replace the `neg_2var_vec_ea` target with a pointer to `Prop42Contentful` as the *unbuilt* target, or drop the Lemma 3.2(2) row entirely. The Lemma 3.4 row (`VVecEA2.conjStruct`) is genuine and stays. |

### `Kamp/Prop42Vacuity.lean` — **KEEP the file; surgical edits only**

Per deliverable (c), the explanation stays intact. Only cross-references naming the deleted
declarations change. Sites:

| Line(s) | Action |
|---|---|
| 12 | `**Read this before treating \`neg_2var_vec_ea\` (\`EANegationClosure.lean:722\`) as a proved asset.**` **ROT** — rewrite: the file is now the record of a *deleted* declaration. Drop the file:line anchor. |
| 18, 24-32 | The refutation narrative. **Keep the mathematics verbatim.** These can retain the name `neg_2var_vec_ea` as a *historical* referent provided the surrounding tense makes clear it no longer exists. |
| 36-40 | "This file does not claim `neg_2var_vec_ea` is broken…" — **keep**, tense-adjust. This paragraph is the anti-pattern guard and must not be weakened. |
| 53-55 | Cites `neg_2var_vec_ea_indep` at `Boneyard/NegationIndep.lean:315` and `_correct` at `:319`. **ROT** — actual `:319` and `:323`. Per (e)'s policy, replace with symbol-name references (no line numbers). Secondary. |
| 65-70 | Cites `Prop43.lean:120-129` (**ROT** — the paragraph is at ~`:126-142` of `Boneyard/Prop43.lean`) and `Boneyard/NegationIndep.lean:357-364` (approximately right, ~`:355-366`). Secondary; convert to symbol/file references. |
| 76-79 | "This file is reachable from the root (the import edge is landed in `NfMultiAnchorBridge.lean`), so CI compiles it. If someone ever repairs `neg_2var_vec_ea` into the contentful shape above…" — **keep the reachability sentence verbatim** (still true and still the point); tense-adjust the second clause. |
| **81-87** | `## Live declarations still presenting the vacuous shape` / "Annotated in place; **deliberately not deleted** (they are consumed live): * `neg_2var_vec_ea` (`EANegationClosure.lean:722`) … * `reflatten_neg_step` (`NfMultiAnchorBridge/NavigatedSpine.lean:178`) …" — **This whole section becomes false and is the single most important edit in the sweep.** Replace with a section recording that both declarations were **deleted** because they were quarantined (one consumer, itself with none), naming them by symbol only. Both anchors here are **ROT** (`:755` and `:206` respectively) — do not replace them with corrected line numbers; remove them. |
| 95, 98, 101 | `prop42_conclusion_is_vacuous`'s own docstring. **Keep the content**; drop the `(\`EANegationClosure.lean:722\`)` anchor at `:95`, tense-adjust `:98`/`:101`. The theorem statement and proof are untouched. |

### `Kamp/Prop42Contentful.lean` — **KEEP the file; two edits**

| Line | Action |
|---|---|
| 32 | `This is the shape \`neg_2var_vec_ea\` (\`EANegationClosure.lean:722\`) actually has; refuted from no hypotheses at all by \`prop42_conclusion_is_vacuous\` (\`Prop42Vacuity.lean\`).` **ROT** — drop the anchor, tense-adjust ("the shape the deleted `neg_2var_vec_ea` had"). The two-bullet vacuity taxonomy at `:30-38` is the constructive core and must be preserved exactly. |
| 161 | `…without dragging in the whole model-dependent negation development (and its vacuous \`neg_2var_vec_ea\`).` — **rewrite**: the justification for the local `private` re-proofs (`tp_neg_iff`, `tp_top_holds`) is the import weight, which still stands; just drop the now-dangling parenthetical. |

**Anchor policy for the entire sweep (deliverable (e))**: replace every `file.lean:NNN` anchor
pointing at the deleted pair with a **symbol-name** reference. Do not compute new line numbers for
anything, including the surviving anchors listed as "secondary" above. Line-number rot is the
failure mode this task exists to stop.

---

## 5. Verification gates

Run in this order. All must be satisfied.

1. `lake build` → exit 0. (Baseline confirmed green this dispatch.)
2. `lake build BimodalTest` → exit 0.
3. `bash scripts/check-module-invariants.sh` → **C2 PASS** (all four flagship axiom sets match
   baseline) and **C3 PASS** (exactly one structural sorry, `countermodel_discrete` in
   `WeakCanonical/Transfer.lean`).

   The four C2 theorems, read from `scripts/check-module-invariants.sh:118-123`, are
   `BXCanonical.completeness`, `completeness_dense`, `completeness_discrete`, and
   `Chronicle.countermodel_dense`. None of them is downstream of the Kamp bridge in a way this
   deletion touches; the two deleted theorems have no consumers at all, so their axiom
   contribution is nil. **Predicted: no movement in either check.** If C2 or C3 moves, something
   was load-bearing — stop and report, do not re-baseline (the script itself calls a C2 divergence
   "a HARD STOP, not a new baseline").
4. `grep -rnw 'neg_2var_vec_ea\|reflatten_neg_step' FormalSystem/ Tests/ --include='*.lean' | grep -v Boneyard`
   → the only surviving hits should be the intentional *historical* prose in `Prop42Vacuity.lean`
   and `Prop42Contentful.lean`. Zero hits in `EANegationClosure.lean`, `NavigatedSpine.lean`,
   `NfMultiAnchorBridge.lean`, `AggregateHookDischarge.lean`, `SubBracket2V.lean`.
5. `scripts/check-module-invariants.sh` C9 (zero task-number citations under `FormalSystem/`) must
   stay green — **do not write "task 473" or any task number into the rewritten prose.**

Note that gate 3 subsumes gates 1 and 5 (the script runs `lake build` as C1). Running `lake build`
standalone first is still worth it for a fast failure signal.

---

## 6. Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| Hidden consumer via `export`/`open`/dot-notation that word-boundary grep misses | Very low | Neither symbol is in a structure namespace; both are plain `theorem`s in `FormalSystem.Metalogic.WeakCanonical.Kamp`. `grep -rnw` over all `.lean` catches every textual use. Gate 1 catches anything grep missed. |
| Unused-declaration linter fails the build on the orphaned `neg_disjunct_list` | Very low | No such default linter in Lean 4; current build already emits warnings and exits 0. |
| Implementer deletes the orphan chain too (§3) and widens the blast radius | Medium | Explicitly out of scope. Deliverable (a) names exactly two declarations. |
| Prose rewrite weakens `Prop42Vacuity`'s explanation | Medium | Deliverable (c) is explicit: keep the explanation intact. The mathematics at `:16-58` and the theorem at `:105-117` are untouched; only cross-references and the `:81-87` section change. |
| Implementer "fixes" rotted anchors by inserting new line numbers | Medium | Deliverable (e) forbids it. §4's anchor policy restates it. |
| Edits stray outside `file_scope` (e.g. Boneyard prose, `Decidability.lean`, the READMEs) | Medium | Boneyard files are not compiled and are owned by no one here. The documentation-correction task owns the other named files. Seven files, no more. |

---

## 7. Tactic survey

**Not applicable.** This task proves nothing, closes no sorry, and introduces no proof obligation.
Deliverable text is explicit: "Prove nothing, close no sorry, and do NOT attempt to repair
`neg_2var_vec_ea` into a contentful form." No tactic search, no `lean_multi_attempt`, no
`lean_hammer_premise` was run, and none is warranted. Zero-debt compliance is trivially satisfied:
the change is a pure deletion plus prose, adding no `sorry` and no axiom.

---

## 8. Recommended phase decomposition

Three phases, each one agent run, each ending at a green build.

- **Phase 1 — Re-verify and delete.** Re-run the §1 greps (deliverable (b) requires the implementer
  to re-verify by symbol before deleting). Then delete `NavigatedSpine.lean:182-213` and
  `EANegationClosure.lean:725-765`. Gate: `lake build` exit 0.
- **Phase 2 — Sweep the prose in the five consumer files.** `EANegationClosure.lean` (2 sites),
  `NavigatedSpine.lean` (4 sites), `NfMultiAnchorBridge.lean` (2 sites),
  `AggregateHookDischarge.lean` (1 site), `SubBracket2V.lean` (1 site). Gate: `lake build` exit 0
  plus §5 gate 4.
- **Phase 3 — Update the record files and run the full gate.** `Prop42Vacuity.lean` (esp. the
  `:81-87` section) and `Prop42Contentful.lean` (2 sites). Gate: `lake build`,
  `lake build BimodalTest`, and `scripts/check-module-invariants.sh` with C2/C3 both PASS.
