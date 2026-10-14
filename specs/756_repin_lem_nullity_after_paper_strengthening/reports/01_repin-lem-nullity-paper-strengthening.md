# Research Report: Task #756

**Task**: 756 - Repin lem nullity after paper strengthening
**Started**: 2026-10-14T21:28:15Z
**Completed**: 2026-10-14T21:40:00Z
**Effort**: medium (research); implementation re-scoped larger than the task description assumes
**Dependencies**: None
**Sources/Inputs**:
- `scripts/check-paper-definitions.sh` run against the live paper (exit 1, 26 drifted anchors) and against a nonexistent `--paper` (neutral skip, exit 0)
- `scripts/check-paper-definitions.sh --resolve "lem:nullity|env|-|-"`
- `docs/reference/paper-definitions-of-record.md` (header sentinels, drift-correction convention, manifest, `lem:nullity` entry)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (live, dirty; sha256 `1fe9fcc5…`, 3940 lines)
- Lean sources read directly: `FormalSystem/Semantics/TaskFrame.lean`, `Semantics/FrameAxioms.lean`, `Semantics/Extension/Admissible.lean`, `Semantics/Extension/Extension.lean`, `Semantics.lean`, `Semantics/IntNormalForm.lean`, `Semantics/Presheaf/Behavior.lean`
- `scripts/check-module-invariants.sh` (C15, C20, C35), `scripts/lean-citation-seeds.txt`, `scripts/lean-citation-manifest.json`, `scripts/export-lean-citations.py`
- Baseline gate runs: `readme-lint.sh` (exit 0), `check-module-invariants.sh --no-build` (exit 0, zero FAIL)
- No literature source beyond the pinned record; the Literature Extraction Protocol does not apply (the paper is an in-repo-adjacent read-only input already governed by the record file)
**Artifacts**:
- `specs/756_repin_lem_nullity_after_paper_strengthening/reports/01_repin-lem-nullity-paper-strengthening.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's central scoping premise is now stale.** The description states that
  `check-paper-definitions.sh` "reports exactly one drifted anchor". Against the live paper it
  reports **26 drifted anchors of 43 pinned** (exit 1), with zero dangling. The paper moved again
  after the task was authored: its last commit touching the file is dated 2026-10-14, the working
  copy is dirty against that commit, and the file has shrunk from the pinned 4573 lines to 3940.
- **The `lem:nullity` drift itself is exactly as described, verbatim.** `--resolve` reproduces the
  description's OLD/NEW texts and both sha256 values character-for-character. The strengthening to
  a biconditional is real and is the paper's current wording.
- **Consequence: the stated acceptance criterion is unreachable under the stated scope.**
  "`scripts/check-paper-definitions.sh` exits 0 against the live paper" cannot be met by re-pinning
  `lem:nullity` alone — 25 other anchors stay drifted and the script still exits 1. The scope and
  the acceptance criterion must be reconciled, one way or the other, before implementation.
- **Recommended: absorb all 26 as one dated drift-correction re-pin** (the record file's own
  established convention; it has absorbed 10-anchor and 14-anchor waves this way). 20 of the 25
  additional drifts are presentational — set-builder `:` → `\mid`, `iff` → `if and only if`,
  `[Title]` additions to theorem environments, footnotes commented out. Only five carry content,
  and none of them contradicts the formalization.
- **No Lean proof work is implied, and the dispatch's load-bearing claim verified.**
  `FrameOver.nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u` already exists
  (`FormalSystem/Semantics/TaskFrame.lean:1324`), derived from `serial` and `limit`, and the *only*
  `Paper: lem:nullity` marker in the tree already sits on its binder-free twin
  `nullity_identity_of_serial_limit` (`TaskFrame.lean:1304`). The library over-satisfies the
  strengthened lemma and preserves its derived status.
- **The dispatch's site enumeration is incomplete in two ways**, both found and enumerated below:
  two typst sites restate the paper's Nullity in its retired weak form, and five prose sites
  attribute "the paper's `lem:nullity`" to `FrameOver.nullity` (the weak loop) — an attribution the
  strengthening moves to `nullity_identity`.
- **A gate the dispatch does not name will go red** if docstrings in the target files are edited:
  **C35** in `check-module-invariants.sh` asserts `scripts/lean-citation-manifest.json` is
  byte-current by recorded `span_start`/`span_end`/`keyword_line`, and 29 seeded entries live in
  files this task edits. Remedy is one command: `python3 scripts/export-lean-citations.py`.

## Context & Scope

Researched: (a) whether the described `lem:nullity` drift is current and correctly quoted; (b) what
else `check-paper-definitions.sh` reports against the live paper; (c) whether the formalization
needs any new Lean content; (d) the complete in-tree site inventory the re-pin falsifies; (e) which
gates the edit set perturbs.

Constraints honoured: no edit to the paper (read-only input); no new Lean declarations proposed; no
change to the four `def:frame` axioms or to Nullity's derived status; zero-debt policy (no `sorry`
or axiom is implied by anything below, because no proof obligation arises at all).

Evidence tier note: lean-lsp was registered and reachable per the dispatch's readiness block, but
every Lean finding below rests on **direct source reads and grep over the working tree**, not on an
LSP symbol-index query. No negative finding below is drawn from an empty LSP result, so the
`index: consulted` caveat does not bear on any conclusion here.

## Findings

### 1. The `lem:nullity` drift, verified

`bash scripts/check-paper-definitions.sh --resolve "lem:nullity|env|-|-"`:

```
sha256:   8442e2bf6b5f6515f2f906132bbe15fe919973d82ae573dba29a919ad14636f5
text:
  \begin{Lthm} \label{lem:nullity}
  	$w \Rightarrow_0 u$ if and only if $w = u$, for all world states $w, u \in W$ in any task frame $\F$.
  \end{Lthm}
