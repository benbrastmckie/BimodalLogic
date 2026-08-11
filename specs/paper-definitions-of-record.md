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
| **File checksum, re-pinned at `BL^+` coverage extension (sha256, current authoritative pin)** | `f07441ebb9751d1e955d5af135bebc107ef7163dea49ccfb29b763aae67d1b27` |
| Line count at `BL^+` coverage extension | 4098 |
| `BL^+` coverage extension re-pin (UTC) | 2026-08-10 (three `def:BLplus-*` anchors added; the run immediately before the re-pin reported case (b) — paper moved, all 23 previously-recorded definitions unchanged) |

<!-- PAPER_PATH: /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex -->
<!-- PAPER_REPO_ROOT: /home/benjamin/Philosophy/Papers/PossibleWorlds -->
<!-- PINNED_COMMIT: cf0da976bd7947e6fae2aa9212953d094faab2c1 -->
<!-- FILE_CHECKSUM: f07441ebb9751d1e955d5af135bebc107ef7163dea49ccfb29b763aae67d1b27 -->
<!-- LINE_COUNT: 4098 -->

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

The `def:BLplus-semantics` entry carries an argument-order caveat: the paper's footnote describes
this repository's `snce`/`untl` constructors as guard-first/event-second, and the Lean tree is
event-first/guard-second. That divergence is quoted here (never silently corrected — this file
records what the paper says) and escalated in `specs/decisions/untl-snce-argument-order.md`.

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
	    The proof appeals to Zorn's lemma and hence to the axiom of choice, and so the derivation of \textit{Occurrence} from \textit{Seriality} and \textit{Spherical} in \textbf{\ref{cor:occurrence}} is a theorem of ZFC, in contrast with the choice-free derivation of the zero loops in \textbf{\ref{lem:nullity}}.
	  }
\end{Tthm}
```
sha256: `af9b23bf53bd9194a496db497197a641317cd3882078f52654b890f1c08b6dab`

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

### `def:constraints` — the constraints imposed on a new duration

```latex
\begin{Ddef} \label{def:constraints}
	For a partial history $\tau : X \to W$ over a frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the \textit{constraints imposed on $z$} are the segments $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t,s \in X$ where $t < z < s$, and the fibers $\Fib(\tau(t), z - t)$ for $t \in X$ otherwise.
\end{Ddef}
```
sha256: `d763818240e73faca164fde60ceeed97a3c5ab9ece9af814724eed28c4488e41`

Promoted from lead-in prose to a numbered definition so the lemmas below can cite it by name.

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
	Although the axioms of \textbf{TM}$^+$ are drawn from the Burgess-Xu (BX) system, the repository's \texttt{snce}/\texttt{untl} constructors follow the Pnueli convention with the guard as the first argument and the event as the second: $\varphi\since\psi$ means $\psi$ held at some past time with $\varphi$ holding throughout the interval since, and $\varphi\until\psi$ means $\psi$ will hold at some future time with $\varphi$ holding throughout the interval until $\psi$ holds.%
	}
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[($\since$)] $\M,\tau,x \vDash \varphi\since\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z < x$ where $\M,\tau,y \vDash \varphi$\\
      \strut\hspace{1.55in}for all $y \in D$ with $z < y < x$.
		\item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z > x$ where $\M,\tau,y \vDash \varphi$\\ 
      \strut\hspace{1.55in}for all $y \in D$ with $x < y < z$.
	\end{enumerate}
\end{Ddef}
```
sha256: `3f56a996ad17e1318eb1c448b3af7d3a5bc583785df739045ce274ba6d8be59b`

**Argument-order caveat — the footnote misdescribes this repository.** The `\footnote` inside the
block above asserts that "the repository's `snce`/`untl` constructors follow the Pnueli convention
with the guard as the first argument and the event as the second". The Lean tree is the other way
round: `Formula.snce`/`Formula.untl` (`FormalSystem/Syntax/Formula.lean:85-90`) and `TruthAt`'s
clauses (`FormalSystem/Semantics/Truth.lean:134-135`) are **event-first / guard-second**, and both
`Axiom.dense_indicator` (`FormalSystem/Semantics/Validity.lean:229-231`) and the `K⁺` combinator
(`FormalSystem/Syntax/Formula.lean:164-166`) depend on the event-first reading. This record quotes
the paper verbatim, as it must; the divergence is recorded and escalated separately in
`specs/decisions/untl-snce-argument-order.md`, and the Lean convention is **not** being changed.

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
- `def:frame-properties` (`Discrete`, `Dense`, `Complete`, `Deterministic` frame classes).
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
thm:extension|env|-|-|af9b23bf53bd9194a496db497197a641317cd3882078f52654b890f1c08b6dab
cor:occurrence|env|-|-|b0228712e0d847f600b5b353b783ec3bc24e7722620f7e39e284af1f1fa5ebea
def:constraints|env|-|-|d763818240e73faca164fde60ceeed97a3c5ab9ece9af814724eed28c4488e41
lem:constraint|env|-|-|9ebed5d29cd939e0b3486dee775b8135077819f0de7228877ffeef6a928bf5e7
lem:fibers|env|-|-|42ec404f8082ceeff30b1da5a28c076c9880704c92d500cb5068ce8b0a1ba7e2
lem:admissible|env|-|-|cc94cfdca6f3c1f581f3876ba737525288417ac9c05b3293c8fa4a621d262469
lem:step|env|-|-|82ab9eb861c6e4cb99575946f4a74f4296b5c8b979d3c2f6e28ac9fa705da94f
def:BL-model|env|-|-|239fba0ff163b461e0d1bf3c0e94da0cb0b62e7b2d7f4519916af4cc50d6967f
def:BL-semantics|env|-|-|8fec78985c2efea20d13c1e6d5c7536ae0e0d864172bbe0460441d61addf22e3
def:BLplus-language|env|-|-|a43b3df2ea2fcb96eeb156b3403a33ac51fcafd2ad4eb55e7915c07cf509f8b7
def:BLplus-semantics|env|-|-|3f56a996ad17e1318eb1c448b3af7d3a5bc583785df739045ce274ba6d8be59b
def:BLplus-defined|env|-|-|2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e
def:frame-validity|env|-|-|2bcc85b0781fd4cc5af05d0741c64f44662706523cf023f3d5237d4ed1e8d1b9
def:logical-consequence|env|-|-|e65c228721a39f8622d2256988b574c96a6cb7fdd6723a2eb63ce8a1f87770f0
CO|aitem|-|-|5c468c01776c449b212c98070b5bfc70951691a23905cd4d4c249bf1f5375d41
TMP-CO|aitem|-|-|2205e7115342b037faeb67a24cb7679e393af582cedf6752c0c07d9a28b8f1be
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
