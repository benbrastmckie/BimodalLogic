# PATH — the execution outline

**Generated** 2026-08-24 from `specs/reviews/review-2026-08-24.md`.
**Last updated** 2026-08-24, after the seven-task batch — **469, 426, 451, 473, 421, 423, 424** —
closed. Steps 1–3 of the previous edition are now history; the decidability route is **decided**.
**Companion files**: `specs/TODO.md` (generated waves), `specs/state.json` (machine truth),
`specs/ROADMAP.md` (to be rewritten by task 468 — **do not trust it until then**).

This is a reading order, not a contract. The dependency graph in `state.json` enforces the same
ordering; if the two ever disagree, `state.json` wins and this file is stale.

---

## Where things stand

Machine baseline re-run 2026-08-24 on the current tree, full `scripts/check-module-invariants.sh`:
**all of C1–C11 pass** (C11 is new — 451 shipped it enforced). Both `lake build` and
`lake build BimodalTest` exit 0, 2462 jobs. **451 live `.lean` files** (397 `FormalSystem/` / 53
`Tests/`), 414 reachable, 37 unreachable-and-manifested; 156 archived files excluded.

Exactly **one** live structural sorry in the whole tree: `countermodel_discrete`
(`WeakCanonical/Transfer.lean:1102`), confirmed by C3. Of the four flagship theorems, three are
axiom-clean at `[propext, Classical.choice, Quot.sound]`; `BXCanonical.completeness` still carries
`sorryAx`, and that taint **is** the one sorry.

Four things that matter more than that number:

- **The route is decided, and it is not the tableau chain.** 469 reported: the rebuilt
  non-permissive filtration lands in `IntPresentation` **directly**. There is no bridge theorem to
  prove, no transfer lemma, no enumeration over `Atom`. The whole decidability assembly is already
  compiled except one obligation. See Step A.
- **The completeness front's next move is unblocked.** 421 completed, so **422** — the discrete-case
  chronicle, the one genuinely open piece of mathematics on this front — is now dependency-eligible
  for the first time. `422 → 169` removes the repository's last sorry.
- **A landed asset is invisible to `lake build`.** `Decidability/BiLasso/` is 19 files, sorry-free,
  oleans built, and **unreachable from the Lake target roots**. It has already been omitted from one
  proof-state audit and is mentioned in `specs/ROADMAP.md` **zero** times. 474 fixes this in hours.
- **The tableau chain is now the superseded alternative.** `462 → 463 → 464 → 465 → 428 → 429 → 410
  → 411 → 430 → 412`, with `433`/`434` in flight, was priced at several person-years containing at
  least three multi-month research problems. 469's verdict means nobody has to pay that. **468
  adjudicates whether it is abandoned or parked** — until then, do not dispatch into it.

---

## What the last batch actually settled

Each row is a fact now recorded in the tree, not a plan.

