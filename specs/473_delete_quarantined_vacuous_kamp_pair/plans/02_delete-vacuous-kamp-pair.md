# Implementation Plan: Task #473

- **Task**: 473 - Delete the quarantined vacuous Kamp Prop 4.2 pair
- **Status**: [IMPLEMENTING]
- **Effort**: 3.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/473_delete_quarantined_vacuous_kamp_pair/reports/01_delete-quarantined-vacuous-kamp-pair.md
- **Artifacts**: plans/02_delete-vacuous-kamp-pair.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Delete two quarantined, sorry-free but vacuous theorems — `neg_2var_vec_ea`
(`Kamp/EANegationClosure.lean`) and its sole consumer `reflatten_neg_step`
(`Kamp/NfMultiAnchorBridge/NavigatedSpine.lean`) — then sweep every prose reference that
presents them as landed Prop 4.2 deliverables, redirecting each to the machine-checked
vacuity record. The record files `Prop42Vacuity.lean` and `Prop42Contentful.lean` are
KEPT; only their cross-references to the deleted names change. Nothing is proved, no sorry
is closed, and no attempt is made to repair the pair into a contentful form.

### Research Integration

The research report independently re-verified the zero-consumer claim by word-boundary
grep over all `.lean` under `FormalSystem/` and `Tests/` and all non-`specs/` markdown:
`neg_2var_vec_ea` has exactly one code consumer (the body of `reflatten_neg_step`),
`reflatten_neg_step` has zero. The `Boneyard/` same-named declaration is not a clash —
`lakefile.lean` sets `roots := #[FormalSystem]` and zero of 452 built `.olean` files sit
under any Boneyard path. Baseline `lake build` was confirmed green (exit 0, 2458 jobs) this
dispatch, so any post-deletion failure is attributable to the deletion. Exact deletion
ranges, a per-site prose inventory, and the gate set below are all taken from that report;
the ranges were spot-checked against the live files during planning and match.

The report also flags a collateral orphan chain (`neg_disjunct_list` at `:697`,
`neg_vecEA2` at `:655`) that loses its only consumer when `neg_2var_vec_ea` goes. That is
build-safe (Lean 4 has no default unused-declaration linter) and explicitly **out of
scope** — deliverable (a) names exactly two declarations.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but was not passed as roadmap context and carries no item naming
this quarantined pair. Its Kamp-chain entries concern `kamp_prior_expressive_completeness`
and the `nf_nvar_exist_all_depths` sorries, neither of which is downstream of the deleted
pair. No roadmap phases are added and ROADMAP.md is not modified.

## Goals & Non-Goals

**Goals**:
- Re-verify the zero-consumer claim by symbol before any edit, with a hard STOP if a live
  consumer appears (deliverable (b)).
- Delete `neg_2var_vec_ea` and `reflatten_neg_step` together (deliverable (a)).
- Rewrite or remove every prose site that presents either symbol as a landed asset
  (deliverable (d)).
- Preserve `Prop42Vacuity.lean` and `Prop42Contentful.lean` intact as explanations, editing
  only cross-references that name the deleted declarations (deliverable (c)).
- Replace rotted `file.lean:NNN` anchors pointing at the deleted pair with symbol-name
  references, computing no new line numbers (deliverable (e)).
- Land green: `lake build`, `lake build BimodalTest`, and `scripts/check-module-invariants.sh`
  with C2 and C3 unmoved.

**Non-Goals**:
- Removing the orphaned `neg_disjunct_list` / `neg_vecEA2` chain, or any other declaration.
- Repairing `neg_2var_vec_ea` into a contentful form; proving anything; closing any sorry.
- Correcting rotted anchors by inserting recomputed line numbers.
- Touching any file outside the seven-file `file_scope`. In particular `Decidability.lean`,
  `Verified/README.md`, `FMP/README.md`, `Soundness.lean`, `WeakCanonical.lean`,
  `RealModel/ShuffleReal.lean` and `PriorExpressivenessDense.lean` belong to the
  documentation-correction task and must be left alone.
