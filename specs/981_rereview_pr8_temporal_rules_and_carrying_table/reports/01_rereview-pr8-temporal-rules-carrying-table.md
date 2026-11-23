# Research Report: Task #981

**Task**: 981 - Re-review PR #8 (temporal rules and the carrying table)
**Started**: 2026-11-22T19:20:00Z
**Completed**: 2026-11-22T21:05:00Z
**Effort**: ~1.75h
**Dependencies**: Task 980 (PR #7 re-review) — read first; PR #7 merged as `3c7197f84`
**Sources/Inputs**: - Codebase (worktree at PR #8 head `49a7efe23`), `gh pr view`/`gh run view` for PR #8, lean-lsp project build/test/lint gates, `lake env lean` compiled probes, `#print axioms`, `records/{milestones,proof-mode,proof-mode-architecture}.md`, `specs/reviews/pr-reviews-2026-11-20/pr8-review.md`, `specs/reviews/pr-reviews-2026-11-21/pr7-{review,approval}.md`
**Artifacts**: - `specs/981_rereview_pr8_temporal_rules_and_carrying_table/reports/01_rereview-pr8-temporal-rules-carrying-table.md`
- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` (the draft response)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The PR head has moved since this task was filed.** It is now `49a7efe231cf98a488ad107dd981881557b1fd96`, not `b020320fd`. A third commit, "File temporal composition and tactics by rule family" (2026-11-22T18:44:07Z), lands review request 2 in full. The first-read finding "TemporalComposition.lean is not split by family" is stale and must not be repeated in the response.
- **The rebase is cheap and I have done it.** `git rebase --onto origin/main fc85c61b9` replays the four commits with seven conflicts, every one of them in a generated-metrics file or an import list, plus **one** real source break: six `Unknown identifier Language` errors in `Automation/ProofMode/Temporal.lean`, because merged PR #7 moved `Language` into `FormalSystem.Tactic.FormulaSyntax`. One `open` line and one `_root_.` qualification fix it. After that: `lake build --wfail` 3013 jobs green, `lake test` 3090 jobs green, `lake lint` green, `check-module-invariants.sh --no-build` ALL CHECKS PASSED. Nothing on this branch had ever been built or tested before this.
- **Nine of the thirteen requests are done or substantially done.** Not done: 1 (rebase), 3 (views out), 4 (induction — correctly, it was an invitation), 13 (records). Partly done: 8b (the carrying table), 10 (tests), 12 (clients described, not landed).
- **The carrying table needs its key changed, not its values.** `carryRules` (`Temporal.lean:120`) is `private`, two rows, keyed by a `past : Bool` plus one source operator. M1's rows need a `(source, target)` key. Compile-verified: three candidate M1 rows typecheck in the *same* proof-to-proof contextual shape the table already stores, so only the key and the visibility have to change.
- **Recommendation: REQUEST CHANGES, with three short conditions** — rebase (offer to do it), fix the one merged acceptance example whose meaning changed, and fix the carrying table's key and visibility. Everything else is a follow-up.

## Context & Scope

Re-review of collaborator PR #8 (`feat/proof-mode-temporal`, `[2/3] Add compositional temporal rules and persistent scope capture`) against the thirteen requests of `specs/reviews/pr-reviews-2026-11-20/pr8-review.md`, and preparation of a draft response. Constraints observed: nothing posted, merged, pushed or approved; all work on the pull-request head in a separate worktree (`/home/benjamin/Projects/.worktrees/BimodalLogic-pr8`, fetched via `git fetch origin refs/pull/8/head`); every claim backed by something run or read.

**Commit reviewed**: `49a7efe231cf98a488ad107dd981881557b1fd96`. Re-checked with `gh pr view 8` at the end of the task: unchanged, `state: OPEN`, `mergeable: CONFLICTING`.

**Commit chain** (`merge-base` with `main` is `81ae7a6c0`):

| sha | title | in this PR's own layer |
|---|---|---|
| `9695749ca` | docs: design compositional proof-mode extensions with mutual review | no — PR #7's |
| `fc85c61b9` | feat: add checked compositional rewriting and bounded simplification | no — PR #7's old head |
| `1f545ea0a` | feat: add compositional temporal rules and persistent scope capture | yes |
| `dc253dde5` | Tighten temporal rule application and scope carrying | yes |
| `b020320fd` | Exercise time reflection on library theorem clients | yes |
| `49a7efe23` | File temporal composition and tactics by rule family | yes — **new since this task was filed** |

**Not verified** (stated plainly, per ground rule iii): I did not run the repository's evidence probes, the `lean_exe` roots, or the `typst` compile; I did not attempt to derive the M4 induction rule (the task forbids it); I did not measure tactic cost or term size for any rule here.

## Findings

### Codebase Patterns

#### 1. Rebase cost — measured, not estimated

PR #8 sits on `fc85c61b9`, the **old** PR #7 head. PR #7 was squash-merged into `main` as `3c7197f84` at its **final** head `6313e693f`, so none of PR #8's ancestry is in `main`'s history and `6313e693f` is not an ancestor of the PR head. Confirmed by `git merge-base --is-ancestor`.

Two routes, both run:

| Route | Conflicts | Verdict |
|---|---|---|
| `git merge origin/main` into the branch | **19** files, including six `add/add` on files PR #7 introduced | wrong route — it re-presents all of PR #7 as a conflict |
| `git rebase --onto origin/main fc85c61b9` | **7** across the four commits | the right route |

The seven, by commit, with each one's class:

| File | Class | Resolution |
|---|---|---|
| `README.md` | generated metrics (file/line/comment counts) | regenerate |
| `FormalSystem/README.md` | generated metrics | regenerate |
| `FormalSystem/Automation/ProofMode/README.md` | generated inventory block | regenerate, **keeping the PR's own description cells** |
| `FormalSystem/Theorems/ProofMode/README.md` | generated inventory block | same |
| `typst/generated/status.typ` | generated stamp + counts | `scripts/typst-sync-check.sh --fix` |
| `Tests/BimodalTest.lean`, `Tests/BimodalTest/Automation/README.md` | generated root/import list | regenerate / union |
| `FormalSystem/Theorems/ProofMode.lean` | import list — `main` renamed `Theorems/ProofMode/Simplification.lean` to `ModalBoolean.lean` + `ModalTemporalBoolean.lean` | union, drop `Simplification`, keep `TemporalComposition` |
| `Tests/BimodalTest/Automation/ProofModeExtensionsTest.lean` | modify/delete — `main` deleted it in PR #7's family split | accept the deletion; the PR's own net change to that file across its whole life is one `import` line, and `49a7efe23` already moved its content into the new per-family test files |

**A trap worth naming in the response.** Resolving the two inventory READMEs with `--ours` (main's side) loses the PR's hand-written description cells, and the generator then re-emits them as `<!-- TODO: add description -->` because it carries descriptions forward by filename and has none to carry. I hit this and had to correct it. The right recipe is: take the PR's rows, then run `scripts/check-module-invariants.sh --emit-inventory` to recompute the line counts.

**The one real break.** After the seven conflicts are resolved the tree does **not** compile:

```
error: FormalSystem/Automation/ProofMode/Temporal.lean:343:40: Unknown identifier `Language`
   (and at 358:42, 388:44, 407:51, 467:43, 483:43)
```

PR #7 moved `Language` to `FormalSystem/Tactic/FormulaSyntax.lean:18`. Every module on `main` that uses it carries `open FormalSystem.Tactic.FormulaSyntax (Language)` (e.g. `Modal.lean:21`, `Meta.lean:26`) and qualifies its own extensions with `_root_.` (e.g. `Meta.lean:40,45`). PR #8's `Temporal.lean` does neither. The fix is two edits in one file:

```lean
namespace FormalSystem.Automation.ProofMode

open FormalSystem.Tactic.FormulaSyntax (Language)   -- added

...

def _root_.FormalSystem.Tactic.FormulaSyntax.Language.temporalViewName   -- was `def Language.temporalViewName`
    (language : Language) (view : Name) : MetaM Name := do
```

Only `Temporal.lean` is affected; `TemporalZTime.lean`, `TemporalBoolean.lean` and `Discrete.lean` contain no bare `Language`.

#### 2. Gate results on the rebased tree

Run in the worktree, through `lake-build-guard.sh`:

| Gate | Result |
|---|---|
| `lake build --wfail` | **PASS** — 3013 jobs, "Build completed successfully" |
| `lake test` | **PASS** — 3090 jobs, zero `error:` lines; the three new test modules built (`ProofModeTemporalTest`, `ProofModeTemporalZTimeTest`, `ProofModeTemporalBooleanProgressTest`) |
| `lake lint` | **PASS** — "Linting passed for FormalSystem" |
| `scripts/check-module-invariants.sh --no-build` | **PASS** — ALL CHECKS PASSED, after `--emit-inventory` |
| `scripts/typst-sync-check.sh --fix` | applied, then clean |
| `scripts/readme-lint.sh` | **FAIL** — 3 new stale dates |

The three new stale dates are `FormalSystem/Automation/ProofMode/README.md`, `FormalSystem/Theorems/ProofMode/README.md` (both PR #8's own directories) and `FormalSystem/Tactic/README.md`. The third is **not** PR #8's: that README is stamped `2026-09-21` and its directory last changed in the PR #7 merge commit `3c7197f84`, so `main` itself is red on `readme-lint.sh` today. PR #8 should bump its own two stamps; the third is ours to fix on `main`.

**CI history.** `gh run list --branch feat/proof-mode-temporal` returns exactly one run, `44476857626`, on `1f545ea0a` — three commits behind the head — and it **failed**. Build, test and lint were all SUCCESS in that run; the single failing check was `readme-lint.sh`. So the only CI evidence that exists is stale, and it failed on the same gate that is still red after the rebase.

#### 3. The carrying table

`FormalSystem/Automation/ProofMode/Temporal.lean:115-125`:

```lean
private structure CarryRule where
  past : Bool
  source : Name
  scope : Name × Name        -- (TM, TM⁺) for a strict G/H scope
  adjacent : Name × Name     -- (TM, TM⁺) for an X/Y step

private def carryRules : Array CarryRule := #[
  ⟨false, `allFuture, (futureKeep, futureKeep), (nextKeep, nextKeep)⟩,
  ⟨true,  `allPast,   (pastKeep,   pastKeep),   (prevKeep, prevKeep)⟩]
```

Lookup is at `Temporal.lean:137`: find the row whose `past` matches the direction and whose `source` operator matches the fact's outer operator.

What M1 needs, from `records/proof-mode.md:177-181` (`M1: Bimodal scope core`): `□A` and `◇A` carried intact into a `□` scope, with the TM⁺ `⊡` mirror; `□` facts crossing into `G` and `H` scopes by MF and TF in both time directions. That is a **(source, target)** relation over sources `{□, ◇, ⊡, ⟐, G, H}` and targets `{□, ⊡, G, H, X, Y}`. The present table cannot express it:

- the **target** is not a field at all — it is implicit in `past`, and the two shapes `scope`/`adjacent` are a hard-coded two-valued target;
- the **key** `(past, source)` cannot distinguish `□ → G` from `□ → □`;
- the table is `private` and lives inside the Temporal family's own tactic module, so `proof_mode_s5_aware_box_scopes` and `proof_mode_cross_modal_scopes_mf_tf` (channel B) cannot add a row without editing a channel-T file — against join 2 of `records/milestones.md`, which says the shape is fixed in A2 before A5 adds rows.

**What does *not* have to change: the value shape.** The rules M1 wants already exist on `main`: `FormalSystem/Theorems/Perpetuity/Helpers.lean:61,81` give `boxToFuture : ⊢ □φ → Gφ` and `boxToPast : ⊢ □φ → Hφ`; `Perpetuity/Principles.lean:342` gives `boxToBoxPast`; and `Theorems/ProofMode/ModalTemporalBoolean.lean` — the module join 2 names as the one both channels file into — already carries the TM⁺ mirrors. These are closed implication schemas, whereas the table stores contextual rules (`futureKeep {P} (h : Γ ⊢ P.allFuture) : Γ ⊢ P.allFuture.allFuture`). The gap closes with the `ctxMp ∘ thmIn` idiom `futureKeep` itself uses. Compile-checked (`lake env lean`, exit 0):

```lean
def boxKeepFuture  {P : Formula} (h : Γ ⊢[fc] P.box) : Γ ⊢[fc] P.allFuture :=
  ctxMp (thmIn (FormalSystem.Theorems.Perpetuity.boxToFuture P)) h
def boxKeepPast    {P : Formula} (h : Γ ⊢[fc] P.box) : Γ ⊢[fc] P.allPast :=
  ctxMp (thmIn (FormalSystem.Theorems.Perpetuity.boxToPast P)) h
def boxKeepBoxPast {P : Formula} (h : Γ ⊢[fc] P.box) : Γ ⊢[fc] P.allPast.box :=
  ctxMp (thmIn (FormalSystem.Theorems.Perpetuity.boxToBoxPast P)) h
```

So the concrete proposal is: **re-key, re-site, keep the values**.

```lean
structure CarryRule where
  source : Name              -- operator of the fact being carried
  target : Name              -- scope being entered
  rule : Name × Name         -- (TM, TM⁺) contextual rule, proof → proof
  framed : Bool              -- the rule takes a leading FrameClass.ZTime ≤ fc certificate
```

with the four present rows becoming `(allFuture, allFuture)`, `(allFuture, next, framed)`, `(allPast, allPast)`, `(allPast, prev, framed)`, and `carriedFacts` taking the target scope instead of a `past` flag.

**Where it lives.** Two options, and the user should rule between them.

- **(a) A shared non-private module**, e.g. `FormalSystem/Automation/ProofMode/Carrying.lean`, imported by `Temporal.lean`, `Discrete.lean` and later `Modal.lean`. Cheapest; M1 adds a row by editing one shared file one line at a time, which join 2 explicitly contemplates ("rows are added one at a time and neither channel restructures it alone").
- **(b) A registry, mirroring the merged view table.** `FormalSystem/Tactic/FormulaViews.lean:36-40` already does exactly this for views: a `SimplePersistentEnvExtension` plus a `register_lview` command whose elaborator type-checks the row at registration. A `register_lcarry` of the same shape lets M1 add rows from `ModalTemporalBoolean.lean` without touching any channel-T file at all. Worth noting against (b): a registry row is not seen by the kernel and `#print axioms` says nothing about it, so the registration command must do the checking — which is precisely what `register_lview`'s elaborator does.

My recommendation is (a) for this PR, because it is a key change plus a file move and nothing more, with (b) left to the views tier (A4), which will already be building the registry machinery.

**Condition of merging, or follow-up?** A condition — but only the *key and the visibility*, not the rows. Join 2 says the shape is fixed in A2, and A2 is this PR. Adding the □ rows is M1's work and must not be asked for here.

#### 4. The changed merged acceptance example

`Tests/BimodalTest/Automation/ProofModeTest.lean:128-132`. One existing example was altered:

```diff
 -- An abstract frame retains the certificate as a real proof obligation.
-example (fc : FrameClass) (hFrame : FrameClass.ZTime ≤ fc) : ⊢[fc] (A.imp A).next := by
+example (fc : FrameClass) (hFrame : True → FrameClass.ZTime ≤ fc) : ⊢[fc] (A.imp A).next := by
   lstep future using []
-  · exact hFrame
+  · exact hFrame True.intro
   · lintro hA
     lexact hA
```

Behaviour measured on both sides with `lake env lean`:

| Context | `main` (before) | PR #8 rebased (after) |
|---|---|---|
| `hFrame : FrameClass.ZTime ≤ fc` in scope | gate is a separate first goal; `exact hFrame` discharges it | **gate is gone**; the only goal is the body `⊢[fc] A.imp A`, and `exact hFrame` fails with `Type mismatch … of sort 'Prop' but is expected to have type ⊢[fc] A.imp A` |
| `hFrame : True → FrameClass.ZTime ≤ fc` | gate is a goal | gate is a goal |

So the policy change is real and user-visible: `lstep` (and `linvariant`, `linduction`, `luntil expand`/`lsince expand`) now reuse an **exact** local `FrameClass.ZTime ≤ fc` certificate and emit the gate only when none is in scope.

**Is this the policy request 7 asked for?** Yes in substance. Request 7 asked for "one helper … with one policy on local `ZTime ≤ fc` certificates and its own messages" and did not say which policy. There is now exactly one helper, `integerTimeGate` (`Temporal.lean:149`), used at four sites (`Discrete.lean:39,59,82`; `TemporalZTime.lean:55`), and the symptom request 7 named is fixed — measured:

```
luntil expand at FrameClass.Dense
  → error: integer-time reasoning requires FrameClass.ZTime ≤ FrameClass.Dense
```

(previously a rewrite-rule error). The policy is also documented, at `Discrete.lean:27-28` and `docs/user-guide/proof-mode-temporal-ztime.md:9-10`.

**But the edit to the example is the wrong fix.** The altered example passes on `main` too — I ran it — so it no longer discriminates between the old and the new behaviour, and its comment, "An abstract frame retains the certificate as a real proof obligation", now describes a certificate disguised behind `True →` rather than an abstract frame. The example has stopped pinning anything. The right fix is two examples: one with an exact certificate showing the gate is discharged, one with no certificate at all showing it is emitted.

**No other merged example changed meaning.** `git diff fc85c61b9 49a7efe23 -- Tests/` touches seven files; apart from `ProofModeTest.lean` they are the three new per-family files, `Tests/BimodalTest.lean` and `Tests/BimodalTest/Automation/README.md` (pure additions), and the one `import` line in `ProofModeExtensionsTest.lean`.

On `records/proof-mode.md:166`: M0's done-when requires "every existing example passing unchanged and no statement, proof or tactic behaviour changed". That constraint binds **M0, the layout move** — it does not bind A2, which is a rule contribution and is entitled to change tactic behaviour. So this is not a record violation; it is a test that should be rewritten rather than disabled.

#### 5. The keyword rename

Done at the keyword level. `TemporalZTime.lean:73,76,80,83` now read `&"contract"` and `&"expand"`; nothing in `FormalSystem/Automation/` uses `fold`/`unfold` as a derivation-step keyword any more (the only hits are `Automation/Normalization.lean:13,15`, an unrelated and long-standing use of the words in prose).

Residue: the Lean *identifiers* still say fold/unfold — `luntilFold`, `luntilUnfold`, `lsinceFold`, `lsinceUnfold` (syntax node names, `TemporalZTime.lean:73-83`), `binaryFold` (the elaborator), and the pure rules `untilFoldRule`, `untilUnfoldRule`, `untilFold`, `untilUnfoldCases` and their Since/TM⁺ mirrors in `Theorems/ProofMode/TemporalComposition/TemporalZTime.lean:27-75`. That is exactly the collision open decision 2 exists to remove, one layer down. Cheap to finish.

This settles open decision 2 of `records/proof-mode-architecture.md:279-285` in the direction the record already recommends, and open decision 3 of `records/milestones.md`. The record edit to draft:

- `records/proof-mode-architecture.md`: delete open decision 2 and state the ruling where the Until/Since tactics are described — fold and unfold name views only; the Until and Since derivation steps are `expand` and `contract`.
- `records/milestones.md`: strike open decision 3, and amend the A2 "What to do next" item 1, which currently says the contribution is merged "with the carrying table agreed (join 2) and the `expand` and `contract` keywords ruled (open decision 3)".

#### 6. The views

`ltemporal_dual` (`Temporal.lean:574,578`) is a third implementation of a job `main` now does twice over. It carries its own hard-coded view list — a ten-armed `match` at `Temporal.lean:365-386` whose fallthrough message spells the ten names out by hand — and its own traversal, `viewCorrespondence` (`Temporal.lean:482-508`). The PR's eighteen view equalities live in `FormalSystem/PlusLanguage/TemporalViews.lean`: nine `*_expand` theorems for `PlusFormula` (lines 70-94) and nine for `Formula` (lines 141-165).

**Which declarations become rows: all eighteen.** Verified against the merged gate rather than asserted — `register_lview` applied to each of the eighteen, exit 0, no rejection:

`release_expand`, `trigger_expand`, `weakUntil_expand`, `weakSince_expand`, `strongRelease_expand`, `strongTrigger_expand`, `before_expand`, `inclusiveUntil_expand`, `inclusiveSince_expand` — for `Formula` and for `PlusFormula` alike.

**Does `ltemporal_dual` survive as a tactic? No.** Also verified, on the PR's own merged example: with the row registered, `lunfold inclusiveUntil` and `ltemporal_dual inclusiveUntil` close the same goal identically (both compile, exit 0). The `using` form, `ltemporal_dual using rule`, is by the PR's own docstring (`Temporal.lean:38`) "`lrewrite` with a native equivalence/equality", which is what `lrewrite` already is. So the whole tactic goes: the view form to `lunfold`/`lfold`, the `using` form to `lrewrite`.

**One siting problem.** `FormalSystem/PlusLanguage/TemporalViews.lean:130-166` declares `FormalSystem.Syntax.Formula.inclusiveUntil`, `inclusiveSince` and the nine TM `*_expand` theorems — core TM syntax, in the TM⁺ directory. Join 4 of `records/milestones.md` has D1 defining the inclusive and weak Until/Since "once on the signature"; leaving TM definitions under `PlusLanguage/` makes that harder. They belong under `FormalSystem/Syntax/` or beside the view table in `FormalSystem/Tactic/`.

#### 7. The induction rule

Nothing in the PR bears on the statement proposed at `records/proof-mode.md:248`. `forwardInvariantRule` is untouched (`Theorems/ProofMode/Discrete.lean:147`, `PlusDiscrete.lean:68`), and nothing new derives anything of the form `(X(e ∨ (g ∧ C)) → C) → G(…) → (g U e → C)`.

`linduction` **is already documented as backward induction only**, in three places: the module docstring (`Discrete.lean:24-25`, "applies the discrete backward-induction schema Z1, leaving `G(G φ → φ)` and `F(G φ)`"), the syntax docstring (`Discrete.lean:111`) and the guide (`docs/user-guide/proof-mode-temporal-ztime.md:7`). It dispatches to `futureBackwardInduction`/`pastBackwardInduction`. So request 4's documentation half is met without anything further being asked; request 4 was an invitation, not a requirement, and should be repeated as one.

#### 8. Gate-one admission

Join 5 of `records/milestones.md` and `records/proof-mode.md:187-190` admit only `G`/`H` carrying and whole-judgment time reflection into gate-one scripts, each once adopted into M1 before the selection is fixed. As they now stand:

- **`keeping`** — it is not a tactic but a syntax fragment on five carriers (`ltemporal_cases`, `ladvance`, `ltemporal_intro` at `Temporal.lean:535,541,547`; `lstep`, `linvariant` at `Discrete.lean:105`). Adoption needs the carrying table re-keyed and re-sited first, because M1's done-when is stated over rows the present key cannot hold — and because M1's own records are the ones that add them. It also needs the rejection messages pinned: today `keeping`'s two refusals (undetermined formula, `Temporal.lean:135-136`; unsupported source operator, `Temporal.lean:139-142`) are reachable but only one of the three new `#guard_msgs` covers this family. Given join 2 fixes the shape in A2, this is the same condition as §3 — it does not add a separate one.
- **`ltime_reflect`** — closer to ready. The `using` form rejects a non-derivation (`Temporal.lean:446`), unresolved parameters (`:448`) and a language mismatch (`:450`); there is a TM⁺ test (`ProofModeTemporalTest.lean:39-42`) and two client re-proofs (`:106-115`). What it lacks for adoption is a message assertion on the goal-direction form and a statement, in M1, of what "whole-judgment" means when the context is empty. Neither is a merge condition.

#### 9. The remaining smaller points

| Point | State |
|---|---|
| Messages printing `allFuture` where the user wrote `G` | **Done.** No `throwError` under `Automation/ProofMode/` names a raw operator; `keeping` now says "carries only G-scoped facts" (`Temporal.lean:141`). Measured residue: the message interpolates the formula itself, so a `□` fact prints as `A.box`. There is no `□` notation for `Formula.box` in the repository, so this is the best available today — worth noting, not worth asking for. |
| `lprogress` untested | **Partly.** `ProofModeTemporalBooleanProgressTest.lean` has one example and it exercises `lprogress cases` only. Three of the four forms — `lprogress using [...]`, `lprogress consequence using`, `lprogress trans using` (`TemporalBoolean.lean:148,154,158`) — are untested, as is the past direction of all four. |
| Past and TM⁺ coverage | Past: improved. TM⁺: **unchanged at exactly one test** (`ProofModeTemporalTest.lean:39-42`), which is the same complaint as before. |
| Plan labels and "relative to the past" wording | **Done.** No `(P3)`, "legacy", "unchanged", "original" or "New …" plan labels remain in the PR's modules or guide pages. (`docs/user-guide/examples.md:364` and `architecture.md:245` carry `(P1)`/`(P6)`, but those are perpetuity-principle numbers in files this PR does not touch.) |
| `#guard_msgs` vs `fail_if_success` | Measured across the eight ProofMode acceptance files on the rebased tree: **7 `#guard_msgs` against 17 `fail_if_success`**. The PR's own three new files contribute 3 and 4. Nine of the seventeen are in PR #7's two files and are already on the PR #7 follow-up list. |
| README description cells | `FormalSystem/Theorems/ProofMode/README.md` ships `TemporalComposition.lean` with an **empty** description, which the inventory generator re-emits as `<!-- TODO: add description -->`. (The `Congruence/` and `TemporalComposition/` directory rows carry the same placeholder, but that is a standing generator limitation on directory rows, present on `main` already.) |

### External Resources

- `scripts/check-module-invariants.sh --emit-inventory` is the generator for every `<!-- BEGIN GENERATED: inventory -->` block; `scripts/readme-inventory.sh` is deprecated and says so. Descriptions are carried forward by filename (`check-module-invariants.sh:477,518`), which is why a `--ours` conflict resolution silently loses them.
- `FormalSystem/Tactic/FormulaViews.lean` (merged with PR #7) is the model for any further table: a `SimplePersistentEnvExtension` plus a checking registration command.
- `.claude/context/project/lean4/domain/metadata-trust-surfaces.md` is the reason a registration command must do its own checking: environment-extension rows are invisible to the kernel and to `#print axioms`.

### Recommendations

- **Request changes, with three conditions: rebase, the gate example, and the carrying table's key and visibility.** [No compiled gate applicable]
- **Offer to do the rebase.** It is seven mechanical conflicts plus one two-edit fix in one file, and it is already done and green in a local worktree; the contributor need only take the diff. [VERIFIED: PASS — `lake build --wfail` 3013 jobs, `lake test` 3090 jobs, `lake lint`, `check-module-invariants.sh --no-build` all pass on the rebased tree]
- **Re-key the carrying table to `(source, target)`, make it non-private, and move it to a module both families import; do not ask for the `□` rows here.** [VERIFIED: PASS — `boxKeepFuture`, `boxKeepPast`, `boxKeepBoxPast` compile via `lake env lean` in the table's existing proof-to-proof shape, so the value shape needs no change]
- **Replace the altered `ProofModeTest.lean` example with two examples — one exact certificate, one none at all.** [VERIFIED: FAIL — the altered example as written compiles on `main` too, so it no longer discriminates; revised to: ask for the pair, since `lstep future using []` under an exact certificate leaves only the body goal (measured) and under `True → …` leaves the gate (measured)]
- **Register all eighteen `*_expand` equalities as view rows and delete `ltemporal_dual`.** [VERIFIED: PASS — all 18 accepted by `register_lview` (exit 0), and `lunfold inclusiveUntil` reproduces `ltemporal_dual inclusiveUntil` on the PR's own merged example]
- **Move the TM definitions out of `FormalSystem/PlusLanguage/TemporalViews.lean`.** [No compiled gate applicable]
- **Repeat request 4 as an invitation and confirm `linduction` is documented as backward induction only — it already is.** [No compiled gate applicable]
- **Ask for the records edit (request 13) as a condition of merging only for open decisions 2 and 3; leave M4 and "Where the work sits" to us.** [No compiled gate applicable]
- **Ask for the follow-ups as follow-ups**: the fold/unfold identifier residue, `lprogress`'s three untested forms, TM⁺'s single test, `#guard_msgs` parity, the missing `TemporalComposition.lean` description, and the two README date stamps. [No compiled gate applicable]
- **Say that `FormalSystem/Tactic/README.md`'s stale date is ours, not theirs** — `main` is red on `readme-lint.sh` today because of the PR #7 merge. [VERIFIED: PASS — stamp `2026-09-21`, directory last changed in `3c7197f84`]

## Decisions

- **Reviewed the new third commit** rather than the head named in the task. Ground rule (ii) requires it, and it changes the answer to request 2 from "not done" to "done".
- **Chose `git rebase --onto origin/main fc85c61b9` as the route to recommend**, over `git merge origin/main` (19 conflicts) and over a fresh branch, because PR #7 was squash-merged and the old PR #7 commits must leave the branch.
- **Did not ask for the `□` rows in this PR.** Join 2 assigns them to M1; A2 owns only the shape.
- **Treated the altered acceptance example as a test defect, not a record violation.** M0's "every existing example passing unchanged" binds the layout move, not a rule contribution.
- **Recommended the shared-module carrying table over a registry for this PR**, with the registry left to A4, and surfaced the choice to the user rather than settling it.
- **Did not treat `A.box` in the `keeping` message as a defect**, because the repository declares no `□` notation and there is nothing better to print today.

## Risks & Mitigations

- **The head may move again before the response is posted.** It moved once already, mid-task. Mitigation: `gh pr view 8` was re-run at the end (unchanged at `49a7efe23`); re-check immediately before posting and re-read any new commit.
- **The rebase I produced is a probe, not a deliverable.** It lives on the throwaway branch `pr8-rebase-probe` in `/home/benjamin/Projects/.worktrees/BimodalLogic-pr8` and includes one extra commit of my own restoring the test imports. Mitigation: if the offer to rebase is taken up, redo it cleanly on a fresh branch rather than pushing the probe.
- **The probe worktree shares `.lake/packages` with the main checkout by symlink.** Mitigation: it was read-only in practice (the main tree's Mathlib build was reused, not rewritten), and the worktree can be removed with `git worktree remove`.
- **`readme-lint.sh` will still fail after the contributor rebases** unless both date stamps are bumped and `main`'s own `FormalSystem/Tactic/README.md` row is fixed. Mitigation: say so explicitly in the response so the red CI is not read as the contributor's fault.
- **Asking for the views move could be read as a condition.** It is not: the view table only merged with PR #7, and the work is a row registration plus a deletion. Mitigation: the draft files it under follow-ups and says why.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The task is a code review of a tactic contribution, not a proof-search problem; no goal in this task needed closing by tactic. The compiled probes run here (`register_lview` acceptance, `lunfold` equivalence, the carrying-row shape check, `lstep` gate behaviour, the `Dense` message, `#print axioms`) are recorded under Findings rather than as a tactic survey.

## Context Extension Recommendations

- **Topic**: Reviewing a stacked pull request after its parent has been squash-merged.
- **Gap**: Nothing in `context/project/lean4/` records that a squash merge severs a stacked branch's ancestry, so `git merge main` presents the whole parent PR as conflicts while `git rebase --onto main <old-parent-head>` does not. This review cost two probes to establish and is a repeatable situation with three stacked PRs in flight.
- **Recommendation**: add a short section to `context/project/lean4/patterns/` (or a new `pr-review-stacked-branches.md`) giving the two routes, the ancestry check (`git merge-base --is-ancestor`), and the generated-file conflict recipe — in particular that `--ours` on an inventory README silently drops hand-written description cells because the generator carries them forward by filename.

## Appendix

**Commands run (selection)**

```
gh pr view 8 --json headRefOid,commits,mergeable,state
gh run list --branch feat/proof-mode-temporal ; gh run view 44476857626 --log-failed
git fetch origin refs/pull/8/head:pr8-head
git worktree add --detach .worktrees/BimodalLogic-pr8 49a7efe23
git merge --no-commit --no-ff origin/main                     # 19 conflicts
git rebase --onto origin/main fc85c61b9                       # 7 conflicts
lake-build-guard.sh build --timeout 1800 -- build --wfail     # 3013 jobs, exit 0
lake-build-guard.sh build --timeout 1800 -- test              # 3090 jobs, exit 0
lake-build-guard.sh build --timeout 1800 -- lint              # exit 0
scripts/check-module-invariants.sh --emit-inventory ; --no-build
scripts/typst-sync-check.sh --fix ; scripts/readme-lint.sh
lake env lean <probe>.lean                                    # six compiled probes
```

**Compiled probes, by what each established**

| Probe | Established |
|---|---|
| `ProbeGate.lean` on `main` | before: exact certificate still leaves the gate as a goal |
| `ProbeGate2.lean` on `main` | the altered example passes on `main` too |
| `ProbeAfter.lean` / `ProbeAfter2.lean` | after: exact certificate discharges the gate; `True → …` does not; `keeping` prints `A.box` |
| `ProbeDense.lean` | `luntil expand` at `Dense` reports the integer-time message |
| `ProbeAxioms.lean` | thirteen new rules depend only on `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx` |
| `ProbeViewRows.lean` | all eighteen `*_expand` equalities accepted by `register_lview` |
| `ProbeUnfold.lean` | `lunfold inclusiveUntil` ≡ `ltemporal_dual inclusiveUntil` |
| `ProbeCarryRows.lean` | three candidate M1 rows typecheck in the table's existing shape |

**Records read**: `records/milestones.md` (joins 2, 4, 5; open decisions 3, 4; goal A table), `records/proof-mode.md` (M0:159-172, M1:174-190, M4:222-259, Lanes:704-730), `records/proof-mode-architecture.md` (open decisions:273-285), `records/theorem-library.md` (skimmed for the M1 cross-reference).

**Reviews read**: `specs/reviews/pr-reviews-2026-11-20/pr8-review.md` (the thirteen requests), `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` and `pr7-approval.md` (the merged state and the follow-up list PR #8 inherits).

---

## Disposition (2026-11-23, implement round, dispatch 12)

This section is additive. Nothing above it is deleted or reworded; where a finding above is
superseded, that is stated here rather than by editing the original.

### The head moved, and the move is large

| Field | Research round (2026-11-22) | This dispatch (2026-11-23) |
|---|---|---|
| `headRefOid` | `49a7efe231cf98a488ad107dd981881557b1fd96` | `5ecc91d63b3a3cdcae1028417d67c3e89907bdad` |
| `state` | `OPEN` | `OPEN` |
| `mergeable` | `CONFLICTING` | `MERGEABLE` |
| `updatedAt` | `2026-11-22T18:44:10Z` | `2026-11-23T04:29:47Z` |

Verbatim: `gh pr view 8 --json headRefOid,state,mergeable,updatedAt` returns

```
{"headRefOid":"5ecc91d63b3a3cdcae1028417d67c3e89907bdad","mergeable":"MERGEABLE","state":"OPEN","updatedAt":"2026-11-23T04:29:47Z"}
```

`5ecc91d63` is a merge commit (`Merge: 49a7efe23 171021f4b`) titled "Refresh temporal proof mode
and register views in the shared tier". Its second parent is `171021f4b`, which is `origin/main`
exactly: `git merge-base origin/main 5ecc91d63` returns `171021f4b`. **The contributor has done
the rebase themselves**, by merging `main` rather than rebasing, and `main` now contains PR #7 as
the squash `3c7197f84`.

Commits unique to the PR (`git log --oneline origin/main..5ecc91d63`): `5ecc91d63`, `49a7efe23`,
`b020320fd`, `dc253dde5`, `1f545ea0a`, `fc85c61b9`, `9695749ca` — seven, of which the first five
are #8's own layer and the last two are #7's now-superseded ancestry carried along by the merge.

### What that supersedes in this report and in the draft

| Claim in the research round | Status now |
|---|---|
| "the branch sits on `fc85c61b9`, the old #7 head; `mergeable: CONFLICTING`" | **superseded** — merged, `MERGEABLE` |
| the rebase recipe `git rebase --onto origin/main fc85c61b9`, seven conflicts, six generated surfaces plus `Theorems/ProofMode.lean` | **moot as an ask** — retained only as the record of what the contributor's merge had to resolve |
| the `Unknown identifier Language` source break in `Automation/ProofMode/Temporal.lean` needing two edits | **resolved by the contributor** — `lake build --wfail` is green on `5ecc91d63` with no local edit |
| "the only CI run is on `1f545ea0a`, three commits behind, and it failed" | **superseded** — run `45112191590` ran on `5ecc91d63` itself and **passed** |
| "I registered all eighteen of your `*_expand` equalities ... with `register_lview`" | **landed by the contributor, and larger**: `FormalSystem/Tactic/TemporalFormulaViews.lean` registers **twenty** rows (ten `Formula`, ten `PlusFormula`), the extra pair being `after`, carried by two `private … := rfl` theorems |
| "`ltemporal_dual` is a third implementation ... the eighteen become rows and the tactic goes away entirely" | **done** — `git grep ltemporal_dual 5ecc91d63` over `FormalSystem`, `Tests` and `docs` returns nothing; `ProofModeTemporalTest.lean:47-50` now uses `lunfold inclusiveUntil` / `lfold inclusiveUntil` |
| "the records ask (condition 4)" | **partly pre-empted** — the contributor edited `records/proof-mode-architecture.md` and `records/proof-mode.md` in the PR itself |
| "`readme-lint.sh` is still red, with three stale date stamps. Two are yours ... the third is mine" | **superseded by measurement** — all three new rows are present on `origin/main` **and** on the PR head, identically; the PR adds none |

### What this dispatch ran, on `5ecc91d63`, in the probe worktree

Worktree `/home/benjamin/Projects/.worktrees/BimodalLogic-pr8`, branch `pr8-head-check` at
`5ecc91d63`, every `lake` call routed through `.claude/scripts/lake-build-guard.sh`:

| Gate | Result |
|---|---|
| `lake build --wfail` | **green**, 3014 jobs, exit 0 |
| `lake test` | **green**, 3091 jobs, exit 0 |
| `lake lint` | **green**, "Linting passed for FormalSystem", exit 0 |
| `scripts/check-module-invariants.sh --no-build` | **ALL CHECKS PASSED** |
| `scripts/readme-lint.sh` | **FAIL (3 new stale dates)** — see below |
| `#print axioms` on 18 contributed rules | only `propext`, `Classical.choice`, `Quot.sound`; no `sorryAx` |

The eighteen rules checked: `untilIntro`, `sinceIntro`, `untilUnfoldRule`, `sinceUnfoldRule`,
`untilFoldRule`, `sinceFoldRule`, `untilUnfoldCases`, `sinceUnfoldCases`, `futureKeep`,
`pastKeep`, `nextKeep`, `prevKeep`, `reflectGoal`, `reflectContext`, `progressCases`,
`pastProgressCases`, `leadsToTrans`, `gWeaken`. `untilIntro`, `sinceIntro`, `futureKeep`,
`pastKeep` and `gWeaken` need only `propext`; the rest take all three.

### `readme-lint.sh` is a standing baseline, not a PR regression — and CI cannot see it

Run on both trees and diffed against `scripts/readme-date-baseline.txt`, the set of rows counted
NEW is **byte-identical** on `origin/main` and on `5ecc91d63`:

```
stale FormalSystem/Automation/ProofMode/README.md 2026-11-19
stale FormalSystem/Tactic/README.md               2026-09-21
stale FormalSystem/Theorems/ProofMode/README.md   2026-11-19
```

So `main` is red on this gate today, the PR introduces nothing, and the research round's
attribution ("two are yours, one is mine") is wrong as stated. The ask that survives is a
courtesy, not a condition: #8 touches both ProofMode directories, so bumping those two stamps
clears two of the three for whoever lands next.

Separately, and worth recording on its own account: **CI never sees this gate fail.** Run
`45112191590`'s `Check README health` step reports
`Stale dates (info): (skipped: shallow clone, no history to date directories against)` and then
`RESULT: PASS`. `readme-lint.sh` disables Check 4's stale arm under `SHALLOW_CLONE=1`
(`scripts/readme-lint.sh:336`), and `actions/checkout` is shallow by default. A green CI
readme-lint is therefore no evidence at all about stale dates; only a full-history local run is.

### Probe worktree disposition

- Path: `/home/benjamin/Projects/.worktrees/BimodalLogic-pr8`
- Branch now checked out: `pr8-head-check` at `5ecc91d63` (the contributor's own head) — this is
  the tree the gate table above was measured in.
- Branch `pr8-rebase-probe` is retained at `4e732c51c`, whose tip commit parks the generated-surface
  and `open … (Language)` fixes the research round's own `git rebase --onto origin/main fc85c61b9`
  needed. **That branch is now evidence only.** The rebase it demonstrates is no longer the ask,
  because the contributor merged `main` instead and the result is green.
- Neither branch was pushed, and neither is to be pushed. If anything from the probe is ever
  wanted it is redone on a fresh branch from the live head.
- The worktree is deliberately **not removed**: it holds a warm `.lake` for the PR head, which is
  what makes a re-check of a moved head cheap.

### Ground rule (ii) re-check log

- `gh pr view 8` at the start of this dispatch: `5ecc91d63` (the move recorded above).
- `gh pr view 8` at the close of this dispatch: recorded in the summary.
