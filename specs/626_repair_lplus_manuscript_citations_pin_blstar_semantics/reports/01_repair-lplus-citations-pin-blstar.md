# Research Report: Task 626

**Task**: 626 - Repair drifted manuscript citations in the L+ files and pin def:BLstar-semantics.
**Started**: 2026-09-20T18:47:00Z
**Completed**: 2026-09-20T19:40:00Z
**Effort**: Small — docstring/documentation edits only, ~15 line-number citations across 5 files,
one manifest pin, one docstring sentence, one README table row.
**Dependencies**: None
**Sources/Inputs**:
- Manuscript: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (4554 lines)
- `docs/reference/paper-definitions-of-record.md` (2123 lines)
- `FormalSystem/Syntax/PlusLanguage/{Axioms,Formula}.lean`
- `FormalSystem/Semantics/PlusLanguage/{PlusTruth,PlusNonValidities,PlusStateLocal}.lean`
- `FormalSystem/Syntax/StarLanguage/README.md`
- `scripts/check-paper-definitions.sh --resolve`
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/04_semantics-first-task-frames.md` §3.2
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All four claims in the dispatch's "WHAT IS WRONG" section are verified against the live
  manuscript and the live repository. The drift is real and larger than the dispatch's "about
  eight docstrings" estimate: **15 line-number citations across 5 files** (not 2), all confined to
  `FormalSystem/Syntax/PlusLanguage/` and `FormalSystem/Semantics/PlusLanguage/`. **No hits in
  `Syntax/StarLanguage/` or `Semantics/StarLanguage/`.**
- The Stability clause now lives at manuscript line 1155 (subsection *Restricted Modalities*,
  `\label{sub:RestrictedModalities}` at line 1144), its footnote at lines 1158–1162, and the
  `⟨τ⟩_x` definition it depends on at line 1153. The appendix block `def:BLstar-semantics` is far
  later, at line 3544–3554 — a *different* occurrence of the same clause, confirmed word-for-word
  identical up to the `\vec{v}` register-vector generalization.
- **A stray, previously-unnoticed drifted citation was also found**: `PlusNonValidities.lean`
  cites "*Determined* (paper line 1426)" twice (lines 25 and 52); *Determined* is now at line 1517,
  under `\subsection{Open Future}` (`\label{sub:OpenFuture}`), not under *Restricted Modalities*.
  *Determined* carries no `\label` of its own (it is a bare `\item[\it Determined:]`), so it must
  be cited by name/phrase, never by label.
- `def:BLstar-semantics`'s current live sha256 (via `--resolve`) is
  `b4d3239cc96ddd1e90965901aca8c378f6ec5ca52f568ea6b2ef59d9c3ba6c95`. `check-paper-definitions.sh`
  with no arguments currently reports case (b) (42 recorded definitions unchanged) — adding
  `def:BLstar-semantics` is a **coverage extension, not a drift correction**, and the file's own
  documented convention (see `paper-definitions-of-record.md` lines 36–41, the 2026-08-13
  coverage-extension precedent) is that a coverage extension does **not** bump the
  `FILE_CHECKSUM`/`PINNED_COMMIT` sentinels — only a drift *correction* does. The implementer
  should follow that precedent, not re-pin the whole-file sentinels.
- The `stab_4` constructor is at `FormalSystem/Syntax/PlusLanguage/Axioms.lean:288-290`. The
  manuscript's commented-out `def:TM-stability` block (lines 3775–3794) lists exactly **SK, ST,
  S5, MS, AS, PS, US** — no S4-shaped schema (`⊡φ → ⊡⊡φ`) — confirming the dispatch's claim that
  `stab_4` is surplus to it, standardly derivable from monomodal S5 (S4 follows from B+T, or
  directly from 5+T).
- The StarLanguage correspondence table (`FormalSystem/Syntax/StarLanguage/README.md`, lines
  103–133) already has a row recording the world registers as excluded (line 111). No row records
  the open-future/open-past/nomic operators of *Restricted Modalities* (manuscript lines
  1179–1210) as unformalized manuscript content; item (4) of the dispatch is un-actioned as of
  this research pass.

## Context & Scope

Task 626 targets citation-drift repair (manuscript line numbers used as citations, which move
every time the author edits the paper) and one anchor-pinning gap (`def:BLstar-semantics` recorded
`LIVE-UNPINNED` in `docs/reference/paper-definitions-of-record.md` on the stated ground that its
clause was quoted only in paraphrase — since resolved as quoted verbatim). The dispatch names four
concrete deliverables and constrains the work to docstrings/documentation only (no declaration,
statement, or proof changes), verified by the C15 anchor gate and a scoped guarded build. This
report is the **research** pass: it verifies every factual claim in the dispatch, extends the
citation inventory by grep beyond the two files the dispatch names by example, resolves every
"replace this with what" question with exact manuscript line numbers and quoted text, computes the
hash needed for the manifest pin, and locates the exact insertion points for the plan/implementation
phase. No files outside this task's own `specs/` directory were modified.

## Findings

### 1. Full citation-drift inventory (broader than the dispatch's example set)

The dispatch names `Axioms.lean` ("about eight docstrings") and `PlusTruth.lean` ("the same kind
of citation") explicitly, then instructs "grep the rest ... for the same pattern and fix what is
found." A grep sweep (`paper line\|paper lines\|line [0-9]\{3,\}\|footnote, line`) across all four
named directories turned up **15 citations in 5 files**, three of which the dispatch does not name
by example:

| File | Line(s) | Stale text | Cites | Current manuscript location |
|---|---|---|---|---|
| `Syntax/PlusLanguage/Axioms.lean` | 39 | `paper line 1108` | `⟨τ⟩_x ⊆ H_F` | `⟨τ⟩_x` defined line 1153 (containment is definitional: `σ ∈ H_F` in the set-builder) |
| `Syntax/PlusLanguage/Axioms.lean` | 41 | `paper footnote, line 1119` | atom-level `p → ⊡p` | footnote line 1161 |
| `Syntax/PlusLanguage/Axioms.lean` | 47 | `paper footnote, line 1118` | monomodal S5 of `⊡` | footnote line 1159 |
| `Syntax/PlusLanguage/Axioms.lean` | 286 | `paper footnote, line 1118` | ST | footnote line 1159 |
| `Syntax/PlusLanguage/Axioms.lean` | 288 | `paper footnote, line 1118` | S4 (`stab_4`) | footnote line 1159 (and see Finding 3: not itself in `def:TM-stability`) |
| `Syntax/PlusLanguage/Axioms.lean` | 291 | `paper footnote, line 1118` | S5 (`stab_5`) | footnote line 1159 |
| `Syntax/PlusLanguage/Axioms.lean` | 295 | `paper line 1108` | MS / `⟨τ⟩_x ⊆ H_F` | line 1153 |
| `Syntax/PlusLanguage/Axioms.lean` | 297 | `paper footnote, line 1119` | AS / atom stability | footnote line 1161 |
| `Syntax/PlusLanguage/Formula.lean` | 22-23 | `(line 1108)` | `⟨τ⟩_x` definition | line 1153 |
| `Syntax/PlusLanguage/Formula.lean` | 23-25 | `is line 1121`; `are lines 1125-1129` | dual `⟐`; `Will`/`will`/`Could`/`could` | dual at line 1163; the four at lines 1167, 1168, 1170, 1171 |
| `Syntax/PlusLanguage/Formula.lean` | 180 | `paper lines 1121, 1125-1129` | section banner for the block below | same remap as above |
| `Syntax/PlusLanguage/Formula.lean` | 182 | `paper line 1121` | dual `⟐φ := ¬⊡¬φ` | line 1163 |
| `Syntax/PlusLanguage/Formula.lean` | 186 | `paper line 1125` | `Will` | line 1167 |
| `Syntax/PlusLanguage/Formula.lean` | 189 | `paper line 1126` | `will` | line 1168 |
| `Syntax/PlusLanguage/Formula.lean` | 192 | `paper line 1128` | `Could` | line 1170 |
| `Syntax/PlusLanguage/Formula.lean` | 196 | `paper line 1129` | `could` | line 1171 |
| `Semantics/PlusLanguage/PlusTruth.lean` | 22 | `(line 1108)` | `⟨τ⟩_x` definition | line 1153 |
| `Semantics/PlusLanguage/PlusTruth.lean` | 33-35 | `footnote, line 1118`; `line 1119` | S5 of `⊡`; atom stability | footnote lines 1159, 1161 |
| `Semantics/PlusLanguage/PlusTruth.lean` | 81 | `(paper line 1108)` | `⟨τ⟩_t` | line 1153 |
| `Semantics/PlusLanguage/PlusTruth.lean` | 163 | `paper line 1121` | `⟐φ` | line 1163 |
| `Semantics/PlusLanguage/PlusTruth.lean` | 193 | `paper lines 1118-1119` | section banner | footnote lines 1159, 1161 |
| `Semantics/PlusLanguage/PlusTruth.lean` | 195 | `paper line 1108` | `⟨τ⟩_x ⊆ H_F` | line 1153 |
| `Semantics/PlusLanguage/PlusNonValidities.lean` | 25 | `paper line 1426` | *Determined* | line 1517 (**not found by the dispatch's example set**) |
| `Semantics/PlusLanguage/PlusNonValidities.lean` | 52 | `JPL paper line 1426` | *Determined* | line 1517 |
| `Semantics/PlusLanguage/PlusStateLocal.lean` | 123 | `footnote (line 1119)` | atom-level `p → ⊡p` | footnote line 1161 (**not found by the dispatch's example set**) |
| `Semantics/PlusLanguage/PlusStateLocal.lean` | 361 | `footnote, line 1119` | atom-level `p → ⊡p` | footnote line 1161 |
| `Semantics/PlusLanguage/PlusStateLocal.lean` | 380 | `line 1119` | atom-level `p → ⊡p` | footnote line 1161 |
| `Semantics/PlusLanguage/PlusStateLocal.lean` | 402 | `footnote at line 1119` | atom-level `p → ⊡p` | footnote line 1161 |

**`Syntax/StarLanguage/` and `Semantics/StarLanguage/` have zero hits** for the same grep pattern,
and zero hits for the specific stale line numbers (1108, 1118, 1119, 1121, 1125, 1126, 1128, 1129,
1155, 1158, 1161, 1426) — the drift is entirely confined to the L⁺ (PlusLanguage) tree.
`FormalSystem/Syntax/StarLanguage/README.md`'s own correspondence table already cites everything
by `\label{}` only (its own header states this convention explicitly, line 106: "Anchors are
cited by `\label` only, never by line number").

**Recommended replacement idiom.** Since none of `⟨τ⟩_x`'s definition, the S5-of-`⊡` footnote, the
atom-stability footnote clause, the dual `⟐`, or `Will`/`will`/`Could`/`could` carry their own
`\label{}` (only the enclosing `def:BLstar-semantics` appendix block and the
`\label{sub:RestrictedModalities}` subsection do), the dispatch's own suggested idiom applies
directly: cite `def:BLstar-semantics` (whose Stability clause is word-for-word identical, per
Finding 2) plus a quotable phrase, e.g. `def:BLstar-semantics`'s `($\Stability$)` clause, "the
footnote to the Stability clause", "the monomodal logic of `⊡` is S5" (quoted phrase from the
footnote), or "subsection Restricted Modalities" for section-level pointers. For *Determined*
(Finding 4, no label at all), the correct idiom is a quoted/named reference: "the manuscript's
*Determined* schema (`φ → ⊡φ`, subsection Open Future)" — never a line number, since none is
stable and none exists to `\label{}`.

### 2. The Stability clause: verified word-for-word identical at both manuscript sites

Manuscript line 1155, subsection *Restricted Modalities* (`\label{sub:RestrictedModalities}` at
line 1144):
```
\item[($\Stability$)] $\M,\tau,x \vDash \Stability \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in \braket{\tau}_x$.
```

Manuscript line 3549, inside `def:BLstar-semantics` (`\label{def:BLstar-semantics}` at line 3544,
block spans 3544–3554):
```
\item[($\Stability$)] $\M,\tau,x,\vec{v} \vDash \Stability\varphi$ \textit{iff} $\M,\sigma,x,\vec{v} \vDash \varphi$ for all $\sigma \in \braket{\tau}_x$.
```

The only difference is the appendix block's `\vec{v}` register-vector parameter, added uniformly
to every point of evaluation in that block (the register vector is otherwise omitted "when no
store or recall operator occurs", per the block's own preamble at line 3546) — the quantifier, the
domain `⟨τ⟩_x`, and the biconditional shape are identical. This confirms the dispatch's claim
(sourced to `specs/559_.../reports/04_semantics-first-task-frames.md` §3.2, items 3–4) and the
Lean-side claim that `StarTruthAt`'s `stab` clause passes `v` unchanged to `σ`:
```
FormalSystem/Semantics/StarLanguage/StarTruth.lean:121
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t → StarTruthAt M σ t v φ
```
`v` (the register vector, four parameters after `M`) appears on both sides of the arrow unchanged
— exactly the manuscript's `\vec{v} \vDash \Stability\varphi ... M,\sigma,x,\vec{v} \vDash \varphi`.
**The `paper-definitions-of-record.md` note that "the clause is quoted in this repository only in
paraphrase" is now false** — `PlusTruth.lean` and `StarTruth.lean` both state the clause as
direct Lean transcriptions, and the docstrings (once re-cited by label rather than by stale line
number) quote the associated phrase directly.

### 3. The `stab_4` constructor and the commented-out `def:TM-stability`

`stab_4` is at `FormalSystem/Syntax/PlusLanguage/Axioms.lean:288-290`:
```lean
  /-- S4: `⊡φ → ⊡⊡φ` (paper footnote, line 1118); `Semantics.stab_four`. -/
  | stab_4 (φ : PlusFormula) :
      PlusAxiom ((PlusFormula.stab φ).imp (PlusFormula.stab (PlusFormula.stab φ)))
