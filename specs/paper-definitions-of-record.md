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
<!-- PINNED_COMMIT: 94f850f69f345fd8e4be2516eb3d74f944e66445 -->
<!-- FILE_CHECKSUM: 5d700a2f05999bb697ab55e16f5a26732cbf7453dbb7d909d21fb67c70da7644 -->
<!-- LINE_COUNT: 4856 -->

### Drift correction and coverage extension (2026-08-17): the target-state-revision re-pin

Absorbed as one re-pin during the reference-manual target-state revision:

- **22 drifted anchors re-quoted and re-hashed**: `thm:s4`, `thm:sym` (macro rename
  `\mathrm{Str}` → `\Str`; `thm:sym` also gained a Williamson/Bacon–Zeng footnote),
  `def:task-relation`, `thm:extension`, `def:constraints`, `lem:nesting`, `def:BL-semantics`,
  `def:BLplus-semantics`, `def:frame-validity`, `def:logical-consequence`, `def:BX`,
  `def:TMplus-f`, `def:TMplus-c`, `def:TMplus`, `app:discrete`, `app:dense`, `app:complete`,
  `cor:tm-completeness`, `def:id`, `def:strongest`, `thm:exist`, `lem:uniq`.
- **2 dangling anchors retired from the manifest** (entries retained, marked DANGLING above):
  `def:BL-model`, `cor:tm-decidability`.