```

Pinned (record line 1037-1042, sha256 `94ed0183…`):

```latex
\begin{Lthm} \label{lem:nullity}
	$w \Rightarrow_0 w$ for every world state $w \in W$ in every task frame $\F = \tuple{W, \D, \Rightarrow}$.
\end{Lthm}
```

Both texts and both hashes match the task description exactly. The strengthening is genuine: an
implication became a biconditional characterising `⇒₀` as the identity relation.

### 2. The drift is 26 anchors, not one — the scope-defining finding

`bash scripts/check-paper-definitions.sh` exits **1** with "26 recorded definition(s) drifted" and
**no** dangling anchors. Paper provenance now:

| Field | Pinned in record | Live |
|---|---|---|
| sha256 | `b4e45e2c…` (`FILE_CHECKSUM` sentinel) | `1fe9fcc5…` |
| line count | 4529 (`LINE_COUNT` sentinel) | 3940 |
| paper repo HEAD | `a166fcbf…` (`PINNED_COMMIT`) | `ab7a4a94…`, file dirty; last commit touching it `6392f019…` (2026-10-14) |

The 26 anchors and their live hashes (captured 2026-10-14; **re-resolve before writing**, see Risks):

| Anchor | New sha256 | Nature of the drift |
|---|---|---|
| `def:temporal-order` | `1fa55867…` | cosmetic: set-builder `:` → `\mid` |
| `def:task-relation` | `f35b1c74…` | **content**: reflection convention restricted from `x \geq 0` to `x > 0`; plus `:` → `\mid` |
| `def:frame` | `1150ed22…` | cosmetic: "for all positive durations $x,y \geq 0$" → "for all durations $x, y \geq 0$". **Sub-anchors did not drift** |
| `lem:nullity` | `8442e2bf…` | **content**: implication → biconditional (this task's target) |
| `def:world-history` | `e94a15db…` | near-cosmetic: top tier re-routed through *partial* instead of *convex* history (equivalent, a total domain is convex) and renamed "world history, or possible world" |
| `thm:extension` | `0677bc17…` | `[Extension]` title added; the choice-free/ZFC footnote **removed** |
| `cor:occurrence` | `e4be0b08…` | `[Occurrence]` title added |
| `def:constraints` | `f39ba974…` | **content**: restructured with named `A`, `C`, `F_t`, `S_{t,s}`; same extension |
| `lem:nesting` | `6ad1e33d…` | rephrased to use `def:constraints`' new names |
| `def:BLplus-language` | `b7027d46…` | cosmetic: `\set{p_i: i\in\N}` → `\set{p_i \mid i\in\N}` |
| `def:time-shift-histories` | `99588bf0…` | cosmetic: "iff" → "if and only if" |
| `def:frame-validity` | `4fdc41ce…` | reworded; non-vacuity footnote commented out |
| `def:BX` | `8fdba7ab…` | Burgess/Xu attribution footnote removed |
| `def:BX-z` | `96e4b25e…` | attribution sentence removed; ℤ/Archimedean claim narrowed to **TM$_z$ soundness** |
| `def:BX-d` | `2423da46…` | attribution sentence removed |
| `thm:TM-soundness` | `05ed3f68…` | **content**: generalized to every system of `def:TMplus` with a context, `Γ ⊢_Λ φ ⇒ Γ ⊨_{C_Λ} φ` |
| `app:discrete` | `465b089f…` | "iff" → "if and only if"; footnote "convex histories" → "possible worlds" |
| `app:dense` | `8b6e84ae…` | "iff" → "if and only if" |
| `app:complete` | `d62b8c53…` | "iff" → "if and only if" |
| `def:frame-properties` | `a8948afa…` | **additive**: ℤ-time / ℝ-time task-frame terminology defined |
| `def:deterministic` | `9a347781…` | trailing reflection-convention clause commented out |
| `cor:saturation-finite` | `98fac4cf…` | **content**: generalized from "every task frame with finite `W`" to "task relations on finite `W`" |
| `cor:tm-completeness` | `f8f5b41f…` | strong/weak completeness definitions lifted out of the statement; Lean-repo footnote commented out; "ℤ-time" → "the ℤ-time task frames" |
| `def:id` | `385b1f8b…` | commented-out derivation lines removed |
| `thm:exist` | `299ecc33…` | `[Existence]` title added |
| `lem:uniq` | `4d7a5038…` | `[Uniqueness]` title added |

**None of these contradicts the formalization.** The two that merit a sentence in the correction
note:

- `def:task-relation`'s `x \geq 0` → `x > 0` **moves the paper toward the tree**, not away. The
  tree already treats zero specially: `TaskFrame.lean:1392`'s docstring says the reflection law is
  "definitional content of `TaskFrame.reflect`" off zero and needs *Limit* at zero
  (`reflection_of_limit`). Excluding `x = 0` from the convention is exactly that structure.
- `cor:saturation-finite`'s generalization to bare task relations matches
  `TaskFrame.saturation_of_fib_subsingleton`/`saturation_of_finite`, which are already stated over a
  bare relation rather than over a frame.

### 3. The formalization is ahead of the paper (verified, not assumed)

| Claim | Evidence |
|---|---|
| The biconditional already exists | `FormalSystem/Semantics/TaskFrame.lean:1324` `theorem nullity_identity (F : FrameOver D) [F.IsRegular] : ∀ w u, F.TaskRel w 0 u ↔ w = u`; total-space form at `:2665` |
| Derived, not a field | `:1326` proves it from `F.serial` and `F.limit`; binder-free twin `nullity_identity_of_serial_limit` at `:1306` |
| Derived status is already prose-of-record | `TaskFrame.lean:1028-1034`, `Semantics.lean:255-259`, `README.md:84` |
| The paper-anchor attribution already points at the biconditional | the tree's single `Paper: \`lem:nullity\`` marker is at `TaskFrame.lean:1304`, on `nullity_identity_of_serial_limit` |
| It is used as the identity characterisation | `IntNormalForm.lean:24` ("`⇒₀` is the identity — the derived theorem `FrameOver.nullity_identity`"), `:200` `simpa using F.nullity_identity w u`; also `DeterministicBridge.lean:141`, `RigidityReal.lean:199` |