```

The manuscript's `def:TM-stability` block is commented out at lines 3772–3794, with an explicit
editorial note at line 3772-3774: "`def:TM-stability`, `cor:deterministic-completeness`, and
`rmk:deterministic-completeness` are commented out as too much for this paper; the result is now
cited from footnotes that point to the Lean 4 repository, which includes it." Its schema list
(lines 3782–3789) is exactly:
```
SK, ST, S5, MS, AS, PS, US
```
— seven schemata, keyed by `\aitem`. **There is no S4-shaped schema** (`⊡φ → ⊡⊡φ`) among them.
This confirms the dispatch's instruction verbatim: `stab_4` is surplus to (not required by)
`def:TM-stability`, and is standardly derivable from the S5 axiom together with ST (in monomodal
normal modal logic, **4** follows from **5** and **T**: `⊡φ → φ` gives `¬⊡φ → ¬φ`, and `5`
(`¬⊡¬φ→⊡¬⊡¬φ`, i.e. the diamond-form here) with substitution `φ := ¬φ` composed with `T` yields
`4`). The dispatch's phrasing "derivable from SK, ST and the S5 schema" matches this standard
derivation route (SK for the necessitation/modus-ponens machinery inside the derivation, ST for T,
S5 (`stab_5`) for 5).

**Recommended docstring addition** (dispatch item 3; exact wording is an implementation-phase
decision, not fixed here, but the factual content to state is): `stab_4` is not itself a schema of
the manuscript's commented-out `def:TM-stability` (which lists SK, ST, S5, MS, AS, PS, US); it is
derivable from SK, ST and S5 (standard monomodal S5: 4 follows from 5 and T) and is kept as a
primitive TM⁺ constructor for convenience. This must say nothing stronger (no claim that TM⁺
would be unsound or incomplete without it, no claim about which downstream proofs would need
re-deriving it) and must not remove the constructor — both explicit dispatch constraints.

### 4. The `def:BLstar-semantics` pin: verbatim text, hash, and manifest-row mechanics

`scripts/check-paper-definitions.sh --resolve "def:BLstar-semantics|env|-|-"` (the sanctioned
procedure per `paper-definitions-of-record.md`'s "How to extend this record" §, step 2) resolves
against the **live working tree** manuscript and returns:

```
sha256:   b4d3239cc96ddd1e90965901aca8c378f6ec5ca52f568ea6b2ef59d9c3ba6c95
text:
  \begin{Ddef} \label{def:BLstar-semantics}
  	For a task frame $\F = \tuple{W, \D, \Rightarrow}$, possible world $\tau \in H_{\F}$, and time $x \in D$, let $\braket{\tau}_x \coloneq \set{\sigma \in H_{\F} \mid \sigma(x) = \tau(x)}$ be the set of possible worlds that intersect $\tau$ at $x$.
  	Adding a vector $\vec{v} = \tuple{v_1, v_2, \ldots}$ of stored times to the point of evaluation, the clauses of \textbf{\ref{def:BL-semantics}} are unchanged and $\vec{v}$ may be omitted when no store or recall operator occurs.
  	Since $\worldStore^i$ and $\worldRecall^i$ do not occur below, the vector $\vec{\mu}$ of stored worlds from \textbf{\S\ref{sub:Extension}} may likewise be suppressed throughout, where the remaining operators are interpreted by:
  	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
  		\item[($\Stability$)] $\M,\tau,x,\vec{v} \vDash \Stability\varphi$ \textit{iff} $\M,\sigma,x,\vec{v} \vDash \varphi$ for all $\sigma \in \braket{\tau}_x$.
  		\item[(\hspace{.6pt}$\timeStore$\hspace{.6pt})] $\M,\tau,x,\vec{v} \vDash \timeStore^i\varphi$ \textit{iff} $\M,\tau,x,\vec{v}_{[x/v_i]} \vDash \varphi$.
  		\item[(\hspace{.6pt}$\timeRecall$\hspace{.6pt})] $\M,\tau,x,\vec{v} \vDash \timeRecall^i\varphi$ \textit{iff} $\M,\tau,v_i,\vec{v} \vDash \varphi$.
  	\end{enumerate}
    \vspace{-.1in}
  \end{Ddef}