- Editing `Boneyard/` prose (uncompiled, out of scope).
- Re-baselining C2 or C3 if either moves.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden consumer via `export`/`open`/dot-notation that grep missed | H | Very L | Phase 1 re-greps by symbol before editing; `lake build` in the same phase catches anything textual search missed. On failure: STOP and report, do not patch around it. |
| Implementer widens scope to the orphaned `neg_disjunct_list` / `neg_vecEA2` chain | M | M | Non-Goals state it explicitly; Phase 1 verification includes a diff check that exactly two declarations were removed. |
| Implementer "repairs" rotted anchors with recomputed line numbers | M | M | Deliverable (e) forbids it; every prose phase's verification greps the touched files for reintroduced `EANegationClosure.lean:` / `NavigatedSpine.lean:NNN` anchors on the deleted pair. |
| Prose rewrite weakens `Prop42Vacuity`'s explanation | H | M | Phase 3 lists exactly which regions are frozen (the refutation narrative, the anti-pattern guard paragraph, the reachability sentence, the theorem statement and proof) versus which change. |
| Deleting `neg_2var_vec_ea` before `reflatten_neg_step` leaves the tree red mid-phase | L | M | Phase 1 is declared `atomic-batch`: both deletions are one commit, intermediate states are expected red and MUST NOT be committed. |
| Edits stray outside `file_scope` | M | M | Final gate greps `git status`/`git diff --name-only` against the seven declared paths. |
| C2 or C3 moves | H | Very L | Phase 4 treats any movement as a HARD STOP and reports rather than re-baselining, per the script's own instruction. |
| A task number leaks into rewritten `FormalSystem/` prose, tripping C9 | M | L | Stated in every prose phase's task list; Phase 4 runs C9 explicitly. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is strictly linear: the
prose sweeps must follow the deletion (so dangling references are visible), and the final
gate must follow all edits.

---

### Phase 1: Re-verify by symbol, then delete both declarations [COMPLETED]

**Goal**: Independently confirm the zero-consumer claim, then remove exactly two theorem
blocks (declaration plus its docstring plus one trailing blank line each) in a single
atomic change that leaves the tree green.

**Tasks**:
- [ ] Re-verify by symbol BEFORE editing (deliverable (b), blocking):
      `grep -rnw 'neg_2var_vec_ea' FormalSystem/ Tests/ --include='*.lean' | grep -v Boneyard`
      and the same for `reflatten_neg_step`. Expected: the only code (non-comment) hits are
      the two declaration sites and the single use of `neg_2var_vec_ea` inside
      `reflatten_neg_step`'s body.
- [ ] **STOP CONDITION**: if any live code consumer beyond that appears, delete nothing,
      leave the tree untouched, and report the consumer. A surprise consumer means the
      analysis is wrong and the deletion is unsafe.
- [ ] Locate the blocks by their opening docstring text, not by line number, and confirm
      the boundaries before cutting: `EANegationClosure.lean` docstring opens
      `/-- **WARNING — THIS THEOREM'S CONCLUSION IS VACUOUS`; `NavigatedSpine.lean`
      docstring opens `/-- **WARNING — THIS RE-EXPORTS A VACUOUS STATEMENT`.