No new declaration, no proof, no axiom, no `sorry` is implied by this drift.

### 4. Complete in-tree site inventory

**4a. Verbatim quotations of the retired `lem:nullity` wording — exactly four, as described.**
`grep -rn 'Rightarrow_0 w'` over live non-`specs/`, non-`Boneyard/` scope returns precisely:

| Site | Note |
|---|---|
| `FormalSystem/Semantics/TaskFrame.lean:113` | module docstring, "(verbatim: …)" |
| `FormalSystem/Semantics/TaskFrame.lean:919` | declaration docstring above `nullity_of_serial_limit` |
| `FormalSystem/Semantics/FrameAxioms.lean:65` | "Paper specification, transcribed" list |
| `FormalSystem/Semantics/Extension/Admissible.lean:34` | already imprecise: says "in every **frame**" where the record pins "in every **task frame**" |

**What "verbatim" means here is load-bearing for scope.** `FrameAxioms.lean:45-46` states the
convention explicitly: "Anchors below are `\label` keys into
`docs/reference/paper-definitions-of-record.md`, which — not the paper source — is the citation
source of record." So these claims are false *only once the record is re-pinned*. The correction
scope therefore tracks the re-pin scope exactly.

**4b. Weak-form paraphrases, reviewed case by case (dispatch step 3).**