```

This is a full `env`-kind anchor (whole `\begin{Ddef}...\end{Ddef}` block, per the file's own
Hashing Method §), matching the row format used for `def:deterministic` and `def:BL-semantics`.

**`check-paper-definitions.sh` with no arguments currently reports case (b)**: "possible_worlds.tex
changed ... but all 42 recorded definitions are unchanged — pass." Adding `def:BLstar-semantics`
is therefore a **coverage extension** (a previously-unpinned anchor being pinned for the first
time), not a drift correction of an already-pinned anchor. The file's own documented convention
for this exact situation — recorded at line 41, the 2026-08-13 `FormalFoundations.typ` coverage
extension of 22 new anchors — is: **the whole-file `FILE_CHECKSUM`/`PINNED_COMMIT` sentinels are
deliberately NOT re-pinned on a coverage extension**, only on a drift *correction*; "bumping the
pin on every append would make the sentinel a diary of touch-events rather than a record of drift
corrections." The implementer should follow this precedent: add the manifest row and the `###`
prose entry, but leave the `<!-- FILE_CHECKSUM -->` / `<!-- PINNED_COMMIT -->` /
`<!-- LINE_COUNT -->` sentinels (currently `b4e45e2c...`/`a166fcbf...`/`4529`, lines 58–60)
untouched, and add a short "Coverage extension (2026-09-20): `def:BLstar-semantics` pinned" prose
subsection following the existing precedent's shape (see lines 41, 761, 783, 800 for the three
existing "Coverage extension" precedent sections). After adding the row, re-run
`check-paper-definitions.sh` with no arguments and confirm it still reports case (b)/(a) — never a
failure — per step 4 of "How to extend this record."

