# PATH — the execution outline

**Generated** 2026-08-24 from `specs/reviews/review-2026-08-24.md`.
**Companion files**: `specs/TODO.md` (generated waves), `specs/state.json` (machine truth),
`specs/ROADMAP.md` (to be rewritten by task 468 — **do not trust it until then**).

This is a reading order, not a contract. The dependency graph in `state.json` enforces the same
ordering; if the two ever disagree, `state.json` wins and this file is stale.

---

## Where things stand

Machine baseline at `874f694a1`, full `scripts/check-module-invariants.sh` run: **all of C1–C10
pass**. Both `lake build` and `lake build BimodalTest` exit 0. Exactly **one** live structural
sorry in the whole tree: `countermodel_discrete` (`WeakCanonical/Transfer.lean`).

Three things that matter more than that number:

- **Sorry-free is not the same as proven.** `Decidability/` has zero sorries and zero axioms, and
  decidability of TM is nonetheless open: theorems never stated, conditional theorems whose
  hypotheses no caller can supply, and one subtree that does not exist on disk.
- **The completeness front is unblocked.** `421 → 422 → 169` runs today and terminates at that one
  sorry. It is independent of decidability.
- **The decidability route is not yet chosen.** Task 469 chooses it. Do not sink further cost into
  the tableau chain before it reports.

---

## Step 1 — repair the tracker  *(run alone)*

| Task | Achieves |
|---|---|
| **470** | Nine mechanical defects: the wrong sorry-count in 421's acceptance criterion, mis-wired dependency edges, undeclared topic, two null descriptions, 177's unresolvable `file_scope`, and the `state.json` counter rot (`29` vs `44` vs `46` actual). |

**Why alone**: items (H) and (I) run `/task --sync` and `/todo`, which rewrite the tracker
wholesale. Anything running concurrently is racing a full-file rewrite with its own status
transitions.

**Note**: items (B), (C) and (D) are already applied — the description says so. **Item (A), the
task-421 acceptance-criterion fix, is not**, and it is the reason this step gates the completeness
front. Left unfixed, 421 fails its own acceptance test against a correct tree.

```
/implement 470
```

---

## Step 2 — clear the misleading and the dead  *(parallel; territories verified disjoint)*

| Task | Achieves |
|---|---|
| **472** | The nine verified false-or-stale documentation claims — `Decidability.lean`'s Status block reading as tableau soundness, `Verified/README.md` marking eight existing files "planned", `FMP/README.md`'s two phantom Key Results, and six more. Ungated on purpose. |
| **473** | Deletes the vacuous `neg_2var_vec_ea` / `reflatten_neg_step` pair (one consumer, which itself has none), keeps `Prop42Vacuity`/`Prop42Contentful` as the record, sweeps ~12 rotted prose anchors. |
No shared `file_scope` entry between them. Both compile Lean; if builds are slow, run 473 first
(7 files) then 472 — likely faster than contending for the build.

```
/implement 472,473
```

**Two tasks left this batch.** 466 (`update-plan-status.sh` silent no-op) and 471
(`roadmap-integration.sh` stdout contract) were **abandoned here and handed to the nvim repo** —
see the cross-repository section below. They no longer block anything in this repo.

---

## Step 3 — decide the route, and start the substance  *(parallel)*

**The two probes.** Both are cheap and both change what you plan next. Neither was runnable before:
each sat behind the multi-year work it exists to inform.

| Task | Achieves |
|---|---|
| **469** | **The route decision.** Can the rebuilt non-permissive filtration land in `IntPresentation` directly, so decidability needs no bridge theorem at all? Verdict + cost comparison against the tableau route. |
| **426** | Whether the `(G p) → □(G p)` branch saturates at some fuel or provably never does. 4–8 h; discriminates a budget question from a termination question. |

**Foundational refactors**, safe to run alongside:

| Task | Achieves |
|---|---|
| **451** | Consolidates the two Boneyards (156 files, 88k lines) into one archive tree, plus a checker that every intra-archive import still resolves. Must precede 468, whose roadmap claims are C7-grounded on file counts. |
| **193** | Applies the validity-intro and truth-simp macros across the soundness layer. The uniformity refactor; has an explicit failure criterion ("working macros and unchanged proof text has FAILED"). |

