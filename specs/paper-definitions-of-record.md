# Paper Definitions of Record

This file is the pinned, verbatim record of the semantic definitions that this repository
depends on from the JPL paper (`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`).
The paper is **read-only input** to this repository: it is never edited from here, and this file
never restates, re-derives, or "improves" any definition it records — it only quotes what the
paper currently says and detects when that text moves.

**Specs and task descriptions in this repository should cite this file, not the paper directly.**
Citing the paper by bare line number has repeatedly gone stale (the paper moved through five
definitional waves between 2026-08-08 and 2026-08-10, and a sixth wave landed on disk, uncommitted,
while this very file was being authored — see "Recording provenance" below). Anchors here are
resolved by `\label{}` name or `\aitem{}` key, never by line number, and `scripts/check-paper-definitions.sh`
re-derives every hash below directly from the live paper file on every run.

## Recording provenance

| Field | Value |
|---|---|
| Paper file | `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` |
| Paper git repo root | `/home/benjamin/Philosophy/Papers/PossibleWorlds` |
| File path relative to repo root | `JPL/possible_worlds.tex` |
| Base commit (`git HEAD` at recording time) | `eb5be99ea3f19a86c9891d7798e619890e36cd43` |
| **File checksum at recording time (sha256, authoritative pin)** | `efe6fc74688aa5ee89b91957b3681771cdcbdfaacb6077040024c395c568cbbd` |
| Line count at recording time | 3988 |
| Recorded (UTC) | 2026-08-10T23:56:47Z |
| File checksum, re-pinned after drift correction (sha256) | `485aa76449488f4c5ee75b001da68796a5d51ecd6ea448fd8e8e6587e1211a95` |
| Line count, re-pinned after drift correction | 3999 |
| Re-pinned (UTC) | 2026-08-11T00:25:00Z |
| File checksum, re-pinned at coverage extension (sha256) | `1256e21837ff81139fda69e9faa14ac756b1f795df32c78b82d885af5055374f` |
| Line count at coverage extension | 3949 |
| Coverage extension re-pin (UTC) | 2026-08-11T01:16:05Z (checksum re-taken at 01:25Z after two further live case-(b) waves during the extension itself) |
| Base commit at `BL^+` coverage extension (paper repo `git HEAD`; file dirty against it) | `cf0da976bd7947e6fae2aa9212953d094faab2c1` |
| File checksum, re-pinned at `BL^+` coverage extension (sha256) | `f07441ebb9751d1e955d5af135bebc107ef7163dea49ccfb29b763aae67d1b27` |
| Line count at `BL^+` coverage extension | 4098 |
| `BL^+` coverage extension re-pin (UTC) | 2026-08-10 (three `def:BLplus-*` anchors added; the run immediately before the re-pin reported case (b) — paper moved, all 23 previously-recorded definitions unchanged) |
| Base commit at three-anchor drift correction (paper repo `git HEAD`; file dirty against it) | `f56cdea0237d102edbb9c64dcef7617d8d2cbc3e` |
| **File checksum, re-pinned at three-anchor drift correction (sha256, current authoritative pin)** | `76406e77cb3936c38b306bf7c4b9272f2c96bb164e7d04dc263650239746276e` |
| Line count at three-anchor drift correction | 4290 |
| Three-anchor drift correction re-pin (UTC) | 2026-08-12T22:55Z (`thm:extension`, `def:constraints`, `def:BLplus-semantics` re-quoted and re-hashed together in one correction; see "Drift correction (2026-08-12)" below) |
| Coverage extension for `typst/FormalFoundations.typ` (22 new anchors: `def:S5`, `def:BX`, `def:TMplus`, `def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`, `thm:M5-valid`, `thm:TM-soundness`, `app:discrete`, `app:dense`, `app:complete`, `def:frame-properties`, `cor:spherical-finite`, `cor:tm-completeness`, `cor:tm-decidability`, `def:id`, `def:strongest`, `thm:exist`, `lem:uniq`, `thm:s4`, `thm:sym`, plus the already-tracked `CO`/`TMP-CO` pair) | `bash scripts/check-paper-definitions.sh` reported case (b) before this extension (paper checksum moved again since the 2026-08-12 three-anchor correction, but all 26 previously-tracked definitions unchanged) and case (b) again after (checksum `0584125456bdd3728eeaf671280ac8c6f6f2afeabf55761378e0c08a5706c9d9`, all 47 recorded definitions unchanged) — no drift on any newly- or previously-tracked anchor. The whole-file checksum sentinels above are deliberately **not** re-pinned to this new checksum: per the dirty-pin convention this file already documents, a re-pin is warranted only when a drift *correction* is absorbed, not on every case-(b) coverage extension: bumping the pin on every append would make the sentinel a diary of touch-events rather than a record of drift corrections. Re-run (UTC) 2026-08-13. |

<!-- PAPER_PATH: /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex -->
<!-- PAPER_REPO_ROOT: /home/benjamin/Philosophy/Papers/PossibleWorlds -->
<!-- PINNED_COMMIT: f56cdea0237d102edbb9c64dcef7617d8d2cbc3e -->
<!-- FILE_CHECKSUM: 76406e77cb3936c38b306bf7c4b9272f2c96bb164e7d04dc263650239746276e -->
<!-- LINE_COUNT: 4290 -->

### Dirty-pin caveat (why the pin is a checksum, not a clean commit)

At the moment this file was authored, the paper's working tree was **dirty relative to its own
git HEAD**: `git status --porcelain` reported `M possible_worlds.tex` against base commit
`eb5be99e` (`git diff --stat HEAD` showed 32 insertions / 12 deletions, net +12 lines). This is a
live instance of the exact failure mode this file exists to guard against — a sixth definitional
wave landing while this task was in flight — and it is recorded here rather than papered over.

The dirty edit was independently confirmed, by re-deriving every hash below **both** before and
after the edit landed, to be **entirely confined to the `def:constraints` / `lem:constraint` /
`lem:admissible` proof-machinery neighborhood** (it restructured that proof and split out a new
`lem:fibers` lemma) — a region deliberately **not** in this file's coverage (see "Deliberately
not covered" below). Every anchor tracked in the manifest hashed identically before and after.
This is exactly **case (b)** from `check-paper-definitions.sh`'s three-outcome contract: the paper
changed, but no recorded definition drifted.

Because the working tree was dirty and no clean commit captured the exact content this file
quotes, the **file checksum** above (not the commit SHA) is the authoritative pin. The commit SHA
is recorded as the best-available provenance anchor (the base the dirty edit was made against),
not as a claim that the quoted content is byte-identical to that commit's committed blob — it is
not (see the caveat's own diff above). Anyone citing this record should treat the checksum as
ground truth and the commit SHA as "approximately where in history this sits."

### Drift correction (2026-08-11, found during independent verification)

The paper's dirty working tree moved **again** while this record was being independently
verified — a live wave, on top of the wave described in the caveat above, occurring in real time
during the verification pass rather than between authoring and verification. Two successive
checksum changes were observed during verification (`efe6fc74...` recording-time →
`645018ae...` mid-verification → `485aa764...`, the final, since-stable state this record is now
re-pinned to). This is exactly the phenomenon this infrastructure exists to catch, and it is
recorded here rather than silently re-pinned without explanation.

Unlike the caveat's original dirty edit (confined to the excluded `def:constraints` neighborhood,
case (b), no tracked anchor affected), **this wave genuinely drifted a tracked anchor**: the paper
renamed `\label{thm:occurrence}` to `\label{cor:occurrence}` and merged its statement with a
separate corollary formerly labelled `app:nonempty` (per the paper's own `%% CHANGE
(occurrence-nonempty-merged)` editorial comment at the site), producing a strictly stronger
statement — the evaluation time `x` is now universally given rather than merely existentially
witnessed. `thm:extension`'s footnote, which cross-references the anchor by name, changed
correspondingly (`\ref{thm:occurrence}` → `\ref{cor:occurrence}`), so both anchors' recorded text
and hash were updated. This is case (c) — genuine drift — correctly caught by
`check-paper-definitions.sh` against the live paper, not a false positive.

**Correction applied**: the `thm:occurrence` entry above is renamed to `cor:occurrence` with its
current verbatim text and freshly-derived hash; `thm:extension`'s entry is re-hashed to match its
updated footnote; the manifest below reflects both changes; the file checksum and line count in
the provenance table above are re-pinned to the post-correction live state. No other tracked
anchor was affected by this wave (confirmed by re-running the full lint after this correction —
see the implementation summary for the verbatim re-run output).

**Known consequence of this correction**: `check-paper-definitions.sh --against eb5be99e...`
(the recorded base commit) will now report `thm:extension`/`cor:occurrence` as drifted/dangling,
because the rename is an uncommitted edit in the paper's working tree that postdates the base
commit — the base commit still has the pre-rename `thm:occurrence` text. This is expected, not a
lint defect: the checksum (re-pinned above), not the base commit, is this record's authoritative
pin, exactly per the dirty-pin caveat's own logic. The no-argument invocation against the live
paper — the check this lint exists to run day to day — passes cleanly (case a) as of this
correction.

### Drift correction (2026-08-12): the three-anchor wave, absorbed as one re-pin

A further live wave drifted **three** tracked anchors at once — `def:BLplus-semantics`,
`thm:extension`, and `def:constraints` — and the gate reported case (c) against all three. All
three are corrected here **together, in a single coherent correction with one whole-file
re-pin**. This is deliberate and is the lesson of the two earlier corrections above: because the
authoritative pin is a **whole-file** checksum, correcting one drifted anchor while leaving the
others uncorrected re-pins the file to a state the record does not fully quote, which is
incoherent — the checksum would then assert "the record matches this file" while two entries
still quoted superseded text. A drift wave is absorbed as a unit or not at all.

What moved, per anchor (each re-quoted verbatim above, each hash re-derived from the live paper
by the same extraction the lint performs, and each re-derivation confirmed against the hash the
lint itself reported for the live text):

- **`def:BLplus-semantics`** (`3f56a996…` → `f40f514e…`): the argument-order footnote was
  **repaired by the paper**, per its own `%% CHANGE (halden-defect-repair,
  untl-snce-convention)` comment at the site. The footnote previously attributed a guard-first
  Pnueli convention to this repository's `snce`/`untl` constructors; it now states the mismatch
  in the direction that actually holds (paper surface notation guard-first, repository
  constructors event-first/Burgess), and adds that the truth conditions agree once the argument
  order is swapped. **The two `($\since$)` / `($\until$)` truth clauses themselves are unchanged
  byte-for-byte** — no semantic claim moved. This resolves, in the paper, the divergence this
  record escalated in `specs/decisions/untl-snce-argument-order.md`; the caveat under that entry
  is rewritten below to describe the repaired footnote rather than the old defective one.
- **`thm:extension`** (`af9b23bf…` → `e63eac74…`): statement unchanged; the footnote's existing
  choice-contrast clause was extended to also name the finite-`W` case discharged choice-free by
  a new corollary (paper comment `%% CHANGE (finite-spherical-corollary)`). See the residual gap
  below.
- **`def:constraints`** (`d763818…` → `3678ab02…`): two changes, both narrowing/wording rather
  than restructuring. The defined term is now "the *constraints on `z`*" (formerly "the
  *constraints imposed on `z`*"), and the segment case gained an explicit "when both `t,s ∈ X`"
  guard on the `t < z < s` condition. The constraint family itself — segments between bracketing
  times, fibers otherwise — is the same family.

**Known residual gap — DISCHARGED (see "Coverage extension (2026-08-17)" below).** The same wave
added three anchors this record did **not** track at all: `cor:spherical-finite` (finite `W`
satisfies *Spherical*, choice-free), `lem:nesting` (imposed fibers and segments nest along the time
order), and `lem:nonempty` (every imposed constraint is nonempty). The gap they left was concrete:
**`thm:extension`'s re-quoted footnote cites `\ref{cor:spherical-finite}`**, so while that anchor
was untracked a tracked entry referenced an untracked one, and a future rename or restatement of
`cor:spherical-finite` would have silently invalidated the cross-reference inside `thm:extension`'s
recorded text without the lint saying anything. All three are now tracked and the gap is closed;
the paragraph is retained rather than deleted so the reasoning that closed it stays legible.

### Coverage extension (2026-08-17): the three constraint-neighborhood anchors

`cor:spherical-finite`, `lem:nesting`, and `lem:nonempty` are now tracked, discharging the residual
gap recorded above. The semantic-FMP-over-ℤ work transcribes `cor:spherical-finite` verbatim as the
source for `TaskFrame.spherical_of_finite`, so leaving its central citation unprotected by the lint
was the immediate motivation; `lem:nesting` and `lem:nonempty` were added with it because they are
the other two members of the same untracked gap and sit in the same `def:constraints` →
`lem:constraint` → `lem:step` chain. `cor:spherical-finite` was resolved and added first, in
isolation, by the finite-frame discharge work; the two constraint lemmas followed. The record moves
from 47 to **49** tracked definitions.

**Lint state at this extension**: the paper has drifted again since the previous coverage
extension, and `scripts/check-paper-definitions.sh` reports **case (c)** — 19 recorded blocks
changed, and two recorded anchors (`def:BL-model`, `cor:tm-decidability`) no longer resolve at all.
That drift is *not* corrected here, and is recorded rather than absorbed: it predates this
extension, it spans anchors this extension does not touch, and re-quoting 19 blocks plus repairing
two dangling anchors is a paper-reconciliation pass in its own right rather than a side effect of
adding three rows. None of the three anchors added here is among the drifted set, and neither are
`def:frame`, `def:frame#Spherical`, `def:directed`, `def:task-relation`, `cor:occurrence`, or
`def:frame-properties`. The whole-file checksum sentinels are therefore **not** re-pinned, per the
dirty-pin convention above: no drift correction was absorbed.

### Coverage extension (2026-08-11): the extension-machinery anchors

The paper-refactor cluster's task descriptions quote the extension machinery (`lem:constraint`,
`lem:step`) directly, and two cluster tasks commit to mirroring the paper's proof decomposition
lemma-for-lemma. Per this file's own extension protocol, those anchors are now **tracked**, not
excluded: `def:constraints`, `lem:constraint`, `lem:fibers`, `lem:admissible`, and `lem:step`
(five entries, added below with hashes derived from the live paper). Note that a paper wave
restructured this neighborhood after the original recording: the admissibility characterization
was **split out** of the old Constraint Lemma into its own `lem:admissible`, warranted by the new
`lem:fibers`, and the lead-in prose was promoted to the numbered `def:constraints`. The current
chain is `def:constraints` → `lem:constraint` (directedness + nonemptiness only) → `lem:fibers`
→ `lem:admissible` → `lem:step` (sole *Spherical* application site) → `thm:extension` (Zorn) →
`cor:occurrence`. The file checksum in the provenance table above is re-pinned to the live state
these hashes were derived from; all 18 previously-recorded anchors were re-verified unchanged at
this re-pin (case (b) — the intervening edits were comment cleanup and proof-prose restructuring
outside every previously-tracked block).