**Manifest row to add** (append to the `<!-- MANIFEST:BEGIN -->` fence, `docs/reference/paper-definitions-of-record.md:1951-1996`):
```
def:BLstar-semantics|env|-|-|b4d3239cc96ddd1e90965901aca8c378f6ec5ca52f568ea6b2ef59d9c3ba6c95
```

**Insertion point for the prose `###` entry**: paper order places `def:BLstar-semantics` (line
3544) immediately after `def:deterministic` (line 3537) and before `lem:deterministic-singleton`
(line 3559, already recorded as `LIVE-UNPINNED`, not in this task's scope) and before
`cor:saturation-finite`/`cor:tm-completeness`. The existing `### \`def:deterministic\`` entry
(`paper-definitions-of-record.md:1690-1702`) is the natural predecessor to insert after, matching
the file's paper-order-by-and-large convention observed across every other `###` entry.

**KNOWN-ANCHORS row removal**: `def:BLstar-semantics` currently has a `LIVE-UNPINNED` row at
`paper-definitions-of-record.md:2033` inside the `<!-- KNOWN-ANCHORS:BEGIN -->` fence (lines
2019-2060). That section is explicitly for anchors *outside* the manifest — pinning the anchor
means this row must be **removed** (not merely edited), since the anchor moves from
"known-but-unpinned" to "pinned in the manifest." The dispatch's instruction to "update its
KNOWN-ANCHORS row" is most naturally satisfied by this removal, carrying forward into the new
`###` entry's prose the substantive content the row currently records (word-for-word from line
2033): the time-register half is implemented as `StarTruthAt` (`Semantics/StarLanguage/StarTruth.lean`),
world registers `up_M`/`down_M` are "deliberately still unimplemented", and that exclusion is
"recorded as an explicit exclusion in `FormalSystem/Syntax/StarLanguage/README.md`'s
correspondence table" — this is the "keep the recorded exclusion of the world registers"
constraint from the dispatch, satisfied by carrying this sentence into the new entry rather than
dropping it.