| Site | Verdict |
|---|---|
| `FormalSystem/Semantics.lean:255-259` | **Keep.** Already names both forms, and already calls `nullity_identity` "the biconditional". Optional: note that the biconditional is now the paper's own statement |
| `FormalSystem/Semantics/Presheaf/Behavior.lean:91` | **Keep.** "needs `w ⇒_0 w`, which is the derived `nullity_identity`" — a correct statement of what the construction consumes |
| `FormalSystem/Semantics/FrameAxioms.lean:113` | **Keep.** "`lem:nullity` itself, DERIVED … from *Seriality* at `x = 0` plus *Limit*" — true of both halves |
| `FormalSystem/Semantics/Extension/Admissible.lean:117` | **Keep.** A References line, "the zero loop `w ⇒₀ w`" — names what the module uses |
| `FormalSystem/Semantics/Extension/Extension.lean:171` | **Keep.** Same shape |
| `docs/reference/state-topology-appendix-support.md:103` | **Keep.** "given `w ⇒₀ w`" is a hypothesis statement, and the weak loop is genuinely all `coneTopology_le_nbhdTopology` consumes |

So dispatch step 3 resolves to **no required edits**, with one optional clarification at
`Semantics.lean:255-259`. This confirms the dispatch's own warning that step 3 is a judgment pass
rather than a search-and-replace.

**4c. Sites the dispatch did not enumerate (new findings).**

*Restatements of the paper's Nullity in the retired weak form:*

| Site | Content |
|---|---|
| `typst/FormalFoundations.typ:230` | `#lemma("Nullity")[$w arrow.r.double.long_(0) w$ for every world state $w$ of every frame.]`, with `#leansrc("Semantics.TaskFrame", "nullity")` at `:231` |
| `typst/chapters/02-semantics.typ:137-155` | states Nullity as the weak loop (`:139-142`, carrying a `// CONFIRM(paper): lem:nullity states this lemma` comment); `:155` already describes `nullity_identity` as derived |

These two now **understate** the paper's lemma. `02-semantics.typ:155` already carries the
biconditional, so the fix is small in both cases.

*Attributions of "the paper's `lem:nullity`" to the weak-loop declaration:*