- [ ] Delete `reflatten_neg_step` in `NavigatedSpine.lean` (docstring through declaration
      plus the trailing blank line; expected span 182-213, ending just before
      `reflatten_prop43`'s docstring).
- [ ] Delete `neg_2var_vec_ea` in `EANegationClosure.lean` (expected span 725-765, ending
      just before the `/-- **List.permutations head-coverage**` docstring).
- [ ] Change no `import` line in either file. `NavigatedSpine` reaches `EANegationClosure`
      transitively via `SubBracket2V` and that edge is needed by other declarations;
      `EANegationClosure`'s own imports all remain consumed.
- [ ] Leave `neg_disjunct_list`, `neg_vecEA2`, and every other declaration in place.
- [ ] Do not touch prose in this phase — that is Phases 2 and 3.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Exactly two declarations are removed, spanning `EANegationClosure.lean`
725-765 and `NavigatedSpine.lean` 182-213, with no import changes. Confirm at implementation
time by locating each block via its opening docstring text (line numbers are a hypothesis,
the docstring text is the anchor), and by checking `git diff --stat` shows exactly two files
changed with roughly 41 and 32 deleted lines and zero added lines.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedSpine.lean` -
  remove the `reflatten_neg_step` docstring + theorem + trailing blank.
- `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` - remove the
  `neg_2var_vec_ea` docstring + theorem + trailing blank.

**Verification**:
- `lake build` exits 0. Any compile failure IS the surprise consumer of deliverable (b):
  stop and report, do not patch around it.
- `git diff --name-only` lists exactly the two files above.
- `git diff` shows only deletions (no added lines) and no `import` line touched.
- `grep -rnw 'neg_2var_vec_ea\|reflatten_neg_step' FormalSystem/ Tests/ --include='*.lean' | grep -v Boneyard`
  returns only prose hits (comments/docstrings); zero code hits remain.

---

### Phase 2: Sweep prose in the five consumer files [NOT STARTED]

**Goal**: Remove or rewrite every prose site in the non-record files that presents either
deleted symbol as a landed Prop 4.2 asset, redirecting each to the vacuity record by symbol
name.

**Tasks**:
- [ ] `EANegationClosure.lean` — delete the `neg_2var_vec_ea` bullet in the module header
      (~`:22`, "is model-dependent Prop 4.2 (existential output)") and the `## Key Theorems`
      bullet (~`:34`). If the surrounding 19-26 sentence still implies a live model-dependent
      counterpart to `neg_2var_vec_ea_indep`, re-word it so it does not.
- [ ] `NavigatedSpine.lean` (~`:21`) — rewrite the `**Prop 4.2** negation step → reflatten_neg_step`
      cross-reference to record that the Prop 4.2 negation step is NOT discharged, pointing at
      `Prop42Vacuity.prop42_conclusion_is_vacuous` and `Prop42Contentful.Prop42Contentful` by
      symbol name only.
- [ ] `NavigatedSpine.lean` (~`:59`) — delete the `neg_2var_vec_ea (EANegationClosure.lean:722, Prop 4.2)`
      bullet from the "Consumed-asset signatures confirmed present (do NOT rebuild)" list.
- [ ] `NavigatedSpine.lean` (~`:132-136`) — rewrite the whole "already had the two hardest
      halves landed" claim, not merely its negation bullet: name only what is genuinely landed
      (`VVecEA2.disj_holds`, `VVecEA2.conj_holds_vvecEA2`), state that the negation half is
      open, and point at `Prop42Vacuity`.
- [ ] `NavigatedSpine.lean` (~`:218`, inside `reflatten_prop43`'s docstring) — rewrite "the
      negation case rides Prop 4.2 (`reflatten_neg_step`)" so it states that `reflatten_prop43`
      covers only the ∨-collapse and the negation case is not supplied, citing `Prop42Vacuity`
      / `Prop42Contentful`. Retain `reflatten_prop43` itself; it is unaffected by the deletion.
- [ ] `NfMultiAnchorBridge.lean` (~`:102-103`) — put the "re-exported by ...
      `NavigatedSpine.reflatten_neg_step`" clause into the past tense. The NOTE's purpose
      (making the guard root-reachable) must survive in substance; only the present-tense
      re-export claim is now false.
- [ ] `NfMultiAnchorBridge.lean` (~`:111-114`) — drop "`/Prop 4.2`" from the EANegationClosure
      import NOTE's asset list. Do NOT remove the import: the edge still transitively supplies
      `PriorINF` (`HasAttainedINF` / `prior_hasAttainedINF`).
- [ ] `AggregateHookDischarge.lean` (~`:55`) — keep the paragraph's verdict and reasoning (it
      explains why the k=0 aggregate used the depth-1 fold engine); replace the
      `neg_2var_vec_ea, EANegationClosure.lean:722` reference with a symbol-name pointer to
      `Prop42Vacuity`.
- [ ] `SubBracket2V.lean` (~`:29`) — in the "Cross-references (external combinators, not in
      this file)" list, either drop the Lemma 3.2(2) row or repoint it at `Prop42Contentful`
      as the *unbuilt* target. Leave the Lemma 3.4 / `VVecEA2.conjStruct` row alone.
- [ ] Anchor policy: replace every `file.lean:NNN` anchor pointing at the deleted pair with a
      symbol-name reference. Compute no new line numbers anywhere.