### 5. StarLanguage correspondence table: existing world-register exclusion row and the missing Restricted-Modalities row

`FormalSystem/Syntax/StarLanguage/README.md:111` already carries:
```
| `def:BLstar-semantics` (world registers `↑_M`, `↓_M`) | — | **Excluded**: world registers are suppressed on the main path, exactly as the deterministic-frame appendix suppresses them. A single-world-register `Det-m` was declared optional at plan time and is not built |
```

No row records the **other three** manuscript-only operators the dispatch's item (4) asks for:
*Open Futures* (`\ket{\tau}_x`, manuscript line 1182), *Open Pasts* (`\bra{\tau}_x`, line 1183),
and *Nomic* necessity (`\Nomic`, the four-place task relation, lines 1201–1207) — all defined in
the same *Restricted Modalities* subsection (lines 1143–1210) as `Stability`, and all explicitly
disclaimed by the manuscript itself at line 1210: "Since the present aim is to develop a bimodal
logic for tense and metaphysical modality, I will omit further consideration of the restricted
modals `Stability, Openfuture, Openpast`, and `Nomic`." This is directly the "manuscript operators
without a formalization here" the dispatch asks to record.

**Constraint reminder (already satisfied by this report and to be carried into the
implementation)**: task 625 formalizes the first two of these (open-future, open-past). Per the
dispatch's explicit instruction — "do not reference its number in any file outside specs/" — and
per this repository's `no-task-references-in-deliverables.md` rule (task numbers are permitted
only inside `specs/**`, git commit messages, and PR metadata), the new README.md row must say
something like "a separate task formalizes the open-future and open-past operators" with **no
task number**, since `FormalSystem/Syntax/StarLanguage/README.md` is outside `specs/`. This report
itself (inside `specs/`) is the correct — and only — place to name task 625 explicitly, which is
why the paragraph above does so.