| Site | Content |
|---|---|
| `docs/reference/API_REFERENCE.md:196` | "`FrameOver.nullity` (`TaskRel w 0 w`, the paper's `lem:nullity`…)" — the strengthening moves this attribution to `nullity_identity`, with `nullity` as its reflexivity half |
| `README.md:84` | "Nullity (`w ⇒_0 w`) is **not** an axiom" — parenthetical now understates the paper |
| `FormalSystem/Semantics/README.md:84` | same shape |
| `docs/development/PROPERTY_TESTING_GUIDE.md:295` | "`lem:nullity` is derived from *Seriality* and *Limit*" — true of both halves, **keep** |
| `typst/chapters/06-notes.typ:32` | "*Nullity* is a derived lemma … both `nullity` and its biconditional form `nullity_identity` are theorems" — **keep**, already covers both |
| `docs/reference/transcription-audit-surface.md:82`, `:165` | "The `⊇` half [of *Limit*] is `lem:nullity`, derived". Still true of the reflexivity half, but imprecise once `lem:nullity` names the whole biconditional — worth a parenthetical |

*Pre-existing false "verbatim" claims, independent of this drift* (false against the **current**
pinned record, before any re-pin):

| Site | Mismatch |
|---|---|
| `FormalSystem/Semantics/TaskFrame.lean:98-102` | quotes `def:frame` as "A \textit{frame} is any…"; the record pins "a \textit{task frame} is any…" and the `⊇`-directed opening clause is omitted |
| `FormalSystem/Semantics/TaskFrame.lean:394-396`, `:412-413`, `:462-463` | use the retired `\Fib(w, x)` function-application form; the record pins the brace form `\fib{w, x}` |
| `FormalSystem/Semantics/Extension/Admissible.lean:34` | "in every frame" vs the record's "in every task frame" |
| `FormalSystem/Semantics/Extension/Admissible.lean:35-38` | quotes `def:constraints` with the retired "constraints *imposed on*" wording and `\Fib(…)` |

The acceptance criterion "no docstring claims a verbatim quotation it does not reproduce", read
literally, reaches these. Recommendation below treats the ones on re-pinned anchors as in scope and
flags the rest.

**4d. Scope relief: the four `def:frame` axioms are byte-stable.** `def:frame#Compositionality`,
`#Seriality`, `#Limit` and `#Saturation` did **not** drift. They carry 91 of the ~110 in-tree
"verbatim" anchor claims (23+23+23+22), including the whole of
`Tests/BimodalTest/Semantics/TaskFrameTest.lean`. None of those needs touching.

**4e. Verbatim-claim load per drifted anchor** (live scope, excluding the record file):