| Task | Verdict |
|---|---|
| **469** | **Route decision: the bridge is eliminated.** Capture, not discovery — 283 added lines across 10 files, **zero deletions**, zero proofs/statements/signatures/imports changed. Findings moved into the docstrings of the symbols they are about (`Validity.lean`, `IntNormalForm.lean`, `DurationClassification.lean`, `PeriodicExtension.lean`, `FMP/FiniteModel.lean`, `FMP/FMP.lean`, `IntPresentation.lean`, `BiLasso/Check.lean`, both READMEs). Spawned **474/475/476**. |
| **426** | **Hypothesis (a) — budget, and already satisfied.** `(G p) → □(G p)` saturates; measured fuel ceiling **25**, bracketed both sides (largest `none` = 24, smallest `hasOpen` = 25); `decide = .invalid` with a countermodel. Nothing needed to change and nothing did. Hypothesis (b) is real but on a **different formula**: `F(G p)` is stationary at 21 formulas from fuel 25 to 4096 — **no fuel figure rescues it**. New probe rows G and H pin the constructor tuple so this family cannot be misread again. |
| **451** | One archive tree at `FormalSystem/Boneyard/`, entirely by `git mv` (all `R100`). 0 unwaived dangling imports across 497 archived import lines; 18 lines waived with reasons. **C11 shipped enforced, no opt-out.** Counts single-sourced (156 files / 88,275 lines / 35 subdirs / 1 archive); 10 new READMEs. |
| **473** | The vacuous pair deleted after re-verifying zero consumers by symbol. `Prop42Vacuity`/`Prop42Contentful` kept as the record; prose swept across five consumer files. |
| **421** | Route (i) — Base-MCS → Discrete-MCS transfer — **refuted in place**, with the `ℤ ×ₗ ℤ` witness written into `countermodel_discrete`'s body so it cannot be re-attempted. New `DiscreteCarrierProbe.lean`: eight `example`s at `D := ℚ ×ₗ ℤ` including `bundleFlow_completeness_from_neg_membership` end-to-end. The sorry is byte-identical to its pre-task state. |
| **423** | `FormalSystem/Metalogic/SetConsequence.lean` — 19 declarations, zero sorries: `SetDerivable`, four per-class `SetSemanticConsequence*`, ten lemmas, four vocabulary definitions. `StrongCompleteness.lean` insertions only. |
| **424** | **GATE PASSED.** Both directions of the shift-set representation theorem landed sorry-free and registered. The `sep` field (the paper's *Limit* axiom) is **first-order** and hence ultraproduct-preserved, so the cancel condition is not met and **Route B — semantic compactness via a bespoke ultraproduct — stands**. Per its own Non-Goals it did not spawn S2–S5; a PASSED verdict only authorizes them. |

**413 was in the recommended batch and never ran.** No `specs/413_*` directory exists, `events.jsonl`
carries zero entries for it, and its status is still `not_started`. There is no record of an
exclusion either — it simply has no trace. It is carried forward into the next batch below.

---

## Two metadata defects found while composing this edition

**(1) 472's `file_scope` named a file that does not exist — corrected here.** It declared
`FormalSystem/Metalogic/Decidability/Decidability.lean`. That path is absent from the tree; the real
file is `FormalSystem/Metalogic/Decidability.lean`, and its `## Status` block (lines 111–115, the
subject of 472 item (a)) is exactly what 472 means to rewrite. Corrected in place via
`state-write.sh`.

**This was load-bearing, not cosmetic.** `FormalSystem/Metalogic/Decidability.lean` is also 474's
first `file_scope` entry — 474 adds one import to it. So **472 and 474 genuinely collide**, and the
collision was **invisible to the admission gate** while the path was wrong: the overlap predicate
matches on exact path or directory-prefix, and a nonexistent path matches nothing. Both tasks would
have been admitted to the same wave and edited the same file concurrently, with no lock, because
locks are derived from `file_scope`. After the correction the gate sees it and reports
`in-batch file_scope collision with #472 at "FormalSystem/Metalogic/Decidability.lean" — deferred to
a later wave, not excluded`, which is the correct behavior.

**(2) 413 has no `file_scope` field at all**, and no `priority`. Not `null` — **absent**. The
pre-dispatch review's Class B scan looks for a *literal null* on `dependencies`/`file_scope`/
`title`/`topic`, so an absent field is invisible to it. Consequence: 413 declares no territory and
takes no lock. It is greenfield (a new BL base-language `Formula` type, its TM axiom set and
derivation trees, and a translation into `BL+`), so nothing in the proposed batch writes where it
would write — the practical risk this round is low. It should still be given a scope before it runs
a second time.

---

## Step A — decidability, on the chosen route  *(this is the front that moved)*

469's verdict reduced decidability of `ValidDiscrete` to **one** obligation. Everything else in the
assembly is already compiled and axiom-clean: three probes in
`specs/469_.../evidence/` measure `#print axioms = [propext, Classical.choice, Quot.sound]` and are
drop-in.

| Task | Class | Achieves |
|---|---|---|
| **474** | **Routine engineering, hours** | Wire the BiLasso layer into the live tree: one import into `Decidability.lean`, **delete exactly 15 manifest lines in the same commit** (C6 fails otherwise), keep the 4 `Extend`/`Successor`/`Orbit`/`Agreement` lines and the separate `PeriodicExtension` block. Then land the three compiled probes as live theorems. **Re-measure the 15/4/1 split before editing.** Ungated on purpose — do not hold this behind any research result. |
| **475** | **Routine engineering + one genuine lemma; days to two weeks** | Carrier normalization. Prove the successor-based analogue of `archimedean_of_lub` — the tree has no such lemma — supplying `Archimedean D` (which does **not** synthesize from `IsSuccArchimedean` + `IsPredArchimedean`) and an `IsLeast` positive witness, then transport `TaskFrame`/`TaskModel`/`WorldHistory`/`TruthAt` along `D ≃+o ℤ`. Only the **completeness** direction needs this; soundness instantiates at ℤ for free and is already compiled in 5 lines. **The recorded wrong turn**: `orderIsoIntOfLinearSuccPredArch` fits the binder bundle verbatim and is wrong — it yields an order-only isomorphism, and durations add. |
| **476** | **OPEN MATHEMATICS, multi-month** | The box-faithful small-model theorem — `cands : Formula → List IntPresentation` with `¬ValidDiscrete φ → ∃ P ∈ cands φ, ∃ w, SatAtState P w φ.neg`. The single remaining obligation. Gated on 475 by dependency, and gated **before that** on a literature check (GKWZ, *Many-Dimensional Modal Logics*, 2003, temporal-products chapter) that is **empowered to refute the task outright**. It carries an explicit prohibition against being re-described as engineering or merged into 474/475. |

**The tableau chain awaits adjudication, not dispatch.** 462 is dependency-eligible today (its deps
469 and 470 are both satisfied) and 434 is eligible and in flight at `partial`. Both are held: they
are 10–15 h and up of termination work on the route 469's verdict has superseded. **468 issues the
verdict on whether that chain is abandoned or parked.** Two findings there stay on the record so
nobody re-derives them:

- **429 is a redesign, not a repair.** Task 418 measured it: the *entire* decidable-branch-gate
  family collapses to `false` on any minted world. Repair option (c) is closed; option (a) carries
  an S5 axiom-4/5 obligation.
- **A fifth termination residual exists** — `UnorderedSuccessorLabelClosed`, carried live and
  refuted in-tree — and still **no task owns it**. 468 assigns it. 470 declined to create a
  duplicate owner; that decision stands.

---

## Step B — the completeness front  *(now open at its head)*

| Task | Achieves |
|---|---|
| **422** | **The one genuinely open piece of mathematics here**, and newly eligible. The discrete-case chronicle over `ℚ ×ₗ ℤ` — the carrier 421 just probed end-to-end. Its own description names the risk: it is *not* verified that the chronicle's block order can be densified without breaking MCS-chain coherence. If it fails, it escalates as `[BLOCKED]` with the failing obligation named — **do not paper over it**. |
| **169** | Consumes 422 to close `countermodel_discrete`. **This is the milestone**: it removes the repository's last sorry and makes all four flagship theorems axiom-clean. |
| **95** | The confirmation pass — re-run `#print axioms`, record, close. Needs only 169. |
| **425** | The discrete non-compactness negative results. Cheap, eligible now that 423 landed, and a negative result closes a front legitimately. |
| **362** | The consequence-completeness capstone, under the settled terminology. |

Strong completeness for **Base** and **Dense** remains an open research question — the missing piece
is a model-existence theorem, not `SetDerivable`, which 423 has now landed. For **Discrete** and
**Dedekind** it is **refuted** (non-compact) and correctly never attempted.

424's PASSED gate authorizes S2–S5 of the compactness route but does not schedule them; nothing was
spawned, by design.

---

## Step C — clear the misleading

| Task | Achieves |
|---|---|
| **472** | The nine verified false-or-stale documentation claims. Ungated on purpose — every one misleads a reader today. |

Re-verified 2026-08-24 while composing this file:

- **(a) still stands** — `Decidability.lean`'s `## Status` block still reads `Soundness: Proven /
  Completeness: Proven`, which is about the Hilbert-system results, not the tableau.
- **(c) still stands** — `FMP/README.md` still lists `filtration_is_finite` and
  `truth_preserved_under_filtration` as Key Results; neither exists as a declaration anywhere in
  `FormalSystem/`.
- **(i) still stands** — `PriorExpressivenessDense.lean` still says "carries this module's **only**
  `sorry`" at line 90 while lines 65 and 183 say sorry-free.
- **(f) appears already fixed** — `WeakCanonical.lean` now says `countermodel_discrete` "carries the
  repository's sole live `sorry`". Confirm before editing; the task's own instruction is to
  re-verify by symbol and not trust the prose in place.
- **469 amended two files 472 also owns** (`FMP/README.md` +28, `FMP/FMP.lean` +24). **Re-measure
  items (b) and (c) against the current text**, not against the description.

---

## Step D — realign the programme  *(468 is now eligible)*

| Task | Achieves |
|---|---|
| **468** | Rewrites `specs/ROADMAP.md` around the PROVEN vs SORRY-FREE distinction; issues a verdict on every active task; assigns `UnorderedSuccessorLabelClosed`; adjudicates 455. Its three dependencies — 469, 426, 451 — are **all satisfied as of this batch**. |
| **455** | Adjudicated by 468 — the review recommends **ABSORB**. Expect a proposal to abandon. |

**468 should follow 474, not accompany it.** They collide at `specs/ROADMAP.md`, and the collision is
substantive rather than incidental: 474 adds the first ROADMAP mention BiLasso has ever had, and 468
rewrites the file wholesale. A roadmap written before the wiring lands would describe a tree in which
the decision layer is still unreachable. 468 also reads better after 472 has corrected the in-file
documentation it will be summarizing.

---

## Side track — the dataset cluster

Independent of everything above.

| Task | Achieves |
|---|---|
| **298** | **Do first**, and it is `partial` and eligible. `data/bmlogic-c7.jsonl` holds 13,749 records while its metadata advertises 77,272 — a live integrity defect, invisible to git (`data/` is gitignored). It alone gates **231, 282, and 296**. |
| **296**, **282** | The derived-operator re-add and the exhaustive-enumeration work. Both wait on 298. |
| **231** | The sync automation. **Must follow 298**, or it automates propagation of the truncated dataset. Its item (7) was permanently dropped — see the cross-repository section. |
| **257** | Blocked on *you*: an HF account, org, and write token. Not an engineering task. |

---

## Decisions that are yours, not an agent's

| | |
|---|---|
| **The tableau chain** | **New this round.** 469's verdict supersedes it. 462/463/464/465/428/429/430/410/411/412/433/434 — abandon, or park explicitly? 468 will propose; the call is yours. Nothing there should be dispatched in the meantime. |
| **219** | Recommended **abandon**. `data/baselines/` does not exist; needs paid runs against now-stale models; no relation to the formalization programme. |
| **127**, **128** | Recommended **abandon or park explicitly**. Both extend the object language, which would multiply the 34-constructor rule set and invalidate the `MintBound.lean` termination work. Good ideas, actively antagonistic to this programme. Both are dependency-eligible and will keep surfacing until dispositioned. |
| **455** | Expect 468 to propose abandonment. |
| **125** | Keep, but off the critical path — a second research programme. Correctly depends on 461. |
| **461** | Blocked on acquiring a source absent from both the Literature corpus and Zotero. |
| **432**, **436** | Marked `completed` over work the audit found still open. 468 proposes corrections; the status call is yours. |

---

## Reading the graph yourself

```bash
scripts/check-module-invariants.sh                    # the machine baseline, C1–C11
sed -n '/Dependency Waves/,/^$/p' specs/TODO.md       # current waves
.claude/scripts/orchestrate-dry-run-report.sh 474 475 472 422 425 413 298   # admission, read-only
jq -r '.active_projects[] | "\(.project_number) \(.status) deps=\((.dependencies//[])|join(","))"' \
  specs/state.json | sort -n
```

Dependency targets that resolve in **neither** `state.json` nor `archive/state.json` are the only
real dangling edges. **Any lint must union both files, and must read the archive's own keys** —
`specs/archive/state.json` has `archived_projects` and `completed_projects`, **not**
`active_projects`. A union scan that assumes the live file's shape silently returns an empty archive
and reports every archived predecessor as missing.

---

## Cross-repository hazard: tasks whose work lands outside this repo

Verified 2026-08-24, unchanged this round. `.claude/` here is **gitignored** (`.gitignore:81`, zero
tracked files) and is regenerated wholesale on an agent-system reload. `agent-system/` **does not
exist** in this repository — the source store is `/home/benjamin/.config/nvim/agent-system/`, a
separate git repo with its own task tracker. **Anything written to `.claude/` here is destroyed on
the next reload.**

| Task | Status | Disposition |
|---|---|---|
| **466** | **ABANDONED here; handoff CLOSED** | The `update-plan-status.sh` defects are now owned by **nvim task 91**, which that repo had already filed independently; the `/meta` dispatch corrected it in place rather than filing a duplicate. Nothing further is pending here. Full original description retained in `specs/archive/state.json`. |
| **471** | **ABANDONED — the finding was WRONG** | The claimed `roadmap-integration.sh` stdout defect does not exist: the comment goes to stderr (`:319`, `>&2`). The reviewer caused the parse error by invoking with `2>&1`. Retracted. |
| **231** item (7) | **DROPPED from scope** | Cannot be completed from this repo; the user chose permanent removal with no successor owner. Items (1)–(6) and (8) are unaffected `data/` work and the task stays here. If the hook is wanted later, wire `sync-all.py` from CI — it already has CI-friendly exit codes. |

**466's defect is real, but one half of what was originally recorded here was WRONG.** The retracted
claim: that a bracket-less Status line falls through to `|| echo ""`, leaving both variables empty and
compare-equal, so a no-op reads as success. **That path does not exist** — `grep -m1` matches a
bracket-less line, so `|| echo ""` never fires. Verified by executing the script against fixtures for
all three malformed shapes: every one exits rc=1. No input produces a false success. Also retracted:
postflight does not diverge silently (`update-task-status.sh:515` branches on rc and `exit 3`s
loudly).

What survives, all confirmed by execution: (1) **diagnostic opacity** — all three malformed shapes
emit a byte-identical `Failed to update status in <file>`, naming no line, content, or reason; (2) the
**`$`-anchor at line 69** means a plan carrying `[IMPLEMENTING] (resumed; …)` can NEVER be stamped,
which is what hard-failed `/orchestrate` postflight; (3) preflight's non-fatal warning masks the
leading indicator of the fatal postflight exit; (4) the idempotency early-exit at lines 62–66 returns
rc=0 with EMPTY stdout while the header promises "path on success, empty on failure/no-op".

**Not at risk**: 472, 474, 475, 476, 422, 425, 413 (`FormalSystem/` and `scripts/` only — note 474
edits `scripts/module-invariants-manifest.txt`, which is **tracked**, not the `.claude/` deploy tree);
468 (writes `specs/ROADMAP.md`, tracked).

---

## The next batch — what to orchestrate now

Computed 2026-08-24 against live `state.json` and **verified with
`orchestrate-dry-run-report.sh`**: all seven admit, **zero exclusions**, wave 0.

```
/orchestrate 474,475,472,422,425,413,298
```

| Task | Why it is in this batch |
|---|---|
| **474** | Hours of routine engineering that makes a 19-file, sorry-free, already-built layer visible to `lake build`. It has already been omitted from one audit; wiring it removes the recurrence of exactly that failure mode. Highest value-per-hour on the board. |
| **475** | The carrier lemma plus transport. `priority=high`, days to two weeks, and it is the sole dependency gating 476 — the only remaining obligation for decidability of `ValidDiscrete`. |
| **472** | Nine documentation claims that mislead a reader today. `priority=high`. It was held last round for a collision with 469, which has now completed. **It will defer one wave behind 474** — see below. |
| **422** | Newly eligible, and the head of the path to the repository's last sorry. Open mathematics; if it fails it must escalate `[BLOCKED]` with the obligation named. |
| **425** | Newly eligible (423 landed). Cheap; a negative result that closes a front legitimately. |
| **413** | Greenfield, proof-theoretic, independent of everything. It was recommended last round and left no trace — carried forward. |
| **298** | `partial`, eligible, and the sole gate on three other tasks (231, 282, 296). A live data-integrity defect that git cannot see. |

**One in-batch collision, and it is handled.** 472 and 474 both declare
`FormalSystem/Metalogic/Decidability.lean`. The gate reports it as a **deferred wave, not an
exclusion** — 472 runs after 474 releases. This costs wall time, not correctness. It is only visible
at all because 472's `file_scope` typo was corrected first (see "Two metadata defects" above); **do
not revert that correction**.

**Why seven and not eight.** Thirteen tasks are dependency-eligible; `MAX_TASKS` is 8. Every
remaining eligible task is excluded for a stated reason, not for lack of room:

| Task | Why not this batch |
|---|---|
| **468** | Collides with **474** at `specs/ROADMAP.md`, and the ordering is substantive: the roadmap should be rewritten against a tree where BiLasso is reachable and 472's corrections have landed. **Run it in the very next batch** — it is `priority=high` and its dependencies are now all satisfied. |
| **193** | Collides with **472** (`Soundness.lean`) *and* **298** (`FormalSystem/Automation/`), both of which are in this batch. Still the one genuinely awkward task to schedule. |
| **462**, **434** | Both eligible; both held. They are the tableau route that 469's verdict superseded, and they collide with each other at `MintBound.lean`. Finishing in-flight work is legitimate — but not before 468 rules on whether the route survives at all. |
| **127**, **128** | Recommended for abandonment. Your call, not an agent's. They will keep appearing as eligible until dispositioned. |
| **476** | Correctly gated on 475, and behind that on a literature check empowered to refute it. |
| **257**, **461**, **428** | `blocked` status — multi-task dispatch skips them. 257 and 461 wait on external inputs; 428 waits on the chain above. |

**Suggested batch after this one**: `/orchestrate 468,193` once 472 and 474 have released their
files — 468 to issue the programme verdict and disposition the tableau chain, 193 to apply the
validity-intro and truth-simp macros. Then whatever 468 says.

### One caveat when you read the pre-dispatch review

The Class A review scans **`active_projects` only**, so it reports the edges of 422 (→ 414, 420, 439,
448), 425 (→ 361), 413 (→ 439) and 298 (→ 297, 343) as `nonexistent`. **They are not.** All seven
targets resolve as `completed` in `specs/archive/state.json`, checked directly this round. This is
the archive-only false positive this file warns about under "Reading the graph yourself" — the
full-graph union scan finds **zero** genuinely dangling edges. **Do not "repair" them.**

You will also see six **idle overlap advisories** naming out-of-batch tasks **95** (at
`FormalSystem/Metalogic/`) and **177** (at `FormalSystem/`). Both declare directory-level scopes so
coarse that they overlap nearly everything; neither is running; neither blocks. Ignore them, or give
95 and 177 narrower scopes if you want them to stop.