### Coverage extension (2026-08-10): the `BL^+` anchors

`def:BLplus-semantics` was cited by the total-history-validity refactor's plan while being
**untracked** — `grep -c BLplus` over this file returned 0 — so any spec quoting it was ungrounded
and unprotected by the lint. Three anchors are now tracked: `def:BLplus-language` (the `BL^+`
language and its `\since`/`\until` constructors), `def:BLplus-semantics` (the two extra truth
clauses, plus the constructor-argument-order footnote), and `def:BLplus-defined` (the derived
temporal operators). All three resolved cleanly, so none is recorded as a gap. The record moves
from 23 to **26** tracked definitions.

The `def:BLplus-semantics` entry carried an argument-order caveat: at the time of this coverage
extension the paper's footnote described this repository's `snce`/`untl` constructors as
guard-first/event-second, while the Lean tree is event-first/guard-second. That divergence was
quoted here (never silently corrected — this file records what the paper says) and escalated in
`specs/decisions/untl-snce-argument-order.md`. **Superseded 2026-08-12**: the paper has since
repaired the footnote in the direction that actually holds; see "Drift correction (2026-08-12)"
above and the rewritten caveat under the entry itself.

## How to read this file

Each entry below has:
- **Anchor**: the `\label{}` name, or (for axioms introduced via the paper's `\aitem` macro) the
  `\aitem` key together with its enclosing section.
- **Verbatim text**: the exact LaTeX source of the defining block, quoted character-for-character
  (including the block's own `%%` editorial-history comments where present — those are literal
  source text and are quoted, not stripped, so the record and the hash always agree).
- **Content hash**: `sha256` of exactly the quoted text (see "Hashing method" below).

Anchors marked **DERIVED** are theorems/lemmas proved from the primitive definitions, not
definitions themselves — recorded here because downstream tasks cite their exact statements as
settled inputs, same as a definition.

### Hashing method (must match `check-paper-definitions.sh` exactly)

- **`env` anchors** (a `\label{X}` on the same line as `\begin{ENV}`, e.g. `\begin{Ddef} \label{def:frame}`):
  the hash covers every line from that `\begin{ENV}` line (inclusive) through the next line
  containing the literal string `\end{ENV}` (inclusive) — i.e. the whole definition/theorem
  environment, including any editorial `%%` comment lines inside it.
- **`item` anchors** (one of `def:frame`'s four axioms, which are `\item[\it NAME:]` entries with
  no `\label` of their own): the enclosing environment is resolved first as above, then the hash
  covers exactly the single line inside that block matching `\item[\it NAME:]`.
- **`aitem` anchors** (an axiom introduced via the paper's `\newcommand{\aitem}[2][]{...\label{#2}}`
  macro, e.g. `\aitem{CO}` or `\aitem[CO]{TMP-CO}`): the hash covers exactly the single line
  matching `\aitem` (optionally `[KEY]`) `{LABEL}`.

This assumes none of the tracked environments nest another instance of the same environment name
inside itself (true for every entry below, verified at recording time) — the extraction takes the
*first* matching `\end{ENV}` after the label line.

---

## Entries

### `def:temporal-order` — temporal order, positive cone, nontrivial `D`

```latex
\begin{Ddef} \label{def:temporal-order}
	A \textit{temporal order} is a nontrivial totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$ with \textit{positive cone} $D^+ \coloneq \set{x \in D : x \geq 0}$.
\end{Ddef}
```
sha256: `bc89eea5f9bafa1e326bc8bda93b6631c49212c1f0c3253208f0cfbdb049fb1f`

### `def:task-relation` — task relation, nonempty `W`, converse convention, fiber, cone, segment

```latex
\begin{Ddef} \label{def:task-relation}
	A \textit{task relation} on a nonempty set of \textit{world states} $W$ over a temporal order $\D$ is any parameterized relation $w \Rightarrow_x u$ for $w,u \in W$ and $x \in D^+$, extended to negative durations by the \textit{converse convention} $w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$ for $x \geq 0$, determining the following for any world states $w, v \in W$ and durations $x, y \in D$:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\it Fiber:] $\Fib(w, x) \coloneq \set{u \in W : w \Rightarrow_x u}$.
		\item[\it Cone:] $(w)_x \coloneq \bigcup\limits_{\vert{y} < x} \Fib(w, y)$ where $x > 0$.
		\item[\it Segment:] $[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)$ where $x, y \geq 0$.
	\end{enumerate}
  \vspace{-.15in}
\end{Ddef}
```
sha256: `b63a34aa6a9f64e5e18df88de658530739caa0561755e694d6cd4b983eeb267b`

### `def:directed` — directed family (used by Spherical)

```latex
\begin{Ddef} \label{def:directed}
	A nonempty family of sets $\mathcal{S}$ is \textit{directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.
\end{Ddef}
```
sha256: `ef9852efbe0e53cc226423bd2c9d5da0decba54cde07bd7f91f1e06515c97d20`

### `def:frame` — the frame definition (whole block, all four axioms)

```latex
\begin{Ddef} \label{def:frame}
	A \textit{frame} is any $\F = \tuple{W, \D, \Rightarrow}$ where $W$ is a nonempty set of world states, $\D$ is a temporal order, and $\Rightarrow$ is a task relation satisfying the following for $x, y \geq 0$:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.
		\item[\it Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.
		\item[\it Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.
		\item[\it Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments.
    % \footnote{
    %   Spherical is the directed-intersection condition $\mathbf{S}_1^d$ in the theory of ball spaces~\cite{Cmiel2021}.
    % }
	\end{enumerate}
  \vspace{-.15in}
\end{Ddef}
```
sha256: `944879579f6b176390b9622db9c9cdfa52f07bc3f8244bd3f01dac1f77ca6926`

Four axioms, not more, not fewer — **Nullity is NOT an axiom**, it is `lem:nullity` below, DERIVED
from Seriality and Limit. Each axiom is also tracked individually (sub-anchors of `def:frame`, no
`\label` of their own — resolved as the enclosing block's `\item[\it NAME:]` line), so that a
future paper edit which reorders or drops exactly one axiom is named precisely rather than only
flagging "`def:frame` changed":

| Sub-anchor | Verbatim text | sha256 |
|---|---|---|
| `def:frame#Compositionality` | `\item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.` | `4b9248498399338eeaccb63c5e8952ca0928b87bb85bcd94f596d9c263bb64fa` |
| `def:frame#Seriality` | `\item[\it Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.` | `ad1863bf950f17906a79b469b40fddb102e4abf5bd1bfd828a2f4b4900c7dbad` |
| `def:frame#Limit` | `\item[\it Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.` | `3eedd389d6cbdf5dff50f82ad9bafed30fe5eff5ec923cfdc165ca75dbe60a5f` |
| `def:frame#Spherical` | `\item[\it Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments.` | `656c4b68708828cbf47849b70636c428257b45f6b9427fa0368d6876408947c9` |

Note: **Compositionality is a biconditional**, not a one-directional implication — this is load
bearing (the right-to-left direction is used directly in, e.g., the constraint-family proofs).

### `lem:nullity` — DERIVED: `w ⇒₀ w` (Nullity is not an axiom)

```latex
\begin{Lthm} \label{lem:nullity}
	$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame $\F = \tuple{W, \D, \Rightarrow}$.
\end{Lthm}
```
sha256: `7840512db4eb75a6f8d4224b80d784239e554f2742163722236df4778de8d9de`

Proved (per the paper) from Seriality at `x = 0` plus Limit — choice-free, unlike `thm:extension`
below which needs Zorn's lemma.

### `def:world-history` — partial history, world history, totality, the extension order, `H_F`

```latex
\begin{Ddef} \label{def:world-history}
	A \textit{partial history} over a frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$.
	% Since the difference $y - x$ is negative whenever $y < x$, these instances are covered by the converse convention: $\tau(x) \Rightarrow_{y-x} \tau(y)$ then reads $\tau(y) \Rightarrow_{x-y} \tau(x)$.
	A \textit{world history} is any partial history whose domain $X$ is \textit{convex}, so that $y \in X$ whenever $x, z \in X$ and $x < y < z$.
  A world history is \textit{total}--- equivalently, a \textit{possible world}--- just in case $X = D$.
	A partial history $\sigma$ \textit{extends} $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$.
	The set of all total world histories over $\F$ is denoted $H_{\F}$.
\end{Ddef}
```
sha256: `4aaa6ec0db38ccbba25ce6dc61d81b8a28f82913ba6b2b1defabaa42f9caf205`

Layering, exactly as the paper states it: **partial history** (nonempty domain, no convexity
requirement) → **world history** (convex domain) → **total** / **possible world** (`X = D`). The
vocabulary "task-constrained function" is retired paper-wide and must not be reintroduced as
current terminology (see the paper-refactor cluster's task descriptions, which record the same
point). `H_F` denotes only the *total* histories.

### `thm:extension` — every partial history extends to a total world history

```latex
\begin{Tthm} \label{thm:extension}
	Every partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ is extended by some total world history $\sigma \in H_{\F}$.%
	  \footnote{
%% CHANGE (finite-spherical-corollary): footnote's existing choice-contrast clause extended to name the finite-$W$ case discharged choice-free by cor:spherical-finite.
%% OLD: 	    The proof appeals to Zorn's lemma and hence to the axiom of choice, and so the derivation of \textit{Occurrence} from \textit{Seriality} and \textit{Spherical} in \textbf{\ref{cor:occurrence}} is a theorem of ZFC, in contrast with the choice-free derivation of the zero loops in \textbf{\ref{lem:nullity}}.
	    The proof appeals to Zorn's lemma and hence to the axiom of choice, and so the derivation of \textit{Occurrence} from \textit{Seriality} and \textit{Spherical} in \textbf{\ref{cor:occurrence}} is a theorem of ZFC, in contrast with the choice-free derivation of the zero loops in \textbf{\ref{lem:nullity}} and of \textit{Spherical} for finite $W$ in \textbf{\ref{cor:spherical-finite}}.
	  }
\end{Tthm}
```
sha256: `e63eac74fb8de22197f9bbb732bf83ea49def7308ca499817683145c99762b3e`

### `cor:occurrence` — DERIVED: every world state occurs at any prescribed time in some total world history (renamed from `thm:occurrence`; see "Drift correction" below)

```latex
\begin{Cthm} \label{cor:occurrence}
	For any frame $\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$, and time $x \in D$, there is a total world history $\tau \in H_{\F}$ where $\tau(x) = w$, and so $H_{\F} \neq \emptyset$.
\end{Cthm}
```
sha256: `b0228712e0d847f600b5b353b783ec3bc24e7722620f7e39e284af1f1fa5ebea`

Follows from `thm:extension`, hence is also a ZFC (not choice-free) result. The paper merged the
former `thm:occurrence` (existential over both the history and the time) with a separate
`app:nonempty` corollary into this single, strictly stronger statement (time `x` is now given, not
merely witnessed) under the new label `cor:occurrence` — see "Drift correction" below. Its
current proof extends the one-point partial history `{⟨x, w⟩}` directly via `thm:extension`; the
former translation argument is gone from this chain (time-shift machinery survives separately
under `def:time-shift-histories`, which remains untracked).

### `def:constraints` — the constraints on a new duration (renamed from "constraints *imposed on*"; see "Drift correction (2026-08-12)")

```latex
\begin{Ddef} \label{def:constraints}
	For a partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the \textit{constraints on $z$} are the segments $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t,s \in X$ where $t < z < s$ when both $t,s \in X$, and the fibers $\Fib(\tau(t), z - t)$ for $t \in X$ otherwise.
\end{Ddef}
```
sha256: `3678ab023f5c7f51e790eb1f8790ae78f4c7f6bb4cd4f7dc3e41b0408b3ac581`

Promoted from lead-in prose to a numbered definition so the lemmas below can cite it by name.
The 2026-08-12 wave shortened the defined term to "the *constraints on `z`*" and added an explicit
"when both `t,s ∈ X`" guard to the segment case; the family being defined is unchanged. Note that
surrounding paper text (and `lem:nonempty`, untracked) still says "imposed on", so both phrasings
appear in the live paper — this record quotes whichever one appears inside the tracked block.

### `lem:nesting` — DERIVED: imposed fibers and segments nest along the time order

```latex
\begin{Lthm} \label{lem:nesting}
  % FIX: if possible, I'd like \Fib to always show up in the same way rather than taking on the italics of this environment. I also want to use \fib if available to match with the others. Fix the macro accordingly.
	For any partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the fibers $\Fib(\tau(t'), z - t') \subseteq \Fib(\tau(t), z - t)$ nest for all times $t \leq t' < z$ in $X$ and symmetrically for all times $z < t' \leq t$ in $X$, while the segments $[\tau(t'), \tau(s')]_{z - t'}^{s' - z} \subseteq [\tau(t), \tau(s)]_{z - t}^{s - z}$ nest for all times $t \leq t' < z < s' \leq s$ in $X$.
\end{Lthm}
```
sha256: `ffc2d16fbded65204f743530a43834025048ac59d7f70524389ba488c9305266`

The block carries an in-source `% FIX:` authorial note about the `\Fib` macro's italics. That line
is literal paper source and is inside the hashed region, so it is quoted here verbatim like any
other in-block comment; it is the paper author's note to themselves, not an instruction to this
repository. Paper order places this lemma immediately after `def:constraints` and before
`lem:nonempty`, which is why both sit here rather than beside `lem:constraint`.

### `lem:nonempty` — DERIVED: every imposed constraint is nonempty

```latex
\begin{Lthm} \label{lem:nonempty}
	For any partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, every constraint imposed on $z$ is nonempty.
\end{Lthm}
```
sha256: `04a49ef8a67071b45bb42ad91ae8e7eba8a3c89a7fd785017e33507b7f8cc6c7`

Note the phrasing divergence already recorded under `def:constraints`: that definition was renamed
to "the constraints *on* `z`", while this lemma (and `lem:nesting`, `lem:constraint`, `lem:fibers`,
`lem:admissible` above and below) still says "imposed on". Both phrasings are live in the paper and
both are quoted as they stand; neither is silently normalized here.

### `lem:constraint` — DERIVED: the constraint family is directed and nonempty

```latex
\begin{Lthm} \label{lem:constraint}
	For any partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the constraints imposed on $z$ form a directed family of nonempty sets.
\end{Lthm}
```
sha256: `9ebed5d29cd939e0b3486dee775b8135077819f0de7228877ffeef6a928bf5e7`

This lemma now states **only** directedness + nonemptiness. The admissibility characterization
that an earlier paper wave carried inside this lemma was split out into `lem:admissible` below —
task specs quoting the old merged statement are stale. Its proof consumes Compositionality in
BOTH directions plus Seriality.

### `lem:fibers` — DERIVED: membership in all constraints ⟺ fiber condition at every time

```latex
\begin{Lthm} \label{lem:fibers}
	For any partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, a world state $u \in W$ belongs to every member of the constraints imposed on $z$ just in case $\tau(t) \Rightarrow_{z-t} u$ for every $t \in X$.
\end{Lthm}
```
sha256: `42ec404f8082ceeff30b1da5a28c076c9880704c92d500cb5068ce8b0a1ba7e2`

New lemma (introduced by the same wave that split `lem:admissible` out of `lem:constraint`).

### `lem:admissible` — DERIVED: one-point extension is a partial history ⟺ membership in all constraints

```latex
\begin{Lthm} \label{lem:admissible}
	For any partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the function $\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs to every member of the constraints imposed on $z$.
\end{Lthm}
```
sha256: `cc94cfdca6f3c1f581f3876ba737525288417ac9c05b3293c8fa4a621d262469`

Proof consumes `lem:nullity` (the zero loop at `z` itself) plus `lem:fibers`.

### `lem:step` — DERIVED: the Step Lemma (sole *Spherical* application site)

```latex
\begin{Lthm} \label{lem:step}
	Every partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any duration $z \in D$.
\end{Lthm}
```
sha256: `82ab9eb861c6e4cb99575946f4a74f4296b5c8b979d3c2f6e28ac9fa705da94f`

Proof: `lem:constraint` gives the directed family, *Spherical* provides a common member, and
`lem:admissible` certifies the extension. Closing remark (verbatim, load-bearing for the discrete
case): "When the family has a $\subseteq$-least member, that member already contains a candidate
and \textit{Spherical} is not needed."

### `def:BL-model` — model of `BL`

```latex
\begin{Ddef} \label{def:BL-model}
	A \textit{model} of $\BL$ is a structure $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$ is a frame and $\vert{p_i} \subseteq W$ for every sentence letter $p_i \in \SL$.
\end{Ddef}
```
sha256: `239fba0ff163b461e0d1bf3c0e94da0cb0b62e7b2d7f4519916af4cc50d6967f`

### `def:BL-semantics` — the truth clauses (TruthAt), including the box clause's quantifier domain

```latex
\begin{Ddef} \label{def:BL-semantics}
%% CHANGE (fix.md B1): formal mirror of body 941 -- evaluation point is a world segment, matching def:world-history's renamed object.
%% OLD: 	Truth in a model at a possible world and time is defined recursively:
%% CHANGE (task 52 total-histories): mirror of the Phase 2 body edits -- evaluation point is a possible world (world history); atom clause loses the dom conjunct, matching the total, bivalent body clause.
%% OLD: 	Truth in a model at a world segment and time is defined recursively:
%% OLD: 		\item[($p_i$)] $\M,\tau,x \vDash p_i$ \textit{iff} $x \in \dom{\tau}$ and $\tau(x) \in |p_i|$.
%% CHANGE (convex-domains): evaluation points are the total possible worlds in H_F, matching the body.
%% OLD: 	Truth in a model at a possible world and time is defined recursively:
%% CHANGE (two-tier): "total possible world" is redundant under the tier discipline -- possible worlds are total by definition.
%% OLD: 	Truth in a model at a total possible world $\tau \in H_{\F}$ and time is defined recursively:
	Truth in a model at a possible world $\tau \in H_{\F}$ and time is defined recursively:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[($p_i$)] $\M,\tau,x \vDash p_i$ \textit{iff} $\tau(x) \in |p_i|$.
		\item[($\bot$)] $\M,\tau,x \nvDash \bot$.
		\item[($\shortrightarrow$)] $\M,\tau,x \vDash \varphi \rightarrow \psi$ \textit{iff} $\M,\tau,x \nvDash \varphi$ or $\M,\tau,x \vDash \psi$.
%% CHANGE (fix.md B1): formal mirror of body 946; must match exactly -- $\Box$ ranges over $H^{\max}_{\F}$.
%% OLD: 		\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$.
%% CHANGE (task 52 total-histories): supersedes the fix.md B1 mirror edit above -- H^max_F is eliminated; Box ranges over H_F, matching the Phase 2 body clause exactly.
%% OLD: 		\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H^{\max}_{\F}$.
		\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$.
		\item[($\Past$)] $\M,\tau,x \vDash \Past \varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $y < x$.
		\item[($\Future$)] $\M,\tau,x \vDash \Future \varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $x < y$.
	\end{enumerate}
  \vspace{-.15in}
\end{Ddef}
```
sha256: `8fec78985c2efea20d13c1e6d5c7536ae0e0d864172bbe0460441d61addf22e3`

**The box clause's quantifier domain is `H_F`** — the full set of *total* world histories, not a
maximal-history set `H^max_F` (that vocabulary is retired; the block's own `%%` comment history
above shows it was explicitly eliminated) and not an externally-supplied `Omega` subset. This is
the single most consequential clause for the current `paper-refactor` cluster: the Lean tree's
`TruthAt` (`FormalSystem/Semantics/Truth.lean:128`) still takes an explicit
`Omega : Set (WorldHistory F)` parameter and quantifies `Box` over `Omega`, not over the full
total-history set directly — that is precisely the gap the cluster's total-history refactor
closes. See "Downstream consumers" below.

### `def:BLplus-language` — the language of `BL^+` (since/until constructors)

```latex
\begin{Ddef} \label{def:BLplus-language}
	The language $\BL^+ \coloneq \tuple{\SL,\bot,\rightarrow,\Box,\since,\until}$ where $\SL \coloneq \set{p_i: i\in \N}$ is a countable set of sentence letters as before where the remaining symbols denote falsity, material implication, the metaphysical necessity operator, the since operator, and the until operator, respectively.
	Well-formed sentences of $\BL^+$ are defined by:
	\[
		\varphi, \psi \Coloneq p_i \mid \bot \mid \varphi \rightarrow \psi \mid \Box\varphi \mid \varphi\since\psi \mid \varphi\until\psi.
	\]
\end{Ddef}
```
sha256: `a43b3df2ea2fcb96eeb156b3403a33ac51fcafd2ad4eb55e7915c07cf509f8b7`

### `def:BLplus-semantics` — the `\since` / `\until` truth clauses (and the argument-order footnote)

```latex
\begin{Ddef} \label{def:BLplus-semantics}
  The \textit{models} of $\BL^+$ are defined in \textbf{\ref{def:BL-model}}, where \textit{truth in a model} $\M$ at $\tau \in H_{\F}$ and $x \in D$ extends the semantics \textbf{\ref{def:BL-semantics}} with the following clauses:\footnote{%
%% CHANGE (halden-defect-repair, untl-snce-convention): the footnote described the repository's \texttt{snce}/\texttt{untl} constructors as following the Pnueli guard-first convention. They do not--- they are event-first (Burgess), while the paper's own surface notation is guard-first. The mismatch is now stated in the direction that actually holds, with an explicit note that the truth conditions agree once the argument order is swapped, so no semantic claim changes.
%% OLD: 	Although the axioms of \textbf{TM}$^+$ are drawn from the Burgess-Xu (BX) system, the repository's \texttt{snce}/\texttt{untl} constructors follow the Pnueli convention with the guard as the first argument and the event as the second: $\varphi\since\psi$ means $\psi$ held at some past time with $\varphi$ holding throughout the interval since, and $\varphi\until\psi$ means $\psi$ will hold at some future time with $\varphi$ holding throughout the interval until $\psi$ holds.
	Although the axioms of \textbf{TM}$^+$ are drawn from the Burgess-Xu (BX) system, the paper's surface notation $\varphi\since\psi$ and $\varphi\until\psi$ below is guard-first, with $\varphi$ the guard and $\psi$ the event, whereas the repository's \texttt{snce}/\texttt{untl} constructors follow the event-first Burgess convention, with the event given first and the guard second.
	The truth conditions agree once the argument order is swapped: $\varphi\since\psi$ means $\psi$ held at some past time with $\varphi$ holding throughout the interval since, and $\varphi\until\psi$ means $\psi$ will hold at some future time with $\varphi$ holding throughout the interval until $\psi$ holds.%
	}
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[($\since$)] $\M,\tau,x \vDash \varphi\since\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z < x$ where $\M,\tau,y \vDash \varphi$\\
      \strut\hspace{1.55in}for all $y \in D$ with $z < y < x$.
		\item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z > x$ where $\M,\tau,y \vDash \varphi$\\ 
      \strut\hspace{1.55in}for all $y \in D$ with $x < y < z$.
	\end{enumerate}
\end{Ddef}
```
sha256: `f40f514e60dcb7a6b36dee664ebcc1d55c2c6bce9e044c5814071f521674d670`

**Argument-order caveat — the footnote now describes this repository correctly (repaired
2026-08-12).** The `\footnote` inside the block above *previously* asserted that "the repository's
`snce`/`untl` constructors follow the Pnueli convention with the guard as the first argument and
the event as the second", which was false of the Lean tree. As of the wave re-quoted above, the
paper has repaired that sentence itself (its own `%% CHANGE (halden-defect-repair,
untl-snce-convention)` comment, retained verbatim in the quoted block): the footnote now says the
paper's surface notation is guard-first while **the repository's constructors are event-first
(Burgess)**, and adds that the truth conditions agree once the argument order is swapped.

That matches the Lean tree: `Formula.snce`/`Formula.untl` (`FormalSystem/Syntax/Formula.lean:85-90`)
and `TruthAt`'s clauses (`FormalSystem/Semantics/Truth.lean:134-135`) are **event-first /
guard-second**, and both `Axiom.dense_indicator` (`FormalSystem/Semantics/Validity.lean:229-231`)
and the `K⁺` combinator (`FormalSystem/Syntax/Formula.lean:164-166`) depend on the event-first
reading. The Lean convention was **not** changed and did not need to be. The divergence remains
recorded in `specs/decisions/untl-snce-argument-order.md`; what changed is that the paper and this
repository now *agree about which convention each of them uses*, so the remaining difference is a
notational one the paper explicitly flags, not a defect. This record continues to quote the paper
verbatim either way — it records what the paper says, including when what it says becomes correct.

Precisely what does and does not diverge: the **shape** of each clause is identical to Lean's (one
existentially witnessed time on the correct side of `x`, one universal quantifier over the open
interval between them). What differs is **which argument plays which role**. The paper's infix
`$\varphi\since\psi$` puts the *event* second (`ψ` is witnessed at `z < x`; `φ` holds throughout),
consistent with its own `def:BLplus-defined` abbreviations `$\past\varphi \coloneq \top\since\varphi$`
and `$\future\varphi \coloneq \top\until\varphi$`. Lean's prefix `Formula.untl φ ψ` puts the *event*
first — `someFuture φ = untl φ ⊤` (`Formula.lean:131`), the mirror image. So the footnote accurately
describes **the paper's own** infix convention; its error is attributing that convention to **this
repository's constructors**, which are the other way round.

### `def:BLplus-defined` — the defined temporal operators of `BL^+`

```latex
\begin{Ddef} \label{def:BLplus-defined}
	The following operators are defined in $\BL^+$:
  \vspace{-.125in}
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\begin{multicols}{2}
			\item[\bf Past:] $\past\varphi \coloneq \top\since\varphi$.
			\item[\bf Future:] $\future\varphi \coloneq \top\until\varphi$.
			\item[\bf Historical:] $\Past\varphi \coloneq \neg\past\neg\varphi$.
			\item[\bf Henceforth:] $\Future\varphi \coloneq \neg\future\neg\varphi$.
			\item[\bf Always:] $\always\varphi \coloneq \Past\varphi \wedge \varphi \wedge \Future\varphi$.
			\item[\bf Sometimes:] $\sometimes\varphi \coloneq \past\varphi \vee \varphi \vee \future\varphi$.
			\item[\bf Next:] $\Next\varphi \coloneq \bot\until\varphi$.
			\item[\bf Previous:] $\Previous\varphi \coloneq \bot\since\varphi$.
		\end{multicols}
	\end{enumerate}
  \vspace{-.25in}
\end{Ddef}    
```
sha256: `2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e`

### `def:frame-validity` — validity over a frame

```latex
\begin{Ddef} \label{def:frame-validity}
	A well-formed sentence $\varphi$ of $\BL$ is \emph{valid over a frame} $\F = \tuple{W, \D, \Rightarrow}$ which we may write $\vDash_{\F} \varphi$ if and only if $\M,\tau,x \vDash \varphi$ for every model $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$, possible world $\tau \in H_{\F}$, and time $x \in D$.
\end{Ddef}
```
sha256: `2bcc85b0781fd4cc5af05d0741c64f44662706523cf023f3d5237d4ed1e8d1b9`

### `def:logical-consequence` — logical consequence and (global) validity

```latex
\begin{Ddef} \label{def:logical-consequence}
%% CHANGE (task 52 total-histories): the x in T typo is fixed to x in D, aligning the mirror with the Phase 3 body consequence definition (models, possible worlds tau in H_F, times x in D).
%% OLD: 	A conclusion $\varphi$ is a \textit{logical consequence} of a set of premises $\Gamma$--- written $\Gamma \vDash \varphi$--- just in case for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in T$, if $\M,\tau,x \vDash \gamma$ for all premises $\gamma \in \Gamma$, then $\M,\tau,x \vDash \varphi$.
	A conclusion $\varphi$ is a \textit{logical consequence} of a set of premises $\Gamma$--- written $\Gamma \vDash \varphi$--- just in case for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in D$, if $\M,\tau,x \vDash \gamma$ for all premises $\gamma \in \Gamma$, then $\M,\tau,x \vDash \varphi$.
	A sentence $\varphi$ is \textit{valid} just in case $\vDash \varphi$.
\end{Ddef}
```
sha256: `e65c228721a39f8622d2256988b574c96a6cb7fdd6723a2eb63ce8a1f87770f0`

This block covers **both** logical consequence (`Γ ⊨ φ`) **and** global validity (`⊨ φ`, "valid
just in case ⊨φ") — the paper defines them in the same `Ddef`. `def:frame-validity` above is the
separate, frame-relative validity notion (`⊨_F φ`); the two are distinct anchors and both are
tracked.

### `CO` / `TMP-CO` — worked example of the `\aitem`-key anchor kind

The paper introduces some axioms via a custom `\aitem[KEY]{LABEL}` macro
(`\newcommand{\aitem}[2][]{\item[{\bf ...}] \refstepcounter{acount}\label{#2}%`), which sets the
**bold displayed key** to its optional first argument (or, if omitted, to the second argument) and
sets the **`\label`** (hence the `\aref`-resolvable anchor) to the second argument. This means a
single displayed key like "CO" can correspond to *two different* `\label` anchors in different
parts of the paper — exactly the case recorded here, per this task's explicit instruction to
demonstrate the mechanism handles both anchor kinds:

| Anchor (`\label`) | Displayed key | Verbatim text | sha256 |
|---|---|---|---|
| `CO` | CO | `\aitem{CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.` | `5c468c01776c449b212c98070b5bfc70951691a23905cd4d4c249bf1f5375d41` |
| `TMP-CO` | CO (same displayed key, `BL^+` restatement) | `\aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.` | `2205e7115342b037faeb67a24cb7679e393af582cedf6752c0c07d9a28b8f1be` |

`CO` and `TMP-CO` are **not** part of `def:frame`'s four axioms (an unrelated coincidence of
abbreviation — `CO` here names a temporal continuity/completeness axiom, unrelated to `def:frame`'s
"Compositionality"). They are included to keep the extraction mechanism exercised against both
anchor kinds the paper actually uses, per this task's instruction; they are not otherwise consumed
by a live task at recording time.

### `def:S5` — the S5 modal logic (rule/axiom schemata)

```latex
\begin{Ddef} \label{def:S5}
  The \textbf{S5} \textit{Modal Logic} is the smallest extension of \textit{Classical Propositional Logic} \textbf{CPL} closed under the following rule schemata and metarule:
  \vspace{-.125in}
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \begin{multicols}{2}
      \aitem[MK]{TMP-MK} $\Box(\varphi \rightarrow \psi) \rightarrow (\Box\varphi \rightarrow \Box\psi)$.
      \aitem[MT]{TMP-MT} $\Box\varphi \rightarrow \varphi$.
      \aitem[M5]{TMP-M5} $\Diamond\Box\varphi \rightarrow \Box\varphi$.
      \aitem[MP]{TMP-MP} $\varphi,\ \varphi \rightarrow \psi \vdash \psi$.
      \aitem[MN]{TMP-MN} \textit{If} $\vdash \varphi$, \textit{then} $\vdash \Box\varphi$.
    \end{multicols}
  \end{enumerate}
  \vspace{-.175in}
\end{Ddef}
```
sha256: `b090402a8048cd02cc163ebf0af7ec3f9c2630edc943feeaf5e9873072f50211`

### `def:BX` — the Base Burgess–Xu tense logic

```latex
\begin{Ddef} \label{def:BX}
  Letting $\varphi_{\tuple{\textsc{s} | \textsc{u}}}$ denote the result swapping occurrences of $\since$ and $\until$ in $\varphi$, \textbf{BX} is the \textit{Base Burgess--Xu Tense Logic} axiomatized below where the past/since direction of each axiom follows from the future/until direction:
  \vspace{-.125in}
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \begin{multicols}{2}
      \aitem[TN]{TMP-TN} \textit{If} $\vdash \varphi$, \textit{then} $\vdash \Future\varphi$.
      \aitem[TD]{TMP-TD} \textit{If} $\vdash \varphi$, \textit{then} $\vdash \varphi_{\tuple{\textsc{s} | \textsc{u}}}$.
    \end{multicols}
  \end{enumerate}
  \vspace{-.175in}
  The seriality \textbf{\aref{TB}} and linearity \textbf{\aref{TL}} axioms from \textbf{TM}, together with connectedness:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \aitem[TB]{TMP-SE} $\future\top$.
    \aitem[TL]{TMP-LN} $\future\varphi \wedge \future\psi \rightarrow [\future(\varphi \wedge \psi) \vee \future(\varphi \wedge \future\psi) \vee \future(\future\varphi \wedge \psi)]$.
    \aitem[CN]{TMP-CN} $(\varphi\until\psi) \wedge (\chi\until\theta) \rightarrow [(\varphi \wedge \chi)\until(\psi \wedge \theta) \vee (\varphi \wedge \chi)\until(\psi \wedge \chi) \vee (\varphi \wedge \chi)\until(\varphi \wedge \theta)]$.
  \end{enumerate}
  The primary axioms for $\since$ and $\until$ are:
  \vspace{-.125in}
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \begin{multicols}{2}
      \aitem[TA]{TMP-CV} $\varphi \rightarrow \Future\past\varphi$.
      \aitem[UE]{TMP-UE} $(\varphi\until\psi) \rightarrow \future\psi$.
      \aitem[UT]{TMP-UT} $\future\varphi \rightarrow (\top\until\varphi)$.
      \aitem[UI]{TMP-UI} $\varphi\until(\varphi \wedge (\varphi\until\psi)) \rightarrow \varphi\until\psi$.

      \aitem[UC]{TMP-UC} $\Future(\varphi \rightarrow \psi) \rightarrow ((\chi\until\varphi) \rightarrow (\chi\until\psi))$.
      \aitem[UF]{TMP-UF} $(\varphi\until\psi) \rightarrow (\varphi \wedge (\varphi\until\psi))\until\psi$.
      \aitem[UG]{TMP-UG} $\Future(\varphi \rightarrow \chi) \rightarrow ((\varphi\until\psi) \rightarrow (\chi\until\psi))$.
      \aitem[SU]{TMP-SU} $\theta \wedge (\varphi\until\psi) \rightarrow \varphi\until(\psi \wedge (\varphi\since \theta))$.
    \end{multicols}
  \end{enumerate}
  \vspace{-.175in}
  The uniformity axioms, which hold vacuously unless the order is discrete, are:
  \vspace{-.125in}
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \begin{multicols}{2}
      \aitem[NP]{TMP-NP} $\Next\top \rightarrow \Previous\top$.
      \aitem[NF]{TMP-NF} $\Next\top \rightarrow \Future\Next\top$.
      \aitem[NA]{TMP-NA} $\Next\top \rightarrow \Past\Next\top$.
      \aitem[NB]{TMP-NB} $\Next\top \rightarrow \Box\Next\top$.
    \end{multicols}
  \end{enumerate}
  \vspace{-.175in}
  The logic \textbf{BX} is smallest extension of \textbf{CPL} closed under all instances of the above.
\end{Ddef}
```
sha256: `1518997ec9497a1fe90f42c270f9b7c32c8b71392846c9a371548aa823fbbc65`

### `def:TMplus-f` — the discrete Burgess–Xu tense logic BX_f, and its Z-time footnote

```latex
\begin{Ddef} \label{def:TMplus-f}
  The \textit{Discrete Burgess--Xu Tense Logic} \textbf{BX}$_f$ is the smallest extension of the base logic \textbf{BX} to include all instances of the following axioms:
  \vspace{-.125in}
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \begin{multicols}{2}
    \aitem[UZ]{TMP-UZ} $\future\varphi \rightarrow (\neg\varphi\until\varphi)$.
    \aitem[Z1]{TMP-Z1} $\Future(\Future\varphi \rightarrow \varphi) \rightarrow (\future\Future\varphi \rightarrow \Future\varphi)$.
    \end{multicols}
  \end{enumerate}
  \vspace{-.175in}
 % is sound and complete over discrete (successor-Archimedean) frames, playing the role that \textbf{\aref{DF}} plays in \textbf{TM} but with finer expressivity since $\since$ and $\until$ can witness nearest past and future times directly.
  Whereas \textbf{\aref{TMP-UZ}} asserts that if $\varphi$ holds at some future time, then there is a \textit{nearest} future $\varphi$-time where $\neg\varphi$ throughout the intervening interval, \textbf{\aref{TMP-Z1}} is a backward induction principle characteristic of successor-Archimedean frames.
%% CHANGE (fix.md C5): promoted the Hölder/Z-time fact into the definition and stated soundness/completeness relative to $\Z$-time; added the non-Archimedean discrete counterexample (UZ/Z1 unsoundness).
%% OLD: (none -- new sentences inserted into def:TMplus-f; the commented-out sentence immediately above already records the prior soundness/completeness remark that this replaces in substance.)
  By H\"{o}lder's theorem, a nontrivial \textit{discrete} Archimedean totally ordered abelian group is isomorphic to $\Z$, so the successor-Archimedean discrete class to which \textbf{BX}$_f$ and \textbf{TM}$^+_\textsc{f}$ are sound and complete is exactly $\Z$-time.
%% CHANGE (halden-defect-repair, discrete-class-scoping): the prior sentence bundled \textbf{TM}$_\textsc{f}$ together with \textbf{BX}$_f$ and \textbf{TM}$^+_\textsc{f}$ and assigned all three soundness and completeness over $\Z$-time. That conflates three systems of different strength: \textbf{TM}$_\textsc{f} = \textbf{TM} + \textbf{\aref{DF}}$ is sound over the whole discrete class, not merely $\Z$-time, so its scope is separated here and its completeness over the broader class left open.
%% NOTE (author decision required): this reflects Branch A of the discrete-class ambiguity--- read \textbf{TM}$_\textsc{f}$ as the full-discrete-class system rather than as the $\Z$-time system. The alternative (Branch B) redefines \textbf{TM}$_\textsc{f}$ as $\Z$-time throughout, which would instead make its completeness hold outright. Branch A was taken during implementation without an interactive author decision; see the accompanying site-inventory decision record. The choice propagates to \textbf{\ref{cor:tm-completeness}}'s \textbf{TM}$_\textsc{f}$ row and its strong-completeness rider.
%% OLD:   By H\"{o}lder's theorem, a nontrivial \textit{discrete} Archimedean totally ordered abelian group is isomorphic to $\Z$, so the successor-Archimedean discrete class to which \textbf{BX}$_f$ (and \textbf{TM}$^+_\textsc{f}$, \textbf{TM}$_\textsc{f}$) are sound and complete is exactly $\Z$-time.
  \textbf{TM}$_\textsc{f}$, by contrast, is sound over the full class of discrete frames, since \textbf{\aref{DF}} is valid on every discrete order and not only on $\Z$-time; whether \textbf{TM}$_\textsc{f}$ is complete over that broader class remains open, as discussed at \textbf{\ref{cor:tm-completeness}}.
  \textbf{\aref{TMP-UZ}} and \textbf{\aref{TMP-Z1}} are not sound over non-Archimedean discrete orders: over $\Z \times_{\mathrm{lex}} \Z$, an atom true only in the second galaxy leaves \textbf{\aref{TMP-UZ}} without a first witness.
\end{Ddef}
```
sha256: `419a80a7d6e9f44a41883f7ce5d0693396e6126fc06a4909b5195d2a98965fe2`

### `def:TMplus-d` — the dense Burgess–Xu tense logic BX_d

```latex
\begin{Ddef} \label{def:TMplus-d}
  The \textit{Dense Burgess--Xu Tense Logic} \textbf{BX}$_d$ is the smallest extension of the base logic \textbf{BX} to include all instances of the following axioms:
  \vspace{-.125in}
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \begin{multicols}{2}
      \aitem[DN]{TMP-DN} $\Future\Future\varphi \rightarrow \Future\varphi$.
      \aitem[NN]{TMP-NN} $\neg\Next\top$.
    \end{multicols}
  \end{enumerate}
  \vspace{-.175in}
  Whereas \textbf{\aref{TMP-DN}} coincides with \textbf{\aref{DN}} of \textbf{TM}, the axiom \textbf{\aref{TMP-NN}} is specific to \textbf{TM}$^+$ and asserts that there is no immediate successor.
\end{Ddef}
```
sha256: `aa6542e6eee06e5c94dddc4b4581715d8b4310bba53615e0c0f80188016f10cf`

### `def:TMplus-c` — the complete Burgess–Xu tense logic BX_c, Reynolds-triple basis, CO derived

```latex
\begin{Ddef} \label{def:TMplus-c}
%% CHANGE (halden-defect-repair, bx-c-reynolds-rebase): re-based BX_c on the Reynolds triple (Prior-U, Sep, with Prior-S as the TD-mirror of Prior-U) rather than CO alone, matching the axiom basis that is actually machine-checked; CO is restated as a derived theorem.
%% OLD:   The \textit{Complete Burgess--Xu Tense Logic} \textbf{BX}$_c$ is the smallest extension of the base logic \textbf{BX} to include all instances of the following axioms:
%% OLD:   \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
%% OLD:     \aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.
%% OLD:   \end{enumerate}
%% OLD:   This axiom coincides with \textbf{\aref{CO}} in \textbf{TM}, though it is expressed in $\BL^+$.
  Letting $K^+\varphi \coloneq \neg(\neg\varphi\until\top)$ and $K^-\varphi \coloneq \neg(\neg\varphi\since\top)$ abbreviate Reynolds' (1992) operators--- $K^+\varphi$ says that $\varphi$ recurs arbitrarily soon in the future, and $K^-\varphi$ that $\varphi$ recurred arbitrarily recently in the past--- the \textit{Complete Burgess--Xu Tense Logic} \textbf{BX}$_c$ is the smallest extension of the base logic \textbf{BX} to include all instances of the following axioms, due to Reynolds (1992), where only the future/until direction of \textbf{\aref{TMP-PU}} is stated, its past/since direction following by \textbf{\aref{TMP-TD}}:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \aitem[Prior-U]{TMP-PU} $(\varphi\until\top) \wedge \future\neg\varphi \rightarrow \varphi\until(\neg\varphi \vee K^+\neg\varphi)$.
    \aitem[Sep]{TMP-SEP} $K^+\varphi \wedge \neg K^+(\varphi \wedge (\neg\varphi\until\varphi)) \rightarrow K^+(K^+\varphi \wedge K^-\varphi)$.
  \end{enumerate}
  \textbf{\aref{TMP-CO}}, restated from \textbf{\aref{CO}} in \textbf{TM}, is a \textit{derived theorem} of \textbf{BX}$_c$ rather than a further axiom, using only \textbf{\aref{TMP-PU}} and the base axioms of \textbf{BX}--- \textbf{\aref{TMP-SEP}} is not needed for the derivation:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.
  \end{enumerate}
  This derivation is machine-checked in the Lean 4 \href{https://github.com/benbrastmckie/BimodalLogic}{repository} for this paper.
  Whether \textbf{\aref{TMP-CO}} alone axiomatizes the same logic as the full triple is open: the converse derivation--- deriving \textbf{\aref{TMP-PU}} and \textbf{\aref{TMP-SEP}} from \textbf{\aref{TMP-CO}} alone--- is conjectured to fail, via an unformalized pen-and-paper sketch involving a $\Q$-flow with isolated $\neg\varphi$ points accumulating at an irrational from above; this independence is not asserted as established.\footnote{%
    A nontrivial Dedekind-complete totally ordered abelian group is Archimedean, hence by H\"{o}lder's theorem isomorphic to $\Z$ or $\R$.
    The complete class is therefore exactly $\set{\Z, \R}$ up to isomorphism, so the Dedekind-complete theory of time is $\mathrm{Th}(\Z) \cap \mathrm{Th}(\R)$ and the dense-and-complete class is exactly $\R$.
    In particular, no non-Archimedean order is complete.
%% CHANGE (halden-defect-repair, bx-c-reynolds-rebase): removed the identification of the proof system TM_c with Th(Z) cap Th(R); that identity holds only for the semantic theory, not for TM_c as axiomatized, and is now stated only as such at cor:tm-completeness.
%% CHANGE (completeness-relocation, residual-halden-comment): corrected "the Halldén-incompleteness defect this task repairs"--- TM_c is semantically incomplete over $\set{\Z,\R}$, not Halldén-incomplete, and no repair is adopted; see cor:tm-completeness for the corrected diagnosis.
%% OLD:     The complete class is therefore exactly $\set{\Z, \R}$ up to isomorphism, so \textbf{TM}$_\textsc{c}$ = $\mathrm{Th}(\Z) \cap \mathrm{Th}(\R)$ and the dense-and-complete class is exactly $\R$.
    }
\end{Ddef}
```
sha256: `b5cca1c9667cb5e516b30a60a28dbef85f83ee40692a0ce5d92aac232d41a6a9`

### `def:TMplus` — TM+ base logic for BL+, and the four-part conservativity footnote

```latex
\begin{Ddef} \label{def:TMplus}
  The \textit{Base Logic of Tense and Modality} \textbf{TM}$^+$ for $\BL^+$ is the smallest extension of \textbf{S5} and the base logic \textbf{BX} that includes the following \textit{bimodal interaction} axiom:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \aitem[MF]{TMP-MF} $\Box\varphi \rightarrow \Box\Future\varphi$.
  \end{enumerate}
  Similarly, the discrete \textbf{TM}$^+_f$, dense \textbf{TM}$^+_d$, and complete \textbf{TM}$^+_c$ extensions of \textbf{TM}$^+$ include the additional axioms that distinguish \textbf{BX}$_f$, \textbf{BX}$_d$, and \textbf{BX}$_c$, respectively.%
%% CHANGE (completeness-relocation, conservativity-footnote): the conservative-extension theorem and its proof are deleted (the label collected seven citing sites, all re-pointed or removed; see cross-references at the sub:Logic bridge sentence and the appendix roadmap). This footnote replaces them, hanging at the sentence naming the discrete/dense/complete BL+ extensions rather than at the definition's opening sentence. It carries the same CEB/CEF/CED/CEC content compactly, names the CEB witness \textbf{(DD)} (the splitting schema, renamed elsewhere in this restructure), and makes no conservativity claim: the theorem asserted one, and the claim was false in the one direction (CEB, CEF) where it could be checked.
  \footnote{
    $\BL$ embeds into $\BL^+$ (\textbf{\ref{thm:BLplus-PastFuture}}), so the \textit{backward} direction holds unconditionally for every extension: every $\BL$-theorem of \textbf{TM}, \textbf{TM}$_\textsc{f}$, \textbf{TM}$_\textsc{d}$, and \textbf{TM}$_\textsc{c}$ remains a theorem of \textbf{TM}$^+$, \textbf{TM}$^+_\textsc{f}$, \textbf{TM}$^+_\textsc{d}$, and \textbf{TM}$^+_\textsc{c}$ respectively.
    The \textit{forward} direction --- whether enriching the language proves genuinely new $\BL$-theorems --- fails for the base case, witnessed by \textbf{(DD)}: \textbf{TM}$^+$ derives \textbf{(DD)} from \textbf{\aref{TMP-NB}} and \textbf{\aref{M5}} together with two $\BL^+$-valid conditionals, a derivation that inherits \textbf{TM}$^+$'s own not-yet-fully-established weak completeness, since that is what supplies the two conditionals as $\textbf{TM}^+$-theorems, while $\textbf{TM} \nvdash \textbf{(DD)}$, refuted on the two-fibre structure of \textbf{\ref{cor:tm-completeness}}'s proof; \textbf{TM} would have to be extended by \textbf{(DD)} for any transfer to have a chance, and completeness of $\textbf{TM} + \textbf{(DD)}$ is itself open.
    The forward direction also fails for the discrete extension, unconditionally, witnessed by \textbf{\aref{TMP-Z1}}: an axiom of the base tense logic's discrete extension and so a $\textbf{TM}^+_\textsc{f}$-theorem trivially, yet unsound over the non-Archimedean discrete order $\Z \times_{\mathrm{lex}} \Z$ and so not a $\textbf{TM}_\textsc{f}$-theorem.
    The forward direction remains open for the dense and complete extensions, with no known counterexample.
    No conservativity claim is therefore made for \textbf{TM}$^+$ over \textbf{TM}.
  }
\end{Ddef}
```
sha256: `2a150421d56a2480b1c03e97acc6b0342f691b43767760163b50245694ae87ea`

### `thm:M5-valid` — the M5 axiom is valid

```latex
\begin{Tthm} \label{thm:M5-valid}
	$\vDash \Diamond\Box\varphi \rightarrow \Box\varphi$.
\end{Tthm}
```
sha256: `bce3cc3be256f7b4c10e34a397e4b3b14abe4e8ed6728e8e91768e9a2ad8b2af`

### `thm:TM-soundness` — the Soundness theorem

```latex
\begin{Tthm}[Soundness] \label{thm:TM-soundness}
	If $\vdash \varphi$, then $\vDash \varphi$.
\end{Tthm}
```
sha256: `23cae2b2fcd8c034b82c4f9294b21aa4d141429a278fa08d085cae2c53bf0529`

### `app:discrete` — the Discrete correspondence theorem (DF)

```latex
\begin{Tthm} \label{app:discrete}
	$(\Past\varphi \wedge \varphi \wedge \future\top) \rightarrow \future\Past\varphi$ is valid over every frame $\F = \tuple{W, \D, \Rightarrow}$ if and only if $\D$ is \textsc{Discrete}.
\end{Tthm}
```
sha256: `46615df7e02cf9bc59eae1c0ca6ce58f8abdc6ccae8750e59bf5aee050900eb1`

### `app:dense` — the Dense correspondence theorem (DN)

```latex
\begin{Tthm} \label{app:dense}
	$\Future\Future\varphi \rightarrow \Future\varphi$ is valid over every frame $\F = \tuple{W, \D, \Rightarrow}$ if and only if $\D$ is \textsc{Dense}.
\end{Tthm}
```
sha256: `d7b9a4391d9d42fe9ea444bf7dc52be2c526dcf4d3ecc8716ba9b88d6684b23d`

### `app:complete` — the Complete correspondence theorem (CO)

```latex
\begin{Tthm} \label{app:complete}
	$\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$ is valid over every frame $\F = \tuple{W, \D, \Rightarrow}$ if and only if $\D$ is \textsc{Complete}.
\end{Tthm}
```
sha256: `93a5bd056796ac04d369c1e2e5e494004914b5fb7ae9eb928efea89d8fb69122`

### `def:frame-properties` — Discrete/Dense/Complete/Deterministic frame-class predicates

```latex
\begin{Ddef} \label{def:frame-properties}
	A task frame $\F = \tuple{W, \D, \Rightarrow}$ is:
	\begin{enumerate}[wide=0pt, labelsep=.05in, itemsep=.075in]
		\item[\sc Discrete] if for any $x \in D$, whenever there exists $y > x$, there is a least such $y' > x$ satisfying $z \geq y'$ for all $z > x$.
		\item[\sc Dense] if for any $x, y \in D$ where $x < y$, there exists $z \in D$ where $x < z < y$.
		\item[\sc Complete] if every nonempty $S \subseteq D$ bounded above has a least upper bound in $D$.
		\item[\sc Deterministic] if $u = v$ whenever $w \Rightarrow_x u$ and $w \Rightarrow_x v$ for $w, u, v \in W$ and $x \in D$.
	\end{enumerate}
\end{Ddef}
```
sha256: `fa34cc4eed0a85acd583c4b7634beddbaf58bb2756ed95bd0bb06c8560e6e0c0`

Note: promoted into coverage by this task (previously listed under "Deliberately not covered"
below, which is updated accordingly).

### `cor:spherical-finite` — every frame with finite W satisfies Spherical, choice-free

```latex
\begin{Cthm} \label{cor:spherical-finite}
	Every frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Spherical}, choice-free.
\end{Cthm}
```
sha256: `76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d`

### `cor:tm-completeness` — the Completeness corollary (TM sound but not complete; completeness carried by BL+)

```latex
\begin{Cthm}[Completeness] \label{cor:tm-completeness}
%% CHANGE (completeness-relocation, four-row-restructure): the prior enumeration mixed two defects. First, its \textbf{TM}$_\textsc{d}$ and \textbf{TM}$_\textsc{dc}$ rows asserted \BL-level completeness by pulling weak completeness of \textbf{TM}$^+_\textsc{d}$/\textbf{TM}$^+_\textsc{c}$ back through the forward direction of \textbf{CED}/\textbf{CEC}, directions the (now-deleted) conservative-extension theorem itself left open; those rows are removed outright rather than merely re-cited, since the $\BL^+$-level results are machine-checked directly and need no pull-back. Second, the enumeration asserted no row at all for \textbf{TM}$^+$'s own base-case completeness, leaving that claim to surface only as a hedged footnote aside; it is now the table's headline row, worded so the same hedge survives promotion to headline status. The comment this replaces also mischaracterized \textbf{TM} and \textbf{TM}$_\textsc{c}$ as "Halldén-incomplete... repaired by" the splitting schema; the corrected diagnosis --- \textbf{TM} is semantically, not Halldén, incomplete, and the schema is retired from any axiom role --- is given in the proof below.
%% OLD:   $\textbf{TM}$, $\textbf{TM}_\textsc{f}$, $\textbf{TM}_\textsc{d}$, $\textbf{TM}_\textsc{c}$, and $\textbf{TM}_\textsc{dc}$ are all \textit{weakly} complete, over the classes of all frames, discrete frames, dense frames, complete frames, and dense-and-complete frames, respectively: every valid formula is a theorem.
%% OLD:   \textit{Strong} completeness, on which every semantic consequence of a possibly infinite premise set is derivable from it, fails for the discrete and complete classes, where compactness fails.
  \textbf{TM} and its extensions \textbf{TM}$_\textsc{f}$, \textbf{TM}$_\textsc{d}$, \textbf{TM}$_\textsc{c}$, and \textbf{TM}$_\textsc{dc}$ are sound over their respective classes of all, discrete, dense, complete, and dense-and-complete task frames, but none is complete; completeness is carried instead by the following $\BL^+$ systems:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \item[\bf TM$^+_\textsc{d}$] Weakly complete over the dense frames: every formula valid over every dense frame is a theorem. Machine-checked, sorry-free, over the full \textsc{Dense} class.
    \item[\bf TM$^+_\textsc{f}$] Weakly complete over $\Z$-time, machine-checked directly over the successor-Archimedean class.
    \item[\bf TM$^+_\textsc{c}$] Weakly complete over the dense-and-complete class, exactly $\R$, machine-checked directly, aligned with \textbf{\ref{def:TMplus-c}}'s Reynolds-triple basis for \textbf{BX}$_c$.
    \item[\bf TM$^+$] Weak completeness over all task frames is the stated Lean-formalization target; one proof obligation remains outstanding (see the \textbf{Lean status} remark below), so this is not yet an established theorem.
  \end{enumerate}
  \textit{Strong} completeness --- on which every semantic consequence of a possibly infinite premise set is derivable from it --- is the aim for \textbf{TM}$^+$ and \textbf{TM}$^+_\textsc{d}$, with no known obstruction to a fully compact treatment of the base and dense classes.
  It provably fails for $\Z$-time and for the dense-and-complete class $\R$, where compactness fails, so weak completeness is the correct target there; nothing is asserted here about the compactness of the full discrete class in either direction, or about \textbf{TM}$_\textsc{c}$'s completeness over $\set{\Z, \R}$, which is not claimed even weakly.
\end{Cthm}
```
sha256: `7c7bfe057fc7832d7a9e1de316f2003ccfaa61832b27448a59424ccfcd08852e`

### `cor:tm-decidability` — the Decidability corollary (open)

```latex
\begin{Cthm}[Decidability] \label{cor:tm-decidability}
%% CHANGE (halden-defect-repair, decidability-rewrite): deleted the false blanket finite-W-over-Z premise (Section proof gives two witnesses: DF for four of the five systems, CO for TM_f) and restated decidability as open, with the intersection reduction given as the target strategy rather than an established result.
%% OLD:   $\textbf{TM}$, $\textbf{TM}_\textsc{f}$, $\textbf{TM}_\textsc{d}$, $\textbf{TM}_\textsc{c}$, and $\textbf{TM}_\textsc{dc}$ are all decidable.
  Whether \textbf{TM}, \textbf{TM}$_\textsc{f}$, \textbf{TM}$_\textsc{d}$, \textbf{TM}$_\textsc{c}$, and \textbf{TM}$_\textsc{dc}$ are decidable is open.
%% CHANGE (completeness-relocation, decidability-tm-star-drop): dropped the retired \textbf{TM}$^*$ label, which is no longer carried through the paper; the intersection-reduction target and the $\mathrm{Th}(\Z)$/$\mathrm{Th}(\R)$ clause are otherwise unchanged.
%% OLD:   Decidability of $\mathrm{Log}(\text{all task frames}) = \mathrm{Log}(\textsc{Discrete}) \cap \mathrm{Log}(\textsc{Dense})$, and of \textbf{TM}$^*$, would follow from decidability of the two factor logics; likewise decidability of $\mathrm{Log}(\text{complete frames}) = \mathrm{Th}(\Z) \cap \mathrm{Th}(\R)$ would follow from decidability of $\mathrm{Th}(\Z)$ and $\mathrm{Th}(\R)$ separately.
  Decidability of $\mathrm{Log}(\text{all task frames}) = \mathrm{Log}(\textsc{Discrete}) \cap \mathrm{Log}(\textsc{Dense})$ would follow from decidability of the two factor logics; likewise decidability of $\mathrm{Log}(\text{complete frames}) = \mathrm{Th}(\Z) \cap \mathrm{Th}(\R)$ would follow from decidability of $\mathrm{Th}(\Z)$ and $\mathrm{Th}(\R)$ separately.
\end{Cthm}
```
sha256: `ac35ffaa47da467febc431669f604d02622301f369bf795075dbe46ed3ee1bcf`

### `def:id` — identity extension of BL (Ref/Imp/LL)

```latex
\begin{Ddef} \label{def:id}
	An \textit{identity extension of $\BL$} is a language $\BL^{\equiv}$ that enriches $\BL$ with a binary propositional identity operator $\equiv$, read $\ulcorner$For $\varphi$ to be true is for $\psi$ to be true$\urcorner$, whose logic comprises classical propositional logic and the minimal theory of identity given below, where $\chi_{(\psi/\varphi)}$ is the result of replacing one or more occurrences of $\varphi$ in any formula $\chi$ with $\psi$:
	\vspace{-.125in}
	\begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
		\begin{multicols}{2}
			\aitem{Ref} $\vdash \varphi \equiv \varphi$.
			\aitem{Imp} $\vdash (\varphi \equiv \psi) \rightarrow (\varphi \rightarrow \psi)$.
			\aitem{LL} $\vdash (\varphi \equiv \psi) \rightarrow (\chi \rightarrow \chi_{(\psi/\varphi)})$.
		\end{multicols}
	\end{enumerate}
	\vspace{-.175in}
  The theory of propositional identity need not be Boolean, accommodating theories in which the absorption laws or other Boolean identities do not hold.\footnote{I defend a bilateral theory of propositional identity in Brast-McKie \cite{Brast-McKie2021}.}
 Symmetry and transitivity of $\equiv$ are nevertheless derivable: given $\varphi \equiv \psi$, applying \textbf{\aref{LL}} to $\chi \coloneq (\varphi \equiv \varphi)$ yields $\psi \equiv \varphi$ by \textbf{\aref{Ref}}, and a further application gives transitivity. 
\end{Ddef}
```
sha256: `f9d32bd7c7faf6f1b7d57b4b970d1e628719188452a5872bfbe5fcc1dc5a0e4a`

### `def:strongest` — strongest objective normal modal operator, Str^O_L(Q)

```latex
\begin{Ddef} \label{def:strongest}
	$\Q$ is a \textit{strongest objective normal modal operator in $L$}--- $\mathrm{Str}^{\OO}_{L}(\Q)$--- iff:
	\vspace{-.05in}
	\begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \item $\vdash \OO(\Q)$; and
		\item $\vdash \forall\P[\OO(\P) \rightarrow (\Q \preceq \P)]$.
	\end{enumerate}
	\vspace{-.15in}
	Objectivity and normality need not be stated separately: clause (1) already entails $\vdash \Obj(\Q)$, $\vdash \mathrm{Ax}(\Q)$, and $\mathrm{Norm}_L(\Q)$ by the remark above.
\end{Ddef}
```
sha256: `de29ef2b68a2c54decf3d40a195b1e3aeceee1e26a348e0386cc0103ac2a5f66`

### `thm:exist` — L has a strongest objective normal modal operator (Bm witnesses)

```latex
\begin{Tthm} \label{thm:exist}
	$\mathrm{Str}^{\OO}_{L}(\Bm)$, so $L$ includes a strongest objective normal modal operator.
\end{Tthm}
```
sha256: `f5b9c808a519f0368fae920a5315e9b87706ec266143ddc7fcfbb2d304d4519d`

### `lem:uniq` — uniqueness of the strongest objective normal modal operator

```latex
\begin{Lthm} \label{lem:uniq}
	If $\mathrm{Str}^{\OO}_{L}(\Q)$ and $\mathrm{Str}^{\OO}_{L}(\P)$, then $\vdash \forall p(\Q p \leftrightarrow \P p)$.
\end{Lthm}
```
sha256: `caf3d5daa522050ef1e3ab9a93e97efee7f2843f929530442814fdf8cec1a0f2`

### `thm:s4` — the strongest objective operator obeys S4

```latex
\begin{Tthm} \label{thm:s4}
	If $\mathrm{Str}^{\OO}_{L}(\Q)$, then $\vdash \forall p(\Q p \rightarrow \Q\Q p)$.
\end{Tthm}
```
sha256: `d465d756c5c5beed3fae760dc704be91d873184758448bbc74984cf1f520d33d`

### `thm:sym` — the strongest objective operator obeys B/Symmetry

```latex
\begin{Tthm} \label{thm:sym}
	If $\mathrm{Str}^{\OO}_{L}(\Q)$, then $\vdash \forall p(p \rightarrow \Q\Dual{\Q}p)$.
\end{Tthm}
```
sha256: `d485d7b791335d9b000c9e6d8b0e3e611cf60ae58bf8a78ed2d260adac9118d6`

### Satisfiability — **no paper-native definition exists** (recorded as a gap, not fabricated)

The paper does not define "satisfiable" or "satisfiability" anywhere as a `\label`led `Ddef`,
`\aitem`, or otherwise-named clause. This was confirmed by an exhaustive `satisfiab` grep over the
current paper text: every occurrence is informal prose ("this is easy to satisfy", "satisfiability
in HyperLTL is undecidable" in a related-work discussion), never a definition. This is independently
corroborated by task 417's own governing description, which states the same finding in its own
words ("Satisfiability has no labeled paper definition").

**This file therefore does not, and must not, invent a satisfiability definition on the paper's
behalf** — doing so would violate this file's own charter of recording only what the paper says.
The Lean tree's `satisfiable` / `SatisfiableAbs` / `FormulaSatisfiable` (`FormalSystem/Semantics/Validity.lean:129,138,154`)
are **repository-native vocabulary**, built from `def:logical-consequence`'s consequence relation
(existential witness against `⊭ ⊥`-style unsatisfiability) but not themselves quoted from, or
citable against, any paper anchor. Any future task that wants to claim "satisfiability" as a
paper-sourced notion should be corrected to cite `def:logical-consequence` (consequence) instead,
or should first get an actual `Ddef`/`\aitem` added to the paper before this file can track it.

---

## Deliberately not covered (scope boundary, not an oversight)

The following paper machinery is adjacent to the entries above but was **not** included in this
round's manifest, because it was not requested and adding it would widen this file's maintenance
surface without a consuming task yet:

- ~~`def:constraints`, `lem:constraint`, `lem:fibers`, `lem:admissible`, `lem:step`~~ — **no
  longer excluded**: promoted into coverage on 2026-08-11 (see "Coverage extension" above),
  because the paper-refactor cluster's descriptions quote them and commit to lemma-for-lemma
  mirroring.
- `def:task-topology` and its topology properties (`T1`, `R0`, `Discrete`) — topology is not named
  in this task's "cover at minimum" list.
- `def:derivability`, `def:soundness` — proof-theoretic, not semantic, definitions; not named in
  this task's "cover at minimum" list.
- `def:time-shift-histories` and the time-shift preservation lemmas.

If a future task needs to cite paper text for any of the above, add it here first (see "How to
extend this record" below), rather than quoting the paper directly in a task spec.

## Downstream consumers (informational, not authoritative — the tasks own their own scoping)

At recording time, the following live tasks quote paper anchors tracked in this file directly in
their `state.json` descriptions and should be re-checked against this file (not the paper) on any
future revision: the `paper-refactor` cluster (tasks whose `topic` field is `paper-refactor` in
`specs/state.json` — quote `def:frame`, `def:world-history`, `def:logical-consequence`,
`def:BL-semantics`'s box clause, and `def:temporal-order`/`def:task-relation`/`def:directed`
verbatim in their re-issued descriptions). See this task's own research report for the audit of
task 424's exposure to the `def:BL-semantics` box-clause / `TruthAt` architecture.

## How to extend this record

1. Identify the anchor's `\label{}` name (environment case) or `\aitem` key + enclosing label
   (item case) or `\aitem` label (aitem case) in the live paper — never a line number.
2. Run `scripts/check-paper-definitions.sh --resolve "ANCHOR|KIND|ENCLOSING|LOCATOR"` (see that
   script's `--help`) to print the currently-resolved text and its sha256.
3. Add a new `### \`ANCHOR\`` entry above quoting that text verbatim, and add a row to the
   machine-readable manifest below with the printed hash.
4. Re-run `scripts/check-paper-definitions.sh` with no arguments and confirm it reports the quiet
   case-(a) pass.

## Machine-readable manifest

`scripts/check-paper-definitions.sh` parses the fenced block below directly — it is the single
source of truth for anchor IDs, kinds, and expected hashes; the prose entries above exist for
human readability and are not machine-parsed. Columns: `anchor_id|kind|enclosing|locator|sha256`.
`kind` is one of `env`, `item`, `aitem` (see "Hashing method" above). `-` means "not applicable".

<!-- MANIFEST:BEGIN -->
```
# anchor_id|kind|enclosing|locator|sha256
def:temporal-order|env|-|-|bc89eea5f9bafa1e326bc8bda93b6631c49212c1f0c3253208f0cfbdb049fb1f
def:task-relation|env|-|-|b63a34aa6a9f64e5e18df88de658530739caa0561755e694d6cd4b983eeb267b
def:directed|env|-|-|ef9852efbe0e53cc226423bd2c9d5da0decba54cde07bd7f91f1e06515c97d20
def:frame|env|-|-|944879579f6b176390b9622db9c9cdfa52f07bc3f8244bd3f01dac1f77ca6926
def:frame#Compositionality|item|def:frame|Compositionality|4b9248498399338eeaccb63c5e8952ca0928b87bb85bcd94f596d9c263bb64fa
def:frame#Seriality|item|def:frame|Seriality|ad1863bf950f17906a79b469b40fddb102e4abf5bd1bfd828a2f4b4900c7dbad
def:frame#Limit|item|def:frame|Limit|3eedd389d6cbdf5dff50f82ad9bafed30fe5eff5ec923cfdc165ca75dbe60a5f
def:frame#Spherical|item|def:frame|Spherical|656c4b68708828cbf47849b70636c428257b45f6b9427fa0368d6876408947c9
lem:nullity|env|-|-|7840512db4eb75a6f8d4224b80d784239e554f2742163722236df4778de8d9de
def:world-history|env|-|-|4aaa6ec0db38ccbba25ce6dc61d81b8a28f82913ba6b2b1defabaa42f9caf205
thm:extension|env|-|-|e63eac74fb8de22197f9bbb732bf83ea49def7308ca499817683145c99762b3e
cor:occurrence|env|-|-|b0228712e0d847f600b5b353b783ec3bc24e7722620f7e39e284af1f1fa5ebea
def:constraints|env|-|-|3678ab023f5c7f51e790eb1f8790ae78f4c7f6bb4cd4f7dc3e41b0408b3ac581
lem:nesting|env|-|-|ffc2d16fbded65204f743530a43834025048ac59d7f70524389ba488c9305266
lem:nonempty|env|-|-|04a49ef8a67071b45bb42ad91ae8e7eba8a3c89a7fd785017e33507b7f8cc6c7
lem:constraint|env|-|-|9ebed5d29cd939e0b3486dee775b8135077819f0de7228877ffeef6a928bf5e7
lem:fibers|env|-|-|42ec404f8082ceeff30b1da5a28c076c9880704c92d500cb5068ce8b0a1ba7e2
lem:admissible|env|-|-|cc94cfdca6f3c1f581f3876ba737525288417ac9c05b3293c8fa4a621d262469
lem:step|env|-|-|82ab9eb861c6e4cb99575946f4a74f4296b5c8b979d3c2f6e28ac9fa705da94f
def:BL-model|env|-|-|239fba0ff163b461e0d1bf3c0e94da0cb0b62e7b2d7f4519916af4cc50d6967f
def:BL-semantics|env|-|-|8fec78985c2efea20d13c1e6d5c7536ae0e0d864172bbe0460441d61addf22e3
def:BLplus-language|env|-|-|a43b3df2ea2fcb96eeb156b3403a33ac51fcafd2ad4eb55e7915c07cf509f8b7
def:BLplus-semantics|env|-|-|f40f514e60dcb7a6b36dee664ebcc1d55c2c6bce9e044c5814071f521674d670
def:BLplus-defined|env|-|-|2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e
def:frame-validity|env|-|-|2bcc85b0781fd4cc5af05d0741c64f44662706523cf023f3d5237d4ed1e8d1b9
def:logical-consequence|env|-|-|e65c228721a39f8622d2256988b574c96a6cb7fdd6723a2eb63ce8a1f87770f0
CO|aitem|-|-|5c468c01776c449b212c98070b5bfc70951691a23905cd4d4c249bf1f5375d41
TMP-CO|aitem|-|-|2205e7115342b037faeb67a24cb7679e393af582cedf6752c0c07d9a28b8f1be
def:S5|env|-|-|b090402a8048cd02cc163ebf0af7ec3f9c2630edc943feeaf5e9873072f50211
def:BX|env|-|-|1518997ec9497a1fe90f42c270f9b7c32c8b71392846c9a371548aa823fbbc65
def:TMplus-f|env|-|-|419a80a7d6e9f44a41883f7ce5d0693396e6126fc06a4909b5195d2a98965fe2
def:TMplus-d|env|-|-|aa6542e6eee06e5c94dddc4b4581715d8b4310bba53615e0c0f80188016f10cf
def:TMplus-c|env|-|-|b5cca1c9667cb5e516b30a60a28dbef85f83ee40692a0ce5d92aac232d41a6a9
def:TMplus|env|-|-|2a150421d56a2480b1c03e97acc6b0342f691b43767760163b50245694ae87ea
thm:M5-valid|env|-|-|bce3cc3be256f7b4c10e34a397e4b3b14abe4e8ed6728e8e91768e9a2ad8b2af
thm:TM-soundness|env|-|-|23cae2b2fcd8c034b82c4f9294b21aa4d141429a278fa08d085cae2c53bf0529
app:discrete|env|-|-|46615df7e02cf9bc59eae1c0ca6ce58f8abdc6ccae8750e59bf5aee050900eb1
app:dense|env|-|-|d7b9a4391d9d42fe9ea444bf7dc52be2c526dcf4d3ecc8716ba9b88d6684b23d
app:complete|env|-|-|93a5bd056796ac04d369c1e2e5e494004914b5fb7ae9eb928efea89d8fb69122
def:frame-properties|env|-|-|fa34cc4eed0a85acd583c4b7634beddbaf58bb2756ed95bd0bb06c8560e6e0c0
cor:spherical-finite|env|-|-|76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d
cor:tm-completeness|env|-|-|7c7bfe057fc7832d7a9e1de316f2003ccfaa61832b27448a59424ccfcd08852e
cor:tm-decidability|env|-|-|ac35ffaa47da467febc431669f604d02622301f369bf795075dbe46ed3ee1bcf
def:id|env|-|-|f9d32bd7c7faf6f1b7d57b4b970d1e628719188452a5872bfbe5fcc1dc5a0e4a
def:strongest|env|-|-|de29ef2b68a2c54decf3d40a195b1e3aeceee1e26a348e0386cc0103ac2a5f66
thm:exist|env|-|-|f5b9c808a519f0368fae920a5315e9b87706ec266143ddc7fcfbb2d304d4519d
lem:uniq|env|-|-|caf3d5daa522050ef1e3ab9a93e97efee7f2843f929530442814fdf8cec1a0f2
thm:s4|env|-|-|d465d756c5c5beed3fae760dc704be91d873184758448bbc74984cf1f520d33d
thm:sym|env|-|-|d485d7b791335d9b000c9e6d8b0e3e611cf60ae58bf8a78ed2d260adac9118d6
```
<!-- MANIFEST:END -->

## Invocation from skills or hooks — decision (recorded, not implemented)

CI cannot enforce this lint: `.github/workflows/ci.yml` has no visibility into
`/home/benjamin/Philosophy/Papers/` (a different repository entirely), so wiring it into CI would
require vendoring or submoduling the paper, which is explicitly out of scope for this task.

**Decision**: `scripts/check-paper-definitions.sh` should be invoked manually for now, in the same
family as its siblings (`check-copyright-headers.sh`, `check-module-invariants.sh`,
`readme-lint.sh`, `typst-sync-check.sh`), none of which are CI- or hook-wired either. The strongest
candidate for automatic invocation, if this is revisited, is a **skill preflight hook** for the
`paper-refactor` topic specifically (e.g. `/research`, `/plan`, `/implement` preflight for a task
whose `topic` is `paper-refactor`) — that is the exact population of tasks that quotes this file's
anchors and would benefit from an automatic staleness check before dispatch. A git pre-commit hook
was considered and rejected: this repository's commits do not touch the paper file at all (it
lives in a separate repository), so a pre-commit hook here would never fire on the event that
actually causes drift. **Implementing either integration is explicitly out of scope for this task**
(deliverable 2 is the lint script itself); this section records the recommendation for whoever
picks up that follow-on work.