- [ ] Write no task number into any `FormalSystem/` file (C9 gate).
- [ ] Touch only the five files listed below.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Ten prose sites across five files (EANegationClosure 2, NavigatedSpine 4,
NfMultiAnchorBridge 2, AggregateHookDischarge 1, SubBracket2V 1). Confirm at implementation
time by running
`grep -rnw 'neg_2var_vec_ea\|reflatten_neg_step' FormalSystem/Metalogic/WeakCanonical/Kamp/ --include='*.lean' | grep -v Boneyard | grep -v Prop42`
plus a `grep -n 'Prop 4\.2' ` over the same five files BEFORE editing, and reconciling the hit
list against the ten sites above. If the count differs, treat the grep as authoritative and
handle every hit; report the discrepancy.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` - 2 header/key-theorem bullets
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedSpine.lean` - 4 sites
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` - 2 import-NOTE sites
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateHookDischarge.lean` - 1 site
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SubBracket2V.lean` - 1 site

**Verification**:
- In-phase (tier `local`): after each file's edit, build that module alone
  (e.g. `lake build FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationClosure`) — Lean
  docstrings have a real parse surface, so a mis-closed `/-- -/` must be caught per file.
- Diff read-through confirming every changed hunk lies inside a comment/docstring region and
  no declaration, signature, or `import` line moved.
- `lake build` exits 0 at phase close.
- `grep -rnw 'neg_2var_vec_ea\|reflatten_neg_step' FormalSystem/ Tests/ --include='*.lean' | grep -v Boneyard`
  returns ZERO hits in these five files (all surviving hits confined to `Prop42Vacuity.lean`
  and `Prop42Contentful.lean`, handled in Phase 3).
- `grep -n 'EANegationClosure.lean:[0-9]\|NavigatedSpine.lean:[0-9]' ` over the five files
  shows no anchor to the deleted pair reintroduced.

---

### Phase 3: Update the vacuity record files [NOT STARTED]

**Goal**: Bring `Prop42Vacuity.lean` and `Prop42Contentful.lean` into truth about the now-deleted
pair while preserving their explanations verbatim in substance. Both files are KEPT
(deliverable (c)).

**Tasks**:
- [ ] `Prop42Vacuity.lean` (~`:12`) — rewrite "Read this before treating `neg_2var_vec_ea`
      (`EANegationClosure.lean:722`) as a proved asset" so it introduces the file as the record
      of a *deleted* declaration. Drop the file:line anchor.
- [ ] `Prop42Vacuity.lean` (~`:18`, `:24-32`) — **KEEP the refutation mathematics verbatim.**
      The name `neg_2var_vec_ea` may remain as a historical referent provided the surrounding
      tense makes clear it no longer exists.
- [ ] `Prop42Vacuity.lean` (~`:36-40`) — **KEEP** the "does not claim `neg_2var_vec_ea` is
      broken" paragraph; tense-adjust only. This is the anti-pattern guard and MUST NOT be
      weakened.
- [ ] `Prop42Vacuity.lean` (~`:81-87`) — **the single most important edit.** The section
      `## Live declarations still presenting the vacuous shape` ("Annotated in place;
      deliberately not deleted (they are consumed live)") is now outright false. Replace it
      with a section recording that both declarations were DELETED because they were
      quarantined (one consumer, itself with none), naming them by symbol only. Both anchors
      in it are rotted — remove them, do not correct them.
- [ ] `Prop42Vacuity.lean` (~`:76-79`) — keep the reachability sentence verbatim (the import
      edge in `NfMultiAnchorBridge.lean` is still landed and still the point); tense-adjust
      only the "if someone ever repairs `neg_2var_vec_ea`" clause.
- [ ] `Prop42Vacuity.lean` (~`:95`, `:98`, `:101`) — in `prop42_conclusion_is_vacuous`'s own
      docstring, drop the `(EANegationClosure.lean:722)` anchor and tense-adjust. The theorem
      statement and proof (~`:105-117`) are UNTOUCHED.
- [ ] `Prop42Vacuity.lean` (~`:53-55`, `:65-70`) — secondary rotted anchors into `Boneyard/`
      (`NegationIndep.lean:315`/`:319`, actual `:319`/`:323`; `Prop43.lean:120-129`, actual
      ~`:126-142`). Convert to symbol/file references. Do NOT compute corrected line numbers.
- [ ] `Prop42Contentful.lean` (~`:32`) — drop the `(EANegationClosure.lean:722)` anchor and
      tense-adjust to "the shape the deleted `neg_2var_vec_ea` had". The two-bullet vacuity
      taxonomy at ~`:30-38` is the constructive core and MUST be preserved exactly.
- [ ] `Prop42Contentful.lean` (~`:161`) — drop the now-dangling "(and its vacuous
      `neg_2var_vec_ea`)" parenthetical. The justification for the local `private` re-proofs
      (`tp_neg_iff`, `tp_top_holds`) is import weight and still stands; keep it.