### 6. Build/gate verification commands (for the implementation phase)

- **C15 anchor gate**: `bash scripts/check-module-invariants.sh` (the C15 check is one of many
  checks this script runs; it walks every `def:`/`thm:`/`lem:`/`cor:`/`app:`/`rmk:` citation in
  live, non-`specs/`, non-`Boneyard/` scope and confirms it resolves against
  `docs/reference/paper-definitions-of-record.md`, either the manifest or the KNOWN-ANCHORS list).
  Since `def:BLstar-semantics` is already resolvable today (via its KNOWN-ANCHORS row) and will
  remain resolvable after moving into the manifest, this check should pass both before and after
  the edit; it is the correctness gate for citation-repair work of this shape.
- **Scoped guarded build**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --
  <Module.Name>`, detached, per the dispatch's constraint. The five touched Lean modules are:
  `FormalSystem.Syntax.PlusLanguage.Axioms`, `FormalSystem.Syntax.PlusLanguage.Formula`,
  `FormalSystem.Semantics.PlusLanguage.PlusTruth`,
  `FormalSystem.Semantics.PlusLanguage.PlusNonValidities`,
  `FormalSystem.Semantics.PlusLanguage.PlusStateLocal`. Since all edits are docstring-only (no
  declaration, statement, or proof changes, per the dispatch's own constraint), any one of these
  modules pulling in the others through the import graph makes a single top-level scoped build
  (e.g. `PlusStateLocal`, which imports `PlusTruth` which imports `Formula`; `Axioms` and
  `PlusNonValidities` are siblings reachable via the aggregator) sufficient to catch a malformed
  doc-comment syntax error across all five; the safest single invocation is the aggregator
  `FormalSystem.Semantics.PlusLanguage` if one exists, else each of the five modules individually.

## Decisions

- Cite `def:BLstar-semantics` (the appendix, `\label`-bearing block) plus a quoted phrase for every
  site currently citing a bare manuscript line number, since none of the specific clauses
  (`⟨τ⟩_x`'s definition, the S5 footnote, the atom-stability footnote sentence, the dual `⟐`, or
  `Will`/`will`/`Could`/`could`) carries its own `\label{}` — this is the only anchor available for
  those sites, matching the dispatch's own suggested idiom.
- For *Determined* (`PlusNonValidities.lean:25,52`), cite by name/quoted phrase only — it has no
  `\label{}` in the manuscript and is under a different subsection (*Open Future*, not *Restricted
  Modalities*) than the dispatch's framing might suggest; this is new information this report
  contributes.
- Follow the file's own documented "coverage extension does not re-pin the whole-file sentinel"
  convention when pinning `def:BLstar-semantics` — do not bump `FILE_CHECKSUM`/`PINNED_COMMIT`.
- Satisfy "keep the recorded exclusion of the world registers" by carrying the KNOWN-ANCHORS row's
  substantive content forward into the new `###` entry's prose, rather than by leaving the
  KNOWN-ANCHORS row in place (which would leave the anchor listed in two places at once,
  contradicting the KNOWN-ANCHORS section's own "outside the manifest" scope).

## Risks & Mitigations

- **Risk**: an implementer re-derives citation replacements independently and re-discovers a
  subset of the 15 sites, missing the 7 sites in `PlusNonValidities.lean`/`PlusStateLocal.lean`
  the dispatch's example set does not name. **Mitigation**: the full inventory table in Finding 1
  is exhaustive (verified by grep across all four named directories with zero hits outside
  `PlusLanguage/`); the plan should enumerate all 15 explicitly rather than re-grep.
- **Risk**: bumping `FILE_CHECKSUM`/`PINNED_COMMIT` on this coverage extension, contradicting the
  file's own documented precedent and creating spurious future drift-detection noise.
  **Mitigation**: Finding 4 names the precedent and the exact sentinel lines (58–60) to leave
  untouched.
- **Risk**: leaving the `LIVE-UNPINNED` KNOWN-ANCHORS row for `def:BLstar-semantics` in place after
  pinning, producing a self-contradictory record (both pinned and "known outside the manifest").
  **Mitigation**: Finding 4 states the row must be removed, with its substantive content carried
  into the new manifest entry's prose.
- **Risk**: referencing task 625's number in `FormalSystem/Syntax/StarLanguage/README.md` (outside
  `specs/`), violating both the dispatch's explicit instruction and
  `.claude/rules/no-task-references-in-deliverables.md`. **Mitigation**: Finding 5 states the
  exact number-free phrasing to use in that file.