- **3 anchors added** (newly load-bearing for the manual's target-state revision):
  `thm:BLplus-PastFuture`, `thm:BLplus-NextPrevious`, `def:time-shift-histories`.
- Sentinels re-pinned: checksum `9fa1c5fc829ecab11fbf5685be622fc90bf4f9198119db48f35ad8a81ce0a2bf`,
  paper repo `git HEAD` `831c599d3f76fc9ebb7fb297ef80442c4624a035` (file dirty against it, per
  the dirty-pin caveat below), 4228 lines, 2026-08-17T17:31Z. Post-edit verification run
  reported all 50 recorded definitions unchanged — pass.

### Drift correction (2026-08-17, second wave): lem:fibers retired

A later editing wave the same day removed `\label{lem:fibers}` from the live paper; every other
recorded anchor verified unchanged. The `lem:fibers` entry is retained above, marked DANGLING and
removed from the manifest. Sentinels re-pinned: checksum
`f134fd7d460c08aaf94c5b1c09571ab2663c509d1ee32f2d31b89ee640281381`, paper repo `git HEAD`
`d1a26f75bcd3e0623d1593263471c5fc63126894` (dirty-pin caveat applies), 4213 lines.

### Drift correction (2026-08-25), part 1: dangling anchors and substantive drift

The paper moved again (4213 -> 4856 lines). `check-paper-definitions.sh` reported **32 drifted
anchors and 6 unresolvable anchors** before this correction. Part 1 resolves every unresolvable
anchor and re-quotes the anchors whose *mathematics or claim* actually changed; part 2 (below)
absorbs the residual terminological and cosmetic drift and re-pins the sentinels.

**6 unresolvable anchors, resolved (4) or retired (2):**

| Anchor | Cause | Resolution |
|---|---|---|
| `def:frame#Compositionality` | paper re-spelled `\item[\it X:]` as `\item[\bf X:]` | resolver made markup-agnostic; re-quoted, re-hashed |
| `def:frame#Seriality` | same | same |
| `def:frame#Limit` | same | same |
| `def:frame#Spherical` | same, plus a genuine change (see below) | same |
| `thm:s4` | label removed from the paper | retired DANGLING; succeeded by `thm:s5` |
| `thm:sym` | label removed from the paper | retired DANGLING; succeeded by `thm:s5` |

The four `def:frame#*` anchors did **not** go dangling because the paper dropped an axiom — all
four axioms are still there. They went dangling because `resolve_text`'s `item` case searched for
the literal `\item[\it NAME:]` and the paper re-spelled the emphasis command. That brittleness is
now fixed in the script itself rather than by re-keying the manifest on `\bf` (which would fail
again on the next markup wave); see "Hashing method" above.

`thm:s4` and `thm:sym` were merged by the paper into a single `thm:s5` (live line 2158), which
states S4, B, **and** T as three conjuncts of one theorem. `thm:s5` is added to the manifest here.

**7 substantive anchors re-quoted and re-hashed** (what changed, and whether it reaches Lean):

| Anchor | What changed | Lean impact |
|---|---|---|
| `def:directed` | split into two clauses, `$\supseteq$-Directed` and `$\subseteq$-Directed`; the old bare "directed" is now the `$\supseteq$` half | **Yes.** Every in-tree quotation of "directed family" is now under-qualified and must read `⊇`-directed. `Spherical` consumes the `⊇` half. |
| `def:frame` | `frame` -> `task frame`; `Spherical` now reads "$\supseteq$-directed family"; a new footnote places Spherical as $\mathbf{S}_1^d$ in the Ćmiel-Kuhlmann-Kuhlmann ball-space hierarchy, **strictly stronger** than "spherically complete" ($\mathbf{S}_1$) | **Yes.** `TaskFrame.lean`'s `Spherical` docstring must carry the `⊇` qualifier and the $\mathbf{S}_1^d$ characterization. Still four axioms; nullity is still not one. |
| `def:frame-properties` | the `Deterministic` clause was **removed**; only Discrete/Dense/Complete remain. Deterministic is now standalone `def:deterministic` (live line 2868) | **Yes.** Any citation of `def:frame-properties` for determinism must repoint to `def:deterministic`. |
| `cor:tm-completeness` | restructured; now states four systems explicitly (TM$^+$ strongly complete over **all** task frames; TM$^+_\textsc{d}$ strongly complete over the dense; TM$^+_\textsc{f}$ weakly complete over $\Z$-time; TM$^+_\textsc{c}$ **weakly** complete over the dense-and-complete class), and adds a footnote attributing these results *and the corresponding soundness results* to this Lean repository | **Yes, twice.** (i) TM$^+_\textsc{c}$ is now weak completeness over the dense-and-complete class, which is what `FrameClass.Dedekind` is — the in-tree "completeness *simpliciter*" / "no `FrameClass` member picks it out" passages are stale. (ii) The new footnote attributes strong completeness for TM$^+$ / TM$^+_\textsc{d}$ to this repository, where both are **conditional** on the unproved `CompactBase` / `CompactDense`. That mismatch is a paper-side correction, recorded in the author memo. |
| `def:strongest` | "strongest objective **normal** modal operator" -> "strongest objective modal operator"; "iff" -> "if and only if"; the normality-redundancy comment removed | No Lean counterpart in the tree (objective-modality appendix is unformalized). |
| `thm:exist` | same "normal" drop | As above. |
| `def:id` | substantially expanded: propositional *variables* rather than sentence letters, an explicit $\chi_{(\psi/\varphi)}$ substitution convention, and a long free-for/operator-scope footnote making $\equiv$ a congruence for the logical vocabulary but not for operator terms | No Lean counterpart (identity extension is unformalized). |
| `thm:extension` | footnote restructured; it **no longer says** the Zorn appeal is "and hence to the axiom of choice", now saying the derivation of *Occurrence* is "a theorem of ZFC" and contrasting it with the choice-free `lem:nullity` and `cor:spherical-finite` | **Yes.** Three in-tree sites quote the retired "and hence to the axiom of choice" wording verbatim. |

(That is eight rows for "7 substantive anchors": `def:strongest` and `thm:exist` carry one and the
same change — the `normal` drop — and the plan counted them as one item. The row count, not the
item count, is what the manifest tracks.)

### Drift correction (2026-08-25), part 2: terminological drift, `def:deterministic`, re-pin

Part 2 absorbs the residual drift left by part 1 and re-pins the sentinels. After part 1 the
checker reported **24 drifted anchors and 0 unresolvable anchors**; all 24 are re-quoted and
re-hashed here, and the checker now returns the quiet case-(a) pass.

**The global `frame` -> `task frame` rename** accounts for most of it. The paper renamed its
central object, so 17 anchors changed by exactly that substitution and nothing else:
`lem:nullity`, `def:world-history`, `cor:occurrence`, `lem:nesting`, `lem:nonempty`,
`lem:admissible`, `lem:step`, `def:BL-semantics`, `def:time-shift-histories`,
`def:frame-validity`, `app:discrete`, `app:dense`, `app:complete`, `cor:spherical-finite`,
`thm:BLplus-NextPrevious`, `def:constraints`, `lem:constraint`. This is terminological, not
mathematical — but it is **not** cosmetic for this repository, because the tree quotes several of
these blocks verbatim in docstrings. Those quotations are corrected against this record.

**Three of the 24 carry a second, non-terminological change** and must not be filed as pure
rename:

| Anchor | Second change | Lean impact |
|---|---|---|
| `lem:constraint` | "form a directed family" -> "form a **$\supseteq$-directed** family", following `def:directed`'s split in part 1 | **Yes.** Every in-tree "directed family" quotation is under-qualified. |
| `def:constraints` | the $\F = \tuple{W, \D, \Rightarrow}$ expansion contracted to a bare $\F$ | No. |
| `thm:BLplus-NextPrevious` | the statement was **split into three sentences**: the `\Next` biconditional, then the no-successor `\leftrightarrow \bot` case as a separate "Additionally" clause, then the past dual. Same content, restructured. | No. |

**Seven anchors changed cosmetically only** — `\vspace` retuning (`def:task-relation`,
`def:BL-semantics`, `def:BLplus-semantics`, `def:S5`), `\item[\it ...]` -> `\item[\bf ...]`
(`def:task-relation`'s Fiber/Cone/Segment items), a `\mathrm{Th}` -> `\Th` macro swap inside an
already-commented-out block (`def:TMplus-c`), prose rewording that changes no claim (`def:BX`'s
"swapping occurrences" -> "interchanging all occurrences", `def:TMplus-f`'s Hölder sentence), and
`def:TMplus`'s deletion of a large commented-out conservativity footnote plus its `% TODO`.

**One anchor added**: `def:deterministic` (live line 2868). The paper removed `Deterministic` from
`def:frame-properties` and gave it its own definition. It is load-bearing —
`FormalSystem/Examples/TemporalStructures.lean` cites it — so it is pinned here rather than left
untracked.

**Twelve new appendix anchors deliberately NOT pinned** (decision recorded, not an oversight).
The paper grew a topology / presheaf / Conduché appendix block carrying
`def:task-topology` (2872), `app:topology-t1` (2904), `app:topology-r0` (2923), `app:gluing`
(2976), `def:interval-site` (3208), `def:behavior-presheaf` (3233), `lem:factorization-linear`
(3247), `lem:interval-twisted-arrow` (3278), `app:presheaf-dictionary` (3313), `def:path-category`
(3386), `def:conduche` (3406), `cor:path-fibration` (3510). **None of them is cited anywhere in
this repository and none has a Lean counterpart.** Pinning them would widen this file's
maintenance surface to a region the tree does not depend on, which is exactly what the
"Deliberately not covered" scope boundary below exists to prevent. If any of them becomes
load-bearing, add it then, via
`check-paper-definitions.sh --resolve "ANCHOR|env|-|-"`.

**Sentinels re-pinned**: checksum
`5d700a2f05999bb697ab55e16f5a26732cbf7453dbb7d909d21fb67c70da7644`, paper repo `git HEAD`
`94f850f69f345fd8e4be2516eb3d74f944e66445` (file dirty against it — the dirty-pin caveat below
applies unchanged), 4856 lines (up from 4213). Post-edit verification run returned the quiet
case-(a) pass: `bash scripts/check-paper-definitions.sh` exits 0.

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
  **Superseded 2026-08-17**: the paper has since removed the footnote outright — the live anchor
  `edde7517…` is footnote-free — and the Lean tree has been migrated to guard-first, so there is
  no longer a convention to describe on either side. The bullet above is retained as the record of
  the 2026-08-12 wave; the caveat under the entry itself has been rewritten again accordingly.
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
above and the rewritten caveat under the entry itself. **Superseded again 2026-08-17**: the
footnote has since been removed from the paper entirely, and the Lean tree has been migrated to
guard-first, discharging the caveat rather than restating it. The decision record is closed as
DECIDED.

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
- **`item` anchors** (one of `def:frame`'s four axioms, which are `\item[MARKUP NAME:]` entries
  with no `\label` of their own): the enclosing environment is resolved first as above, then the
  hash covers exactly the single line inside that block whose item label is `NAME:`. Resolution is
  **markup-agnostic**: the emphasis command is tried in the order `\it`, `\bf`, `\em`,
  `\itshape`, `\bfseries`, bare, and the first match wins. This is deliberate — the paper
  re-spelled all four `def:frame` items from `\item[\it NAME:]` to `\item[\bf NAME:]` in a
  2026-08 editing wave, and a resolver keyed on one spelling reported four live anchors as
  DANGLING on a purely cosmetic change. The hash still covers the resolved line **verbatim**, so
  the markup change itself is still reported as drift; only the *resolution* is markup-agnostic.
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
		\item[\bf Fiber:] $\fib{w, x} \coloneq \set{u \in W : w \Rightarrow_x u}$.
		\item[\bf Cone:] $(w)_x \coloneq \bigcup\limits_{\vert{y} < x} \fib{w, y}$ where $x > 0$.
		\item[\bf Segment:] $[w, v]_x^y \coloneq \fib{w, x} \cap \fib{v, -y}$ where $x, y \geq 0$.
	\end{enumerate}
  \vspace{-.1in}
\end{Ddef}
```
sha256: `c12d018290feb5a12e1757aae3718593c940c3d5bd19c6bbd5d8a87bcf525193`

### `def:directed` — directed family (used by Spherical)

```latex
\begin{Ddef} \label{def:directed}
	A nonempty family of sets $\mathcal{S}$ is:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\bf $\mathbf{\supseteq}$-Directed:] just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.
		\item[\bf $\mathbf{\subseteq}$-Directed:] just in case $S_1, S_2 \subseteq S$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.
	\end{enumerate}
\end{Ddef}
```
sha256: `096a8398223596825ff71372dc565a77354d41fff69f8bf0b3fe485edad0c75b`

### `def:frame` — the frame definition (whole block, all four axioms)

```latex
\begin{Ddef} \label{def:frame}
	A \textit{task frame} is any $\F = \tuple{W, \D, \Rightarrow}$ where $W$ is a nonempty set of world states, $\D$ is a temporal order, and $\Rightarrow$ is a task relation satisfying the following for $x, y \geq 0$:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\bf Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.
		\item[\bf Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.
		\item[\bf Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.
		\item[\bf Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments.%
    \footnote{
      The nonempty fibers and segments form a \textit{ball space} on $W$ in the sense of \'{C}miel, Kuhlmann, and Kuhlmann.
      \textit{Spherical} is the downward-directed-intersection condition $\mathbf{S}_1^d$ of the ball-space hierarchy of~\cite{Cmiel2021}--- the nest condition $\mathbf{S}_1$ with a $\supseteq$-directed system of balls in place of a nest--- and so is strictly stronger than the standard \textit{spherically complete} condition, which is $\mathbf{S}_1$ itself.
    }
	\end{enumerate}
  \vspace{-.1in}
\end{Ddef}
```
sha256: `294733a3cb5d65a1c048d850689e6d78e7a29c8b78cc8fed5d35b3ce3618583b`

Four axioms, not more, not fewer — **Nullity is NOT an axiom**, it is `lem:nullity` below, DERIVED
from Seriality and Limit. Each axiom is also tracked individually (sub-anchors of `def:frame`, no
`\label` of their own — resolved as the enclosing block's `\item[MARKUP NAME:]` line, markup-agnostically), so that a
future paper edit which reorders or drops exactly one axiom is named precisely rather than only
flagging "`def:frame` changed":

| Sub-anchor | Verbatim text | sha256 |
|---|---|---|
| `def:frame#Compositionality` | `\item[\bf Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.` | `35905314d686a1676dfda8d4c7d092de8c3335104c0510e7069d6656a4ac87e3` |
| `def:frame#Seriality` | `\item[\bf Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.` | `afffcd074afce7442d2c02108f49e70c128de3d4d7ccac41833f95e2ae3cd952` |
| `def:frame#Limit` | `\item[\bf Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.` | `6acfdc8df119a71d24d863399f6e6d3aff9a507e920c8a57e9427df94224b369` |
| `def:frame#Spherical` | `\item[\bf Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments.%` | `92b407bc45ab62ce5bac22982c67e2555efb4a990ddf8e61fd7f1b45840bcf60` |

Note: **Compositionality is a biconditional**, not a one-directional implication — this is load
bearing (the right-to-left direction is used directly in, e.g., the constraint-family proofs).

### `lem:nullity` — DERIVED: `w ⇒₀ w` (Nullity is not an axiom)

```latex
\begin{Lthm} \label{lem:nullity}
	$w \Rightarrow_0 w$ for every world state $w \in W$ in every task frame $\F = \tuple{W, \D, \Rightarrow}$.
\end{Lthm}
```
sha256: `94ed018343635a8ef6671daef07eaa72da1cb49fd11043fb3aa9b391a2c9c973`

Proved (per the paper) from Seriality at `x = 0` plus Limit — choice-free, unlike `thm:extension`
below which needs Zorn's lemma.

### `def:world-history` — partial history, world history, totality, the extension order, `H_F`

```latex
\begin{Ddef} \label{def:world-history}
	A \textit{partial history} over a task frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$.
	% Since the difference $y - x$ is negative whenever $y < x$, these instances are covered by the converse convention: $\tau(x) \Rightarrow_{y-x} \tau(y)$ then reads $\tau(y) \Rightarrow_{x-y} \tau(x)$.
	A \textit{world history} is any partial history whose domain $X$ is \textit{convex}, so that $y \in X$ whenever $x, z \in X$ and $x < y < z$.
  A world history is \textit{total}--- equivalently, a \textit{possible world}--- just in case $X = D$.
	A partial history $\sigma$ \textit{extends} $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$.
	The set of all total world histories over $\F$ is denoted $H_{\F}$.
\end{Ddef}
```
sha256: `3d4679bdb4828aad40f6a0d8deb6ff5af09fa52d2181100cfe159f2a23303a15`

Layering, exactly as the paper states it: **partial history** (nonempty domain, no convexity
requirement) → **world history** (convex domain) → **total** / **possible world** (`X = D`). The
vocabulary "task-constrained function" is retired paper-wide and must not be reintroduced as
current terminology (see the paper-refactor cluster's task descriptions, which record the same
point). `H_F` denotes only the *total* histories.

### `thm:extension` — every partial history extends to a total world history

```latex
\begin{Tthm} \label{thm:extension}
	Every partial history $\tau : X \to W$ over a task frame $\F = \tuple{W, \D, \Rightarrow}$ is extended by some total world history $\sigma \in H_{\F}$.%
	  \footnote{
	    The proof appeals to Zorn's lemma, and so the derivation of \textit{Occurrence} from \textit{Seriality} and \textit{Spherical} in \textbf{\ref{cor:occurrence}} is a theorem of ZFC, in contrast with the derivation of the zero loops in \textbf{\ref{lem:nullity}} and the derivation of \textit{Spherical} for finite $W$ in \textbf{\ref{cor:spherical-finite}}, both of which are choice-free.
	  }
\end{Tthm}
```
sha256: `1140d4819b9b0030275f249c60b7cb2fb15da97f9d07df2196d6e06508f65e38`

### `cor:occurrence` — DERIVED: every world state occurs at any prescribed time in some total world history (renamed from `thm:occurrence`; see "Drift correction" below)

```latex
\begin{Cthm} \label{cor:occurrence}
	For any task frame $\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$, and time $x \in D$, there is a total world history $\tau \in H_{\F}$ where $\tau(x) = w$, and so $H_{\F} \neq \emptyset$.
\end{Cthm}
```
sha256: `244bb2e5f6036bbe405549501390b90f432ece28c232fd18caa8b82ab3bb9a8c`

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
	For a partial history $\tau : X \to W$ over a task frame $\F$ and duration $z \in D \setminus X$, the \textit{constraints on $z$} are the segments $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t,s \in X$ where $t < z < s$ when both $t,s \in X$, and the fibers $\fib{\tau(t), z - t}$ for $t \in X$ otherwise.
\end{Ddef}
```
sha256: `50aadae779c7d57c810e94209614b5cdfe2590fa82c1c0793db948e8d0917e28`

Promoted from lead-in prose to a numbered definition so the lemmas below can cite it by name.
The 2026-08-12 wave shortened the defined term to "the *constraints on `z`*" and added an explicit
"when both `t,s ∈ X`" guard to the segment case; the family being defined is unchanged. Note that
surrounding paper text (and `lem:nonempty`, untracked) still says "imposed on", so both phrasings
appear in the live paper — this record quotes whichever one appears inside the tracked block.

### `lem:nesting` — DERIVED: imposed fibers and segments nest along the time order

```latex
\begin{Lthm} \label{lem:nesting}
	For any partial history $\tau : X \to W$ over a task frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the fibers $\fib{\tau(t'), z - t'} \subseteq \fib{\tau(t), z - t}$ nest for all times $t \leq t' < z$ in $X$ and symmetrically for all times $z < t' \leq t$ in $X$, while the segments $[\tau(t'), \tau(s')]_{z - t'}^{s' - z} \subseteq [\tau(t), \tau(s)]_{z - t}^{s - z}$ nest for all times $t \leq t' < z < s' \leq s$ in $X$.
\end{Lthm}
```
sha256: `ed036f28b70b99d4294515c0f1da64a62e471aa4795394cda4d9010b1f1971a7`

The block carries an in-source `% FIX:` authorial note about the `\Fib` macro's italics. That line
is literal paper source and is inside the hashed region, so it is quoted here verbatim like any
other in-block comment; it is the paper author's note to themselves, not an instruction to this
repository. Paper order places this lemma immediately after `def:constraints` and before
`lem:nonempty`, which is why both sit here rather than beside `lem:constraint`.

### `lem:nonempty` — DERIVED: every imposed constraint is nonempty

```latex
\begin{Lthm} \label{lem:nonempty}
	For any partial history $\tau : X \to W$ over a task frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, every constraint imposed on $z$ is nonempty.
\end{Lthm}
```
sha256: `8067bf45a360f04db7a94280bde1b359dac58e8311f2fba1d58db15bf2336598`

Note the phrasing divergence already recorded under `def:constraints`: that definition was renamed
to "the constraints *on* `z`", while this lemma (and `lem:nesting`, `lem:constraint`, `lem:fibers`,
`lem:admissible` above and below) still says "imposed on". Both phrasings are live in the paper and
both are quoted as they stand; neither is silently normalized here.

### `lem:constraint` — DERIVED: the constraint family is directed and nonempty

```latex
\begin{Lthm} \label{lem:constraint}
	For any partial history $\tau : X \to W$ over a task frame $\F$ and duration $z \in D \setminus X$, the constraints imposed on $z$ form a $\supseteq$-directed family of nonempty sets.
\end{Lthm}
```
sha256: `ca6719adfaad9f6dc3d1b6a57de013598dd80847014d9c2fb60ed626b895370f`

This lemma now states **only** directedness + nonemptiness. The admissibility characterization
that an earlier paper wave carried inside this lemma was split out into `lem:admissible` below —
task specs quoting the old merged statement are stale. Its proof consumes Compositionality in
BOTH directions plus Seriality.

### `lem:fibers` — DERIVED: membership in all constraints ⟺ fiber condition at every time — **DANGLING as of the 2026-08-17 second re-pin (removed from manifest)**

The live paper no longer carries a `\label{lem:fibers}` (the lemma was removed or absorbed in
a later editing wave the same day as the first re-pin). The quoted text below is retained as
the last-resolved historical record. If the paper restores the anchor, re-add a manifest row
via `check-paper-definitions.sh --resolve "lem:fibers|env|-|-"`.

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
	For any partial history $\tau : X \to W$ over a task frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the function $\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs to every member of the constraints imposed on $z$.
\end{Lthm}
```
sha256: `9606ef1f1264887ed51358744df7e5fc290250dd8209f445fd138700da56de8e`

Proof consumes `lem:nullity` (the zero loop at `z` itself) plus `lem:fibers`.

### `lem:step` — DERIVED: the Step Lemma (sole *Spherical* application site)

```latex
\begin{Lthm} \label{lem:step}
	Every partial history $\tau : X \to W$ over a task frame $\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any duration $z \in D$.
\end{Lthm}
```
sha256: `b1f65f70cc243de5b32d4e2a46c35c986dd0322cf3ca0524fb76701af3e3be4b`

Proof: `lem:constraint` gives the directed family, *Spherical* provides a common member, and
`lem:admissible` certifies the extension. Closing remark (verbatim, load-bearing for the discrete
case): "When the family has a $\subseteq$-least member, that member already contains a candidate
and \textit{Spherical} is not needed."

### `def:BL-model` — model of `BL` — **DANGLING as of the 2026-08-17 re-pin (removed from manifest)**

The live paper no longer carries a `\label{def:BL-model}` — an exhaustive grep over the current
text finds no such label. The model definition survives in the paper without this anchor name.
The quoted text below is retained as the last-resolved historical record; the anchor is removed
from the machine manifest so the checker no longer reports it as unresolvable. If the paper
restores or renames the anchor, re-add a manifest row via
`check-paper-definitions.sh --resolve "def:BL-model|env|-|-"`.

```latex
\begin{Ddef} \label{def:BL-model}
	A \textit{model} of $\BL$ is a structure $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$ is a frame and $\vert{p_i} \subseteq W$ for every sentence letter $p_i \in \SL$.
\end{Ddef}
```
sha256: `239fba0ff163b461e0d1bf3c0e94da0cb0b62e7b2d7f4519916af4cc50d6967f`

### `def:BL-semantics` — the truth clauses (TruthAt), including the box clause's quantifier domain

```latex
\begin{Ddef} \label{def:BL-semantics}
	A \textit{model} of $\BL$ is a structure $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$ is a task frame and $\vert{p_i} \subseteq W$ for every sentence letter $p_i \in \SL$.
	Relative to a model $\M$, possible world $\tau \in H_{\F}$, and time $x \in D$, \textit{truth} is defined recursively as follows:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[($p_i$)] $\M,\tau,x \vDash p_i$ \textit{iff} $\tau(x) \in |p_i|$.
		\item[($\bot$)] $\M,\tau,x \nvDash \bot$.
		\item[($\shortrightarrow$)] $\M,\tau,x \vDash \varphi \rightarrow \psi$ \textit{iff} $\M,\tau,x \nvDash \varphi$ or $\M,\tau,x \vDash \psi$.
		\item[($\Box$)] $\M,\tau,x \vDash \Box \varphi$ \textit{iff} $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$.
		\item[($\Past$)] $\M,\tau,x \vDash \Past \varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $y < x$.
		\item[($\Future$)] $\M,\tau,x \vDash \Future \varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y\in D$ where $x < y$.
	\end{enumerate}
  \vspace{-.1in}
\end{Ddef}
```
sha256: `5f53774a3b8a04272bb3c8bf9d41f5cd777e8dc8b1ba30c92aa19113399b228b`

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
  The \textit{models} of $\BL^+$ are defined as in \textbf{\ref{def:BL-semantics}}, where \textit{truth in a model} $\M$ at $\tau \in H_{\F}$ and $x \in D$ extends the semantics \textbf{\ref{def:BL-semantics}} with the following clauses:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[($\since$)] $\M,\tau,x \vDash \varphi\since\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z < x$ where $\M,\tau,y \vDash \varphi$\\
      \strut\hspace{1.55in}for all $y \in D$ with $z < y < x$.
		\item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z > x$ where $\M,\tau,y \vDash \varphi$\\ 
      \strut\hspace{1.55in}for all $y \in D$ with $x < y < z$.
	\end{enumerate}
  \vspace{-.1in}
\end{Ddef}
```
sha256: `735c614181b042a498ec68826b234d30c9035464d9887b6fe717bab90e0705eb`

**Argument-order caveat — DISCHARGED 2026-08-17. There is no longer a divergence, and there is no
longer a footnote.**

Two things changed, in this order:

1. **The paper removed the footnote.** The anchor re-quoted above (`edde7517…`) is
   **footnote-free**: it carries the two `($\since$)` / `($\until$)` clauses and nothing else. Its
   two predecessors did carry an argument-order `\footnote` — first attributing a guard-first
   Pnueli convention to this repository's constructors (`3f56a996…`), then, after the paper's own
   `%% CHANGE (halden-defect-repair, untl-snce-convention)` repair, asserting the reverse
   (`f40f514e…`). Both are superseded. Neither sentence exists in the live paper, and neither
   should be quoted as current paper text; the historical quotations are retained in
   `specs/decisions/untl-snce-argument-order.md`.

2. **The Lean tree was aligned to the paper.** `Formula.untl` and `Formula.snce`
   (`FormalSystem/Syntax/Formula.lean:85-106`) now take the **guard first and the event second**,
   and `TruthAt`'s clauses (`FormalSystem/Semantics/Truth.lean:165-168`) read
   `| Formula.untl ψ φ => ∃ s, t < s ∧ TruthAt … s φ ∧ ∀ r, t < r → r < s → TruthAt … r ψ` — the
   existential witness second, the open-interval condition first, exactly as the `(until)` clause
   above states it. The migration was a uniform argument swap of the two constructors and every
   call site, carried out under
   `specs/448_migrate_snce_untl_to_guard_first_order/plans/01_guard-first-migration.md`. It is
   meaning-preserving by construction: `lake build` green at the same job count, per-file `sorry`
   census byte-identical to baseline, axiom count unchanged, and the role-keyed `toJson` oracle
   regenerating byte-identically.

Corroborated independently by `def:BLplus-defined` below, which the Lean derived operators now
match character for character: `$\past\varphi \coloneq \top\since\varphi$` →
`somePast φ = Formula.snce Formula.top φ` (`Formula.lean:157`);
`$\future\varphi \coloneq \top\until\varphi$` → `someFuture φ = Formula.untl Formula.top φ`
(`:147`); `$\Next\varphi \coloneq \bot\until\varphi$` → `next φ = Formula.untl Formula.bot φ`
(`:511`); `$\Previous\varphi \coloneq \bot\since\varphi$` → `prev φ = Formula.snce Formula.bot φ`
(`:516`).

**This is a prose repair, not a re-pin — no anchor hash moved.** The verbatim block and its
`edde7517…` checksum above are the live paper text; only this caveat, which described a footnote
that no longer exists and a Lean convention that no longer holds, was rewritten.

One residual asymmetry, deliberate and not a defect: the codebase's **prefix** rendering
`U(event, guard)` (`Formula.prettyPrint`, the machine appendix's `schema_string`, and
`asUntil?`/`asSince?`'s returned pair) remains **event-first**, unlike the constructor and unlike
the paper's infix. Each such site now says so explicitly. Flipping it is deferred; see the
"Deferred consequences" section of the decision record.

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

### `thm:BLplus-PastFuture` — DERIVED: the H/G truth conditions of the defined tense operators (the unconditional language embedding)

```latex
\begin{Tthm} \label{thm:BLplus-PastFuture}
	$\M,\tau,x \vDash \Past\varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $y < x$; and $\M,\tau,x \vDash \Future\varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $x < y$.
\end{Tthm}
```
sha256: `cf9d2e2bb1bcb17e3f27d9ac76f89c340f2cce5992586c617f4202051ac8256d`

### `thm:BLplus-NextPrevious` — DERIVED: Next/Previous truth conditions over Discrete frames

```latex
\begin{Tthm} \label{thm:BLplus-NextPrevious}
	Over \textsc{Discrete} task frames, $\M,\tau,x \vDash \Next\varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for the immediate successor $y$ of $x$.
  Additionally, $\M,\tau,x \vDash \Next\varphi \leftrightarrow \bot$ when $x$ has no immediate successor.
	The past dual holds for $\Previous\varphi$ in an analogous manner.
\end{Tthm}
```
sha256: `5d9a6febeae6e2dd4c78e1912616e75e6ae7896c929e75345b2ba6403c0693c9`

### `def:time-shift-histories` — time-shift between possible worlds, translation form

```latex
\begin{Ddef} \label{def:time-shift-histories}
	For a task frame $\F = \tuple{W, \D, \Rightarrow}$, the possible worlds $\tau, \sigma \in H_{\F}$ are \emph{time-shifted from $x$ to $y$}--- written $\tau \approx_x^y \sigma$--- \textit{iff} there exists a \textit{translation} $\bar{a} : D \to D$, $\bar{a}(z) = z + d$ for some $d \in D$, where $y = \bar{a}(x)$ and $\tau(z) = \sigma(\bar{a}(z))$ for all $z \in D$.
\end{Ddef}
```
sha256: `d468e821f5d1edb0316cbc0ce3895a8148a2e460ba5e2a6f6c1b67f1c029d202`

### `def:frame-validity` — validity over a frame

```latex
\begin{Ddef} \label{def:frame-validity}
	A well-formed sentence $\varphi$ of $\BL$ is \emph{valid over a task frame} $\F = \tuple{W, \D, \Rightarrow}$ which we may write $\vDash_{\F} \varphi$ if and only if $\M,\tau,x \vDash \varphi$ for every model $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where $\F = \tuple{W, \D, \Rightarrow}$, possible world $\tau \in H_{\F}$, and time $x \in D$.%
    \footnote{
      Since $H_{\F} \neq \emptyset$ for every task frame by \textbf{\ref{cor:occurrence}}, frame validity is never vacuous: every task frame contributes evaluation points, and so $\nvDash_{\F} \bot$ for every task frame $\F$.
    }
\end{Ddef}
```
sha256: `86a0c4b220bc43d04a2bfc14ccd14f0dab0182ff735ffde9c660e3a0ce7b2259`

### `def:logical-consequence` — logical consequence and (global) validity

```latex
\begin{Ddef} \label{def:logical-consequence}
	A conclusion $\varphi$ is a \textit{logical consequence} of a set of premises $\Gamma$--- written $\Gamma \vDash \varphi$--- just in case for all models $\M$, possible worlds $\tau \in H_{\F}$, and times $x \in D$, if $\M,\tau,x \vDash \gamma$ for all premises $\gamma \in \Gamma$, then $\M,\tau,x \vDash \varphi$.
	A sentence $\varphi$ is \textit{valid} just in case $\vDash \varphi$.
\end{Ddef}
```
sha256: `3af67167ee4a393d77fc8cfa8ddc065fe932bedf76a14febb8608a9001af5486`

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
  \vspace{-.275in}
\end{Ddef}
```
sha256: `f588157a5ad86a277b73c29b682d66052db206bf75111acebeef80b34a40c946`

### `def:BX` — the Base Burgess–Xu tense logic

```latex
\begin{Ddef} \label{def:BX}
  Letting $\varphi_{\tuple{\textsc{s} | \textsc{u}}}$ denote the result of interchanging all occurrences of $\since$ and $\until$ in $\varphi$, \textbf{BX} is the \textit{Base Burgess--Xu Tense Logic} axiomatized below where the past/since direction of each axiom follows from the future/until direction:
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
    \aitem[TL]{TMP-LN} $(\future\varphi \wedge \future\psi) \rightarrow [\future(\varphi \wedge \psi) \vee \future(\varphi \wedge \future\psi) \vee \future(\future\varphi \wedge \psi)]$.
    \aitem[CN]{TMP-CN} $[(\varphi\until\psi) \wedge (\chi\until\theta)] \rightarrow [(\varphi \wedge \chi)\until(\psi \wedge \theta) \vee (\varphi \wedge \chi)\until(\psi \wedge \chi) \vee (\varphi \wedge \chi)\until(\varphi \wedge \theta)]$.
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
sha256: `9af6879e367d85e7732f2d699cb2fea1862f0efc44ea497fd25604405bc771f2`

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
  Whereas \textbf{\aref{TMP-UZ}} asserts that if $\varphi$ in the future, then there is a \textit{nearest} future $\varphi$-time where $\neg\varphi$ throughout the intervening interval, \textbf{\aref{TMP-Z1}} is a backward induction principle that is characteristic of successor-Archimedean task frames.
  It follows by H\"{o}lder's theorem that a nontrivial discrete Archimedean totally ordered abelian group is isomorphic to $\Z$, and so the successor-Archimedean discrete class to which \textbf{BX}$_f$ and \textbf{TM}$^+_\textsc{f}$ are sound and complete is exactly $\Z$-time.
  % \textbf{TM}$_\textsc{f}$, by contrast, is sound over the full class of discrete frames, since \textbf{\aref{DF}} is valid on every discrete order and not only on $\Z$-time; whether \textbf{TM}$_\textsc{f}$ is complete over that broader class remains open, as discussed at \textbf{\ref{cor:tm-completeness}}.
  % \textbf{\aref{TMP-UZ}} and \textbf{\aref{TMP-Z1}} are not sound over non-Archimedean discrete orders: over $\Z \times_{\mathrm{lex}} \Z$, an atom true only in the second galaxy leaves \textbf{\aref{TMP-UZ}} without a first witness.
\end{Ddef}
```
sha256: `748db67fde66dfae930e60f5e332c608585b3ac2f3f35628704536b7884bde54`

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
  Letting $K^+\varphi \coloneq \neg(\neg\varphi\until\top)$ and $K^-\varphi \coloneq \neg(\neg\varphi\since\top)$ abbreviate Reynolds' (1992) operators--- $K^+\varphi$ says that $\varphi$ recurs arbitrarily soon in the future, and $K^-\varphi$ that $\varphi$ recurred arbitrarily recently in the past--- the \textit{Complete Burgess--Xu Tense Logic} \textbf{BX}$_c$ is the smallest extension of the base logic \textbf{BX} to include all instances of the following axioms, due to Reynolds (1992), where only the future/until direction of \textbf{\aref{TMP-PU}} is stated, its past/since direction following by \textbf{\aref{TMP-TD}}:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \aitem[Prior-U]{TMP-PU} $(\varphi\until\top) \wedge \future\neg\varphi \rightarrow \varphi\until(\neg\varphi \vee K^+\neg\varphi)$.
    \aitem[Sep]{TMP-SEP} $K^+\varphi \wedge \neg K^+(\varphi \wedge (\neg\varphi\until\varphi)) \rightarrow K^+(K^+\varphi \wedge K^-\varphi)$.
  \end{enumerate}
  The following axiom restates \textbf{\aref{CO}} from \textbf{TM}, and is a \textit{derived theorem} of \textbf{BX}$_c$ rather than a further axiom, using only \textbf{\aref{TMP-PU}} and the base axioms of \textbf{BX}:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.
  \end{enumerate}
  As a result, \textbf{\aref{TMP-CO}} may be omitted from \textbf{BX}$_c$.
  % This derivation is machine-checked in the Lean 4 \href{https://github.com/benbrastmckie/BimodalLogic}{repository} for this paper, and so will not be provided here.
  % Whether \textbf{\aref{TMP-CO}} alone axiomatizes the same logic as the full triple is open: the converse derivation--- deriving \textbf{\aref{TMP-PU}} and \textbf{\aref{TMP-SEP}} from \textbf{\aref{TMP-CO}} alone--- is conjectured to fail, via an unformalized pen-and-paper sketch involving a $\Q$-flow with isolated $\neg\varphi$ points accumulating at an irrational from above; this independence is not asserted as established.\footnote{%
  %   A nontrivial Dedekind-complete totally ordered abelian group is Archimedean, hence by H\"{o}lder's theorem isomorphic to $\Z$ or $\R$.
  %   The complete class is therefore exactly $\set{\Z, \R}$ up to isomorphism, so the Dedekind-complete theory of time is $\Th{\Z} \cap \Th{\R}$ and the dense-and-complete class is exactly $\R$.
  %   In particular, no non-Archimedean order is complete.
    % }
\end{Ddef}
```
sha256: `116725ac133c7ce7660d6c32e3654c2e8456c03dcd1cf97cd3b254238c2d4c03`

### `def:TMplus` — TM+ base logic for BL+, and the four-part conservativity footnote

```latex
\begin{Ddef} \label{def:TMplus}
  The \textit{Base Logic of Tense and Modality} \textbf{TM}$^+$ for $\BL^+$ is the smallest extension of \textbf{S5} and the base logic \textbf{BX} that includes the following \textit{bimodal interaction} axiom:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \aitem[MF]{TMP-MF} $\Box\varphi \rightarrow \Box\Future\varphi$.
  \end{enumerate}
  Similarly, the discrete \textbf{TM}$^+_f$, dense \textbf{TM}$^+_d$, and complete \textbf{TM}$^+_c$ extensions of \textbf{TM}$^+$ include the additional axioms that distinguish \textbf{BX}$_f$, \textbf{BX}$_d$, and \textbf{BX}$_c$, respectively.
\end{Ddef}
```
sha256: `f7a811e63f644732b3e316541ca281ce1bdce81bd7d9c4358514470c8185fa4b`

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
	$\F \vDash (\Past\varphi \wedge \varphi \wedge \future\top) \rightarrow \future\Past\varphi$ iff $\F$ is a \textsc{Discrete} task frame.
\end{Tthm}
```
sha256: `fa0634d7f914f5cf78be7524ee8ced0d70cabf2d634db3ddeabbfe13b2be74db`

### `app:dense` — the Dense correspondence theorem (DN)

```latex
\begin{Tthm} \label{app:dense}
	$\F \vDash \Future\Future\varphi \rightarrow \Future\varphi$ iff $\F$ is a \textsc{Dense} task frame.
\end{Tthm}
```
sha256: `4f8bb793ec8d762013c413327c05c50e691c6d54fefdcb0bedd3076b3b782bfe`

### `app:complete` — the Complete correspondence theorem (CO)

```latex
\begin{Tthm} \label{app:complete}
	$\F \vDash \always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$ iff $\F$ is a \textsc{Complete} task frame.
\end{Tthm}
```
sha256: `2fe5c5e879af2ae0e7ef1823d3c61b6d3608f21495525396b82a4350e349f168`

### `def:frame-properties` — Discrete/Dense/Complete/Deterministic frame-class predicates

```latex
\begin{Ddef} \label{def:frame-properties}
	A task frame $\F = \tuple{W, \D, \Rightarrow}$ is:
	\begin{enumerate}[wide=0pt, labelsep=.05in, itemsep=.075in]
		\item[\sc Discrete] if for any $x \in D$, whenever there exists $y > x$, there is a least such $y' > x$ satisfying $z \geq y'$ for all $z > x$.
		\item[\sc Dense] if for any $x, y \in D$ where $x < y$, there exists $z \in D$ where $x < z < y$.
		\item[\sc Complete] if every nonempty $S \subseteq D$ bounded above has a least upper bound in $D$.
	\end{enumerate}
\end{Ddef}
```
sha256: `7820dd2fdaada72ff505787f47c049f63c24362cf25e48b7677724d850275086`

Note: promoted into coverage by this task (previously listed under "Deliberately not covered"
below, which is updated accordingly).

### `def:deterministic` — the Deterministic frame-class predicate (standalone since the 2026-08 wave)

Split out of `def:frame-properties` by the paper: Deterministic used to be a fourth clause inside
that definition and is now a definition of its own at live paper line 2868. Added to the manifest
at the 2026-08-25 re-pin because `FormalSystem/Examples/TemporalStructures.lean` cites it, and
citing `def:frame-properties` for determinism is now wrong.

```latex
\begin{Ddef} \label{def:deterministic}
	A task frame $\F = \tuple{W, \D, \Rightarrow}$ is \textsc{Deterministic} just in case $u = v$ whenever $w \Rightarrow_x u$ and $w \Rightarrow_x v$ for $w, u, v \in W$ and $x \in D$, holding in both temporal directions since \textbf{\ref{def:task-relation}}'s converse convention already extends $x$ over all of $D$.
\end{Ddef}
```
sha256: `3baae0ee62cee6a0bd81b18951efb3cd5d1097a017f9c60ccd2d8b87e4a3e175`

### `cor:spherical-finite` — every frame with finite W satisfies Spherical, choice-free

```latex
\begin{Cthm} \label{cor:spherical-finite}
	Every task frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Spherical}, choice-free.
\end{Cthm}
```
sha256: `26ed8ff4c8b01f1dde980e075bc2e0bd45571951be82160bb184d59227b9f7b3`

### `cor:tm-completeness` — the Completeness corollary (TM sound but not complete; completeness carried by BL+)

```latex
\begin{Cthm}[Completeness] \label{cor:tm-completeness}
  Where $\Gamma \vDash_{\mathsf{C}} \varphi$ restricts \textbf{\ref{def:logical-consequence}} to models over task frames in a class $\mathsf{C}$, a proof system $\mathbf{S}$ is \textit{strongly complete} over $\mathsf{C}$ just in case $\Gamma \vDash_{\mathsf{C}} \varphi$ implies $\Gamma \vdash_{\mathbf{S}} \varphi$ for every set of sentences $\Gamma$, and \textit{weakly complete} over $\mathsf{C}$ just in case $\vDash_{\mathsf{C}} \varphi$ implies $\vdash_{\mathbf{S}} \varphi$.
  Completeness is then carried by the following $\BL^+$ systems:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \item[\bf TM$^+$] Strongly complete over all task frames.
    \item[\bf TM$^+_\textsc{d}$] Strongly complete over the dense task frames.
    \item[\bf TM$^+_\textsc{f}$] Weakly complete over $\Z$-time.
    \item[\bf TM$^+_\textsc{c}$] Weakly complete over the dense-and-complete class.
  \end{enumerate}
  Strong completeness provably fails for $\Z$-time as well as for the dense-and-complete class $\R$ where compactness fails, and so weak completeness is the appropriate target.%
    \footnote{
      These results, together with the soundness of the corresponding systems, have been established in the Lean 4 \href{https://github.com/benbrastmckie/BimodalLogic}{repository} for this paper, and so their proofs are not reproduced here.
    }
\end{Cthm}
```
sha256: `04255c86b60567dd33a9cc708351dc02af254f798f4e82663e60b83b6f41847d`

### `cor:tm-decidability` — the Decidability corollary (open) — **DANGLING as of the 2026-08-17 re-pin (removed from manifest)**

The live paper no longer carries a `\label{cor:tm-decidability}` (the corollary is commented
out / removed), even though the paper's Conclusion still asserts decidability — an internal
inconsistency surfaced to the user separately. The quoted text below is retained as the
last-resolved historical record; the anchor is removed from the machine manifest so the checker
no longer reports it as unresolvable. The obligation that the finished paper restore or restate
this corollary is carried by `// CONFIRM(paper):` comments in `typst/` chapters. If the paper
restores the anchor, re-add a manifest row via
`check-paper-definitions.sh --resolve "cor:tm-decidability|env|-|-"`.

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
  Letting $\BL^{\Box}$ be the purely modal fragment of $\BL$, each $p_i \in \SL$ will be understood to be a \textit{propositional variable} rather than sentence letter.
  The \textit{identity extension} of $\BL^{\Box}$ is a language $\BL^{\equiv}$ enriched to include a binary propositional identity operator $\equiv$, read $\ulcorner$For $\varphi$ just is for $\psi\urcorner$, whose logic comprises classical propositional logic and the minimal theory of identity given below, where $\chi_{(\psi/\varphi)}$ is the result of replacing one or more occurrences of $\varphi$ in any formula $\chi$ with $\psi$:
	\vspace{-.125in}
	\begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
		\begin{multicols}{2}
			\aitem{Ref} $\vdash \varphi \equiv \varphi$.
			\aitem{Imp} $\vdash (\varphi \equiv \psi) \rightarrow (\varphi \rightarrow \psi)$.
			\aitem[LL$^{-}$]{LL} $\vdash (\varphi \equiv \psi) \rightarrow (\chi \rightarrow \chi_{(\psi/\varphi)})$
        where $\psi$ is free for $\varphi$ in $\chi$ and no replaced $\varphi$ lies in the scope of an operator.%
        \footnote{
          A formula $\psi$ is \textit{free for} $\varphi$ in $\chi$ just in case no replaced occurrence of $\varphi$ lies within the scope of a quantifier binding a variable free in $\varphi$ or $\psi$.
          The condition is vacuous in $\BL^{\equiv}$, which has no quantifiers.
          The operator-scope proviso makes $\equiv$ a congruence for the logical vocabulary--- identicals may be substituted for one another within $\rightarrow$, $\bot$, $\equiv$, and the quantifiers added below--- but not for operator terms. % as in \textbf{\S\ref{sec:Introduction}}. %: the logical constants are objective, whereas an operator may be opaque.
        }
		\end{multicols}
	\end{enumerate}
	\vspace{-.175in}
  The theory of propositional identity need not be Boolean, accommodating theories in which the absorption laws or other Boolean identities do not hold.\footnote{I defend a bilateral theory of propositional identity in Brast-McKie \cite{Brast-McKie2021}.}
  Symmetry and transitivity of $\equiv$ are nevertheless derivable, and since each replaces an occurrence lying outside any operator term, both survive the proviso on \textbf{\aref{LL}}.
  % Given $\varphi \equiv \psi$, instantiating \textbf{\aref{Ref}} at $\varphi$ gives $\vdash \varphi \equiv \varphi$, and applying \textbf{\aref{LL}} with $\chi \coloneq (\varphi \equiv \varphi)$, replacing the first occurrence of $\varphi$, gives $\vdash (\varphi \equiv \psi) \rightarrow [(\varphi \equiv \varphi) \rightarrow (\psi \equiv \varphi)]$, which detaches by permuting antecedents and applying modus ponens to give $\psi \equiv \varphi$, i.e., symmetry.
  % Given also $\psi \equiv \theta$, a further application of \textbf{\aref{LL}}, with $\chi \coloneq (\varphi \equiv \psi)$, replacing the occurrence of $\psi$, gives $\vdash (\psi \equiv \theta) \rightarrow [(\varphi \equiv \psi) \rightarrow (\varphi \equiv \theta)]$, which detaches with both hypotheses to give $\varphi \equiv \theta$, i.e., transitivity.
\end{Ddef}
```
sha256: `1a608153e9b78659db2bfc13b2c11c024dceb0acde9cfaa8b900345cda2af238`

### `def:strongest` — strongest objective normal modal operator, Str^O_L(Q)

```latex
\begin{Ddef} \label{def:strongest}
	$\Q$ is a \textit{strongest objective modal operator in $L$}--- $\Str^{\OO}_{L}(\Q)$--- if and only if:
	\begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \item $\vdash \OO(\Q)$; and
		\item $\vdash \forall\P[\OO(\P) \rightarrow (\Q \preceq \P)]$.
	\end{enumerate}
  \vspace{-.1in}
\end{Ddef}
```
sha256: `57786b2c8758c3c7ea80ac7a80464b331ea77ff9b8c804a032504394bc800369`

### `thm:exist` — L has a strongest objective normal modal operator (Bm witnesses)

```latex
\begin{Tthm} \label{thm:exist}
	$\Str^{\OO}_{L}(\Bm)$, so $L$ includes a strongest objective modal operator.
\end{Tthm}
```
sha256: `fb6d83115f2effb62bc56a233e84212da50c0b692a60ebcdf2a0ea30fcfa9db9`

### `lem:uniq` — uniqueness of the strongest objective normal modal operator

```latex
\begin{Lthm} \label{lem:uniq}
	If $\Str^{\OO}_{L}(\Q)$ and $\Str^{\OO}_{L}(\P)$, then $\vdash \forall p(\Q p \leftrightarrow \P p)$.
\end{Lthm}
```
sha256: `ff8ac0629d00554c5d54c580e68c4886297c63e24fd214338614560eedb862cf`

### `thm:s4` — the strongest objective operator obeys S4 — **DANGLING as of the 2026-08-25 re-pin (removed from manifest)**

The live paper no longer carries a `\label{thm:s4}`. The paper folded the S4, B/Symmetry, and T
results for the strongest objective operator into a **single** theorem, `thm:s5` (live paper line
2158), which states all three conjuncts at once. The quoted text below is retained as the
last-resolved historical record; the anchor is removed from the machine manifest so the checker no
longer reports it as unresolvable. Its successor is tracked as `thm:s5` below. If the paper
restores the anchor, re-add a manifest row via
`check-paper-definitions.sh --resolve "thm:s4|env|-|-"`.

```latex
\begin{Tthm} \label{thm:s4}
	If $\Str^{\OO}_{L}(\Q)$, then $\vdash \forall p(\Q p \rightarrow \Q\Q p)$.
\end{Tthm}
```
sha256: `09599de2c925eba38b8ac8e9e6007118e9c6539100a777d98ada030d3d5fcd95`

### `thm:sym` — the strongest objective operator obeys B/Symmetry — **DANGLING as of the 2026-08-25 re-pin (removed from manifest)**

The live paper no longer carries a `\label{thm:sym}`. The paper folded the S4, B/Symmetry, and T
results for the strongest objective operator into a **single** theorem, `thm:s5` (live paper line
2158), which states all three conjuncts at once. The quoted text below is retained as the
last-resolved historical record; the anchor is removed from the machine manifest so the checker no
longer reports it as unresolvable. Its successor is tracked as `thm:s5` below. If the paper
restores the anchor, re-add a manifest row via
`check-paper-definitions.sh --resolve "thm:sym|env|-|-"`.

```latex
\begin{Tthm} \label{thm:sym}
	If $\Str^{\OO}_{L}(\Q)$, then $\vdash \forall p(p \rightarrow \Q\Dual{\Q}p)$.%
  \footnote{
    \textbf{\aref{O-Conv}} is a term-level form of the principle, due to Williamson \citep[p.~457]{Williamson2016}, that every necessity has a reversal, where Bacon and Zeng \citep[Prop.~4.1]{Bacon2022} prove that principle equivalent to the \textbf{B} axiom for the broadest necessity.
    Here \textbf{\aref{I9}} makes $\Cnv{\Q}$ a reversal of $\Q$ and \textbf{\aref{O-Conv}} keeps it in the class, so \textbf{\ref{thm:sym}} derives one direction of that equivalence with a canonical converse in place of an existential.
  }
\end{Tthm}
```
sha256: `64e88f37ad07f9dcd339ebd0789e5a84cc6a0098f597cbcef2513a801332e582`

### `thm:s5` — the strongest objective operator obeys S5 (S4 + B + T, in one theorem)

Successor to the retired `thm:s4` and `thm:sym` above: the paper merged both, and added the T
conjunct, into a single theorem in the 2026-08 wave. Added to the manifest at the 2026-08-25
re-pin because the pair it replaces was load-bearing and would otherwise have gone untracked.

```latex
\begin{Tthm} \label{thm:s5}
	If $\Str^{\OO}_{L}(\Q)$, then  $\vdash \forall p(\Q p \rightarrow \Q\Q p)$, $\vdash \forall p(p \rightarrow \Q\Dual{\Q}p)$, and $\vdash \forall p(\Q p \rightarrow p)$.
\end{Tthm}
```
sha256: `14b32c8a3281aa246e1f83277fd940bdb9fcb8b88b702cda42c0fbf89a0112d7`

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
def:task-relation|env|-|-|c12d018290feb5a12e1757aae3718593c940c3d5bd19c6bbd5d8a87bcf525193
def:directed|env|-|-|096a8398223596825ff71372dc565a77354d41fff69f8bf0b3fe485edad0c75b
def:frame|env|-|-|294733a3cb5d65a1c048d850689e6d78e7a29c8b78cc8fed5d35b3ce3618583b
def:frame#Compositionality|item|def:frame|Compositionality|35905314d686a1676dfda8d4c7d092de8c3335104c0510e7069d6656a4ac87e3
def:frame#Seriality|item|def:frame|Seriality|afffcd074afce7442d2c02108f49e70c128de3d4d7ccac41833f95e2ae3cd952
def:frame#Limit|item|def:frame|Limit|6acfdc8df119a71d24d863399f6e6d3aff9a507e920c8a57e9427df94224b369
def:frame#Spherical|item|def:frame|Spherical|92b407bc45ab62ce5bac22982c67e2555efb4a990ddf8e61fd7f1b45840bcf60
lem:nullity|env|-|-|94ed018343635a8ef6671daef07eaa72da1cb49fd11043fb3aa9b391a2c9c973
def:world-history|env|-|-|3d4679bdb4828aad40f6a0d8deb6ff5af09fa52d2181100cfe159f2a23303a15
thm:extension|env|-|-|1140d4819b9b0030275f249c60b7cb2fb15da97f9d07df2196d6e06508f65e38
cor:occurrence|env|-|-|244bb2e5f6036bbe405549501390b90f432ece28c232fd18caa8b82ab3bb9a8c
def:constraints|env|-|-|50aadae779c7d57c810e94209614b5cdfe2590fa82c1c0793db948e8d0917e28
lem:nesting|env|-|-|ed036f28b70b99d4294515c0f1da64a62e471aa4795394cda4d9010b1f1971a7
lem:nonempty|env|-|-|8067bf45a360f04db7a94280bde1b359dac58e8311f2fba1d58db15bf2336598
lem:constraint|env|-|-|ca6719adfaad9f6dc3d1b6a57de013598dd80847014d9c2fb60ed626b895370f
lem:admissible|env|-|-|9606ef1f1264887ed51358744df7e5fc290250dd8209f445fd138700da56de8e
lem:step|env|-|-|b1f65f70cc243de5b32d4e2a46c35c986dd0322cf3ca0524fb76701af3e3be4b
def:BL-semantics|env|-|-|5f53774a3b8a04272bb3c8bf9d41f5cd777e8dc8b1ba30c92aa19113399b228b
def:BLplus-language|env|-|-|a43b3df2ea2fcb96eeb156b3403a33ac51fcafd2ad4eb55e7915c07cf509f8b7
def:BLplus-semantics|env|-|-|735c614181b042a498ec68826b234d30c9035464d9887b6fe717bab90e0705eb
def:BLplus-defined|env|-|-|2ac6361a2b84d20dd498f3e392072862554dd964a9ab6fc54bd868ee0a5bf56e
thm:BLplus-PastFuture|env|-|-|cf9d2e2bb1bcb17e3f27d9ac76f89c340f2cce5992586c617f4202051ac8256d
thm:BLplus-NextPrevious|env|-|-|5d9a6febeae6e2dd4c78e1912616e75e6ae7896c929e75345b2ba6403c0693c9
def:time-shift-histories|env|-|-|d468e821f5d1edb0316cbc0ce3895a8148a2e460ba5e2a6f6c1b67f1c029d202
def:frame-validity|env|-|-|86a0c4b220bc43d04a2bfc14ccd14f0dab0182ff735ffde9c660e3a0ce7b2259
def:logical-consequence|env|-|-|3af67167ee4a393d77fc8cfa8ddc065fe932bedf76a14febb8608a9001af5486
CO|aitem|-|-|5c468c01776c449b212c98070b5bfc70951691a23905cd4d4c249bf1f5375d41
TMP-CO|aitem|-|-|2205e7115342b037faeb67a24cb7679e393af582cedf6752c0c07d9a28b8f1be
def:S5|env|-|-|f588157a5ad86a277b73c29b682d66052db206bf75111acebeef80b34a40c946
def:BX|env|-|-|9af6879e367d85e7732f2d699cb2fea1862f0efc44ea497fd25604405bc771f2
def:TMplus-f|env|-|-|748db67fde66dfae930e60f5e332c608585b3ac2f3f35628704536b7884bde54
def:TMplus-d|env|-|-|aa6542e6eee06e5c94dddc4b4581715d8b4310bba53615e0c0f80188016f10cf
def:TMplus-c|env|-|-|116725ac133c7ce7660d6c32e3654c2e8456c03dcd1cf97cd3b254238c2d4c03
def:TMplus|env|-|-|f7a811e63f644732b3e316541ca281ce1bdce81bd7d9c4358514470c8185fa4b
thm:M5-valid|env|-|-|bce3cc3be256f7b4c10e34a397e4b3b14abe4e8ed6728e8e91768e9a2ad8b2af
thm:TM-soundness|env|-|-|23cae2b2fcd8c034b82c4f9294b21aa4d141429a278fa08d085cae2c53bf0529
app:discrete|env|-|-|fa0634d7f914f5cf78be7524ee8ced0d70cabf2d634db3ddeabbfe13b2be74db
app:dense|env|-|-|4f8bb793ec8d762013c413327c05c50e691c6d54fefdcb0bedd3076b3b782bfe
app:complete|env|-|-|2fe5c5e879af2ae0e7ef1823d3c61b6d3608f21495525396b82a4350e349f168
def:frame-properties|env|-|-|7820dd2fdaada72ff505787f47c049f63c24362cf25e48b7677724d850275086
def:deterministic|env|-|-|3baae0ee62cee6a0bd81b18951efb3cd5d1097a017f9c60ccd2d8b87e4a3e175
cor:spherical-finite|env|-|-|26ed8ff4c8b01f1dde980e075bc2e0bd45571951be82160bb184d59227b9f7b3
cor:tm-completeness|env|-|-|04255c86b60567dd33a9cc708351dc02af254f798f4e82663e60b83b6f41847d
def:id|env|-|-|1a608153e9b78659db2bfc13b2c11c024dceb0acde9cfaa8b900345cda2af238
def:strongest|env|-|-|57786b2c8758c3c7ea80ac7a80464b331ea77ff9b8c804a032504394bc800369
thm:exist|env|-|-|fb6d83115f2effb62bc56a233e84212da50c0b692a60ebcdf2a0ea30fcfa9db9
lem:uniq|env|-|-|ff8ac0629d00554c5d54c580e68c4886297c63e24fd214338614560eedb862cf
thm:s5|env|-|-|14b32c8a3281aa246e1f83277fd940bdb9fcb8b88b702cda42c0fbf89a0112d7
```
<!-- MANIFEST:END -->

## Untracked sources

Not every passage of the paper this repository relies on is anchorable. `resolve_text` in
`scripts/check-paper-definitions.sh` supports exactly two anchor kinds — `env`, resolved by
grepping for `\label{...}`, and `aitem`, resolved by `\aitem{...}` — and errors on anything else.
A passage carrying neither marker therefore cannot be given a manifest row: the row would be a
dangling anchor and the check would fail on it. The paper is read-only input to this repository,
edited elsewhere, so adding a `\label` is not an option either.

Such passages are recorded here in prose instead, so that the reliance is visible even though it
is unverifiable by the lint. **Do not promote any entry in this section to a manifest row** unless
the passage has acquired a resolvable anchor upstream first.

### The finite-case effectiveness footnote

- **Location**: `JPL/possible_worlds.tex`, in the footnote attached to the discussion of the
  finite case (at the time of recording, line 1648). No `\label`, no `\aitem`.
- **Relied on by**: `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean`, which quotes it
  verbatim in its module docstring, and the two `extend_periodic` theorems it introduces —
  `FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic` (effective, presented
  frames) and `FormalSystem.Semantics.TaskFrame.extend_periodic` (general finite carrier).
- **Text**:

  > In this case the conclusion of \textbf{\ref{thm:extension}} becomes effective without appeal
  > to Zorn's lemma: since $W$ is finite, the forward and backward orbits extending a bounded
  > world history must each revisit a world state, so every bounded world history extends to a
  > possible world that is eventually periodic in both directions--- a finite prefix plus a finite
  > cycle each way--- and is therefore finitely representable, licensing a finite certificate that
  > a given bounded history is a fragment of a possible world.

- **What the formalisation preserves**: the doubly ultimately-periodic extension and the finite
  certificate, both in full. "Without appeal to Zorn's lemma" is preserved as *no Zorn* — an
  import-graph fact — and **not** as choice-freedom in Lean's sense, which is a claim about a
  different axiom. The measured accounting lives in `extend_periodic`'s own docstring.

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