`def:task-relation` 7 · `def:frame` 8 · `lem:nullity` 6 (4 quoting the retired sentence) ·
`def:world-history` 14 · `def:temporal-order` 4 · `def:constraints` 4 · `def:frame-properties` 4 ·
`thm:extension` 3 · `cor:occurrence` 3 · `def:frame-validity` 2 · `cor:saturation-finite` 1.
Most quote a *clause* that did not move (e.g. `def:world-history`'s first sentence is unchanged;
`thm:extension`'s main sentence is unchanged and only its footnote and title moved), so the
per-site work is dominated by "read and confirm no change needed".

### 5. Gates and baselines

| Gate | Baseline today | Effect of this work |
|---|---|---|
| `scripts/check-paper-definitions.sh` (live paper) | **exit 1**, 26 drifted | the thing being fixed |
| `scripts/check-paper-definitions.sh` (paper absent) | `SKIP (neutral)`, **exit 0** — verified with `--paper /nonexistent/x.tex` | unchanged; confirms the dispatch's "NOT A CI FAILURE". CI wires the script at `.github/workflows/ci.yml:203-210` and takes exactly this path |
| `scripts/readme-lint.sh` | **exit 0** (`RESULT: PASS`) | no expected effect |
| `scripts/check-module-invariants.sh --no-build` | **exit 0**, zero `FAIL` lines | see C35 below |
| C15 (anchors resolve against the record) | PASS | safe: no new anchor is cited and none goes dangling. No `docs/theorem-index.md` row exists for nullity, so C15's second assertion is not engaged |
| C20 (declaration-span citations) | PASS; 10 recorded baseline mismatches, **none in this task's files** | safe |
| **C35 (citation manifest byte-current)** | PASS | **will go red.** The manifest records `keyword_line`/`span_start`/`span_end`; e.g. `TaskFrame.nullity_of_serial_limit` is pinned at span 916-964, keyword 941, and its docstring is the edit target. 29 seeded entries live in files this task edits (TaskFrame.lean 23, PartialHistory.lean 3, Validity.lean 2, TemporalOrder.lean 1). Remedy: `python3 scripts/export-lean-citations.py`, then commit the regenerated manifest. Never hand-edit it |
| `lake build` | not run in research (expensive; no Lean code change is proposed) | docstring-only edits; required at implementation per the acceptance list |

### 6. The record file's own conventions (what the implementation must follow)

- **Obtain text and hashes via `--resolve`, never by transcription.** There is no `--fix` mode by
  design. The record's "How to extend this record" section and every prior drift-correction note
  ("re-quoted from live text via `--resolve`, none hand-written") say so.
- **One dated correction section per wave.** Precedent: "Drift correction and rename absorption
  (2026-09-17): the time-reflection wave" (14 re-hashed + 1 retired), "Drift correction
  (2026-09-02): ten-anchor re-pin". Each lists what was re-hashed, what content moved, and what
  in-tree prose it forced.
- **Re-pin the whole-file sentinels on a drift correction**, not on a case-(b) coverage extension.
  This wave is a correction, so `PINNED_COMMIT`, `FILE_CHECKSUM` and `LINE_COUNT` are all re-pinned.
- **Existing inconsistency to fix while there**: the provenance table's last row names
  `88d9a9a6…` / 4573 lines as "current authoritative pin" (the 2026-09-28 `def:id` footnote re-pin),
  but the `FILE_CHECKSUM` sentinel still carries `b4e45e2c…` / 4529 and `PINNED_COMMIT` still
  carries `a166fcbf…`. The sentinels are what the script reads, so the fast path has simply never
  hit. Setting all of them to the new values resolves the divergence.
- **Preserve the standing claim that Nullity is DERIVED, not an axiom** (record line 991,
  `TaskFrame.lean:113`). The strengthening does not promote it: the tree derives both halves from
  `serial` + `limit`, and the derivation remains choice-free.
- **One note the correction should carry**: `thm:extension`'s footnote — the one asserting the
  choice-free status of `lem:nullity` and `cor:saturation-finite` against `thm:extension`'s Zorn
  appeal — has been **removed from the paper**. The tree asserts choice-freeness in several places
  (`TaskFrame.lean:924-925`, `FrameAxioms.lean:113-115`, `typst/FormalFoundations.typ:238,343`).
  The claims remain true of the Lean proofs (which is what the tree is entitled to assert), but they
  no longer have a live paper footnote behind them. Recording that in the correction note prevents a
  future reader hunting for a citation that is gone.

### Recommendations

**Recommended approach — Option A: absorb all 26 as one dated drift-correction re-pin.**

1. Re-run `scripts/check-paper-definitions.sh` to get the live drift list afresh (the paper is dirty
   and was edited today), then `--resolve` each drifted anchor one at a time.
2. For each of the 26: replace the fenced `latex` block and the `sha256:` line in its prose entry,
   and the hash in the `MANIFEST:BEGIN/END` row. Do not touch the 17 unchanged rows, and do not
   touch the four `def:frame#*` sub-anchor rows.
3. Add one `### Drift correction (2026-10-14): the …-wave re-pin` section following the 2026-09-17
   section's shape: the re-hashed list, the five content-bearing changes called out individually,
   the two paper-ward-alignment notes from §2, and the `thm:extension` footnote-removal note.
4. Re-pin `PINNED_COMMIT`, `FILE_CHECKSUM`, `LINE_COUNT` and add the provenance-table rows;
   reconcile the sentinel/table divergence noted in §6.
5. Correct the four retired-wording verbatim sites (§4a) to the new biconditional text. At
   `Admissible.lean:34` also fix "frame" → "task frame".
6. Judgment pass over the remaining verbatim claims on the 26 re-pinned anchors (§4e), re-quoting
   only where the quoted clause actually moved.
7. Fix the two typst weak-form restatements and the `API_REFERENCE.md:196` / `README.md:84` /
   `FormalSystem/Semantics/README.md:84` attributions (§4c); add the parenthetical at
   `transcription-audit-surface.md:82,165`.
8. Run `python3 scripts/export-lean-citations.py` and commit the regenerated manifest (C35).
9. Verify: `check-paper-definitions.sh` exit 0; `lake build` green (detached, via
   `lake-build-guard.sh`); `readme-lint.sh` and `check-module-invariants.sh --no-build` exit 0.

**Option B (not recommended): re-pin `lem:nullity` only.** Requires amending the acceptance
criterion to "no longer reports `lem:nullity` as drifted" and spawning a follow-on task for the
other 25. It leaves the local gate red — which is the condition the task exists to clear — and means
reading the same paper twice. Only preferable if the user wants the nullity question settled in
strict isolation.

No sorry-free-path question arises: there is no proof obligation anywhere in this task.

## Decisions

- **Treat the record file, not the live paper, as what "verbatim" means in a docstring.** Taken from
  `FrameAxioms.lean:45-46`'s explicit statement of the convention. This is what makes the correction
  scope equal to the re-pin scope, and what makes dispatch step 3 resolve to almost no edits.
- **Report the 26-anchor drift as a scope finding rather than silently widening the task.** The
  acceptance criterion and the stated scope are in direct conflict; which one yields is the user's
  call, so it is surfaced as a `user_decision` rather than assumed.
- **Classify the 25 additional drifts by content rather than counting them.** 20 presentational, 5
  content-bearing, 0 contradicting the formalization — this is what makes Option A cheap enough to
  recommend.
- **Do not propose promoting Nullity to an axiom or adding any declaration.** Both halves already
  exist as theorems off `serial` + `limit`; the strengthening is absorbed entirely in the record and
  in prose.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **The paper moves again mid-dispatch.** It is dirty against HEAD and was committed today; the record file documents this happening twice before, including "a sixth wave landed on disk, uncommitted, while this very file was being authored" | Re-run `--resolve` immediately before writing each block, and re-run the bare check at the end. If it reports fresh drift, absorb it into the same dated section rather than opening a second one |
| **The 26 live hashes in §2 go stale** for the same reason | They are reference/triage data only. The implementation must take its hashes from its own `--resolve` calls, per the record's own rule |
| **C35 goes red** after docstring edits | `python3 scripts/export-lean-citations.py`; commit the regenerated manifest. Never hand-edit it |
| **Over-correction**: rewriting a verbatim quote whose clause did not actually move | Diff the quoted clause against the freshly re-pinned block before editing. §4b's six "Keep" verdicts and §4d's byte-stable sub-anchors are the bulk of the protection |
| **Scope creep into pre-existing defects** (§4c's last table) | Fix those on re-pinned anchors (`def:frame` opening, `def:task-relation`'s `\Fib(`→`\fib{`, `def:constraints` at `Admissible.lean:35-38`) since they are in the files being touched anyway; leave anything else, and say so explicitly in the summary |
| **Concurrency**: six sibling tasks dispatch this cycle on the same tree with no declared `file_scope` | Re-read each file immediately before editing; stage explicit file lists only; treat a foreign modification or an unexpected build failure outside this task's files as a sibling's, and report rather than "fix" |
| **typst edits outside the lean4 task type's usual remit** | The typst sites here are statement-accuracy corrections to a restatement of the paper's lemma, not presentation work. If the user prefers, they split cleanly into a `typst` follow-on; flag rather than assume |

## Tactic Survey Results

- Not applicable (no tactic survey performed). No proof obligation arises anywhere in this task:
  `FrameOver.nullity_identity` and `nullity_identity_of_serial_limit` already exist and already
  prove the strengthened statement, so there is no goal to search tactics against.

## Context Extension Recommendations

- **Topic**: absorbing a multi-anchor paper-definition drift wave.
  **Gap**: the procedure is recorded only as narrative inside
  `docs/reference/paper-definitions-of-record.md`'s own dated sections, and has to be reverse-engineered
  from them each time (as this dispatch did). The C35 regeneration step is not mentioned there at all,
  even though every docstring-level correction triggers it.
  **Recommendation**: a short `context/project/lean4/operations/paper-drift-absorption.md` giving the
  ordered procedure — bare check → per-anchor `--resolve` → prose + manifest edits → dated correction
  section → sentinel re-pin → in-tree verbatim judgment pass → `export-lean-citations.py` → the four
  acceptance gates — with the dirty-paper re-resolve warning stated once.
- **Topic**: the meaning of "verbatim" in this tree's docstrings.
  **Gap**: stated once, in passing, at `FormalSystem/Semantics/FrameAxioms.lean:45-46`. It is the fact
  that determines the blast radius of every re-pin, and it is easy to miss.
  **Recommendation**: state it in `docs/reference/paper-definitions-of-record.md`'s "How to read this
  file" section, which is where someone scoping a re-pin will look.

## Appendix

**Commands run**

```
bash scripts/check-paper-definitions.sh                                  # exit 1, 26 drifted, 0 dangling
bash scripts/check-paper-definitions.sh --paper /nonexistent/x.tex       # SKIP (neutral), exit 0
bash scripts/check-paper-definitions.sh --resolve "lem:nullity|env|-|-"
bash scripts/readme-lint.sh                                              # exit 0, RESULT: PASS
bash scripts/check-module-invariants.sh --no-build                       # exit 0, zero FAIL
sha256sum / wc -l on the live paper; git -C ~/Philosophy/Papers/PossibleWorlds rev-parse HEAD
grep -rn 'Rightarrow_0 w' --include=*.lean --include=*.md --include=*.typ   # the 4 verbatim sites
grep -rn 'verbatim' … | grep -oE '`(def|thm|lem|cor|app):[^`]+`' | sort | uniq -c   # per-anchor load
grep -rn 'nullity_identity' --include=*.lean FormalSystem/ Tests/
grep -rn 'ullity' --include=*.typ --include=*.md                            # typst + docs sites
grep -rn 'Paper:.*lem:nullity' --include=*.lean --include=*.md              # one marker, on the biconditional
python3 -c "…json…" on scripts/lean-citation-manifest.json                  # span pinning, 29 affected entries
```

**References**

- `docs/reference/paper-definitions-of-record.md` — §"Recording provenance", §"How to read this
  file" / "Hashing method", §"How to extend this record", §"Machine-readable manifest", the
  `lem:nullity` entry (line 1037), and the dated drift-correction sections of 2026-09-02, 2026-09-07,
  2026-09-17, 2026-09-18 and 2026-09-28 used as the format precedent
- `scripts/check-paper-definitions.sh` — header (three outcomes, neutral-skip/CI rationale),
  `--resolve` mode, `pinned_text_from_record`
- `docs/development/CI_CD_PROCESS.md` — "Wiring a New Check Script"; `.github/workflows/ci.yml:203`
- `scripts/check-module-invariants.sh` — C15, C20, C35 (C35 remediation hint at the check itself)
- `scripts/export-lean-citations.py` — header, determinism contract
- `docs/reference/transcription-audit-surface.md` — the name-keyed definitional surface and its
  *Limit*/`lem:nullity` rows