## Context Extension Recommendations

None. The existing `paper-definitions-of-record.md` conventions (Hashing Method, coverage-extension
precedent, KNOWN-ANCHORS/manifest split) already cover everything this task needs; no new context
file is warranted.

## Appendix

### Search queries / commands used

```
grep -n "paper line\|line [0-9]\{3,\}\|footnote, line\|manuscript.*line" FormalSystem/Syntax/PlusLanguage/Axioms.lean
grep -rn "paper line\|paper lines\|line [0-9]\{3,\}\|footnote, line" FormalSystem/Syntax/PlusLanguage FormalSystem/Semantics/PlusLanguage FormalSystem/Syntax/StarLanguage FormalSystem/Semantics/StarLanguage
grep -rn "line [0-9]\|lines [0-9]\|paper line\|footnote.*line\|1108\|1118\|1119\|1121\|1125\|1126\|1128\|1129\|1155\|1158\|1161\|1426" FormalSystem/Syntax/StarLanguage FormalSystem/Semantics/StarLanguage
grep -n "BLstar-semantics\|def:BLstar" /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex
grep -n "Restricted Modalities\|Determined\\\\b" /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex
grep -n "stab_4" FormalSystem/
grep -n "TM-stability\|TM-stab" /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex
bash scripts/check-paper-definitions.sh --resolve "def:BLstar-semantics|env|-|-"
bash scripts/check-paper-definitions.sh
```

### References

- Manuscript subsection *Restricted Modalities*: `\label{sub:RestrictedModalities}`,
  `possible_worlds.tex:1143-1210`
- Manuscript subsection *Open Future*: `\label{sub:OpenFuture}`, `possible_worlds.tex:1501` ff.,
  *Determined* schema at line 1517
- Manuscript appendix `def:BLstar-semantics`: `possible_worlds.tex:3544-3554`
- Manuscript commented-out `def:TM-stability`: `possible_worlds.tex:3772-3794`
- `docs/reference/paper-definitions-of-record.md`: Hashing Method (lines 856-877), How to Extend
  This Record (1933-1943), Machine-readable manifest (1944-1997), `def:deterministic` entry
  (1690-1702, insertion precedent), coverage-extension precedent (line 41), KNOWN-ANCHORS
  `def:BLstar-semantics` row (line 2033)
- `FormalSystem/Syntax/StarLanguage/README.md`: correspondence table (103-133), world-register
  exclusion row (111)
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/04_semantics-first-task-frames.md`
  §3.2 (word-for-word verification source cited by the dispatch)