- [ ] Change no theorem statement, no proof, and no `import` line in either file.
- [ ] Write no task number into either file (C9 gate).

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Nine edit sites — seven in `Prop42Vacuity.lean`, two in
`Prop42Contentful.lean` — all confined to comments and docstrings, with zero declarations,
proofs, or imports changed. Confirm at implementation time by running
`grep -nw 'neg_2var_vec_ea\|reflatten_neg_step' FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Vacuity.lean FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean`
before editing and reconciling against the list above; treat the grep as authoritative and
report any discrepancy.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Vacuity.lean` - cross-references and the
  `## Live declarations still presenting the vacuous shape` section
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean` - 2 cross-reference sites

**Verification**:
- In-phase (tier `local`): build each edited module alone after its edit.
- `git diff` for both files shows changes confined to comment/docstring regions: no `theorem`,
  `lemma`, `def`, or `import` line altered.
- `lake build` exits 0.
- `grep -n 'EANegationClosure.lean:[0-9]\|NavigatedSpine.lean:[0-9]' ` over both files returns
  no anchor to the deleted pair.
- The frozen regions still read as before in substance: the refutation narrative, the
  anti-pattern guard paragraph, the root-reachability sentence, the `Prop42Contentful`
  two-bullet taxonomy, and `prop42_conclusion_is_vacuous`'s statement and proof.

---

### Phase 4: Final verification gate [NOT STARTED]

**Goal**: Run the complete gate set and confirm nothing was load-bearing after all. No file
edits in this phase.

**Tasks**:
- [ ] `lake build` -> exit 0.
- [ ] `lake build BimodalTest` -> exit 0.
- [ ] `bash scripts/check-module-invariants.sh` -> **C2 PASS** (all four flagship axiom sets
      match baseline: `BXCanonical.completeness`, `completeness_dense`, `completeness_discrete`,
      `Chronicle.countermodel_dense`) and **C3 PASS** (exactly one live structural sorry,
      `countermodel_discrete` in `WeakCanonical/Transfer.lean`).
- [ ] **HARD STOP** if C2 or C3 moves: something was load-bearing. Report; do NOT re-baseline
      (the script itself calls a C2 divergence a hard stop, not a new baseline).
- [ ] Confirm C9 (zero task-number citations under `FormalSystem/`) is still green.
- [ ] Residual-symbol grep:
      `grep -rnw 'neg_2var_vec_ea\|reflatten_neg_step' FormalSystem/ Tests/ --include='*.lean' | grep -v Boneyard`
      -> surviving hits ONLY as intentional historical prose in `Prop42Vacuity.lean` and
      `Prop42Contentful.lean`; zero in the other five files.
- [ ] File-scope containment: `git diff --name-only` against the merge base lists only the
      seven declared `file_scope` paths and nothing else — in particular none of
      `Decidability.lean`, `Verified/README.md`, `FMP/README.md`, `Soundness.lean`,
      `WeakCanonical.lean`, `RealModel/ShuffleReal.lean`, `PriorExpressivenessDense.lean`.
- [ ] Confirm zero new `sorry` and zero new axiom introduced (trivially satisfied: the change
      is deletion plus prose).

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The cumulative diff touches exactly the seven declared `file_scope` paths
and no others. Confirm at implementation time with `git diff --name-only` against the merge
base; any eighth path is a scope breach to be reverted and reported, not accepted.

**Files to modify**:
- None. This phase is verification only.

**Verification**:
- All six gate items above satisfied, with the C2/C3 hard-stop honored.

---

## Testing & Validation

- [ ] `lake build` exits 0.
- [ ] `lake build BimodalTest` exits 0.
- [ ] `scripts/check-module-invariants.sh`: C2 PASS (four flagship axiom sets unmoved), C3 PASS
      (sole structural sorry `countermodel_discrete`), C9 green.
- [ ] Zero code references to `neg_2var_vec_ea` or `reflatten_neg_step` outside `Boneyard/`.
- [ ] Zero prose references presenting either symbol as a landed asset; every surviving mention
      is historical and points at the vacuity record.
- [ ] No `file.lean:NNN` anchor to the deleted pair anywhere; no newly computed line numbers.
- [ ] Diff confined to the seven `file_scope` files.
- [ ] `Prop42Vacuity.lean` and `Prop42Contentful.lean` still present, still root-reachable, and
      their explanations intact.

## Artifacts & Outputs

- Two theorem declarations removed (~73 lines including docstrings).
- Ten prose sites rewritten or removed across five consumer files.
- Nine cross-reference sites updated across the two record files, including the replacement of
  `Prop42Vacuity.lean`'s `## Live declarations still presenting the vacuous shape` section with
  a deletion record.
- A green tree with C2/C3 unmoved.

## Rollback/Contingency

Every phase ends at a green build and is committed separately (Phase 1 as one atomic
two-file commit), so `git revert` of any single phase commit restores the prior green state.
If Phase 1's re-verification finds a surprise consumer, nothing has been edited yet — abort
with a report and leave the tree untouched. If `lake build` fails after the deletion, that
failure IS the surprise consumer of deliverable (b): revert the deletion commit and report
the consumer rather than patching around it. If C2 or C3 moves at the final gate, revert to
the last green commit and report; do not re-baseline either check.