**Completeness front opens here:**

| Task | Achieves |
|---|---|
| **421** | Replaces the refuted Base→Discrete transfer guidance in `Transfer.lean` with the refutation, and probes the `ℚ ×ₗ ℤ` carrier's Mathlib instances. Small. |
| **423** | Creates `SetConsequence.lean` with `SetDerivable` — verified absent today, while `SetConsistent`/`set_lindenbaum` already exist. The first real step on strong completeness. |
| **413** | The TM+/TM conservativity bridge. Greenfield, purely proof-theoretic, independent of everything else. |
| **424** | The shift-set representation gate, re-issued against the landed total-history semantics. |

```
/implement 469,426        # probes first if you want the verdict sooner
/implement 451,193
/implement 421,423,413,424
```

---

## Step 4 — realign the programme  *(after 469, 426, 451)*

| Task | Achieves |
|---|---|
| **468** | Rewrites `specs/ROADMAP.md` around the PROVEN vs SORRY-FREE distinction; issues a verdict on every active task; assigns the unowned fifth termination residual; adjudicates 455. Carries six amendments (10a–10f) correcting its own charter. |
| **455** | Adjudicated by 468 — the review recommends **ABSORB** (its Stage 1 is strictly contained in 468's Stage 4c). Expect a proposal to abandon it. |

Why here and not earlier: 468 must state, per front, what is proven / open / refuted. It cannot
describe decidability honestly until 469 reports, and its file-count claims go stale immediately if
451 runs after it.

```
/implement 468
```

---

## Step 5 — the completeness front

| Task | Achieves |
|---|---|
| **422** | **The one genuinely open piece of mathematics here.** The discrete-case chronicle over `ℚ ×ₗ ℤ`. Its own description names the risk: it is *not* verified that the chronicle's block order can be densified without breaking MCS-chain coherence. If it fails, it escalates as `[BLOCKED]` with the failing obligation named — do not paper over it. |
| **169** | Consumes 422 to close `countermodel_discrete`. **This is the milestone**: it removes the repository's last sorry and makes all four flagship theorems axiom-clean. |
| **95** | The confirmation pass — re-run `#print axioms`, record the result, close. Was gated at wave 10; now needs only 169. |
| **425** | The discrete non-compactness negative results. Cheap, and a negative result closes a front legitimately. |
| **362** | The consequence-completeness capstone, under the settled terminology. |

Strong completeness for **Base** and **Dense** remains an open research question — the missing piece
is a model-existence theorem, not `SetDerivable`. For **Discrete** and **Dedekind** it is
**refuted** (non-compact) and correctly never attempted.

```
/implement 422   # then 169, then 95 / 425 / 362
```

---

## Step 6 — decidability  *(shape depends on 469)*

**If 469 says the filtration can land in `IntPresentation` directly**: the work is the
non-permissive filtration (re-discharging all four `def:frame` axioms — multi-month, unavoidable on
any route), plus the missing carrier lemma: the successor-based analogue of `archimedean_of_lub`,
which `IntNormalForm.lean` names and which is **not in the tree**. No bridge theorem.

**If it says otherwise**: the tableau chain, in graph order —
`462 → 463 → 464 → 465 → 428 → 429 → 410 → 411 → 430 → 412`, with `433`/`434` finishing in flight.
Budget this honestly: the audit prices full tableau soundness *and* completeness at several
person-years containing at least three separate multi-month research problems.

Two things already settled, so nobody re-derives them:

- **429 is a redesign, not a repair.** Task 418 measured it: the *entire* decidable-branch-gate
  family collapses to `false` on any minted world, not just `boxAnchoredCheck`. Repair option (c)
  is closed; option (a) is the identified route and carries an S5 axiom-4/5 obligation.
- **A fifth termination residual exists** — `UnorderedSuccessorLabelClosed`, carried live and
  refuted in-tree — and no task owns it. 468 assigns it.

---

## Side track — the dataset cluster

Independent of everything above; run it when you want, in this order.

| Task | Achieves |
|---|---|
| **298** | **Do first.** `data/bmlogic-c7.jsonl` holds 13,749 records while its metadata advertises 77,272 — a live integrity defect, invisible to git (`data/` is gitignored). |
| **296**, **282** | The derived-operator re-add and the exhaustive-enumeration work. 282 needs a real description first (470 item F). |
| **231** | The sync automation. **Must follow 298**, or it automates propagation of the truncated dataset. |
| **257** | Blocked on *you*: an HF account, org, and write token. Not an engineering task. |

---

## Decisions that are yours, not an agent's

| | |
|---|---|
| **219** | Recommended **abandon**. `data/baselines/` does not exist; needs paid runs against now-stale models; no relation to the formalization programme. |
| **127**, **128** | Recommended **abandon or park explicitly**. Both extend the object language, which would multiply the 34-constructor rule set and invalidate the `MintBound.lean` termination work. Good ideas, actively antagonistic to this programme. |
| **455** | Expect 468 to propose abandonment. |
| **125** | Keep, but off the critical path — a second research programme. Now correctly depends on 461. |
| **461** | Blocked on acquiring a source absent from both the Literature corpus and Zotero. |
| **432**, **436** | Marked `completed` over work the audit found still open. 468 proposes corrections; the status call is yours. |

---

## Reading the graph yourself

```bash
scripts/check-module-invariants.sh                    # the machine baseline, C1–C10
sed -n '/Dependency Waves/,/^$/p' specs/TODO.md       # current waves
jq -r '.active_projects[] | "\(.project_number) \(.status) deps=\((.dependencies//[])|join(","))"' \
  specs/state.json | sort -n
```

Dependency targets that resolve in **neither** `state.json` nor `archive/state.json` are the only
real dangling edges. Roughly 21 targets resolve only in the archive — those are satisfied, not
broken. Any lint must union both files.

---

## Cross-repository hazard: tasks whose work lands outside this repo

Verified 2026-08-24. `.claude/` here is **gitignored** (`.gitignore:81`, zero tracked files) and is
regenerated wholesale on an agent-system reload. `agent-system/` **does not exist** in this
repository — the source store is `/home/benjamin/.config/nvim/agent-system/`, a separate git repo
with its own task tracker (48 active tasks).

Anything written to `.claude/` here is destroyed on the next reload.

| Task | Status | Disposition |
|---|---|---|
| **466** | **ABANDONED here** 2026-08-24 | `update-plan-status.sh` silently no-ops on a non-conforming Status line. Handed to the nvim session for filing via `/meta`. Full description retained in `specs/archive/state.json` as the record. |
| **471** | **ABANDONED — the finding was WRONG** | The claimed `roadmap-integration.sh` stdout defect does not exist: the comment is written to stderr (`:319`, `>&2`), and `/review`'s documented `$( )` capture works. The reviewer caused the parse error by invoking with `2>&1`. Retracted; see issue L-1. |
| **231** item (7) | Annotated, task stays | Cannot be completed from this repo. Recommended: drop item (7), keep the other seven sub-targets here. |

Both abandonments were verified safe: nothing depended on either task, and the graph has zero
dangling edges afterward.

**466's defect is real and independently confirmed** by the source-store maintainer, who found it
worse than reported: the status *read* at `update-plan-status.sh:62,72` is unanchored and falls
through to `|| echo ""` on a bracket-less line, so `current_status` and `updated_status` are both
empty and compare equal — the verification cannot distinguish "updated" from "matched nothing". It
is awaiting the nvim user's approval for filing there; if declined it comes back here.

**471's defect was not real** and the task was invalid. Nothing is pending for it.

Checked for duplicates: nvim task 50 is adjacent (stale-roadmap no-op, verify-deploy) but covers
neither the `update-plan-status.sh` silent no-op nor the `roadmap-integration.sh` stdout contract.

**Not at risk**: 470 (writes `specs/state.json`, tracked), 468 and 455 (invoke `.claude/scripts/*`
but do not edit them), 472 and 473 (`FormalSystem/` only).
