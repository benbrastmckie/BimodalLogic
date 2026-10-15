# Paper Definitions of Record

This file is the pinned, verbatim record of the semantic definitions that this repository
depends on from the JPL paper (`~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`).
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
| Paper file | `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` |
| Paper git repo root | `~/Philosophy/Papers/PossibleWorlds` |
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
| Base commit at the ten-anchor drift correction (paper repo `git HEAD`; file dirty against it) | `fa0dbf7c053e6ecd22e9815180dd91beb2604e61` |
| **File checksum, re-pinned at the ten-anchor drift correction (sha256, current authoritative pin)** | `7303bc9e8529b84f881b17b6f0ef3027f104a6c9ab91315c573a15e00bac0143` |
| Line count at the ten-anchor drift correction | 4867 |
| Ten-anchor drift correction re-pin (UTC) | 2026-09-02T23:08Z (see "Drift correction (2026-09-02): ten-anchor re-pin" below) |
| Base commit at the z/d/r rename-absorption re-pin (paper repo `git HEAD`; file dirty against it, and the last commit to touch the file is `acfa75fdd270dd69145c76b788144b1ce0aee98c`) | `f61bbd75d3aa0c777fdeb91804868145f7169684` |
| File checksum, first re-pin during the z/d/r rename-absorption (sha256, superseded within the hour) | `c3846c1ef93991228f2e309c7d9831df732b5dec657157425cf593a0256d278e` (line count 4483) |
| File checksum, re-pinned after the in-flight `def:BX-z` follow-on drift (sha256, superseded 2026-09-17) | `1b3c33a2b6a445b14e13e2f59b10c02b5140bb00280a3191ef27448e63460aa5` |
| Line count at that re-pin | 4452 |
| z/d/r rename-absorption re-pin (UTC) | 2026-09-08T01:30Z (15 entries re-hashed, 9 anchors retired, 3 renamed anchors newly pinned; see "Drift correction and rename absorption (2026-09-07)" below) |
| Base commit at the time-reflection wave re-pin (paper repo `git HEAD`; file dirty against it) | `a166fcbf2951482ecdccc643c7458ac92d67126c` |
| **File checksum, re-pinned at the time-reflection wave (sha256, superseded 2026-09-28)** | `b4e45e2c5f771ee0d86be6c6e3a302cceb454771cd53475ed3628258083ddfa0` |
| Line count at that re-pin | 4529 |
| Time-reflection wave re-pin (UTC) | 2026-09-17T09:19Z (14 entries re-hashed, `thm:M5-valid` retired, TD → TR absorbed with carve-outs; see "Drift correction and rename absorption (2026-09-17)" below) |
| Base commit at the `def:id` footnote re-pin (paper repo `git HEAD`; file dirty against it) | `96ffaf43c6cccd10322366615b24513604f57a04` |
| **File checksum, re-pinned at the `def:id` footnote re-pin (sha256, superseded 2026-10-14)** | `88d9a9a64de7b7192899d284885c0ee807de4b9fcabe12d4c6b5c4570ac1f499` |
| Line count at that re-pin | 4573 |
| `def:id` footnote re-pin (UTC) | 2026-09-28 (one anchor re-hashed: the `Brast-McKie2021` footnote in `def:id` gained a trailing clause on transparency being maintained for the entirety of the language. Expository only -- no axiom, no substitution convention and no operator-scope proviso changed, and `def:id` has no Lean counterpart, so no citation or soundness-chain consequence. Absorbed rather than left red because the gate had been failing on this single clause since the paper edit. Re-run after the re-pin reported case (b), all 43 recorded definitions unchanged.) |

| Base commit at the 27-anchor drift correction (paper repo `git HEAD`; the file is **clean** against it, and that commit is also the last to touch the file: `4e00e00c273e19a437b65f48e1ca71c483268400` is its parent-side predecessor) | `9ad4aa5d1bda09d885d37b296fdde1bc1a0817ee` |
| File checksum, re-pinned at the 27-anchor drift correction (sha256, superseded 2026-10-15) | `0e39993c2aa955e0a3bfc224e8ba93fdfcd02ca9d4e2ca115cb4e2cccdb05d78` |
| Line count at that re-pin | 3962 |
| 27-anchor drift correction re-pin (UTC) | 2026-10-14 (27 entries re-hashed in one correction, headlined by the `lem:nullity` strengthening from an implication to a biconditional, plus `def:id` re-hashed a second time when the paper moved again while this correction was in flight — 28 re-hashes over 27 distinct anchors. No anchor retired, none renamed, none newly pinned. See "Drift correction (2026-10-14): the 27-anchor wave" below. The three whole-file sentinels and this table's "current authoritative pin" row had diverged across the 2026-09-17 and 2026-09-28 re-pins; setting all of them to the values above resolves that. Unlike every re-pin since 2026-08-10, this one pins a **clean** file: the paper was committed between the first and second resolution of `def:id`.) |
| Base commit at the BX/TM demotion wave (paper repo `git HEAD`; the file is **dirty** against it, and that commit is also the last to touch the file) | `bc010a06096299f605b12989461dc7ce86612b31` |
| **File checksum, re-pinned at the BX/TM demotion wave (sha256, current authoritative pin)** | `5362b6ba32825d32e73f8adeeeade63d2f8d556cebd9ba0603a595225b970245` |
| Line count at that re-pin | 4079 |
| BX/TM demotion wave re-pin (UTC) | 2026-10-15 (ten entries re-hashed and `def:strongest` retired DANGLING in one correction, headlined by the coincidence of the paper's primitive axiom set with `inductive Axiom`'s 20 constructors: `UE` and `UT` were removed from the paper outright, and `TC`/`TL`/`NP`/`NF`/`NA`/`Z1`/`DN` were demoted to derived theorems inside the definitions that used to axiomatize them, with `NB` moving into `def:TMplus` alongside `MF`. See "Drift correction (2026-10-15): the BX/TM demotion wave" below. The paper moved three times during the implementation dispatch alone, and `def:id` was re-hashed three times inside this one correction; the gate's green verdict is conditional on the revision this row names, not unconditional.) |
<!-- PAPER_PATH: ~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex -->
<!-- PAPER_REPO_ROOT: ~/Philosophy/Papers/PossibleWorlds -->
<!-- PINNED_COMMIT: bc010a06096299f605b12989461dc7ce86612b31 -->
<!-- FILE_CHECKSUM: 5362b6ba32825d32e73f8adeeeade63d2f8d556cebd9ba0603a595225b970245 -->
<!-- LINE_COUNT: 4079 -->

### Drift correction (2026-10-15): the BX/TM demotion wave

**The paper's primitive axiom set and this tree's `inductive Axiom` now coincide key for key.**
That is the headline of this wave, and it is an identity rather than a containment. The paper
names sixteen primitive schemata — `MK`, `MT`, `M5` (S5); `TS`, `UI`, `UC`, `UF`, `UG`, `US`,
`CN` (base tense); `MF`, `NB` (bimodal interaction); `UZ` (discrete); `NN` (dense); `PU`, `SEP`
(Dedekind) — which with the four CPL constructors `prop_k`, `prop_s`, `ex_falso`, `peirce` give
twenty, the exact constructor count and the exact key set of
`FormalSystem/ProofSystem/Axioms.lean`'s `inductive Axiom` (verified: 20 constructors, counted
from the inductive itself). Every earlier record entry that framed the relation as a **proper
subset** ("the tree's primitive set is now a proper subset of `def:BX`/`def:BX-z`/`def:BX-d`'s
lists … minus the nine of them that are theorems of the others") describes a state of affairs
that this wave retired; the 2026-10-14 `**Amended by**` note at `def:BX` below is rewritten
accordingly.

The checker was red (exit 1, case (c)) before this correction: **ten pinned entries drifted and
one anchor went dangling**. It gives the quiet case-(b)-then-(a) pass after it.

**Re-hashed (re-quoted from live text via `--resolve`, none hand-written):** `CO`, `def:BX`,
`def:BX-z`, `def:BX-d`, `def:TMplus`, `app:discrete`, `def:id`, `thm:exist`, `lem:uniq`,
`thm:s5`.

**Retired (manifest row removed, prose entry retained and marked `DANGLING`, `KNOWN-ANCHORS`
row added):** `def:strongest`. The paper removed the `\label{def:strongest}` definition
outright; `Str` survives as an `\aitem{Str}` key inside `\label{def:key-terms}`, the
operator-predicate definition that also carries `Fac`, `Ax` and `Ord`, with the `L` subscript
dropped and strongest-hood expressed as derivability of `$\Str^{\OO}(\Q)$`. The primed
`Str'` notion went with it, which is why `thm:exist` and `lem:uniq` lost their `Str'` halves in
the same wave.

#### The removal and the demotions are two different editorial acts

**Removal — `UE` and `UT` are no longer paper keys at all.** The live paper carries **zero**
`\aitem`, `\alabel` or `\aref` occurrences of either (measured, not assumed). They are not
demoted to derived theorems in the paper; they are gone from it. They survive in this tree as
`DerivedAxioms.untilF` (UE, from UG with guard `⊤` plus TN) and `DerivedAxioms.fUntilEquiv`
(UT, an identity), which are true theorems of the tree with **no paper key to attribute them
to**. Any in-tree `Paper:` line or anchor cell that attributed UE or UT to `def:BX` was made
false by this wave and is corrected in this task.

**Demotion — seven schemata the paper still displays, now marked derived rather than
axiomatic.** Each is still an item of `\S`Logic or `\S`Extensions, and each definition that used
to axiomatize it now states in its own text that it is a derived theorem:

| Schema | Still displayed as | The definition that now marks it derived | Derived in the paper of | Paper's own Lean citation |
|---|---|---|---|---|
| `TC` | `\aitem{TC}` | `def:BX` | **BX** | `\leanfoot{ConnectDerived.connectFuture}` |
| `TL` | `\aitem{TL}` | `def:BX` | **BX** | `\leanfoot{LinearityDerived.tempLinearity}` |
| `NP` | `\alabel{NP}` in prose | `def:TMplus` | **TM**, not BX | in-prose `\leanrepo{}` reference |
| `NF` | `\alabel{NF}` in prose | `def:TMplus` | **TM**, not BX | in-prose `\leanrepo{}` reference |
| `NA` | `\alabel{NA}` in prose | `def:TMplus` | **TM**, not BX | in-prose `\leanrepo{}` reference |
| `Z1` | `\aitem{Z1}` | `def:BX-z` | **TM**$_\textsc{z}$, not BX$_\textsc{z}$ | `\leanfoot{CompletenessDerived.z1Thm}` |
| `DN` | `\aitem{DN}` | `def:BX-d` | **BX**$_\textsc{d}$ | `\leanfoot{LinearityDerived.density}` |

`NP`, `NF` and `NA` deserve a separate note: they are the three that lost their `\aitem` status
as well. They are no longer displayed axiom items but `\alabel`-tagged schemata inside a
paragraph of `\S`Logic that states them as theorems of **TM** derived from `NB` together with
`MF` and `MT`. The system matters: they are theorems of TM rather than of BX, because their
derivation goes through the bimodal interaction axioms, which BX does not have. `def:TMplus`
says exactly this, and it is the only definition in the paper that can say it — which is also
why `def:TMplus` now names **two** bimodal interaction axioms, `MF` and `NB`, where it named one.

**`NB` moved, it was not demoted.** It is still a primitive, but a primitive of `def:TMplus`
rather than of `def:BX`. In the tree it is `Axiom.discrete_box_necessity`, and it always sat in
the uniformity layer rather than the BX temporal layer, so no Lean constructor moved.

#### The four unformalized objective-modality anchors, plus a fifth

`def:id`, `def:strongest`, `thm:exist` and `lem:uniq` are absorbed here **on the user's recorded
authorization** (`specs/.../.decisions.json`, cycle 5), not as a silent widening of scope. The
measured basis for that authorization: each has **zero citing files** under `FormalSystem/` or
`docs/` other than this record file itself. The paper-side cause is one editorial decision —
the primed `Str'` operator was dropped, `def:strongest` was folded into `def:key-terms`'s
`\aitem{Str}`, and `thm:exist` and `lem:uniq` were restated in the object-language derivability
form (`$\vdash \Str^{\OO}(\Q)$`) that drops the `L` subscript. `def:id` was rebuilt from a clean
slate: `$\BL^{\equiv}$` is no longer the identity extension of a fragment of `$\BL$` but a
language in its own right, with its propositional variables, its operator terms, identity at
both types and the predicate `$\OO$` all in place before the minimal theory of identity is
stated, and with the `free for` proviso deferred to the quantified language.

**`thm:s5` is the fifth, and it was not in the authorized list.** It drifted newly, after that
authorization was given: `If $\Str^{\OO}_{L}(\Q)$` became `If $\vdash \Str^{\OO}(\Q)$` — the
same drop of the `L`-subscripted metalinguistic form that moved `thm:exist` and `lem:uniq`, in
the same section of the same revision. It is absorbed on the same measured basis, re-verified
here rather than assumed: `grep -rln thm:s5` over `FormalSystem/`, `docs/`, `typst/` and
`README.md` returns **this record file alone**. Absorbing it has no Lean and no prose
consequence, and naming it here is what makes the absorption auditable.

#### Two changes that are not definitional

- **`CO`'s drift is a citation append, nothing more.** The axiom gained
  `\leanfoot{DedekindDerived.coDerived}` and is otherwise byte-identical. The paper is pointing
  at this tree, which is the direction of travel this whole wave exhibits.
- **`app:discrete`'s drift is pure addition.** The static-frame footnote gained a soundness
  argument — over `$\Z$` the static frame validates `$\Next\top$` at every time, so extending
  **TM** by `DN` alone does not prove `NN` — and a new `\label{fn:static-frame}`. The added
  independence claim is **not formalized in this tree and not rowed here**: the user's recorded
  authorization for the four unformalized anchors expressly did not extend to `app:discrete`,
  which is formalized and has seven citing files. Whether the DN-does-not-prove-NN claim should
  be formalized is deferred as a separate question, and no `fn:static-frame` row is added.

#### `lem:derived-schemata` no longer exists

The paper removed the appendix lemma *Derived Schemata* "as unreadable", recording the removal
in an authorial source comment: each schema it collected is now stated as derived at the point
where it is displayed (`\S`Logic, `\S`Extensions) and inside `def:BX`, `def:BX-z`, `def:BX-d`
and `def:TMplus`, with no separate theorem. The anchor has **zero in-tree citations** (the
`#derived-schemata` links in `docs/reference/axiom-reference.md` are intra-document anchors to
that file's own section, not citations of the paper label), so no row is retired and no
`DANGLING` row is added. Any task description or note still pointing at `lem:derived-schemata`
for the derivations is stale; the live sources are the four definitions above.

#### The absorbed revision, and the paper's motion during the run

This correction pins a **dirty** file, and the paper was being edited *while this correction was
being applied*: four distinct whole-file checksums were measured during the implementation
dispatch alone, on top of the several that moved across the research and planning runs. Every
hash below was therefore re-derived at write time from `--resolve` and asserted against the
resolver's own sha before being written, and each old block was asserted to re-hash to its
recorded old sha before being replaced, so no placement was assumed. The gate was re-run after
every absorption round and the whole-file sentinels were re-taken last, after the final round.

| Field | Value |
|---|---|
| Paper sha256 absorbed | see the `FILE_CHECKSUM` sentinel above |
| Line count | see the `LINE_COUNT` sentinel above |
| Paper repo `git HEAD` | `bc010a06096299f605b12989461dc7ce86612b31` (also the last commit to touch the file) |
| Working-tree posture | **dirty** against that commit |

`def:id` was re-hashed **five times** inside this single correction, for five successive revisions
of the same block minutes apart (`f56301e5` → `b52579e8` → `18edbbea` → `58e1cdd6` → the hash its
entry now carries), which is the
same in-flight pattern the 2026-10-14 wave recorded for the same anchor. The acceptance claim
for this wave is therefore conditional by construction: the gate is green **against the revision
named by the sentinels above**, not unconditionally, and a thirteenth revision landing after this
file was written would re-red the gate without invalidating anything recorded here.


### Drift correction (2026-10-14): the 27-anchor wave

The checker was red (exit 1, case (c)) before this correction: **27 pinned entries drifted**, no
anchor went dangling, and the four `def:frame#*` sub-anchors were byte-stable throughout. It gives
the quiet case-(a) pass after it. The paper moved twice more while this correction was in flight
(three distinct `git HEAD`s and three distinct checksums across the research, planning and
execution runs), which is why every hash below was re-derived at execution time rather than carried
from the earlier runs.

**Re-hashed (re-quoted from live text via `--resolve`, none hand-written):** `def:temporal-order`,
`def:task-relation`, `def:frame`, `lem:nullity`, `def:world-history`, `thm:extension`,
`cor:occurrence`, `def:constraints`, `lem:nesting`, `def:BLplus-language`,
`def:time-shift-histories`, `def:frame-validity`, `def:BX`, `def:BX-z`, `def:BX-d`,
`thm:TM-soundness`, `app:discrete`, `app:dense`, `app:complete`, `def:frame-properties`,
`def:deterministic`, `cor:saturation-finite`, `cor:tm-completeness`, `def:id`, `def:strongest`,
`thm:exist`, `lem:uniq`.

**In-flight re-resolution of `def:id` (same wave, same section).** The paper moved a fourth time
while this correction was being applied, and the gate came back red on `def:id` alone after
everything below had already been re-pinned. Two expository edits inside the block: "the absorption
laws or other Boolean identities do not hold" became "the Boolean identities do not hold", and
"Symmetry and transitivity of $\equiv$" became "The symmetry and transitivity of $\equiv$". No
axiom, no substitution convention, no operator-scope proviso and no type distinction changed, and
`def:id` has no Lean counterpart, so there is no citation or soundness-chain consequence. Re-hashed
from `--resolve` into this same section, and the whole-file sentinels re-taken against the newer
file; the paper repo had also committed the file by then, which is why this re-pin is the first
since 2026-08-10 to pin a clean rather than a dirty working tree.

**Purely presentational in this wave (no content), recorded so a future reader does not go looking
for a change that is not there:** set-builder `:` became `\mid` in `def:temporal-order`,
`def:task-relation` and `def:BLplus-language`; `\textit{iff}` and `iff` became "if and only if" in
`def:time-shift-histories`, `app:discrete`, `app:dense` and `app:complete`; `cor:occurrence`,
`thm:extension`, `thm:exist` and `lem:uniq` gained environment titles (`[Occurrence]`,
`[Extension]`, `[Existence]`, `[Uniqueness]`); `def:frame`'s quantifier preamble lost the
mislabel "positive" ("for all positive durations $x, y \geq 0$" → "for all durations
$x, y \geq 0$", the range unchanged and still inclusive of zero); `lem:nesting` is now stated via
`def:constraints`'s own named families `F_t` and `S_{t,s}` instead of respelling the fibers and
segments, and lost the in-source `% FIX:` authorial note it used to carry; `def:constraints` was
restructured around named `A`, `C`, `F_t` and `S_{t,s}` with the segment-case guard restated as
"when $A$ and $C$ are both nonempty", defining the same family; `def:deterministic` had its
"holding in both temporal directions" clause commented out without changing the predicate; and
`def:world-history` now defines the top tier off *partial* history under both names
("A \textit{world history}, or \textit{possible world}") rather than off convex history, denoting
the same set since a total domain is trivially convex.

**Content-bearing changes, each called out individually:**

1. **`lem:nullity` was strengthened from an implication to a biconditional.** The paper said
   "$w \Rightarrow_0 w$ for every world state $w \in W$ in every task frame
   $\F = \tuple{W, \D, \Rightarrow}$"; it now says "$w \Rightarrow_0 u$ if and only if $w = u$,
   for all world states $w, u \in W$ in any task frame $\F$". This characterises `⇒₀` as the
   identity relation on `W`, which is strictly stronger than the zero loop. **The DERIVED status is
   untouched**: Nullity is still a lemma and still not a fifth frame axiom, `def:frame` still
   carries exactly four, and the strengthened form is still derived from *Seriality* at `x = 0` plus
   *Limit*. The formalization is **ahead of** this change rather than behind it: the biconditional
   is `FrameOver.nullity_identity` in `FormalSystem/Semantics/TaskFrame.lean`, with
   `nullity_identity_of_serial_limit` deriving it choice-free from *Seriality* and *Limit* over a
   bare task relation, and `FrameOver.nullity` carrying the reflexivity half. No new Lean
   declaration was needed for this wave, and none was added.
2. **`thm:TM-soundness` was generalized.** It said "If $\vdash \varphi$, then $\vDash \varphi$";
   it now says "Each system $\Lambda$ of \textbf{\ref{def:TMplus}} is sound: if
   $\Gamma \vdash_\Lambda \varphi$, then $\Gamma \vDash_{\mathsf{C}_\Lambda} \varphi$" — per-system,
   with a context $\Gamma$, and class-relative validity. This is the shape the tree's soundness
   results already have.
3. **`def:frame-properties` gained the ℤ-time and ℝ-time task-frame definitions**, so a task frame
   is now an "$\Z$-time task frame" or an "$\R$-time task frame" just in case its temporal order is
   isomorphic to `ℤ` or to `ℝ`.
4. **`cor:tm-completeness` was restated in terms of those new classes** ("Weakly complete over the
   $\Z$-time task frames" in place of "over $\Z$-time"), and the strong/weak completeness
   definitions it used to carry inline are gone from the block.
5. **`def:id` was generalized from formulas to terms.** `Ref` and `LL` now range over `α`, `β`
   that are "both formulas or, once operator terms are available in `def:lang`, both operator
   terms", and the operator-scope proviso reads "within the argument of an operator term" rather
   than "in the scope of an operator". `def:id` has no Lean counterpart, so there is no citation or
   soundness-chain consequence.
6. **`def:strongest` gained a second notion**, `Str'^{\OO}_{L}(\Q)` ("the meet of the objective
   modalities in $L$"), together with the argument that it implies `Str^{\OO}_{L}(\Q)` while the
   converse would require the identity. **`thm:exist`** now asserts `Str'` for `\Bm` and derives
   `Str` from it, and **`lem:uniq`** gained the matching uniqueness half for `Str'` plus a footnote
   on the independence of `I8` and of the identity of two strongest objective modalities. None of
   these three has a Lean counterpart.

**Two paper-ward alignments — the paper moved toward the tree, not away from it:**

- `def:task-relation`'s reflection convention now reads "for $x > 0$" where it read "for
  $x \geq 0$". The convention is therefore no longer stated at zero, which is exactly how the tree
  already treats it: the zero case is not a convention there but a consequence, `reflection_of_limit`.
- `cor:saturation-finite` now reads "Task relations on finite set of world states $W$ satisfy
  \textit{Saturation}, choice-free" in place of "Every task frame $\F = \tuple{W, \D, \Rightarrow}$
  with finite $W$ satisfies \textit{Saturation}, choice-free". The statement is now about bare task
  relations rather than full task frames, which is the generality the tree already has in
  `TaskFrame.saturation_of_fib_subsingleton` and `TaskFrame.saturation_of_finite`.

**Footnote removals — three citations the tree can no longer point at:**

- **`thm:extension` lost the choice-freeness footnote.** The footnote that said the Extension
  proof appeals to Zorn's lemma, so `cor:occurrence` is a theorem of ZFC "in contrast with the
  derivation of the zero loops in `lem:nullity` and the derivation of *Saturation* for finite $W$
  in `cor:saturation-finite`, both of which are choice-free", is gone from the paper. The tree's
  choice-freeness claims remain **true of the Lean proofs** — which is what this repository is
  entitled to assert, and what `nullity_identity_of_serial_limit` and `saturation_of_finite`
  actually establish — but they no longer have a live paper footnote behind them. Recorded here so
  a future reader does not hunt for a citation that no longer exists.
- **`def:BX` lost its Burgess/Xu attribution footnote**, which mapped `TN`, `TS`, `UC`, `UG`, `US`,
  `UF`, `UI`, `CN`, `UE`, `TL` onto Burgess's and Xu's numbered axioms and named the present
  system's own additions. `def:BX-d` likewise lost its "neither `DN` nor `NN` is due to Burgess or
  Xu" sentence, and `def:BX-z` lost the corresponding sentence about `UZ` and `Z1`.
- **`def:frame-validity` and `cor:tm-completeness` had their footnotes commented out** (frame
  validity's non-vacuity via `cor:occurrence`; completeness's pointer to the Lean repository and
  its `Determined`/`Stability` extension note). Both are commented out in the paper source rather
  than deleted, so they sit inside the hashed region as `%`-prefixed lines and are quoted here
  verbatim like any other in-block comment.

**In-tree prose this wave forced.** The in-tree correction scope is exactly the re-pinned set,
because "verbatim" in this tree's docstrings means verbatim *against this record file*, not against
the paper (stated at `FormalSystem/Semantics/FrameAxioms.lean`). Four docstrings quoted the retired
`lem:nullity` sentence under an explicit "verbatim" label and were re-quoted:
`FormalSystem/Semantics/TaskFrame.lean` (module docstring and the docstring above
`nullity_of_serial_limit`), `FormalSystem/Semantics/FrameAxioms.lean` (the
"Paper specification, transcribed" list), and `FormalSystem/Semantics/Extension/Admissible.lean`.
Non-Lean restatements of the lemma were corrected in `README.md`,
`docs/reference/API_REFERENCE.md`, `docs/reference/transcription-audit-surface.md`,
`typst/FormalFoundations.typ` and `typst/chapters/02-semantics.typ`.

The other re-pinned anchors forced these further corrections, each on a docstring that labelled
its quotation "verbatim":

- `def:frame`'s whole-definition quote in `FormalSystem/Semantics/TaskFrame.lean`'s module
  docstring was re-quoted. It had said "A \textit{frame} is any …" where the record pins "a
  \textit{task frame} is any …", omitted the `⊇`-directed opening clause entirely, and carried the
  old "for $x, y \geq 0$" preamble; the blanket-condition quote above `Serial` was re-quoted for
  the same preamble.
- `def:task-relation`'s quotes in `TaskFrame.lean` were re-quoted for the reflection convention's
  "for $x > 0$" and for the *Fiber* clause's `\mid`, and the retired `\Fib(w, x)`
  function-application form was replaced with the pinned brace form `\fib{w, x}` at the three
  *Fiber*/*Cone*/*Segment* clause quotes (and in one neighbouring prose line that used the same
  retired notation). The module's own discussion of whether the convention covers zero was
  rewritten: the paper's proviso is now strictly positive, so the tree's strict-at-zero split is
  licensed outright rather than defended as a reading.
- `def:temporal-order`'s quotes in `TaskFrame.lean`, `FormalSystem/Semantics/TemporalOrder.lean`
  and `FormalSystem/Examples/TemporalStructures.lean` were re-quoted for the `\mid` set-builder.
- `def:constraints`'s quotes in `FormalSystem/Semantics/FrameAxioms.lean` (twice) and
  `FormalSystem/Semantics/Extension/{Admissible,Constraint}.lean` were re-quoted for the `A`/`C`/
  `F_t`/`S_{t,s}` restructuring. These had also carried three pre-existing errors at once — "over
  a frame" for "over a task frame", the retired "constraints *imposed on*" wording, and
  `\Fib(…)` — all now gone.
- `def:frame-validity`'s two quotes in `FormalSystem/Semantics/Validity.lean` were re-quoted for
  the "--- written … --- just in case" rewording.
- `def:world-history`'s block quote in `FormalSystem/Semantics/PartialHistory.lean` was re-quoted
  for the world-history/possible-world tier, and the note claiming the appendix routes that tier
  through convex histories was corrected.
- `cor:saturation-finite`'s two quotes in `TaskFrame.lean` were re-quoted for the generalization
  to bare task relations.
- `thm:extension`'s **footnote** quotes in `FormalSystem/Semantics/Extension/Extension.lean`
  (twice) were removed rather than re-quoted, since the footnote no longer exists to quote. Each
  now says so and restates the choice-freeness contrast as a property of the Lean proofs.

Paraphrases that state only the weak loop *as what a proof consumes* were deliberately kept: a
proof that needs only `w ⇒₀ w` keeps citing `w ⇒₀ w`, and
`FormalSystem/Semantics/Presheaf/Behavior.lean`,
`docs/reference/state-topology-appendix-support.md`,
`docs/development/PROPERTY_TESTING_GUIDE.md`, `typst/chapters/06-notes.typ` and the References
lines of `FormalSystem/Semantics/Extension/Admissible.lean` and
`FormalSystem/Semantics/Extension/Extension.lean` are correct as they stand. `def:frame-properties`
and `def:deterministic` forced nothing: the clauses the tree quotes from them did not move.
`docs/theorem-index.md` and `FormalSystem/Semantics/README.md` forced nothing either — neither
reproduces re-pinned block text.

**Left alone deliberately.** Pre-existing false-`verbatim` claims on anchors *outside* this
re-pinned set are not fixed here, since this wave gives no occasion to touch those files. The one
found while sweeping is `FormalSystem/Semantics/Extension/Step.lean`'s `def:frame#Saturation`
quote, which says "for any directed family" where the record pins "for any
$\supseteq$-directed family"; `def:frame#Saturation` is byte-stable and was not re-pinned.

### Label rename absorption (2026-09-18): `lem:temporal-duality` → `lem:time-reflection`, prose only, no re-pin

The paper renamed `lem:temporal-duality` to `lem:time-reflection`. The old label no longer occurs
anywhere in the paper. The lemma also grew: besides the truth equivalence
`M,τ,x ⊨ φ ⇔ M⁻,τ⁻,n(x) ⊨ φ⟨S|U⟩`, it now states that `F⁻` is a task frame and that `τ ↦ τ⁻` is
a bijection `H_F → H_{F⁻}`. `thm:TR-valid` cites it by the new label.
`bash scripts/check-paper-definitions.sh` reports case (b): the checksum moved, and every recorded
definition is unchanged. Neither label has a manifest row, so nothing is re-hashed, and per the
dirty-pin convention the whole-file sentinels are **not** re-pinned (case (b) is not a drift
correction). `lem:time-reflection` gets a `LIVE-UNPINNED` row in `KNOWN-ANCHORS`: the tree now cites
it by name (the `MinusFrame.lean` truth-lemma docstrings) but only paraphrases it. No
`lem:temporal-duality` row is added, because no site outside this file keeps the old label.

The rename removes the justification for the 2026-09-17 wave's "semantic lemma keeps its name"
carve-out, so the carve-out is withdrawn and one principle now governs the tree: **`reflect` names
every operation that reverses time order on any object (formula, frame, history, truth lemma);
`swap` survives only for exchanges that are not time reversal.** Each remaining `swap`-named
family was classified by that test.

**Renamed (time reversal).** Statements are unchanged; only names move.

| Old | New | Why it is time reversal |
|---|---|---|
| `MinusFrame.swap` | `MinusFrame.reflect` | the paper's `F⁻` (distinct from `TaskFrame.reflect`, the reflection convention on relations; different namespace) |
| `truth_swap` | `truth_reflectTime` | the L⁻ analogue of `lem:time-reflection` |
| `swapUS`, `swapUS_involutive` | `reflectTimeBoxOpaque`, `reflectTimeBoxOpaque_involutive` | time reflection with box subformulas treated as atoms |
| `swap_norm` (simp attribute) | `reflect_time_norm` | collects the `reflect_time_*` push-through lemmas |
| `Encoding.swap` | `Encoding.reflectTime` | the encoding conjugated by `reflectTime`; it exchanges nothing |
| `plusValidIn_swap_of_tm`, `plusValidIn_swap_of_tm_deriv` | `plusValidIn_reflect_time_of_tm`, `plusValidIn_reflect_time_of_tm_deriv` | conclude validity of `φ.reflectTime` |
| `cValid_swap_of_tm`, `cValid_swap_of_tm_deriv`, `naiveAxiom_cValid_swap`, `naive_cValid_and_swap` | `cValid_reflect_time_of_tm`, `cValid_reflect_time_of_tm_deriv`, `naiveAxiom_cValid_reflect_time`, `naive_cValid_and_reflect_time` | conclude `CValid φ.reflectTime` |
| `starValid_{discrete_propagate_fwd, discrete_propagate_bwd, discrete_box_necessity, density, dense_indicator, z1, sep, modal_future, paste, untl_paste}_swap` | `starValid_*_reflect_time` | each is the `reflectTime` image of a schema |
| `swap_next_all_future_eq` | `reflect_time_next_all_future_eq` | a `reflectTime` image equation |

**Kept (exchange, not time reversal).** Mathlib `Equiv.swap`/`Prod.swap`/`List.Perm.swap`; the
Kamp/EF index transpositions `aggOdSwap12*`, `CAggOdSwap_clause_iff*`, `swapNF01*`,
`cons2_comp_swap01`; `monoInv_swap`/`monoInv_of_swap` (pair-component exchange);
`pairProject_swap_*`; `contraSwap` (contraposition argument exchange); the `trySwap*` mutators,
which exchange operators within one time direction (until↔release, P↔H, box↔diamond). The
serialized tags stay byte-stable for output compatibility: the mutation-family strings
`"modal_swap"`/`"temporal_swap"`/`"derived_swap"` with their `*SwapCount` fields, and the
`"temporal_duality"` strings and `"temporalDualityCount"` key already carved out by the 2026-09-17
wave. Operator-duality names (▽/△, F/G) are a different concept and also stay. The typst notation
macro `#let swap` is a macro name, not a claim, and is kept.

**Deferred.** Other words for time reversal (`clockMirrorIso`/`truthAt_mirror`, `TruthAntiIso`,
`DenseModelSurgery.dual`) are not `swap` and are left for a possible follow-up.

### Drift correction and rename absorption (2026-09-17): the time-reflection wave

The checker was red (exit 1, case (c)) before this correction: **14 pinned entries drifted and
1 pinned anchor went dangling**. It gives the quiet case-(a) pass after it.

**Re-hashed (re-quoted from live text via `--resolve`, none hand-written):** `def:BL-semantics`,
`def:BLplus-language`, `def:S5`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus`,
`app:discrete`, `app:dense`, `app:complete`, `def:frame-properties`, `cor:tm-completeness`,
`def:id`. Most of the drift is reflow and rewording. In particular every system definition changed
"the smallest extension of X closed under Y" to "X extends ... to include Y", and `def:TMplus`
gained the sentence that the derivation relation is the smallest relation closed under a system's
axioms and rules. The `DerivationTree` docstrings use neither phrasing and needed no edit, since an
inductive family already is that least relation. Eight in-tree paraphrases of the old phrasing (seven
in `typst/`, one in `FormalSystem/MinusLanguage/Axioms.lean`) were reworded.

**Retired (manifest row removed, prose entry retained and marked `DANGLING`, `KNOWN-ANCHORS` row
added):** `thm:M5-valid`. The paper commented out the whole theorem environment. No live citation
existed.

**Three substantive renames, each decided separately:**

1. **"converse convention" → "reflection convention"** (`def:task-relation`). **Adopted earlier**:
   the tree already follows it. See the re-pin note at the `def:task-relation` entry. Regression
   gate: the phrase "converse convention" survives only as quoted history in this file.
2. **Metarule `TD` → `TR`** (`def:BX`, "time reflection"). **Adopted in full**, identifiers
   included, by the user's decision. The rule abbreviation `TD` became `TR` in prose, and
   rule-sense "temporal duality" became "time reflection". Identifier map (substring rename across
   `FormalSystem/` excluding `Boneyard/`, `Tests/`, READMEs, `docs/` and `typst/`):

   | Old | New |
   |---|---|
   | `swapTemporal` (on `Formula`, `PlusFormula`, `StarFormula`, and every compound such as `ofPlus_swapTemporal`, `swapTemporal_injective`) | `reflectTime` |
   | `swap_temporal_*` (e.g. `swap_temporal_involution`, `provEquiv_swap_temporal_congr`) | `reflect_time_*` |
   | `temporal_duality` (every `DerivationTree` constructor, `temporal_duality_height_succ`) | `time_reflection` |
   | `TemporalDuality` (`applyTemporalDuality`, `mkTemporalDuality`, `TemporalDualityIntegration`) | `TimeReflection` |
   | `temporalDuality` (`MutationType.temporalDuality`, `temporalDualityCount`) | `timeReflection` |

   Scale: 1,466 identifier occurrences across 81 Lean files, plus 187 prose lines renamed and
   28 kept after classification.

   **Deliberate divergences (carve-outs), each with its reason:**
   - **Operator duality is a different concept.** `temporalDualityNeg`/`temporalDualityNegRev` and
     the "modal and temporal duality" prose of `Theorems/Perpetuity/MonotonicityDuality.lean`, its
     README, `Theorems/Perpetuity.lean` and `PerpetuityTest.lean` name the ▽/△ duality. So do the
     `section TemporalDuality` of `Theorems/TemporalDerived.lean` and its "Temporal Duality" headings
     (F/G and P/H via double negation). None of these mean the metarule, and none is renamed.
   - **The semantic lemma's name (carve-out withdrawn 2026-09-18).** This wave originally kept
     prose naming `lem:temporal-duality` ("temporal duality soundness", "past-future swap preserves
     validity") because the paper kept that label. The paper has since renamed it
     `lem:time-reflection`, so the carve-out is withdrawn and that prose now uses time-reflection
     wording. See "Label rename absorption (2026-09-18)" above.
   - **Serialized wire tags stay byte-stable.** These are the `"temporal_duality"` string literals in
     dataset/JSON output (`BimodalTools/DataExport.lean`, `DatasetGenerator.lean`,
     `ProofStepExtractor.lean`, `ContrastiveGenerator.lean`, `ProofExtractorMain.lean`), the
     `"temporalDualityCount"` key in `ProofFirstBenchmark.lean`, and the rule-name list in the
     training-pipeline sync protocol (internal, not part of the tracked deliverable). Each code
     site carries a comment saying so. These tags are
     *not* a claim about the paper's `def:BX`. The one exception is `MachineAppendixMain.lean`,
     whose rule `name`/`conclusion` strings follow the live constructor names, because the typst
     machine appendix is recounted against them.
   - **The `swap`-named families, decided by the same test.** Each family was judged by whether
     it denotes the paper's time reflection `φ⟨S|U⟩` (rule TR, `thm:TR-valid`).
     - `swapMinus` → `MinusFormula.reflectTime` (**renamed**). It is time reflection on L⁻, box
       included, and TM⁻'s TR transforms by it. Compounds follow the substring rule:
       `reflectTime_involution`, `reflectTime_neg` and the other push-through lemmas,
       `reflectTime_df_valid_of_predOrder`, and `tr_reflectTime : tr φ.reflectTime =
       (tr φ).reflectTime`, which intertwines it with `Formula.reflectTime`.
     - `*_swap_valid*` → `*_reflect_time_valid*` (**renamed**). Every member concludes validity of
       `φ.reflectTime` for an axiom or derivation, which is `thm:TR-valid` restricted to axioms
       (e.g. `axiom_reflect_time_validIn_min`, `derivable_valid_and_reflect_time_validIn`).
     - `swapUS` (kept by this wave; **renamed 2026-09-18** to `reflectTimeBoxOpaque`). It leaves
       `.box φ` opaque on purpose, because `TemporalTruth` reads box-subformulas as atoms, so it is
       not `φ⟨S|U⟩` on boxes and must not share the bare `reflectTime` name. The qualified name
       says so, and so does its docstring.
     - `truth_swap` (kept by this wave; **renamed 2026-09-18** to `truth_reflectTime`). It is the
       L⁻ analogue of `lem:time-reflection` (then `lem:temporal-duality`). The frame operation it
       uses, `MinusFrame.swap` (the paper's `F⁻`), is renamed `MinusFrame.reflect` in the same
       step.
     - The serialized mutation-family tags `"modal_swap"`, `"temporal_swap"` and `"derived_swap"`
       are a different concept and stay byte-stable. No renamed substring occurs in any string
       literal.
     - Adjacent `swap`-named identifiers (the `swap_norm` simp attribute, `*_swap_of_tm*`, the
       `cValid` swaps, `starValid_*_swap`) were outside this decision. They have since been
       classified and renamed; see "Label rename absorption (2026-09-18)" above for the full map.
   - **`Boneyard/**`** is an archive that is not built, and it is untouched.
   - Benchmark output labels (`"Temporal duality"` in `DerivationBenchmark.lean`,
     `docs/project-info/performance-targets.md`) are kept for output and history stability. The
     `untl`/`snce` rename's migration pattern data was recorded by a one-off migration script
     (since deleted, its rename mapping preserved in git history) and is not part of the live
     deliverable.
3. **`\past`/`\future` labels "Past"/"Future" → "Some Past"/"Some Future"**, with `\Past`/`\Future`
   now "All Past"/"All Future" (`def:BLplus-language`). **Adopted.** The Lean names
   `somePast`/`someFuture`/`allPast`/`allFuture` already matched. The label sites in
   `Syntax/Formula.lean`, `docs/reference/operators.md` and `docs/user-guide/quickstart.md` now use
   the paper's labels.

**Constructor naming audit: closed.** The open note in `FormalSystem/MinusLanguage/Axioms.lean`
has been replaced. The paper-key → primary constructor → explicit mirror table is now in
`docs/reference/axiom-reference.md` § Paper Key Correspondence. The verdict, originally *same
system, explicit mirrors*, has since become *same primitive system*: `inductive Axiom` now has
exactly the paper's 29 schemata (CPL as K/S/EFQ/Peirce, MK, MT, M5, the 11 BX temporal schemata,
NP/NF/NA/NB, MF, DN, NN, UZ, Z1, PU, SEP), with TL, CN and TS stated verbatim (3-way disjunctions
right-associated). Every former surplus constructor -- the TR mirrors, modal 4 and B, and the
past forms of UZ and PU -- is a machine-checked derived theorem in
`FormalSystem.ProofSystem.DerivedAxioms`, so the textual correspondence and the follow-up it
called for are both superseded. `discrete_propagate_bwd` remains NA itself, not a mirror.
The same closure corrected
`typst/FormalFoundations.typ`'s remark that the development "has no TR rule" and that the
uniformity layer "does not even match in count". Both claims were wrong.

**Amended by** `FormalSystem/ProofSystem/LinearityDerivedFacts.lean`, 2026-10-14, and
**resolved** by the 2026-10-15 BX/TM demotion wave above: the divergence this note was opened to
record no longer exists, and the "exactly the paper's 29 schemata" figure in the paragraph above
is a superseded historical reading — 788 reduced the constructor count to 20 and the paper has
since come to the same set. The tree's primitive set is not a proper subset of `def:BX`/`def:BX-z`/
`def:BX-d`'s lists; the paper's primitive schemata and `inductive Axiom`'s 20 constructors now
**coincide key for key** (CPL 4, MK/MT/M5, TS, UG, UC, US, UF, UI, CN, MF, NB, UZ, NN, PU, SEP).
The nine schemata derived in the tree — TC, UE, UT, NP, NF, NA
(`FormalSystem/Theorems/ConnectDerived.lean`, `ProofSystem/DerivedAxioms.lean`), TL and DN
(`FormalSystem/Theorems/LinearityDerived.lean`) and Z1
(`FormalSystem/Metalogic/CompletenessDerived.lean`, through the ℤ-time completeness engine) —
are no longer schemata the paper lists as axioms: UE and UT are not paper keys at all, TC and TL
are derived theorems of BX in `def:BX`'s own text, NP/NF/NA are derived theorems of TM in
`def:TMplus`'s, Z1 of TM$_z$ in `def:BX-z`'s and DN of BX$_d$ in `def:BX-d`'s. The derivation
record for TL stands: it is derived from CN (Xu 1988 §3: Σ₄ is complete for linear frames with
Burgess's A4a deleted; §4 Theorem 4.3: the G/H-level (13) is strictly weaker than (10)), A4a is
**not** restored, and `LinearityDerivedFacts.lean` also retracts that module's earlier
underivability claim (its branching frame refutes CN itself). The paper is still never edited
from here, but it no longer needs to be: it reached the tree's position on its own, and the
2026-10-15 entry above records how.
The footnote erratum below stands — UE follows from UG, not UC — and is what
`DerivedAxioms.untilF` implements.

**TM⁻ de-attributed.** `MinusLanguage/Axioms.lean` no longer describes TM⁻ as a paper system. It
now reads as this repository's own transposition, consistent with "Language correspondence
(2026-09-08)" above.

**`def:BX`'s Burgess/Xu provenance footnote: closed.** The paper attributes TN, TS,
UC/UG/US/UF/UI (A1a/A2a/A3a/A5a/A6a), CN (A7a, with Xu) and TL (in spirit, Xu's V₃) to Burgess and
Xu, and marks TC/UT/NP/NF/NA/NB as original. The apparent contradiction with the tree is resolved
in the paper's favour: **CN is Burgess 1982 A7a**, and it is sound. Burgess 1982 §1.2 uses the same
strict/open-guard semantics as this tree (the guard holds on `x < z < y`), and the tree proves A7a
valid under it (`linear_until_valid` in `FormalSystem/Metalogic/Soundness.lean`). The old NOTE in
`ProofSystem/Axioms.lean` that called A7a "removed as unsound under open guard" was about a
different formula. A former constructor pair, `linear_until_a7a`/`linear_since_a7a`, copied
Burgess's `U(event, guard)` argument positions into the guard-first `untl` without swapping them,
so A7a's fixed guard `q∧s` became a fixed event. That fixed-event variant is unsound and was
removed, but the defect was in the transcription, not in A7a. The NOTE now says so. The full
reconciled map is in `FormalSystem/ProofSystem/Axioms.lean`'s module docstring, § Axiom Sources,
and in `docs/reference/axiom-reference.md` § Paper Key Correspondence. Each attributed
constructor's docstring also carries its Burgess/Xu tag. On Xu, the precise statement is this:
Xu 1988 prints A7a as his formula (10), with mirror (11), and places it in the axiom set Σ₄, which
is complete for the class 𝒞₄ of linear frames. On its own, (10) defines the first-order interval
condition (10)*, not linearity itself. The footnote's "defining linear frames" is directionally
right but loose. Burgess 1984's A7a is a different axiom (Dedekind completeness,
`Fp ∧ FG¬p → F(HFp ∧ G¬p)`), and the three Chronicle files that cite it now say so.

**Paper footnote errata (outside this repository).** Two items in the `def:BX` footnote are wrong
against the sources. They are recorded here, and the paper source is not edited from this
repository. The quoted footnote block below is left exactly as the paper prints it.

1. *UE's derivation.* The footnote says UE follows from UC with ψ = ⊤. It follows from **UG** with
   the new guard χ = ⊤, plus TN for `G(φ → ⊤)`: UG gives `(φUψ) → (⊤Uψ)`, and `⊤Uψ` is `Fψ`.
   UC with ψ = ⊤ gives `(χUφ) → (χU⊤)`, which is not UE.
2. *TL's source.* Xu 1988 has no frame class `𝖵₃`; his classes are 𝒞₀-𝒞₅. TL is verbatim Burgess
   1984 §0.3 axiom A2a (mirror A2b), and the nearest Xu formula is (13), `Fp → G(p ∨ Fp ∨ Pp)`
   (§4, Theorem 4.3).

**`cor:tm-completeness`'s new *Determined* sentence is backed by the tree.** It reads: each system
"extended to include *Determined* ... sound over the task frames in its class validating
*Determined* and weakly complete over the Deterministic task frames in that class".
`FormalSystem/Metalogic/Deterministic/` proves exactly this shape: `detSoundness` and
`detSoundnessDet` in `Soundness.lean`, and `detCompletenessBase`/`detCompletenessDense`/
`detCompletenessZTime` in `Completeness.lean`.

**Record-side TD mentions.** The paper's validity theorem for the rule is now `thm:TR-valid`
(formerly `thm:TD-valid`). Neither is pinned or cited in live tree scope. The quoted historical
text in this file (for example the retired `def:TMplus-c` block's `\aref{TMP-TD}`) is left verbatim.

### Language correspondence (2026-09-08): permanent, prose only, no re-pin

The repository renamed its object languages so that its names mean what the paper's mean. This
section records the resulting correspondence as a **permanent** fact about the two documents, not
as a pending alignment to be resolved later.

**The manuscript has exactly two languages.** They are 𝓛 and 𝓛⋆, where 𝓛⋆ bundles the stability
modal ⊡ with **both** register families — time store/recall and world store/recall. The
line-independent anchor for that is the sentence defining `\BL^\star` in `\S sub:Extension`;
`sub:` is a sectioning prefix, which C15's citation pattern does not match, so it needs no
`KNOWN-ANCHORS` row. `def:BLstar-semantics` interprets ⊡, `timeStore` and `timeRecall`, and
suppresses the world registers.

**`def:BLplus-language` and `def:TMplus` keep their anchor labels.** Their *labels* still read
`BLplus`/`TMplus` for historical reasons, but their *content* has defined 𝓛 and TM since the
paper collapsed `BL^+` into `BL`. After this rename they correspond to this repository's **L**
and **TM** on the nose — the repository's earlier `L⁺`/`TM⁺` names for them are gone. No text
moved on either side, so neither anchor's hash changes.

**The correspondence, stated permanently:**

| Repository | Manuscript |
|---|---|
| **L**, **TM** (with TM_z, TM_d, TM_r) | 𝓛 (`def:BLplus-language`), TM (`def:TMplus`, `cor:tm-completeness`) — the same systems under the same names |
| **L⁻**, **TM⁻** | **no counterpart.** The H/G fragment was withdrawn from the paper; the passage that named a Past/Future system is commented out in the live source. L⁻ is this repository's own language, and its `z`/`d`/`r` subscripts are Lean-only labels |
| **L⁺**, **TM⁺** | L⁺ is the **⊡-only fragment** of the manuscript's 𝓛⋆. The manuscript supplies no logic for 𝓛⋆ (it places one outside its scope), so TM⁺ answers to no paper system |
| **L⋆** | the **time-register fragment** of the manuscript's 𝓛⋆ — ⊡ plus `timeStore`/`timeRecall`, which is what `app:deterministic-future` uses. The world registers are not formalized |

Every docstring and README that relates a repository language to the paper must say this in those
words. In particular, a repository result about L⁺ or L⋆ is a result about a **fragment of 𝓛⋆**,
and must never be described by a paper name it does not have. The one paper name that now
transfers without qualification is TM, and it transfers because the two are the same system.

**No pin moved.** Per "How to extend this record", this is a prose-and-classification change: no
anchor was added, no anchor drifted as a result of it, and therefore **no `verbatim:` block, no
`sha256:` line, no manifest row, and neither the `PINNED_COMMIT` nor the `FILE_CHECKSUM` sentinel
was touched**. This follows the precedent of "Vocabulary alignment (2026-09-07): prose only, no
re-pin" above.

`scripts/check-paper-definitions.sh` was re-run after the edit. Its verdict is unchanged by this
work: **case (b)**, drift detected, with the same six anchors the separate re-pin work already
owns — `def:S5`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus` — every one of them a
`smallest extension of X closed under Y` → `extends X to include Y` rewording plus, for `def:BX`
and `def:BX-r`, footnote/comment churn. No anchor entered or left that set because of this rename.

**Citation sites that moved.** The `app:ObjectiveModality` row of "Anchor classification
(2026-09-07)" above names the former `BaseLanguage/Axioms.lean` as its citing file; that module
is now `FormalSystem/MinusLanguage/Axioms.lean`. The anchor, its classification and its reason are
unchanged.

### Drift correction and rename absorption (2026-09-07): the z/d/r wave

The paper's z/d/r wave is the largest single wave this record has absorbed: **15 pinned entries
drifted, 9 pinned anchors went dangling, and 3 renamed anchors were newly pinned**, all in one
correction. The checker was red (exit 1) before it and gives the quiet case-(a) pass after it.

**What the paper did.** Three structural moves, each with record-side consequences:

1. **`BL^+` collapsed into `BL`.** The paper stopped maintaining a separate since/until language:
   `def:BLplus-language` now defines `BL` itself and absorbs the eight defined operators that
   `def:BLplus-defined` used to carry; `def:BL-semantics` absorbs the `\since`/`\until` truth
   clauses that `def:BLplus-semantics` used to carry (and drops the `\Past`/`\Future` clauses,
   which are now defined rather than primitive); and the `TM`$^+$ family lost its superscript
   throughout — `def:TMplus` now names **TM**, for **BL**, with extensions **TM**$_z$ / **TM**$_d$
   / **TM**$_r$. The anchor id `def:TMplus` is unchanged; only its content moved.
2. **The `f`/`d`/`c` subscripts became `z`/`d`/`r`, under new labels.** `def:TMplus-f` →
   `def:BX-z`, `def:TMplus-d` → `def:BX-d`, `def:TMplus-c` → `def:BX-r`. These are renames with
   content changes, not pure re-labellings: all three now cite `\S`Extensions for their axioms
   instead of displaying them, `def:BX-z` defers the Hölder step and cites `prop:archimedean`,
   and `def:BX-r` is re-titled *Dense and Complete* and presented as an extension of **BX**$_d$.
3. **The correspondence theorems moved from frames to temporal orders.** `app:discrete`,
   `app:dense`, `app:complete` are now stated as `$\vDash_{\D}$ … iff `$\D$` is …` over a
   temporal order rather than `$\F \vDash$ … iff `$\F$` is a … task frame`, and
   `def:frame-properties` defines Discrete/Dense/Complete on the temporal order first, deriving
   the frame-level predicates from it. `app:discrete` also gained a long footnote explaining why
   these cannot be sharpened to single task frames (the static frame is the counterexample) and
   citing this repository for the fibre-level formulation.

**Retired (manifest row removed, prose entry retained and marked `DANGLING`, `KNOWN-ANCHORS` row
added):** `def:directed` (folded inline into `def:frame`'s opening clause), `def:BLplus-semantics`
and `def:BLplus-defined` (absorbed as above), `thm:BLplus-PastFuture` and
`thm:BLplus-NextPrevious` (removed with the `BL^+` cluster), `TMP-CO` (the `BL^+` restatement of
`CO`; the plain `CO` anchor is still live and still pinned), and `def:TMplus-f` / `def:TMplus-d` /
`def:TMplus-c` (renamed as above).

**Newly pinned:** `def:BX-z` (`385f73e8…`), `def:BX-d` (`555db844…`), `def:BX-r` (`b35751c7…`).

**Re-hashed:** `def:frame`, `def:world-history`, `thm:extension`, `cor:occurrence`,
`def:BL-semantics`, `def:BLplus-language`, `def:S5`, `def:BX`, `def:TMplus`, `app:discrete`,
`app:dense`, `app:complete`, `def:frame-properties`, `cor:saturation-finite`,
`cor:tm-completeness`. Two of these are not mere re-quotes and carry their own notes at their
entries: `cor:saturation-finite` changed **environment** (`Cthm` → `Lthm`) with its statement
word-for-word unchanged, and `def:frame` both absorbed `def:directed` and **softened its
ball-space footnote from "strictly stronger" to "at least as strong as"**, withdrawing the
strictness claim.

`cor:tm-completeness`'s list now reads: **TM** strongly complete over all task frames,
**TM**$_d$ strongly complete over the dense task frames, **TM**$_z$ weakly complete over
ℤ-time, **TM**$_r$ weakly complete over ℝ-time (previously "the dense-and-complete class").

**Four corrections recorded so the next reader does not re-derive them:**

- **The Z1 / Past–Future-fragment footnote is commented out, not live.** The paper's Logic
  subsection carries the fragment claim and its footnote entirely behind `%` (paper lines
  ~1332–1340), with an author note giving the reason: "footnote commented out until the
  BimodalLogic repository establishes that the Past/Future language admits no complete
  axiomatization; the repository currently shows only that one particular system in that language
  is incomplete over ℤ-time." Nothing here is pinned as live, and no `KNOWN-ANCHORS` row is added
  for it. This repository's `not_bl_derivable_z1`
  (`FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean`) is what the commented-out footnote
  *would* cite; the accompanying Kripke countermodel for the base class is a pen-and-paper claim
  this repository does **not** check.
- **`thm:TM-soundness` needed no re-hash.** It is not in the drifted list above, and that is
  correct rather than an omission: everything the paper changed about it — the extension to
  **TM** and its extensions, the new sentence that the since/until/next/previous schemata are
  valid by their clauses as verified in this repository, and the footnote's re-aimed citation —
  lives in the `\begin{proof}` block *after* `\end{Tthm}`, which `resolve_env` does not capture.
  A future task that wants that text pinned must pin the proof block, which the current resolver
  cannot do.
- **`def:BX-r`'s second Reynolds axiom is `SEP`, not `SP`.** The displayed key is `Sep` and the
  `\aitem` label is `SEP`.
- **`prop:fragment` and `rmk:fragment` are gone and require no action.** An exhaustive grep of the
  live paper finds no such labels, no manifest row pinned either, and no file in live tree scope
  cites either name. No `DANGLING` row is added: the record's rule is that a row is a decision,
  and there is no citation to make honest.

**No repository-side consequence:** `lem:temporal-duality` (since renamed `lem:time-reflection`; see the 2026-09-18 absorption) (paper line 4061) and `thm:TD-valid` (since renamed `thm:TR-valid`; see the 2026-09-17 wave)
(line 4133) were restated for the since/until interchange with new inductive `U`/`S` cases, but
neither has a manifest row and neither is cited anywhere in live tree scope, so this wave leaves
them alone. `prop:archimedean` (line 3265) is a live `Pthm` that `def:BX-z` now cites for the
failure of `UZ`/`Z1` over non-Archimedean discrete orders; it is a pen-and-paper result this
repository does not check, and it is recorded as `LIVE-UNPINNED` (not pinned as verified) if and
when tree prose cites it.

**Moving target during absorption.** The paper file changed on disk *four times while this
correction was being written*: `f3acc3ad…` → `c3846c1e…` between the re-hash and the first
sentinel re-pin, then `c485a615…`, then `1b3c33a2…`. The first three were case (b) — no recorded
definition drifted — but the fourth genuinely drifted `def:BX-z`: the author deleted the two
`%% NEW CHANGE […]` editorial comment lines and the three commented-out sentences from inside the
`Ddef` environment, leaving the live prose word-for-word identical. Because `resolve_env` hashes
the whole environment, comment-only deletions are hash-visible; `def:BX-z` was therefore
re-quoted and re-hashed (`385f73e8…` → `3e2af812…`) and the sentinels re-pinned a second time.
Every anchor was re-derived against the then-current file before each pin, and the checker was
re-run afterwards. Hashes were derived only via `check-paper-definitions.sh --resolve`; none was
hand-written. A reader should expect this file's pin to be behind the live paper again by the
time they read it — that is the condition this infrastructure exists to detect, not a defect in
the pin.

### Anchor classification (2026-09-07): four `LIVE-UNPINNED` rows for the C15 gate

`scripts/check-module-invariants.sh`'s **C15** was the sole failing check group, reporting four
paper-anchor citations resolving to nothing here. All four were re-measured against the live
`.tex` and against the paper repository's `HEAD`, and all four resolve to live, non-commented
`\label{}` targets in both — so all four are recorded `LIVE-UNPINNED`, none `DANGLING`, and no
citation site needed correcting:

| Anchor | Paper environment | Cited by | Why unpinned |
|---|---|---|---|
| `app:ObjectiveModality` | `\subsection{Objective Modality}%` with the label on the following line | `FormalSystem/MinusLanguage/Axioms.lean` (cited as the former `BaseLanguage/Axioms.lean` when this row was recorded; see "Citation sites that moved" above) | **Structurally unpinnable.** `resolve_env` reads the environment name off the same line as the `\label{}`, so a sectioning label on its own line can never resolve. Same shape as the already-recorded `app:TaskSemantics`. |
| `app:drift` | `Tthm` | `Independence/DriftFrame.lean`, `Independence/RealTranslationFrame.lean` | Pinnable in principle, useless in practice: the `Tthm` block carries only the statement, while the text `DriftFrame.lean` actually engages with — the `λ ≔ (v − w)/(x + y)` interpolation and the compactness/finite-intersection *Saturation* argument — sits in the `\begin{proof}` block *after* `\end{Tthm}`, which `resolve_env` does not capture. A pin would hash text the tree never quotes. |
| `cor:no-characterization` | `Cthm` | `Independence/README.md`, `Independence/DriftFrame.lean`, `Independence/StateSetTruth.lean`, `Independence/RealTranslationFrame.lean` | Cited by name only. |
| `lem:deterministic-singleton` | `Lthm` | `Independence/RealTranslationFrame.lean`, `Independence/StateSetTruth.lean` | Cited by name only; `StateSetTruth.lean` names its choice-free (⇒) direction but quotes no text. |

`app:ObjectiveModality` entered the cited set with the `Axioms.lean` paper-name correspondence
table; the other three entered with the `Metalogic/Independence/` frames. No manifest row, no
`FILE_CHECKSUM` sentinel, and no `PINNED_COMMIT` sentinel is touched by this wave — nothing
drifted, so there is nothing to re-pin.

### Rename absorption (2026-09-02): `Spherical` → `Saturation`

The paper renamed its fourth task-frame axiom from *Spherical* to *Saturation*, moving both
anchors that named it. Two MANIFEST rows were re-keyed to follow:

| Old anchor | New anchor | New checksum |
|---|---|---|
| `def:frame#Spherical` | `def:frame#Saturation` | `c293e9f830a2e1f0154d1ee7be2c7a121a7aa0ec4476266637e4fffaff345c60` |
| `cor:spherical-finite` | `cor:saturation-finite` | `6456eb11cb2adf8b06c929c3f6b5d19dc581f9ba7a33af8a28e61ec675567d74` |

Both checksums were resolved against the live paper via `check-paper-definitions.sh --resolve`
before the rows were written, and independently a second time during implementation; the two
derivations agree. The repository's 441 corresponding occurrences were renamed in the same wave.

**This is a rename absorption, not a drift correction, and the distinction is load-bearing here.**
The anchors did not merely change text — their *keys* moved, which is why they showed up as
`could not be resolved` rather than as drift. Re-keying the rows takes
`check-paper-definitions.sh` from **2 unresolvable to 0**. It does *not* touch the 10 drifted
anchors (`def:task-relation`, `def:directed`, `def:frame`, `def:frame#Compositionality`,
`def:frame#Seriality`, `def:frame#Limit`, `def:world-history`, `thm:extension`,
`def:BLplus-defined`, `def:time-shift-histories`), whose drifted set is byte-identical before and
after this absorption. At least two of those are substantive rather than cosmetic
(`def:time-shift-histories` dropped its explicit translation function; `def:BLplus-defined`
changed item emphasis) and warrant a paper-reconciliation pass of their own.

Per the dirty-pin convention above, the whole-file checksum sentinels are **not** re-pinned: no
drift correction was absorbed here, only a key migration.

**Deliberately left alone.** The prose of this file is a historical record of what the paper said
at the time, so rewriting it would falsify the record. The drift table at
`def:frame#Spherical`, the footnote quoted under `thm:extension`, the resolved-text block under
`cor:spherical-finite`, and the earlier coverage-extension narratives all keep the old name and
should. One item is a judgment call rather than quoted text: the entry heading ``def:directed``
— directed family (used by Spherical)`` is this record's own navigation, not paper text, and
still says *Spherical*. It was left unchanged because it falls outside this absorption's declared
scope, and is flagged here so a later pass can decide it deliberately.

### Drift correction (2026-09-02): ten-anchor re-pin

The ten anchors the rename absorption above left drifted are re-quoted and re-hashed here, and the
sentinels are re-pinned, because a drift *correction* is now being absorbed (the dirty-pin
convention). Before this correction `check-paper-definitions.sh` reported **10 drifted, 0
unresolvable**; after it, the quiet case-(a) pass. Paper file sha256 `7303bc9e…`, 4867 lines,
paper repo `git HEAD` `fa0dbf7c053e6ecd22e9815180dd91beb2604e61` with the file dirty against it
(`M JPL/possible_worlds.tex`) — the dirty-pin caveat below applies unchanged, so the checksum is
the authoritative pin and the SHA is provenance only.

Classification, anchor by anchor:

| Anchor | Change | Class |
|---|---|---|
| `def:time-shift-histories` | The explicit translation function `\bar{a}(z) = z + d` with `y = \bar{a}(x)` is gone; the relation is now stated pointwise as `\tau(z) = \sigma(z + y - x)` for all `z \in D`. | **Substantive** (same relation, since `d = y - x` is forced; but the definiens changed shape) |
| `def:world-history` | Last sentence: "The set of all total world histories over $\F$ is denoted $H_{\F}$" → "The set of all possible worlds over $\F$ is denoted $H_{\F}$". | Terminological — equivalent by the definition's own "total--- equivalently, a possible world" |
| `def:frame` | `\item[\bf …]` → `\item[\it …]` on all four axioms; the fourth axiom's name *Spherical* → *Saturation* (the rename already absorbed at the key level above); the footnote moved `~\cite{Cmiel2021}` from the second sentence to the first and renamed *Spherical* → *Saturation* in its text. | Cosmetic + rename; no mathematical change |
| `def:frame#Compositionality`, `def:frame#Seriality`, `def:frame#Limit` | `\bf` → `\it` item emphasis only. | Cosmetic |
| `thm:extension` | Footnote wording only: *Spherical* → *Saturation* twice, and the cross-reference `cor:spherical-finite` → `cor:saturation-finite`. Statement unchanged. | Rename follow-through; cosmetic |
| `def:task-relation` | `\bf` → `\it` on the Fiber/Cone/Segment items (reversing the 2026-08-25 `\it` → `\bf` change). | Cosmetic |
| `def:directed` | `\item[\bf $\mathbf{\supseteq}$-Directed:]` → `\item[\it $\supseteq$-Directed:]` (and the `\subseteq` twin). | Cosmetic |
| `def:BLplus-defined` | `\bf` → `\it` on all eight defined-operator items. | Cosmetic |

**The repository's Lean statements are unaffected.** Every change above is equivalent to the
pinned text it replaces: `WorldHistory.timeShift` was already the pointwise `σ(z + Δ)` reading
of `def:time-shift-histories`, `H_F` (`WorldHistory F`) already denotes exactly the total
histories, and the emphasis/rename changes carry no content. The two in-tree verbatim quotations
that this correction does move — the `def:world-history` closing sentence, quoted in
the former `ConvexHistory` module (the renamed successor to the former
`WorldHistory.lean`; both since deleted and folded into `PartialHistory.lean`), `PartialHistory.lean`, and
`FormalSystem/Metalogic/Algebraic/FlowFrame.lean` — are updated to the live wording in the same
change set.

**Two navigation headings updated.** ``def:directed — directed family (used by Spherical)`` now
reads *(used by Saturation)*, resolving the judgment call the rename absorption above flagged;
and ``def:time-shift-histories — …, translation form`` now reads *…, pointwise form*, following
the substantive change. Both headings are this record's own navigation, not quoted paper text, so
updating them does not falsify the record. For the same reason the `def:frame` sub-anchor table's
fourth row is re-keyed from `def:frame#Spherical` to `def:frame#Saturation` with the live text
and hash the rename absorption already placed in the manifest — the table is the record's
per-axiom index of the *current* pins, and it now agrees with the manifest again.

**Deliberately left alone.** Every earlier narrative section keeps its historical wording
(*Spherical*, "translation form", the 2026-08-25 note that `def:task-relation`'s items went
`\it` → `\bf`) — those describe what the paper said at the time. `app:auto_existence` and
`lem:history-time-shift-preservation` remain `LIVE-UNPINNED`: the Lean docstrings that cite them
do so by name only and quote no text.

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
| `cor:tm-completeness` | restructured; now states four systems explicitly (TM$^+$ strongly complete over **all** task frames; TM$^+_\textsc{d}$ strongly complete over the dense; TM$^+_\textsc{f}$ weakly complete over $\Z$-time; TM$^+_\textsc{c}$ **weakly** complete over the dense-and-complete class), and adds a footnote attributing these results *and the corresponding soundness results* to this Lean repository | **Yes — one live item.** (i) **Live.** TM$^+_\textsc{c}$ is now weak completeness over the dense-and-complete class, which is what `FrameClass.RTime` is (`FrameClass.Dedekind` does not exist — the constructor was renamed under the Discrete/Dedekind -> ZTime/RTime convention; see `docs/development/NAMING_CONVENTION_DEVIATION.md`) — the in-tree "completeness *simpliciter*" / "no `FrameClass` member picks it out" passages are stale. (ii) **Resolved 2026-09-01.** The new footnote attributes strong completeness for TM$^+$ / TM$^+_\textsc{d}$ to this repository. That attribution was, when this row was written, conditional on the then-unproved `CompactBase` / `CompactDense`. Both are now proved — `compactBase` and `compactDense` in `FormalSystem/Metalogic/Compactness.lean`, by an ultraproduct model-existence construction — and the strong-completeness results themselves are inhabited unconditionally by `strongCompletenessBase` and `strongCompletenessDense` in that module, sorry-free at exactly `[propext, Classical.choice, Quot.sound]`. The paper's attribution is accurate as it stands; no paper-side correction is needed for (ii). |
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
(3386), `def:conduche` (3406), `cor:path-fibration` (3510). Pinning them would widen this file's
maintenance surface to a region the tree does not depend on, which is exactly what the
"Deliberately not covered" scope boundary below exists to prevent.

**Two of the twelve are no longer uncited (2026-10-02), and one more is now cited as a
pointer.** The claim this paragraph previously made — "None of them is cited anywhere in this
repository and none has a Lean counterpart" — was true when it was written and is now false for
`def:interval-site` and `def:behavior-presheaf`, which the interval site and behavior presheaf of
`FormalSystem/Semantics/Presheaf/` formalize (`Obj`/`Tr`/`Tr.comp` and the coverage trio in
`Site.lean`; `Beh`, its presheaf action and `Beh.germEquiv` in `Behavior.lean`). The dictionary theorem
`app:presheaf-dictionary` — the third of the twelve to lose its uncited status — and the
containing section label `app:Structure`, which is not itself one of the twelve, are cited by
those modules as pointers. All four now carry a **`DANGLING`** `KNOWN-ANCHORS` row, and all four
remain deliberately **unpinned** — not as a maintenance-surface judgement but because they are
*unpinnable*: `app:Structure` was cut from the paper in full under an explicit `% SECTION CUT`
record and the surviving commented block carries a bare `% CHECK`, and
`check-paper-definitions.sh --resolve` structurally cannot read text off a commented-out
`\label{}`. The remaining nine of the twelve (`def:task-topology`, `app:topology-t1`, `app:topology-r0`,
`app:gluing` — itself since restored and separately recorded — `lem:factorization-linear`,
`lem:interval-twisted-arrow`, `def:path-category`, `def:conduche`, `cor:path-fibration`) are
unaffected by this correction. If any of them becomes load-bearing, add it then, via
`check-paper-definitions.sh --resolve "ANCHOR|env|-|-"` — or, if the appendix is still cut, as a
`DANGLING` row.

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

**Still dirty at the 2026-09-07 z/d/r rename-absorption re-pin.** `git status --porcelain`
reported `M JPL/possible_worlds.tex` against `HEAD` = `f61bbd75`, and the last commit actually to
touch the file is `acfa75fd`, an ancestor of neither the pinned content nor of `HEAD`'s tree for
this path. The `PINNED_COMMIT` sentinel therefore again does **not** reproduce `FILE_CHECKSUM`,
and that is expected rather than a defect. Stronger than in the earlier waves: the file changed on
disk *during* the absorption itself (see the moving-target note in the 2026-09-07 narrative
above), so the pin is a snapshot of a file under active edit. Use `--resolve` against the live
file, never `--against <commit>`, when re-deriving anything from this wave.

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
  record escalated in `docs/architecture/untl-snce-argument-order.md`; the caveat under that entry
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
`docs/architecture/untl-snce-argument-order.md`. **Superseded 2026-08-12**: the paper has since
repaired the footnote in the direction that actually holds; see "Drift correction (2026-08-12)"
above and the rewritten caveat under the entry itself. **Superseded again 2026-08-17**: the
footnote has since been removed from the paper entirely, and the Lean tree has been migrated to
guard-first, discharging the caveat rather than restating it. The decision record is closed as
DECIDED.

### Vocabulary alignment (2026-09-07): prose only, no re-pin

The repository's own commentary around `def:world-history`, `thm:extension` and `cor:occurrence`
still described the paper's middle tier as a *world history* and its top tier as a *total* world
history. Those are the superseded terms: the pinned text of `def:world-history` above already
layers **partial history** -> **convex history** -> **possible world**, and reserves `H_F` for the
possible worlds. The surrounding headings and commentary have been brought onto that vocabulary.

This was a prose-only correction. Per "How to extend this record", no anchor was added and no
anchor drifted, so **no `verbatim:` block, no `sha256:` line, no manifest row, and neither the
`PINNED_COMMIT` nor the `FILE_CHECKSUM` sentinel was touched**. `scripts/check-paper-definitions.sh`
was re-run after the edit and its drifted-anchor set was unchanged (the six `def:S5`, `def:BX`,
`def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus` anchors owned by the separate re-pin work);
`def:world-history`, `thm:extension` and `cor:occurrence` do not appear in it.

One occurrence of the superseded wording survives below and is deliberate: the drift-log row
under "Drift correction and rename absorption (2026-09-07)" quotes it as archival evidence of what
the paper used to say. The `>`-quoted footnote under "Untracked sources" was found to be quoting
the *superseded* text of a footnote the paper has since revised, and was re-quoted from the live
paper in the same change; see the note recorded there.

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
	A \textit{temporal order} is a nontrivial totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$ with \textit{positive cone} $D^+ \coloneq \set{x \in D \mid x \geq 0}$.
\end{Ddef}
```
sha256: `1fa55867b57322f0dd7d6cc346e3ebe09809a5990832b34de58b1805acd14894`

### `def:task-relation` — task relation, nonempty `W`, reflection convention, fiber, cone, segment

Re-pinned when the paper renamed the *converse convention* to the *reflection convention*
(wording only; the stipulation `w ⇒_{-x} u ≔ u ⇒_x w` is unchanged). The Lean encoding follows the
paragraph's shape: the primitive relation `FrameOver.PosRel` lives on `D⁺`, the extended relation
is the definition `FrameOver.TaskRel := TaskFrame.reflect PosRel`, and the reflection law is the
theorem `FrameOver.reflection`, not a structure field. `PosRel` and the state type are, together
with the carrier's nonemptiness, the *whole* of a frame's data: `def:frame`'s four axioms are
constraints on that data, not part of it — see `def:frame` below.

```latex
\begin{Ddef} \label{def:task-relation}
	A \textit{task relation} on a nonempty set of \textit{world states} $W$ over a temporal order $\D$ is any parameterized relation $w \Rightarrow_x u$ for $w,u \in W$ and $x \in D^+$, extended to negative durations by the \textit{reflection convention} $w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$ for $x > 0$, determining the following for any world states $w, v \in W$ and durations $x, y \in D$:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\it Fiber:] $\fib{w, x} \coloneq \set{u \in W \mid w \Rightarrow_x u}$.
		\item[\it Cone:] $(w)_x \coloneq \bigcup\limits_{\vert{y} < x} \fib{w, y}$ where $x > 0$.
		\item[\it Segment:] $[w, v]_x^y \coloneq \fib{w, x} \cap \fib{v, -y}$ where $x, y \geq 0$.
	\end{enumerate}
  \vspace{-.1in}
\end{Ddef}
```
sha256: `f35b1c7412b592c99a7a4bdc2889a5d19cf23712e4c9c08cd51cda917e3b60c5`

### `def:directed` — directed family (used by Saturation) — **DANGLING as of the 2026-09-07 rename-absorption re-pin (removed from manifest)**

The live paper no longer carries a `\label{def:directed}`. The `⊇`-directed condition was
folded inline into `def:frame`'s opening clause ("Letting a nonempty family of sets
$\mathcal{S}$ be *$\supseteq$-directed* just in case …"), and the `⊆`-directed half was
dropped. The quoted text below is retained as the last-resolved historical record. If the paper
restores the anchor, re-add a manifest row via
`check-paper-definitions.sh --resolve "def:directed|env|-|-"`.

```latex
\begin{Ddef} \label{def:directed}
	A nonempty family of sets $\mathcal{S}$ is:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\it $\supseteq$-Directed:] just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.
		\item[\it $\subseteq$-Directed:] just in case $S_1, S_2 \subseteq S$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.
	\end{enumerate}
\end{Ddef}
```
sha256: `5164210f644bb467aadc3bd279a5774cc14b67e88bdee6b8373a2025a22031f1`

### `def:frame` — the frame definition (whole block, all four axioms)

```latex
\begin{Ddef} \label{def:frame}
	Letting a nonempty family of sets $\mathcal{S}$ be \textit{$\supseteq$-directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$, a \textit{task frame} is any $\F = \tuple{W, \D, \Rightarrow}$ where $W$ is a nonempty set of world states, $\D$ is a temporal order, and $\Rightarrow$ is a task relation satisfying the following for all durations $x, y \geq 0$:
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.
		\item[\it Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.
		\item[\it Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.
		\item[\it Saturation:] $\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments.%
    \footnote{
      The nonempty fibers and segments form a \textit{ball space} on $W$ in the sense of \'{C}miel, Kuhlmann, and Kuhlmann~\cite{Cmiel2021}.
      \textit{Saturation} is the downward-directed-intersection condition $\mathbf{S}_1^d$ of the ball-space hierarchy--- the nest condition $\mathbf{S}_1$ with a $\supseteq$-directed system of balls in place of a nest--- and so is at least as strong as the standard \textit{spherically complete} condition, which is $\mathbf{S}_1$ itself.
    }
	\end{enumerate}
  \vspace{-.1in}
\end{Ddef}
```
sha256: `1150ed22cb6a9e8e0f84a57e3b342fafb143930370814ff4f4fdf9790be5604d`

Four axioms, not more, not fewer — **Nullity is NOT an axiom**, it is `lem:nullity` below, DERIVED
from Seriality and Limit. Each axiom is also tracked individually (sub-anchors of `def:frame`, no
`\label` of their own — resolved as the enclosing block's `\item[MARKUP NAME:]` line, markup-agnostically), so that a
future paper edit which reorders or drops exactly one axiom is named precisely rather than only
flagging "`def:frame` changed":

| Sub-anchor | Verbatim text | sha256 |
|---|---|---|
| `def:frame#Compositionality` | `\item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$.` | `4b9248498399338eeaccb63c5e8952ca0928b87bb85bcd94f596d9c263bb64fa` |
| `def:frame#Seriality` | `\item[\it Seriality:] $w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$.` | `ad1863bf950f17906a79b469b40fddb102e4abf5bd1bfd828a2f4b4900c7dbad` |
| `def:frame#Limit` | `\item[\it Limit:] $\bigcap\limits_{x > 0} (w)_x = \set{w}$.` | `3eedd389d6cbdf5dff50f82ad9bafed30fe5eff5ec923cfdc165ca75dbe60a5f` |
| `def:frame#Saturation` | `\item[\it Saturation:] $\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments.%` | `c293e9f830a2e1f0154d1ee7be2c7a121a7aa0ec4476266637e4fffaff345c60` |

Note: **Compositionality is a biconditional**, not a one-directional implication — this is load
bearing (the right-to-left direction is used directly in, e.g., the constraint-family proofs).

**How the four axioms are encoded.** They are **not** fields of `FrameOver`. `FrameOver` is the
*general* frame structure — a nonempty state type and the primitive relation on `D⁺`, and nothing
more — and the four are frame **constraints** on it, carried by the `Prop`-valued class
`FrameOver.IsRegular` (`Semantics/TaskFrame.lean`); the class satisfying all four is the class of
*regular* frames, and the qualifier is dropped thereafter exactly as the paper drops it. Each is
also a standalone predicate over a bare relation — `TaskFrame.Compositional`, `TaskFrame.Serial`,
`TaskFrame.Limit`, `TaskFrame.Saturation` — so any subset can be assumed and a result can be
stated at the constraint it uses. `F.comp`, `F.serial`, `F.limit` and `F.saturation` remain the
names, now as theorems taking `[F.IsRegular]`, with the types the fields had. Witnesses that
satisfy some constraints and not others live in `Semantics/StateTopology/Counterexamples.lean`;
they are not expressible while the constraints are fields, which is why the encoding changed.

**2026-09-07 wave — two changes inside this block, both load bearing:**

1. **`def:directed` was folded in.** The opening clause now defines `$\supseteq$-directed`
   inline ("Letting a nonempty family of sets $\mathcal{S}$ be *$\supseteq$-directed* just in
   case …"), and the standalone `def:directed` label is gone (recorded `DANGLING` above). The
   `$\subseteq$-directed` half was dropped entirely — the paper no longer defines it anywhere, so
   any in-tree prose describing `def:directed` as "split into a `⊇` and a `⊆` clause" is
   describing a definition that no longer exists.
2. **The ball-space footnote was softened from "strictly stronger" to "at least as strong as".**
   The paper now says *Saturation* ($\mathbf{S}_1^d$) "is at least as strong as the standard
   *spherically complete* condition, which is $\mathbf{S}_1$ itself". The strictness claim was
   withdrawn, not merely reworded: `\mathbf{S}_1^d \Rightarrow \mathbf{S}_1` is asserted, and
   the converse is no longer denied. In-tree prose asserting **strict** strengthening now overstates
   the paper. (The 2026-08-25 narrative table below records the *old*, strict wording; it is
   historical and is deliberately left as written.)
   Also in this block: "for $x, y \geq 0$" became "for all positive durations $x, y \geq 0$" —
   wording only, no change to the quantifier's range.

### `lem:nullity` — DERIVED: `w ⇒₀ u ↔ w = u` (Nullity is not an axiom)

```latex
\begin{Lthm} \label{lem:nullity}
	$w \Rightarrow_0 u$ if and only if $w = u$, for all world states $w, u \in W$ in any task frame $\F$.
\end{Lthm}
```
sha256: `8442e2bf6b5f6515f2f906132bbe15fe919973d82ae573dba29a919ad14636f5`

Proved (per the paper) from Seriality at `x = 0` plus Limit. The lemma is a **biconditional**
characterising `⇒₀` as the identity relation on `W`; the reflexivity half (`w ⇒₀ w`) is the weaker
statement the tree's `FrameOver.nullity` carries, and the biconditional is
`FrameOver.nullity_identity` (`Semantics/TaskFrame.lean`), with
`nullity_identity_of_serial_limit` deriving it choice-free from *Seriality* and *Limit* over a bare
task relation. The choice-freeness contrast with `thm:extension` (which needs Zorn's lemma) is a
true property of the Lean proofs, but the paper footnote that asserted it was removed from
`thm:extension` — see "Drift correction (2026-10-14)" above.

### `def:world-history` — partial history, convex history, possible world, the extension order, `H_F`

```latex
\begin{Ddef} \label{def:world-history}
	A \textit{partial history} over a task frame $\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$.
	A \textit{convex history} is any partial history whose domain $X$ is \textit{convex}, so that $y \in X$ whenever $x, z \in X$ and $x < y < z$.
	A \textit{world history}, or \textit{possible world}, is any partial history whose domain is \textit{total}, so that $X = D$.
	A partial history $\sigma$ \textit{extends} $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$.
	The set of all possible worlds over $\F$ is denoted $H_{\F}$.
\end{Ddef}
```
sha256: `e94a15db019603c0c924690c29b84b6b82d2b9443e87e0050e3ffa184533c889`

Layering, as the paper states it: **partial history** (nonempty domain, no convexity
requirement), **convex history** (convex domain), and **world history**/**possible world**
(`X = D`), the last defined off *partial* history rather than off convex history. The
vocabulary "task-constrained function" is retired paper-wide and must not be reintroduced as
current terminology (see the paper-refactor cluster's task descriptions, which record the same
point). `H_F` denotes the *possible worlds*, not the convex histories.

**Body/appendix wording note (prose only, no re-pin).** The body of the paper's
sec:Construction states the top tier without the middle one: "A \textit{world history} is any
partial history $\tau : X \to W$ whose domain is \textit{total}, so that $X = D$", writing $H_{\F}$
for the set of all world histories and then calling them the possible worlds. The appendix
`def:world-history` pinned above now states the tier the same way, off partial history and under
both names ("A \textit{world history}, or \textit{possible world}, is any partial history whose
domain is \textit{total}"); it previously routed the tier through convex histories. Either
phrasing denotes the **same set**, because a total domain is trivially convex. The Lean
definition follows the body: `WorldHistory F` is
`{τ : PartialHistory F // τ.IsTotal}`, convexity is the predicate `PartialHistory.IsConvex`, and
`PartialHistory.IsTotal.isConvex` records the inclusion. The paper text is not edited, and this
note adds no anchor, `verbatim:` block, `sha256:` line or manifest row.

### `thm:extension` — every partial history extends to a possible world

```latex
\begin{Tthm}[Extension] \label{thm:extension}
	Every partial history $\tau : X \to W$ over a task frame $\F = \tuple{W, \D, \Rightarrow}$ is extended by some possible world $\sigma \in H_{\F}$.
\end{Tthm}
```
sha256: `0677bc175c0717349e5e69f257f43bd06976bffd89c3877a9f020496416822d7`

### `cor:occurrence` — DERIVED: every world state occurs at any prescribed time in some possible world (renamed from `thm:occurrence`; see "Drift correction" below)

```latex
\begin{Cthm}[Occurrence] \label{cor:occurrence}
	For any task frame $\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$, and time $x \in D$, there is a possible world $\tau \in H_{\F}$ where $\tau(x) = w$, and so $H_{\F} \neq \emptyset$.
\end{Cthm}
```
sha256: `e4be0b08ecd39e559fff831361440f1af2c51760a9c053e1f2dba4a65b025af4`

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
	For a partial history $\tau : X \to W$ over a task frame $\F$ and duration $z \in D \setminus X$, split $X$ into $A \coloneq \set{t \in X \mid t < z}$ and $C \coloneq \set{s \in X \mid s > z}$, which exhaust $X$ since $z \notin X$, and write $F_t \coloneq \fib{\tau(t), z - t}$ for $t \in X$ and $S_{t,s} \coloneq [\tau(t), \tau(s)]_{z-t}^{s-z}$ for $\tuple{t,s} \in A \times C$.
	The \textit{constraints on $z$} are the segments $S_{t,s}$ for $\tuple{t,s} \in A \times C$ when $A$ and $C$ are both nonempty, and the fibers $F_t$ for $t \in X$ otherwise.
\end{Ddef}
```
sha256: `f39ba974df411b9f436932fd4414146e66b333219de896758028974fc4297a21`

Promoted from lead-in prose to a numbered definition so the lemmas below can cite it by name.
The 2026-08-12 wave shortened the defined term to "the *constraints on `z`*" and added an explicit
"when both `t,s ∈ X`" guard to the segment case; the family being defined is unchanged. Note that
surrounding paper text (and `lem:nonempty`, untracked) still says "imposed on", so both phrasings
appear in the live paper — this record quotes whichever one appears inside the tracked block.

### `lem:nesting` — DERIVED: imposed fibers and segments nest along the time order

```latex
\begin{Lthm} \label{lem:nesting}
	For a partial history $\tau : X \to W$ over a task frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the fibers and segments of \textbf{\ref{def:constraints}} nest: $F_{t'} \subseteq F_t$ for all times $t \leq t' < z$ in $X$ and symmetrically for all times $z < t' \leq t$ in $X$, while $S_{t',s'} \subseteq S_{t,s}$ for all times $t \leq t' < z < s' \leq s$ in $X$.
\end{Lthm}
```
sha256: `6ad1e33d546003cc35a454687dfdd2dca32e99668f1f5d92ad9f0616a2f3a61d`

The lemma is now stated in terms of `def:constraints`'s own named families `F_t` and `S_{t,s}`
rather than spelling the fibers and segments out again; the in-source `% FIX:` authorial note about
the `\Fib` macro's italics that the block used to carry is gone from the hashed region. Paper order
places this lemma immediately after `def:constraints` and before `lem:nonempty`, which is why both
sit here rather than beside `lem:constraint`.

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
		\item[($\since$)] $\M,\tau,x \vDash \varphi\since\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z < x$ where $\M,\tau,y \vDash \varphi$\\
      \strut\hspace{1.55in}for all $y \in D$ with $z < y < x$.
		\item[($\until$)] $\M,\tau,x \vDash \varphi\until\psi$ \textit{iff} $\M,\tau,z \vDash \psi$ for some time $z > x$ where $\M,\tau,y \vDash \varphi$\\ 
      \strut\hspace{1.55in}for all $y \in D$ with $x < y < z$.
	\end{enumerate}
  \vspace{-.1in}
Since the defined operators $\Past$ and $\Future$ satisfy the natural truth clauses, proofs will appeal to them freely without derivation.
\end{Ddef}
```
sha256: `aad8ee543a63a394983e02c2c7ec81e02aaf7737768bcb0d492c668c38de3eb2`

**The box clause's quantifier domain is `H_F`** — the set of *possible worlds*, not a
maximal-history set `H^max_F` (that vocabulary is retired; the block's own `%%` comment history
above shows it was explicitly eliminated) and not an externally-supplied `Omega` subset. This is
the single most consequential clause for the current `paper-refactor` cluster: the Lean tree's
`TruthAt` (`Semantics/Truth.lean`) still takes an explicit
`Omega : Set (WorldHistory F)` parameter and quantifies `Box` over `Omega`, not over the full
total-history set directly — that is precisely the gap the cluster's total-history refactor
closes. See "Downstream consumers" below.

### `def:BLplus-language` — the language of `BL^+` (since/until constructors)

```latex
\begin{Ddef} \label{def:BLplus-language}
	The language $\BL \coloneq \tuple{\SL,\bot,\rightarrow,\Box,\since,\until}$ where $\SL \coloneq \set{p_i \mid i\in \N}$ is a countable set of \textit{sentence letters} with operators for \textit{falsity}, \textit{material implication}, \textit{metaphysical necessity}, \textit{since}, and \textit{until}, respectively.
	Well-formed sentences of $\BL$ are defined by:
	\[
		\varphi, \psi \Coloneq p_i \mid \bot \mid \varphi \rightarrow \psi \mid \Box\varphi \mid \varphi\since\psi \mid \varphi\until\psi.
	\]
	The following operators are defined in $\BL$:
  \vspace{-.125in}
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\begin{multicols}{2}
			\item[\it Some Past:] $\past\varphi \coloneq \top\since\varphi$.
			\item[\it Some Future:] $\future\varphi \coloneq \top\until\varphi$.
			\item[\it All Past:] $\Past\varphi \coloneq \neg\past\neg\varphi$.
			\item[\it All Future:] $\Future\varphi \coloneq \neg\future\neg\varphi$.
			\item[\it Always:] $\always\varphi \coloneq \Past\varphi \wedge \varphi \wedge \Future\varphi$.
			\item[\it Sometimes:] $\sometimes\varphi \coloneq \past\varphi \vee \varphi \vee \future\varphi$.
			\item[\it Next:] $\Next\varphi \coloneq \bot\until\varphi$.
			\item[\it Previous:] $\Previous\varphi \coloneq \bot\since\varphi$.
		\end{multicols}
	\end{enumerate}
  \vspace{-.25in}
\end{Ddef}
```
sha256: `b7027d468a844f09068c7dc765498e4668708ac09b175cfc20594bcaba5d3c95`

### `def:BLplus-semantics` — the `\since` / `\until` truth clauses (and the argument-order footnote) — **DANGLING as of the 2026-09-07 rename-absorption re-pin (removed from manifest)**

The live paper no longer carries a `\label{def:BLplus-semantics}`. When the paper collapsed
`BL^+` into `BL`, the `\since` / `\until` clauses became clauses of `def:BL-semantics` itself
(which is pinned, and whose 2026-09-07 re-hash records exactly this change). The quoted text
below is retained as the last-resolved historical record.

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
   `docs/architecture/untl-snce-argument-order.md`.

2. **The Lean tree was aligned to the paper.** `Formula.untl` and `Formula.snce`
   (`Syntax/Formula.lean`) now take the **guard first and the event second**,
   and `TruthAt`'s clauses (`Semantics/Truth.lean`) read
   `| Formula.untl ψ φ => ∃ s, t < s ∧ TruthAt … s φ ∧ ∀ r, t < r → r < s → TruthAt … r ψ` — the
   existential witness second, the open-interval condition first, exactly as the `(until)` clause
   above states it. The migration was a uniform argument swap of the two constructors and every
   call site, carried out under the guard-first migration recorded in
   `docs/architecture/untl-snce-argument-order.md`. It is
   meaning-preserving by construction: `lake build` green at the same job count, per-file `sorry`
   census byte-identical to baseline, axiom count unchanged, and the role-keyed `toJson` oracle
   regenerating byte-identically.

Corroborated independently by `def:BLplus-defined` below, which the Lean derived operators now
match character for character: `$\past\varphi \coloneq \top\since\varphi$` →
`somePast φ = Formula.snce Formula.top φ` (`Syntax/Formula.lean`);
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

### `def:BLplus-defined` — the defined temporal operators of `BL^+` — **DANGLING as of the 2026-09-07 rename-absorption re-pin (removed from manifest)**

The live paper no longer carries a `\label{def:BLplus-defined}`. The eight defined operators
(Past/Future/Historical/Henceforth/Always/Sometimes/Next/Previous) now sit inside
`def:BLplus-language`'s own block, which is pinned. The quoted text below is retained as the
last-resolved historical record.

```latex
\begin{Ddef} \label{def:BLplus-defined}
	The following operators are defined in $\BL^+$:
  \vspace{-.125in}
	\begin{enumerate}[wide=0pt, labelsep=.1in, itemsep=.075in]
		\begin{multicols}{2}
			\item[\it Past:] $\past\varphi \coloneq \top\since\varphi$.
			\item[\it Future:] $\future\varphi \coloneq \top\until\varphi$.
			\item[\it Historical:] $\Past\varphi \coloneq \neg\past\neg\varphi$.
			\item[\it Henceforth:] $\Future\varphi \coloneq \neg\future\neg\varphi$.
			\item[\it Always:] $\always\varphi \coloneq \Past\varphi \wedge \varphi \wedge \Future\varphi$.
			\item[\it Sometimes:] $\sometimes\varphi \coloneq \past\varphi \vee \varphi \vee \future\varphi$.
			\item[\it Next:] $\Next\varphi \coloneq \bot\until\varphi$.
			\item[\it Previous:] $\Previous\varphi \coloneq \bot\since\varphi$.
		\end{multicols}
	\end{enumerate}
  \vspace{-.25in}
\end{Ddef}    
```
sha256: `fcad976996f1346178180d69dd93196df651818705c00fe546db8bea56f3c8f5`

### `thm:BLplus-PastFuture` — DERIVED: the H/G truth conditions of the defined tense operators (the unconditional language embedding) — **DANGLING as of the 2026-09-07 rename-absorption re-pin (removed from manifest)**

The live paper no longer carries a `\label{thm:BLplus-PastFuture}`; it went away with the
`BL^+` fragment cluster. The quoted text below is retained as the last-resolved historical
record. The repository's own `TruthAt` H/G characterizations are unaffected — they are proved
in-tree, not imported from this anchor.

```latex
\begin{Tthm} \label{thm:BLplus-PastFuture}
	$\M,\tau,x \vDash \Past\varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $y < x$; and $\M,\tau,x \vDash \Future\varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for all $y \in D$ with $x < y$.
\end{Tthm}
```
sha256: `cf9d2e2bb1bcb17e3f27d9ac76f89c340f2cce5992586c617f4202051ac8256d`

### `thm:BLplus-NextPrevious` — DERIVED: Next/Previous truth conditions over Discrete frames — **DANGLING as of the 2026-09-07 rename-absorption re-pin (removed from manifest)**

The live paper no longer carries a `\label{thm:BLplus-NextPrevious}`; it went away with the
`BL^+` fragment cluster. The quoted text below is retained as the last-resolved historical
record.

```latex
\begin{Tthm} \label{thm:BLplus-NextPrevious}
	Over \textsc{Discrete} task frames, $\M,\tau,x \vDash \Next\varphi$ \textit{iff} $\M,\tau,y \vDash \varphi$ for the immediate successor $y$ of $x$.
  Additionally, $\M,\tau,x \vDash \Next\varphi \leftrightarrow \bot$ when $x$ has no immediate successor.
	The past dual holds for $\Previous\varphi$ in an analogous manner.
\end{Tthm}
```
sha256: `5d9a6febeae6e2dd4c78e1912616e75e6ae7896c929e75345b2ba6403c0693c9`

### `def:time-shift-histories` — time-shift between possible worlds, pointwise form

```latex
\begin{Ddef} \label{def:time-shift-histories}
	For a task frame $\F = \tuple{W, \D, \Rightarrow}$, the possible worlds $\tau, \sigma \in H_{\F}$ are \emph{time-shifted from $x$ to $y$}--- written $\tau \approx_x^y \sigma$--- if and only if $\tau(z) = \sigma(z + y - x)$ for all $z \in D$.
\end{Ddef}
```
sha256: `99588bf0dec609563ce3fe129bee59b3ca36826726349b3e0f7fc403efdbedbc`

### `def:frame-validity` — validity over a frame

```latex
\begin{Ddef} \label{def:frame-validity}
	A well-formed sentence $\varphi$ of $\BL$ is \emph{valid over a task frame} $\F = \tuple{W, \D, \Rightarrow}$--- written $\vDash_{\F} \varphi$--- just in case $\M,\tau,x \vDash \varphi$ for every model $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ over $\F$, possible world $\tau \in H_{\F}$, and time $x \in D$.%
    % \footnote{
    %   Since $H_{\F} \neq \emptyset$ for every task frame by \textbf{\ref{cor:occurrence}}, frame validity is never vacuous: every task frame contributes evaluation points, and so $\nvDash_{\F} \bot$ for every task frame $\F$.
    % }
\end{Ddef}
```
sha256: `4fdc41ce401c80032aef112060e0b9ce932b82c777759272bba7998dc113ad61`

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

### `CO` / `TMP-CO` — worked example of the `\aitem`-key anchor kind — **`TMP-CO` DANGLING as of the 2026-09-07 rename-absorption re-pin (removed from manifest; `CO` remains pinned)**

The paper introduces some axioms via a custom `\aitem[KEY]{LABEL}` macro
(`\newcommand{\aitem}[2][]{\item[{\bf ...}] \refstepcounter{acount}\label{#2}%`), which sets the
**bold displayed key** to its optional first argument (or, if omitted, to the second argument) and
sets the **`\label`** (hence the `\aref`-resolvable anchor) to the second argument. This means a
single displayed key like "CO" can correspond to *two different* `\label` anchors in different
parts of the paper — exactly the case recorded here, per this task's explicit instruction to
demonstrate the mechanism handles both anchor kinds:

| Anchor (`\label`) | Displayed key | Verbatim text | sha256 |
|---|---|---|---|
| `CO` | CO | `\aitem{CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.\leanfoot{DedekindDerived.coDerived}` | `707368059ff1f7cc53c8b4ca9c591781ee427263797c8d36d3fb85e8abe8e955` |
| `TMP-CO` | CO (same displayed key, `BL^+` restatement) | `\aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.` | `2205e7115342b037faeb67a24cb7679e393af582cedf6752c0c07d9a28b8f1be` |

**2026-09-07 update.** The live paper no longer carries an `\aitem{...}{TMP-CO}`: the `BL^+`
restatement of the completeness axiom disappeared with `def:TMplus-c` (now `def:BX-r`), which
*derives* `CO` from `PU` rather than restating it under a second label. `TMP-CO` is therefore
removed from the machine manifest and recorded `DANGLING`; the table row above is retained as the
last-resolved historical record. `CO` itself still resolves and stays pinned, so the worked
example of the two-anchor `\aitem` mechanism survives in half-form — a second live example is
`def:S5`'s `TMP-MK`/`MK` family should one ever be needed.

`CO` and `TMP-CO` are **not** part of `def:frame`'s four axioms (an unrelated coincidence of
abbreviation — `CO` here names a temporal continuity/completeness axiom, unrelated to `def:frame`'s
"Compositionality"). They are included to keep the extraction mechanism exercised against both
anchor kinds the paper actually uses, per this task's instruction; they are not otherwise consumed
by a live task at recording time.

### `def:S5` — the S5 modal logic (rule/axiom schemata)

```latex
\begin{Ddef} \label{def:S5}
  The \textbf{S5} \textit{Modal Logic} extends \textit{Classical Propositional Logic} \textbf{CPL} to include all instances of the axiom schemata \textbf{\aref{MK}}, \textbf{\aref{MT}}, and \textbf{\aref{M5}}, the rule \textbf{\aref{MP}}, and the metarule \textbf{\aref{MN}} presented in \textbf{\S\ref{sub:Logic}}.
\end{Ddef}
```
sha256: `dc940901838a1228ffa3b3170466bbc3d8046f4596db23184afb55fb32896257`

### `def:BX` — the Base Burgess–Xu tense logic, and the two schemata (TC, TL) it marks derived

```latex
\begin{Ddef} \label{def:BX}
  The \textit{Base Burgess--Xu Tense Logic} \textbf{BX} extends \textbf{CPL} to include the metarules \textbf{\aref{TN}} and \textbf{\aref{TR}} together with all instances of the axiom schemata \textbf{\aref{TS}}, \textbf{\aref{UI}}, \textbf{\aref{UC}}, \textbf{\aref{UF}}, \textbf{\aref{UG}}, \textbf{\aref{US}}, and \textbf{\aref{CN}} presented in \textbf{\S\ref{sub:Logic}}.
  The schemata \textbf{\aref{TC}} and \textbf{\aref{TL}} of \textbf{\S\ref{sub:Logic}} are \textit{derived theorems} of \textbf{BX} rather than further axioms, machine-checked in the Lean 4 \leanrepo{}, and so are not included among its axioms.
\end{Ddef}
```
sha256: `64cc5cc90860bd5c3855701a4de57c38a10ffb6d0c59025224c82869f8454ec2`

### `def:TMplus-f` — the discrete Burgess–Xu tense logic BX_f, and its Z-time footnote — **DANGLING as of the 2026-09-07 rename-absorption re-pin: RENAMED to `def:BX-z` (removed from manifest)**

The paper renamed this anchor to `def:BX-z`, which is pinned below. The quoted text is retained
as the last-resolved historical record, and it is the *old* text that in-tree docstrings used to
quote: the closing sentence now attributes the ℤ-time narrowing to `prop:archimedean` plus the
§Extensions Hölder footnote rather than deriving it inline, and the systems are named
**BX**$_z$ / **TM**$_z$ rather than **BX**$_f$ / **TM**$^+_f$. Any docstring still quoting the
text below is quoting a version of the paper that no longer exists.

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

### `def:TMplus-d` — the dense Burgess–Xu tense logic BX_d — **DANGLING as of the 2026-09-07 rename-absorption re-pin: RENAMED to `def:BX-d` (removed from manifest)**

The paper renamed this anchor to `def:BX-d`, which is pinned below. The quoted text is retained
as the last-resolved historical record; the live definition no longer inlines the `DN`/`NN`
axiom statements, citing `\S`Extensions for them instead.

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

### `def:TMplus-c` — the complete Burgess–Xu tense logic BX_c, Reynolds-triple basis, CO derived — **DANGLING as of the 2026-09-07 rename-absorption re-pin: RENAMED to `def:BX-r` (removed from manifest)**

The paper renamed this anchor to `def:BX-r`, which is pinned below, and re-titled the system
*Dense and Complete* rather than *Complete*. The quoted text is retained as the last-resolved
historical record. Note that the live definition's second Reynolds axiom is displayed and
labelled `SEP`, not `SP`; and the `TMP-CO` restatement quoted below no longer exists.

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

### `def:BX-z` — the discrete Burgess–Xu tense logic BX_z (RENAMED from `def:TMplus-f`), its ℤ-time narrowing, and Z1 marked derived

**Re-hashed twice on 2026-09-07**: the second time for a comment-only deletion inside the
environment (the `%% NEW CHANGE` editorial lines and three commented-out sentences), which changes
the hash without changing a word of the live prose. The text below is the post-deletion state.

**Renamed** from `def:TMplus-f` by the paper's 2026-09 z/d/r wave. Two substantive changes came
with the rename, and in-tree prose that predates them is stale rather than merely mis-labelled:
the axiom statements are no longer inlined (the definition cites `\S`Extensions for `UZ` and
`Z1`), and the ℤ-time narrowing is no longer derived here from Hölder's theorem — the definition
now cites `prop:archimedean` for the failure of `UZ`/`Z1` over non-Archimedean discrete orders and
`\S`Extensions for the Hölder step, concluding that the discrete task frames over which
**BX**$_z$ and **TM**$_z$ are sound and complete are exactly those over ℤ-time.

```latex
\begin{Ddef} \label{def:BX-z}
  The \textit{Discrete Burgess--Xu Tense Logic} \textbf{BX}$_\textsc{z}$ extends the base logic \textbf{BX} to include all instances of \textbf{\aref{UZ}} presented in \textbf{\S\ref{sub:Extension}}.
  The backward induction principle \textbf{\aref{Z1}} of \textbf{\S\ref{sub:Extension}} is a \textit{derived theorem} of the discrete extension \textbf{TM}$_\textsc{z}$ of \textbf{\ref{def:TMplus}} rather than a further axiom, machine-checked in the Lean 4 \leanrepo{} for the full bimodal system rather than for \textbf{BX}$_\textsc{z}$ alone, and so is not included among the axioms of \textbf{BX}$_\textsc{z}$.
  Since \textbf{\aref{UZ}} fails over every \textsc{Discrete} temporal order that is not Archimedean by \textbf{\ref{prop:archimedean}}, and a \textsc{Discrete} temporal order is Archimedean just in case it is isomorphic to $\Z$, the \textsc{Discrete} temporal orders over whose task frames \textbf{TM}$_\textsc{z}$ is sound are exactly those of $\Z$-time.
\end{Ddef}
```
sha256: `c38466b21121724f71d039014c525e5e4f8c397025f37746fcfb7587c85a5581`

### `def:BX-d` — the dense Burgess–Xu tense logic BX_d (RENAMED from `def:TMplus-d`), and DN marked derived

**Renamed** from `def:TMplus-d`. The axioms `DN` and `NN` are no longer displayed here; the
definition cites `\S`Extensions for them.

```latex
\begin{Ddef} \label{def:BX-d}
  The \textit{Dense Burgess--Xu Tense Logic} \textbf{BX}$_\textsc{d}$ extends the base logic \textbf{BX} to include all instances of \textbf{\aref{NN}} presented in \textbf{\S\ref{sub:Extension}}.
  The density schema \textbf{\aref{DN}} of \textbf{\S\ref{sub:Extension}} is a \textit{derived theorem} of \textbf{BX}$_\textsc{d}$ rather than a further axiom, using only \textbf{\aref{NN}} and the axioms of \textbf{BX} as machine-checked in the Lean 4 \leanrepo{}, and so is not included among the axioms of \textbf{BX}$_\textsc{d}$.
\end{Ddef}
```
sha256: `44a74c839c0c74141fb1565120cb91193973fc33a69c35d5070bcbc67379e40c`

### `def:BX-r` — the dense-and-complete Burgess–Xu tense logic BX_r (RENAMED from `def:TMplus-c`), CO derived

**Renamed** from `def:TMplus-c`, and re-titled *Dense and Complete Burgess--Xu Tense Logic*: it
is now presented as the extension of **BX**$_d$ (not of **BX**) by `PU` and `SEP`. The second
Reynolds axiom is labelled **`SEP`**, not `SP`. `CO` remains a *derived theorem* rather than an
axiom, now derived from `PU` together with the axioms of **BX**; the `TMP-CO` restatement that the
old definition carried no longer exists (see the `CO` / `TMP-CO` entry above).

```latex
\begin{Ddef} \label{def:BX-r}
  The \textit{Dense and Complete Burgess--Xu Tense Logic} \textbf{BX}$_\textsc{r}$ extends the dense logic \textbf{BX}$_\textsc{d}$ to include \textbf{\aref{PU}} and \textbf{\aref{SEP}} presented in \textbf{\S\ref{sub:Extension}}.
  The completeness axiom \textbf{\aref{CO}} of \textbf{\S\ref{sub:Extension}} is a \textit{derived theorem} of \textbf{BX}$_\textsc{r}$ rather than a further axiom, using only \textbf{\aref{PU}} and the axioms of \textbf{BX}, and so is not included among the axioms of \textbf{BX}$_\textsc{r}$.
\end{Ddef}
```
sha256: `650cb790801150df6a3d04a1356bb8c346b4e24694f381d8c5fbc7458da8f038`

Note (2026-09-20, prose only, no re-pin): the root `README.md` used to describe the paper's
complete-order system, under this entry's earlier name `def:TMplus-c`, as completeness
*simpliciter* with models `{ℤ, ℝ}` and theory `Th(ℤ) ∩ Th(ℝ)`, concluding that no element of the
tree's `FrameClass` picked the class out; it also recorded the corollary's axiom basis (BX_d vs.
BX plus the Reynolds axioms) as an open question. Both claims are retired: the class this entry
now names is dense-and-complete, matching `FrameClass.RTime` (`DenselyOrdered D` plus Dedekind
completeness) exactly, and the axiom basis is settled by this entry's own text (BX_r extends
**BX**$_d$ by `PU` and `SEP`). See `cor:tm-completeness` below (~line 1713) for the corollary text
this entry's completeness axiom feeds.

### `def:TMplus` — the base logic TM of tense and modality, its two bimodal interaction axioms MF and NB, and the uniformity schemata it marks derived

```latex
\begin{Ddef} \label{def:TMplus}
  The \textit{Base Logic of Tense and Modality} \textbf{TM} for $\BL$ extends \textbf{S5} and the base logic \textbf{BX} to include all instances of the \textit{bimodal interaction} axioms \textbf{\aref{MF}} and \textbf{\aref{NB}} presented in \textbf{\S\ref{sub:Logic}}.
  The uniformity schemata \textbf{\aref{NP}}, \textbf{\aref{NF}}, and \textbf{\aref{NA}} of \textbf{\S\ref{sub:Logic}} are \textit{derived theorems} of \textbf{TM} rather than of \textbf{BX}, their derivations using \textbf{\aref{NB}} together with \textbf{\aref{MF}} and \textbf{\aref{MT}}, as derived in the Lean 4 \leanrepo{}.
  The discrete \textbf{TM}$_\textsc{z}$, dense \textbf{TM}$_\textsc{d}$, and dense and complete \textbf{TM}$_\textsc{r}$ extensions of \textbf{TM} include the additional axioms that distinguish \textbf{BX}$_\textsc{z}$, \textbf{BX}$_\textsc{d}$, and \textbf{BX}$_\textsc{r}$, respectively.
  The derivation relation $\vdash_\Lambda$ for the system $\Lambda$ is the smallest relation closed under the axioms and rules for $\Lambda$, omitting subscripts when ambiguity does not threaten.
\end{Ddef}
```
sha256: `139a9a56bdf9b22c2544c6c86ec1eeb178e4908810578556ed6c057de8ef5e42`

### `thm:M5-valid` — the M5 axiom is valid — **DANGLING as of the 2026-09-17 re-pin (removed from manifest)**

The paper fully commented out this theorem environment (its `\label{thm:M5-valid}` line now sits
behind `%`), so `resolve_env` can no longer resolve it. No file in live tree scope cites the anchor.
The quoted text below is retained as the last-resolved historical record, following the
2026-09-07 retirement precedent.

```latex
\begin{Tthm} \label{thm:M5-valid}
	$\vDash \Diamond\Box\varphi \rightarrow \Box\varphi$.
\end{Tthm}
```
sha256: `bce3cc3be256f7b4c10e34a397e4b3b14abe4e8ed6728e8e91768e9a2ad8b2af`

### `thm:TM-soundness` — the Soundness theorem

```latex
\begin{Tthm}[Soundness] \label{thm:TM-soundness}
	Each system $\Lambda$ of \textbf{\ref{def:TMplus}} is sound: if $\Gamma \vdash_\Lambda \varphi$, then $\Gamma \vDash_{\mathsf{C}_\Lambda} \varphi$.
\end{Tthm}
```
sha256: `05ed3f68f6491d2be65d46053a9d56df7ca606daf11837b4da4a1ffca68a68ab`

### `app:discrete` — the Discrete correspondence theorem (DF), and the static-frame footnote's DN-does-not-prove-NN soundness argument

```latex
\begin{Tthm} \label{app:discrete}
	$\vDash_{\D} (\Past\varphi \wedge \varphi \wedge \future\top) \rightarrow \future\Past\varphi$ if and only if $\D$ is \textsc{Discrete}.%
	  \footnote{
	    The theorems of this kind cannot be sharpened to single task frames.
	    The \textit{static} task frame over $\D$, in which $w \Rightarrow_x u$ just in case $w = u$, satisfies every clause of \textbf{\ref{def:frame}}--- each cone and each nonempty fiber and segment being a singleton--- yet its possible worlds are constant, so that every sentence of $\BL$ has the same truth value at every time along a possible world and \textbf{\aref{DF}}, \textbf{\aref{DN}}, and \textbf{\aref{CO}} are all valid over it whatever $\D$ may be.
	    Over $\Z$ it also validates $\Next\top$ at every time, and so by soundness extending \textbf{TM} by \textbf{\aref{DN}} alone does not prove \textbf{\aref{NN}}.
	    Since the tense operators see $\D$ only through the possible worlds that $\Rightarrow$ admits, correspondence holds over the fibre $\Tcls{\D}$ rather than frame by frame, as the Lean 4 repository for this paper records.
	    \label{fn:static-frame}
	  }
\end{Tthm}
```
sha256: `240826f45dae75872ef1219aaac79903d775f424ac46077feac45febfd7bcc54`

### `app:dense` — the Dense correspondence theorem (DN)

```latex
\begin{Tthm} \label{app:dense}
	$\vDash_{\D} \Future\Future\varphi \rightarrow \Future\varphi$ if and only if $\D$ is \textsc{Dense}.
\end{Tthm}
```
sha256: `8b6e84aed02d8ea8313a71fb3dbc71250a009c025e295c38fad1dbe9f257f24d`

### `app:complete` — the Complete correspondence theorem (CO)

```latex
\begin{Tthm} \label{app:complete}
	$\vDash_{\D} \always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$ if and only if $\D$ is \textsc{Complete}.
\end{Tthm}
```
sha256: `d62b8c533b7ee02f43de493e98b4111f048215f14353ef588c03c9bd530549ce`

#### Reading note (of record) on `app:discrete` / `app:dense` / `app:complete`

The three statements above read as per-frame biconditionals — call this reading (T0):
"$\F \vDash ax$ iff $\F$ is a Discrete/Dense/Complete task frame." The (⇒) direction of
(T0) is **false** as stated: degenerate frames refute it (the tree's `staticFrame`, on which
every history is constant, validates each axiom over orders that are not Discrete/Dense/
Complete respectively). What the paper's appendix proofs actually prove — and what their
closing sentences state — is the temporal-order-level biconditional (T1):

> (∀ task frame $\F$ with temporal order $\D$, $\F \vDash ax$) iff $\D$ is
> Discrete/Dense/Complete.

**(T1) is the reading of record for this repository**: it is what the Lean tree formalizes.
The (⇐) directions of (T0) are genuinely per-frame and are the per-class soundness facts the
tree already carries. No non-degeneracy hypothesis is to be bolted onto (T0); class-level
exactness is recovered by the indicator-axiom mechanism, not by patching these statements.
Adjudication of record: the "Verdict (the front's definition of record)" finding of the
definitional-review-and-closure research report (2026, `app:dense` conflict adjudication).


### `def:frame-properties` — Discrete/Dense/Complete/Deterministic frame-class predicates, and the ℤ-time / ℝ-time task frames

```latex
\begin{Ddef} \label{def:frame-properties}
	A temporal order $\D = \tuple{D, +, 0, \leq}$ is:
	\begin{enumerate}[wide=0pt, labelsep=.05in, itemsep=.075in]
		\item[\sc Discrete] if for any $x \in D$, whenever there exists $y > x$, there is a least such $y' > x$ satisfying $z \geq y'$ for all $z > x$.
		\item[\sc Dense] if for any $x, y \in D$ where $x < y$, there exists $z \in D$ where $x < z < y$.
		\item[\sc Complete] if every nonempty $S \subseteq D$ bounded above has a least upper bound in $D$.
	\end{enumerate}
	A task frame $\F = \tuple{W, \D, \Rightarrow}$ inherits these properties from $\D$, and is a \textit{$\Z$-time task frame} or an \textit{$\R$-time task frame} just in case $\D$ is isomorphic to $\Z$ or to $\R$, respectively.
\end{Ddef}
```
sha256: `a8948afad219b9d3f52cd328bfeefe04f6ccde06bb4883cfc6dfdee67a7f70f9`

Note: promoted into coverage by this task (previously listed under "Deliberately not covered"
below, which is updated accordingly).

### `def:deterministic` — the Deterministic frame-class predicate (standalone since the 2026-08 wave)

Split out of `def:frame-properties` by the paper: Deterministic used to be a fourth clause inside
that definition and is now a definition of its own at live paper line 2868. Added to the manifest
at the 2026-08-25 re-pin because `FormalSystem/Examples/TemporalStructures.lean` cites it, and
citing `def:frame-properties` for determinism is now wrong.

```latex
\begin{Ddef} \label{def:deterministic}
	A task frame $\F = \tuple{W, \D, \Rightarrow}$ is \textsc{Deterministic} just in case $u = v$ whenever $w \Rightarrow_x u$ and $w \Rightarrow_x v$ for $w, u, v \in W$ and $x \in D$. %, holding in both temporal directions since \textbf{\ref{def:task-relation}}'s reflection convention already extends $x$ over all of $D$.
\end{Ddef}
```
sha256: `9a347781ddbb850ddcc5500f4a614309fd47fae7e20f63eaef7335a4ab1b0d3d`

### `def:BLstar-semantics` — the truth definition for the manuscript's `\BL^\star` (pinned 2026-09-20, promoted from the KNOWN-ANCHORS `LIVE-UNPINNED` list)

Promoted into the manifest by this task's coverage extension: the anchor's `($\Stability$)` clause
is now confirmed **quoted verbatim** in this repository — not merely paraphrased — in two places:
subsection *Restricted Modalities* (`sub:RestrictedModalities`) states it first, and this block
restates it word-for-word except for the uniform `\vec{v}` register-vector parameter the block
adds for the store/recall operators. `PlusTruthAt`'s `stab` clause
(`FormalSystem/PlusLanguage/PlusTruth.lean`) implements the clause on the nose, and
`StarTruthAt` (`FormalSystem/StarLanguage/StarTruth.lean`) implements it over points
`(τ, x, v⃗)`, passing the register vector unchanged to `σ`. This retires the ground the
KNOWN-ANCHORS row gave for leaving the anchor unpinned ("the clause is quoted in this repository
only in paraphrase"), per this record's own charter: "If a docstring starts quoting one verbatim,
promote it to the manifest at that point."

Carried forward from the removed KNOWN-ANCHORS row: the anchor's block also covers the
`\timeStore^i`/`\timeRecall^i` store/recall clauses. Its **time-register half is implemented** as
`StarTruthAt` over points `(τ, x, v⃗)` (`FormalSystem/StarLanguage/StarTruth.lean`),
while the **world registers `↑_M`/`↓_M` are deliberately still unimplemented** — recorded as an
explicit exclusion in `FormalSystem/StarLanguage/README.md`'s correspondence table.

```latex
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
sha256: `b4d3239cc96ddd1e90965901aca8c378f6ec5ca52f568ea6b2ef59d9c3ba6c95`

Note: **coverage extension, not a drift correction** — the whole-file `PINNED_COMMIT` /
`FILE_CHECKSUM` / `LINE_COUNT` sentinels above are deliberately **not** re-pinned by this addition,
following the 2026-08-13 22-anchor precedent recorded elsewhere in this file: a coverage extension
adds a manifest row without asserting that the whole file was re-verified against a new commit.

### `cor:saturation-finite` — task relations on a finite W satisfy Saturation, choice-free (renamed from `cor:spherical-finite`; **environment changed `Cthm` → `Lthm`** in the 2026-09-07 wave)

The manifest row was re-keyed from `cor:spherical-finite` to `cor:saturation-finite` at the
2026-09-02 rename absorption, but the prose entry below still quoted the pre-rename *Spherical*
text; it is refreshed here. The 2026-09-07 wave additionally moved the result from a `Cthm`
(corollary) to an `Lthm` (lemma) environment while leaving the statement itself word-for-word
unchanged. That is a hash-visible change even though nothing mathematical moved, because
`resolve_env` hashes the whole `\begin{…}`/`\end{…}` block. The manifest row's `kind` stays
`env` — the resolver reads the environment name off the `\label{}` line rather than being told it
— so no column but the sha256 needed re-checking. The anchor id is still `cor:` prefixed while the
environment is now a lemma; that mismatch is the paper's, and this record follows the paper.

```latex
\begin{Lthm} \label{cor:saturation-finite}
	Task relations on finite set of world states $W$ satisfy \textit{Saturation}, choice-free.
\end{Lthm}
```
sha256: `98fac4cfb09991ec3046ab843e1d3fa5e089e2e52d50dbe7130bacdf8528353a`

### `cor:tm-completeness` — the Completeness corollary (TM sound but not complete; completeness carried by BL+)

```latex
\begin{Cthm}[Completeness] \label{cor:tm-completeness}
  The $\BL$ systems are complete over their classes of task frames:
  \begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \item[\bf TM] Strongly complete over all task frames.
    \item[\bf TM$_\textsc{d}$] Strongly complete over the dense task frames.
    \item[\bf TM$_\textsc{z}$] Weakly complete over the $\Z$-time task frames.
    \item[\bf TM$_\textsc{r}$] Weakly complete over the $\R$-time task frames.
  \end{enumerate}
  Strong completeness provably fails over the $\Z$-time task frames as well as the $\R$-time task frames, where compactness fails.%
    % \footnote{
    %   These results, together with the soundness of the corresponding systems, are established in the Lean 4 \leanrepo{} for this paper, and so their proofs are not reproduced here.
    %   Each system is also extended to include \textit{Determined} and governing axioms in the language with $\Stability$, each sound over the task frames in its class validating \textit{Determined} and weakly complete over the \textsc{Deterministic} task frames in that class.
    % }
\end{Cthm}
```
sha256: `f8f5b41f998e59322052accce9ac219dfbe9fe7931329bebbdb5b1cc855f0bce`

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
  % NEW CHANGE: the proviso on LL is folded into the definition of the substitution notation, so that the list has three clean items and no dangling `where' line. The free-for condition is still added in def:qe, where quantifiers first appear.
  The logic for $\BL^{\equiv}$ comprises classical propositional logic and the minimal theory of identity given below, where $\alpha$ and $\beta$ are both formulas or both operator terms, and $\chi_{(\beta/\alpha)}$ is the result of replacing one or more occurrences of $\alpha$ in any formula $\chi$ with $\beta$, none of which lies within the argument of an operator:
	\vspace{-.125in}
	\begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
		\begin{multicols}{2}
			% NEW CHANGE: Imp is removed, being the instance of LL at chi := phi. The five proofs that cited it now cite LL, and the minimal theory of identity is Ref and LL alone.
			\aitem{Ref} $\vdash \alpha \equiv \alpha$.
			\aitem[LL$^{-}$]{LL} $\vdash (\alpha \equiv \beta) \rightarrow (\chi \rightarrow \chi_{(\beta/\alpha)})$.
		\end{multicols}
	\end{enumerate}
	\vspace{-.175in}
  % NEW CHANGE: the type note and the sentence on symmetry and transitivity return here from def:lang, since both types now exist here.
  % NEW CHANGE: Imp is recorded as the instance of LL at chi := phi, which is why it concerns formulas alone, since chi must be a formula. The label is kept because six proofs cite it.
  The schemata above are instantiated at both types.
  The restriction on \textbf{\aref{LL}} makes the transparency of the objective modalities is nontrivial rather than holding for the whole language.
  % NEW CHANGE: `operator term' becomes `operator' in the phrase `the argument of an operator', here and in the gloss on O-Tran, matching the proviso on LL.
  The symmetry and transitivity of $\equiv$ are derivable at either type from \textbf{\aref{Ref}} and \textbf{\aref{LL}}, and since each replaces an occurrence lying outside the argument of any operator, both survive the proviso on \textbf{\aref{LL}}.
  % The theory of propositional identity need not be Boolean, accommodating theories in which the Boolean identities do not hold.\footnote{I defend a hyperintensional theory of propositional identity in Brast-McKie \cite{Brast-McKie2021} where transparency is maintained for the entirety of the language rather than posited for the objective modalities alone.}
\end{Ddef}
```
sha256: `09ab2f4451284a8774a8c63ca3a26586bb4fb175271f3affdf45bfb23776100f`

### `def:strongest` — strongest objective modal operator Str^O_L(Q), and the meet of the objective modalities Str'^O_L(Q) — **DANGLING as of the 2026-10-15 BX/TM demotion wave (removed from manifest)**

The paper removed the `\label{def:strongest}` definition outright. `Str` is now an object-language
abbreviation introduced as an `\aitem{Str}` key inside `\label{def:key-terms}` — the
operator-predicate definition that also carries `Fac`, `Ax` and `Ord` — reading
`$\Str^{\OO}(\Q) \coloneq \OO(\Q) \wedge \forall\P[\OO(\P) \rightarrow (\Q \preceq \P)]$`,
with the `L` subscript dropped and strongest-hood expressed by derivability of that formula.
The primed `Str'` notion and its dominance argument went with the removed definition, which is
why `thm:exist` and `lem:uniq` lost their `Str'` halves in the same wave. The text below is
retained as the last-resolved historical record: any docstring still quoting it is quoting a
version of the paper that no longer exists. Succeeded by `def:key-terms`, which this file does
not pin — no in-tree docstring quotes its text, and the anchor carries a `LIVE-UNPINNED` row
only if one starts to.

```latex
\begin{Ddef} \label{def:strongest}
	$\Q$ is a \textit{strongest objective modal operator in $L$}--- $\Str^{\OO}_{L}(\Q)$--- if and only if:
	\begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \item $\vdash \OO(\Q)$; and
		\item $\vdash \forall\P[\OO(\P) \rightarrow (\Q \preceq \P)]$.
	\end{enumerate}
	$\Q$ is \textit{the meet of the objective modalities in $L$}--- $\Str'^{\OO}_{L}(\Q)$--- if and only if:
	\begin{enumerate}[leftmargin=.5in,labelsep=.15in,itemsep=.075in]
    \item $\vdash \OO(\Q)$; and
		\item $\vdash \forall p\,(\Q p \equiv \forall\P(\OO(\P) \rightarrow \P p))$.
	\end{enumerate}
	Since the second clause of $\Str'^{\OO}_{L}(\Q)$ yields $\vdash \Q p \rightarrow (\OO(\P) \rightarrow \P p)$ by \textbf{\aref{Imp}} after instantiating at $p$ and $\P$, permuting antecedents and generalizing gives dominance, so $\Str'^{\OO}_{L}(\Q)$ implies $\Str^{\OO}_{L}(\Q)$, whereas the converse would require the identity.
\end{Ddef}
```
sha256: `1df0d202e5c4ccfeb92b6c83048ece99bb80dc6ce46774a05ff9e728e93231ec`

### `thm:exist` — L includes a strongest objective modality (the existential claim)

```latex
\begin{Tthm}[Existence] \label{thm:exist}
	$\vdash \exists\Q\,\Str^{\OO}(\Q)$, so $L$ includes a strongest objective modality.
\end{Tthm}
```
sha256: `1a70ff465a8077e896592ef0cab36a4476c89864fa05920120d01e928938e9cd`

### `lem:uniq` — uniqueness up to equivalence of the strongest objective modality

```latex
\begin{Lthm}[Uniqueness] \label{lem:uniq}
	If $\vdash \Str^{\OO}(\Q)$ and $\vdash \Str^{\OO}(\P)$, then $\vdash \forall p(\Q p \leftrightarrow \P p)$.
\end{Lthm}
```
sha256: `3fe647f782b71327a8cedfae5e80a83e143453fef4b77ef96fd465369b4866b9`

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
	If $\vdash \Str^{\OO}(\Q)$, then $\vdash \forall p(\Q p \rightarrow \Q\Q p)$, $\vdash \forall p(p \rightarrow \Q\Dual{\Q}p)$, and $\vdash \forall p(\Q p \rightarrow p)$.
\end{Tthm}
```
sha256: `be08911a0adace5f87b4870bf80a22ad92cb5e16303628887d8087a529ed57f8`

### Satisfiability — **no paper-native definition exists** (recorded as a gap, not fabricated)

The paper does not define "satisfiable" or "satisfiability" anywhere as a `\label`led `Ddef`,
`\aitem`, or otherwise-named clause. This was confirmed by an exhaustive `satisfiab` grep over the
current paper text: every occurrence is informal prose ("this is easy to satisfy", "satisfiability
in HyperLTL is undecidable" in a related-work discussion), never a definition. This is independently
corroborated by the "Semantic FMP (finite world-state over ℤ)" task's own governing description,
which states the same finding in its own words ("Satisfiability has no labeled paper definition").

**This file therefore does not, and must not, invent a satisfiability definition on the paper's
behalf** — doing so would violate this file's own charter of recording only what the paper says.
The Lean tree's `satisfiable` / `SatisfiableAbs` / `FormulaSatisfiable` (`Semantics/Validity.lean`)
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
  this task's "cover at minimum" list. **Justification refreshed 2026-09-07**: the z/d/r wave
  restated both for **TM** and the full language **BL** rather than for the retired Past/Future
  fragment system (paper lines 4031 and 4035). The restatement makes them *more* relevant to this
  repository, not less, but the exclusion stands on its original ground — they are proof-theoretic
  — and no in-tree site quotes either. Promote them the moment one does.
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
the "shift-set representation theorem / compactness feasibility gate" task's exposure to the
`def:BL-semantics` box-clause / `TruthAt` architecture.

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
def:temporal-order|env|-|-|1fa55867b57322f0dd7d6cc346e3ebe09809a5990832b34de58b1805acd14894
def:task-relation|env|-|-|f35b1c7412b592c99a7a4bdc2889a5d19cf23712e4c9c08cd51cda917e3b60c5
def:frame|env|-|-|1150ed22cb6a9e8e0f84a57e3b342fafb143930370814ff4f4fdf9790be5604d
def:frame#Compositionality|item|def:frame|Compositionality|4b9248498399338eeaccb63c5e8952ca0928b87bb85bcd94f596d9c263bb64fa
def:frame#Seriality|item|def:frame|Seriality|ad1863bf950f17906a79b469b40fddb102e4abf5bd1bfd828a2f4b4900c7dbad
def:frame#Limit|item|def:frame|Limit|3eedd389d6cbdf5dff50f82ad9bafed30fe5eff5ec923cfdc165ca75dbe60a5f
def:frame#Saturation|item|def:frame|Saturation|c293e9f830a2e1f0154d1ee7be2c7a121a7aa0ec4476266637e4fffaff345c60
lem:nullity|env|-|-|8442e2bf6b5f6515f2f906132bbe15fe919973d82ae573dba29a919ad14636f5
def:world-history|env|-|-|e94a15db019603c0c924690c29b84b6b82d2b9443e87e0050e3ffa184533c889
thm:extension|env|-|-|0677bc175c0717349e5e69f257f43bd06976bffd89c3877a9f020496416822d7
cor:occurrence|env|-|-|e4be0b08ecd39e559fff831361440f1af2c51760a9c053e1f2dba4a65b025af4
def:constraints|env|-|-|f39ba974df411b9f436932fd4414146e66b333219de896758028974fc4297a21
lem:nesting|env|-|-|6ad1e33d546003cc35a454687dfdd2dca32e99668f1f5d92ad9f0616a2f3a61d
lem:nonempty|env|-|-|8067bf45a360f04db7a94280bde1b359dac58e8311f2fba1d58db15bf2336598
lem:constraint|env|-|-|ca6719adfaad9f6dc3d1b6a57de013598dd80847014d9c2fb60ed626b895370f
lem:admissible|env|-|-|9606ef1f1264887ed51358744df7e5fc290250dd8209f445fd138700da56de8e
lem:step|env|-|-|b1f65f70cc243de5b32d4e2a46c35c986dd0322cf3ca0524fb76701af3e3be4b
def:BL-semantics|env|-|-|aad8ee543a63a394983e02c2c7ec81e02aaf7737768bcb0d492c668c38de3eb2
def:BLplus-language|env|-|-|b7027d468a844f09068c7dc765498e4668708ac09b175cfc20594bcaba5d3c95
def:time-shift-histories|env|-|-|99588bf0dec609563ce3fe129bee59b3ca36826726349b3e0f7fc403efdbedbc
def:frame-validity|env|-|-|4fdc41ce401c80032aef112060e0b9ce932b82c777759272bba7998dc113ad61
def:logical-consequence|env|-|-|3af67167ee4a393d77fc8cfa8ddc065fe932bedf76a14febb8608a9001af5486
CO|aitem|-|-|707368059ff1f7cc53c8b4ca9c591781ee427263797c8d36d3fb85e8abe8e955
def:S5|env|-|-|dc940901838a1228ffa3b3170466bbc3d8046f4596db23184afb55fb32896257
def:BX|env|-|-|64cc5cc90860bd5c3855701a4de57c38a10ffb6d0c59025224c82869f8454ec2
def:BX-z|env|-|-|c38466b21121724f71d039014c525e5e4f8c397025f37746fcfb7587c85a5581
def:BX-d|env|-|-|44a74c839c0c74141fb1565120cb91193973fc33a69c35d5070bcbc67379e40c
def:BX-r|env|-|-|650cb790801150df6a3d04a1356bb8c346b4e24694f381d8c5fbc7458da8f038
def:TMplus|env|-|-|139a9a56bdf9b22c2544c6c86ec1eeb178e4908810578556ed6c057de8ef5e42
thm:TM-soundness|env|-|-|05ed3f68f6491d2be65d46053a9d56df7ca606daf11837b4da4a1ffca68a68ab
app:discrete|env|-|-|240826f45dae75872ef1219aaac79903d775f424ac46077feac45febfd7bcc54
app:dense|env|-|-|8b6e84aed02d8ea8313a71fb3dbc71250a009c025e295c38fad1dbe9f257f24d
app:complete|env|-|-|d62b8c533b7ee02f43de493e98b4111f048215f14353ef588c03c9bd530549ce
def:frame-properties|env|-|-|a8948afad219b9d3f52cd328bfeefe04f6ccde06bb4883cfc6dfdee67a7f70f9
def:deterministic|env|-|-|9a347781ddbb850ddcc5500f4a614309fd47fae7e20f63eaef7335a4ab1b0d3d
def:BLstar-semantics|env|-|-|b4d3239cc96ddd1e90965901aca8c378f6ec5ca52f568ea6b2ef59d9c3ba6c95
cor:saturation-finite|env|-|-|98fac4cfb09991ec3046ab843e1d3fa5e089e2e52d50dbe7130bacdf8528353a
cor:tm-completeness|env|-|-|f8f5b41f998e59322052accce9ac219dfbe9fe7931329bebbdb5b1cc855f0bce
def:id|env|-|-|09ab2f4451284a8774a8c63ca3a26586bb4fb175271f3affdf45bfb23776100f
thm:exist|env|-|-|1a70ff465a8077e896592ef0cab36a4476c89864fa05920120d01e928938e9cd
lem:uniq|env|-|-|3fe647f782b71327a8cedfae5e80a83e143453fef4b77ef96fd465369b4866b9
thm:s5|env|-|-|be08911a0adace5f87b4870bf80a22ad92cb5e16303628887d8087a529ed57f8
```
<!-- MANIFEST:END -->

## Known anchors outside the manifest (machine-readable)

`scripts/check-module-invariants.sh`'s **C15** check asserts that every `def:`/`thm:`/`lem:`/
`cor:`/`app:`/`rmk:` citation in live, non-`specs/`, non-`Boneyard/` scope resolves *here* — never
against the live `.tex`, so C15 does not go red merely because the author edited the paper. The
manifest above covers every **pinned** anchor. This block covers the rest: anchors the tree cites
that the manifest deliberately does not pin, each with an explicit status, so that every citation
in the tree is a recorded decision rather than an accident.

Two statuses:

- **`LIVE-UNPINNED`** — the anchor resolves to a live, non-commented `\label{}` in the paper, but
  is deliberately not pinned. Pinning costs a re-quote-and-re-hash on every paper wave, and is
  warranted only where the tree quotes the anchor's *text*. These are cited by **name only** (as a
  pointer, e.g. "see `app:deterministic`"), so a pin would buy nothing. If a docstring starts
  quoting one verbatim, promote it to the manifest at that point.
- **`DANGLING`** — the anchor does **not** resolve to a live `\label{}`: it was retired, it was
  commented out, or it never existed. Every in-tree citation of one of these must say so at the
  citation site; C15 only asserts that the anchor is *recorded* here, not that the prose is honest.

<!-- KNOWN-ANCHORS:BEGIN -->
```
# anchor_id|status|note
app:ObjectiveModality|LIVE-UNPINNED|section label for the objective-modality appendix; cited as a pointer. STRUCTURALLY UNPINNABLE: resolve_env reads the environment name off the same line as the \label{}, and this label sits on its own line under a \subsection{...}% — the app:TaskSemantics precedent
app:TaskSemantics|LIVE-UNPINNED|section label for the task-semantics appendix; cited as a pointer
app:auto_existence|LIVE-UNPINNED|automorphism existence; cited as a pointer, text never quoted
app:deterministic|LIVE-UNPINNED|determinism CORRESPONDENCE theorem, not the definition; the definition is def:deterministic, which IS pinned
app:deterministic-future|LIVE-UNPINNED|the deterministic-future appendix, whose sentence sent:det uses the time store/recall operators; cited as a pointer by README.md's object-language table, which records that this repository's L⋆ is the time-register fragment the appendix actually uses. BOTH HALVES ARE NOW FORMALIZED: the positive half is sentDet_of_deterministic (StarLanguage/StarDeterminism.lean) and the negative half is refute_sentDet (StarLanguage/StarNonValidities.lean), with the (*) chain as sentDet_unfold (StarLanguage/StarValidity.lean). Not pinned: no docstring quotes its text -- the transcription is of the displayed sentence and the (*) chain, both cited by \label
app:drift|LIVE-UNPINNED|the non-deterministic drift frame theorem (Tthm); DriftFrame.lean discusses its PROOF (the interpolation and the compactness/finite-intersection Saturation argument), which lives in the \begin{proof} block outside the Tthm and so is not what a pin would hash; the statement itself is cited as a pointer
app:gluing|LIVE-UNPINNED|the gluing lemma for two convex histories that agree on their overlap; cited as a pointer by FormalSystem/OpenLanguage/ (OpenClasses.lean and the component README), whose paste_mem_openFutureClass_inter_openPastClass is its two-total-history instance over paste (PlusLanguage/PlusPasting.lean), and by FormalSystem/Semantics/Presheaf/Sheaf.lean, whose sheaf_clause is its interval-site reading for two sections agreeing at a seam. Not pinned: no docstring quotes its text
app:topology-continuous|LIVE-UNPINNED|history-continuity lemma in the topology appendix; cited as a pointer by StateTopology.lean, text never quoted
app:topology-r0|LIVE-UNPINNED|topology appendix; part of the block this file deliberately does not cover
app:topology-t1|LIVE-UNPINNED|topology appendix; part of the block this file deliberately does not cover
cor:no-characterization|LIVE-UNPINNED|the no-characterization corollary (Cthm); cited as a pointer, text never quoted
cor:perpetuity-valid|LIVE-UNPINNED|perpetuity principles valid; the live anchor that replaced the never-existent app:valid
def:BL-language|LIVE-UNPINNED|the BL language; cited as a pointer alongside the pinned def:BLplus-language
def:event-operators|LIVE-UNPINNED|the Ddef defining After, Release and Before in BL: After(phi,psi) := not-phi U (phi and psi), Release(phi,psi) := not(not-phi U not-psi), Before(phi,psi) := Release(psi,not-phi) and f-phi, closing with the remark that After(phi,top) = not-phi U phi says there is a next phi-time. After and Before are FORMALIZED as Formula.after and Formula.before (FormalSystem/Syntax/Formula.lean), each pinned by an example ... := rfl against the literal primitive expansion of the paper's right-hand side; Release was already present as Formula.release, whose arguments are REVERSED relative to the paper's Release (Formula.release a b is the paper's Release(b,a)), a mapping recorded in docs/architecture/untl-snce-argument-order.md. After is mirrored into L+ as PlusFormula.after and into the language-generic clause tier as TruthClauses.after. Not pinned: the citing docstrings transcribe the operator structure rather than quoting the paper's prose, the sent:det precedent
def:canonical-frames|LIVE-UNPINNED|the Ddef introducing the paper's two canonical countermodel frames over a temporal order: the translation frame F^tr_D = (D, D, =>), with w =>_d u iff u = w + d, carrying the translations sigma_c(z) = z + c for c in D; and the two-state frame F^ts_D = ({w_0, w_1}, D, =>), whose zero duration is the identity and whose every positive duration permits every transition. Both frames are FORMALIZED as translationFrame and permissiveFrame (FormalSystem/Semantics/Frames/Standard.lean), and the characterizations of lem:canonical-frames are carried by FormalSystem/Semantics/Correspondence/DurationFrames.lean. Cited as a pointer by that module; not pinned, since no docstring quotes its text
def:flow|LIVE-UNPINNED|the Ddef defining the Flow condition on a task frame: W is linearly ordered by < and every possible world is an order-isomorphism of (D, <) onto (W, <). FORMALIZED as OrderFlow (FormalSystem/Metalogic/Independence/OrderTransfer.lean), whose fields state that order-isomorphism condition pointwise; the hypothesis set [F.IsRegular] (h : OrderFlow F) carried by the _of_isRegular corollaries of Independence/StateSetTruth.lean is this condition with nothing left over. Cited as a pointer, text never quoted
def:nomic-frame|LIVE-UNPINNED|the Ddef relativizing def:frame: one carrier W together with a family of task relations =>^w, one per world state, each satisfying def:frame, so that F^w = (W, D, =>^w) is an ordinary task frame, the law-histories H_F^w are its possible worlds, and H_F is their union over w. FORMALIZED as NomicFrame with its derived family NomicFrame.at, the regularity class NomicFrame.IsRegular and its instAtIsRegular instance, and lawHist/HF (FormalSystem/Semantics/Nomic/Frame.lean). Cited as a pointer, text never quoted
def:nomic-properties|LIVE-UNPINNED|the Ddef defining the three properties of a nomic frame: Lawful (every nomologically possible world lies in the law-histories of each state it occupies), Static (the law-histories of the states occupied at any two times along one nomologically possible world coincide) and Uniform (every world state determines the same law-histories). FORMALIZED as NomicFrame.Lawful, NomicFrame.Static and NomicFrame.Uniform, with the two implications from Uniform as static_of_uniform and lawful_of_uniform (FormalSystem/Semantics/Nomic/Frame.lean). Cited as a pointer, text never quoted
def:nomic-witnesses|LIVE-UNPINNED|the Ddef fixing the Z-time presentation of the hierarchy witnesses by one-step relations R_w, with =>^w_n = R_w^n and the reflection convention for n < 0. FORMALIZED as NomicFrame.ofStepFamily (FormalSystem/Semantics/Nomic/ZTime.lean), whose w-th member is FrameOver.ofStep (R w) by rfl, so every Z-normal-form lemma applies to it unchanged. Cited as a pointer, text never quoted
def:state-set|LIVE-UNPINNED|the Ddef defining the state set of each sentence of BL extended with Stability by a recursion over a linearly ordered W appealing to just < and the sets assigned to the sentence letters, mentioning no task frame. FORMALIZED as satSet (FormalSystem/Metalogic/Independence/StateSetTruth.lean); its box clause is encoded as an argument-ignoring set rather than the paper displayed if-then-else, to keep Classical.choice out of the definition, which that module docstring records as a decision with its reason. Cited as a pointer, text never quoted
def:task-topology|LIVE-UNPINNED|topology appendix; part of the block this file deliberately does not cover
def:time-reflection|LIVE-UNPINNED|the Ddef defining time reflection: the reflected frame F- (w =>-_x u := w =>_{-x} u), the reflected world tau- := tau o n with n(x) = -x, and the sentence map phi -> phi_{S|U} that exchanges Since with Until. FORMALIZED as FrameOver.rev / TaskFrame.rev (FormalSystem/Semantics/TaskFrame.lean), TaskModel.rev / WorldHistory.rev / revHistEquiv / revAntiIso (FormalSystem/Semantics/Reversal.lean) and Formula.reflectTime (FormalSystem/Syntax/Formula.lean). Cited as a pointer by Reversal.lean; not pinned, since no docstring quotes its text
lem:after-negation|LIVE-UNPINNED|the Lthm asserting that After(phi,top) -> (not-After(phi,psi) <-> After(phi,not-psi)) is valid over every task frame, the point being that any two next phi-times coincide so that under the guard both sides read one and the same point. FORMALIZED as after_negation_valid (FormalSystem/Metalogic/SoundnessLemmas/EventOperators.lean), over the language-generic TruthClauses.after_negation and its next-time uniqueness input TruthClauses.isNextTime_unique (FormalSystem/Semantics/TruthClauses.lean). Not a soundness case: Formula.after is a derived operator, not an Axiom constructor, so nothing in the soundness induction consumes it. Not pinned: the citing docstrings transcribe the schema rather than quoting the paper's prose
lem:canonical-frames|LIVE-UNPINNED|the Lthm making four claims about the two frames of def:canonical-frames: (a) the translation frame is a Deterministic task frame; (b) its possible worlds are exactly the translations sigma_c for c in D; (c) the two-state frame is a task frame just in case D is Discrete; and (d) in that case it is not Deterministic and every function from D to {w_0, w_1} is one of its possible worlds. ALL FOUR ARE FORMALIZED in FormalSystem/Semantics/Correspondence/DurationFrames.lean: (a) translationFrame_deterministic, generalising the real-line instance to every temporal order; (b) translationHistEquiv, translation_histSet_eq and translation_exists_unique; (c) permRel_limit_iff_isDiscrete and permRel_constraints_iff_isDiscrete, stated at the bare relation permRel and tied to the frame by permissiveFrame_taskRel_eq, since the frame cannot be formed without the SuccOrder and NoMaxOrder data discreteness itself supplies; (d) permissiveFrame_not_deterministic and permissiveHistEquiv. Cited as a pointer by that module; not pinned, since no docstring quotes its text
lem:deterministic-singleton|LIVE-UNPINNED|deterministic-frame singleton fibers (Lthm); cited as a pointer (StateSetTruth.lean names its choice-free direction but quotes no text)
lem:history-time-shift-preservation|LIVE-UNPINNED|time-shift preservation; cited as a pointer
lem:nomic-occurrence|LIVE-UNPINNED|the Lthm asserting that over every nomic frame each world state occurs at every time along some nomologically possible world, proved by applying cor:occurrence to the relativized frame. FORMALIZED as NomicFrame.occurrence (FormalSystem/Semantics/Nomic/Frame.lean), a one-line wrapper on PartialHistory.occurrence at the relativized member F^w, which is the paper's own proof; the nomic forward pointer in StateSetTruth.lean names it for the nomic port, and the Semantics/Nomic/ cluster now supplies the frame-level machinery it wanted. Cited as a pointer, text never quoted
lem:nomic-recovery|LIVE-UNPINNED|the Lthm asserting that two world states determine the same law-histories just in case they determine the same relativized task relation: H_F^w = H_F^u iff =>^w = =>^u. FORMALIZED as NomicFrame.lawHist_eq_iff_taskRel_eq over the one-directional helper taskRel_imp_of_lawHist_eq (FormalSystem/Semantics/Nomic/Recovery.lean), whose forward direction runs the paper's own two-point partial history through thm:extension, with the d = 0 case by lem:nullity and the d < 0 case by the reflection convention. Choice-bearing through thm:extension, per rmk:choice. Cited as a pointer, text never quoted
lem:state-set|LIVE-UNPINNED|the Lthm asserting that over a task frame satisfying Flow the truth of every sentence of BL extended with Stability at a possible world and a time is membership of the state occupied there in the state set of def:state-set, whence frame-validity of the Determined schema and the equivalence of frame-validity with the state set exhausting W under every assignment. ALL THREE SENTENCES ARE FORMALIZED at [F.IsRegular] (h : OrderFlow F) as plusTruthAt_iff_mem_satSet_of_isRegular, determined_of_orderFlow_of_isRegular and plusValidOn_iff_satSet_univ_of_isRegular (FormalSystem/Metalogic/Independence/StateSetTruth.lean), over the two-hypothesis forms the same module retains for their choice-free consumer. Cited as a pointer, text never quoted
lem:time-reflection|LIVE-UNPINNED|the time-reflection lemma (renamed by the paper from lem:temporal-duality, 2026-09-18): truth is preserved from M,tau,x to M-,tau-,n(x) under reflectTime, F- is a task frame, and tau -> tau- is a bijection. Cited as a pointer by the MinusFrame.lean truth-lemma docstrings (truth_reflectTime is its L- analogue); paraphrased, never quoted
prop:archimedean|LIVE-UNPINNED|the Pthm asserting that UZ and Z1 both fail over every non-Archimedean Discrete temporal order; def:BX-z cites it for the ZTime narrowing, and the tree now cites it by name at the IsZTime sites (FrameProperty.lean, FrameClassValidity.lean, Validity.lean, BLValidity.lean, Indicator.lean, LexIntWitness.lean, Semantics.lean, Correspondence/README.md, FormalFoundations.typ). The tree machine-checks the proposition at the generality stated, in Metalogic/Independence/ArchimedeanSharpness.lean: not_validOnFrameOver_prior_UZ_nonArchimedean and not_validOnFrameOver_z1_nonArchimedean refute UZ and Z1 over every non-Archimedean carrier with a least positive duration, with not_validOnFrames_isDiscrete_* the bare-Discrete-class form. Still LIVE-UNPINNED rather than a MANIFEST row: the tree cites the anchor by name and never quotes its text, which is what a pinned row would assert. Promote to the manifest only if a docstring starts quoting its text
prop:nomic-hierarchy|LIVE-UNPINNED|the Pthm asserting that Uniform implies both Static and Lawful, that neither Static nor Lawful implies the other, and that Static-and-Lawful does not imply Uniform, the three gaps witnessed by finite Z-time nomic frames. FORMALIZED as nomic_hierarchy with its per-witness independence theorems (FormalSystem/Semantics/Nomic/Witnesses.lean), resting on static_of_uniform and lawful_of_uniform (Nomic/Frame.lean). A prop: anchor, so outside C15's gated prefix set; recorded for consistency with the prop:archimedean row. Cited as a pointer, text never quoted
prop:nomic-tense-free|LIVE-UNPINNED|the Pthm asserting that the nomic operator and the modal box agree over every nomic frame on the tense-free fragment, so that every S5 schema for the nomic operator is valid there, by the same state-set induction as lem:state-set with one clause shared between the two operators and no temporal clauses at all. NOT FORMALIZED: no nomic machinery exists in this tree; recorded alongside lem:nomic-occurrence for the nomic port, and for consistency with the prop:archimedean row, though prop: is outside the gated prefix set. Cited as a pointer, text never quoted
rmk:choice|LIVE-UNPINNED|the remark listing the results of the paper that are CHOICE-FREE, app:gluing among them. Cited by name by FormalSystem/Semantics/Gluing.lean and FormalSystem/Semantics/README.md, which record that the claim it makes for app:gluing is asserted mechanically rather than in prose: convexGlue and gluing_clause are pinned at [propext, Quot.sound] by the C14 heredoc pair in scripts/check-module-invariants.sh, so a later edit that reintroduced Classical.choice would fail the build. Cited as a pointer; not pinned, since no docstring quotes its text
sent:det|LIVE-UNPINNED|the displayed sentence of app:deterministic-future, up^1 Future up^2 down^1 (Stability down^2 not-phi or Stability down^2 phi); transcribed as sentDet (StarLanguage/StarValidity.lean) and cited by name in StarValidity.lean, StarDeterminism.lean, StarNonValidities.lean, StarDiscrimination.lean and ForwardDeterministicFrame.lean. Cited by name only; not pinned, since the transcription is of the operator structure rather than of quoted prose. Note that \Future here is the manuscript preamble's BOXED F (universal future), not the diamond f -- checked against the display and against the (*) chain's "for all y > x" step
sub:RestrictedModalities|LIVE-UNPINNED|the subsection that introduces the stability clause, the items Open Futures and Open Pasts, the clauses for the open-future and open-past operators, and the nomic operator. A sub: label, so C15 does not gate it; recorded because the open-future and open-past halves are now FORMALIZED in FormalSystem/OpenLanguage/ (the three classes in OpenClasses.lean, the two clauses in OpenTruth.lean, the inclusion / intersection / monotonicity sentence as theorems), while the nomic operator is not. Not pinned: the component cites it by label and by quotable phrase, and a subsection label has no environment for resolve_env to read
thm:TR-valid|LIVE-UNPINNED|the Tthm asserting that if phi is valid then so is its time reflection phi_{S|U}, from which thm:TM-soundness' TR case follows per frame class because the reflected frame shares its temporal order. FORMALIZED as validOnFrames_reflectTime with its frame-class instance validIn_reflectTime, the involution form validIn_reflectTime_iff, valid_reflectTime, and validComplete_reflectTime / validQTime_reflectTime at the two predicates no FrameClass tag denotes (FormalSystem/Semantics/Validity.lean), over the per-class closure FrameClass.Sat.rev (FormalSystem/Semantics/FrameClassValidity.lean) and the frame-level lem:time-reflection transport truthAt_rev (FormalSystem/Semantics/Reversal.lean). Cited by name by Validity.lean, FrameClassValidity.lean, Metalogic/Soundness.lean (which records that the per-axiom reflection dispatch is retained deliberately as an independent re-derivation) and Semantics/README.md; not pinned, since no docstring quotes its text
TMP-CO|DANGLING|the BL^+ restatement of CO; it went away with def:TMplus-c (now def:BX-r), which derives CO from PU rather than restating it under a second label. The plain CO anchor is still live and still pinned
app:Structure|DANGLING|the section label for the cut appendix "Topological and Categorical Structure". app:Structure was cut from the paper IN FULL under an explicit % SECTION CUT record ("Topological and Categorical Structure" (app:Structure) in full) and the surviving commented block carries a bare % CHECK, so the author has not finished reviewing it. Cited as a pointer by FormalSystem/Semantics/Presheaf/ (Site.lean, Behavior.lean), which records that state at each citation site. NOT PINNABLE: check-paper-definitions.sh --resolve structurally cannot read text off a commented-out \label{}
app:nonempty|DANGLING|merged by the paper into cor:occurrence; cited only where the tree records the merge
app:presheaf-dictionary|DANGLING|the Tthm asserting that Beh(F) is a presheaf on Int(D) with the Sheaf, Totality, Germs, Possible Worlds, Determinism and Reflection clauses. app:Structure was cut from the paper IN FULL under an explicit % SECTION CUT record ("Topological and Categorical Structure" (app:Structure) in full) and the surviving commented block carries a bare % CHECK; the author has not finished reviewing it, and this anchor went with the cut. The Germs clause is formalized as Beh.germEquiv (FormalSystem/Semantics/Presheaf/Behavior.lean) and the Sheaf clause as sheaf_clause, with its site-indexed form sheaf_clause_site and its compatible-family condition compat_iff_match (FormalSystem/Semantics/Presheaf/Sheaf.lean); the clause's site-side content alone is cover_germ_composites (Presheaf/Site.lean). The Totality clause is formalized as totality_clause, with its site-indexed form totality_clause_site and its binder-free engine totality_of_isRestriction, and the Directed Gluing clause as directed_gluing_clause, with its engine directed_gluing_of_isRestriction and its uniqueness half directed_gluing_unique (FormalSystem/Semantics/Presheaf/Directed.lean); both are wrappers on thm:extension, and that module's docstring carries the measured choice record that separates them. The Determinism clause is formalized as the biconditional deterministic_iff_separated (FormalSystem/Semantics/DeterministicBridge.lean) over Presheaf.Separated and its choice-free half separated_of_deterministic (FormalSystem/Semantics/Presheaf/Determinism.lean), with the asymmetry that separatedness is strictly stronger than the validity of Determined on the frame recorded as separated_strictly_stronger (FormalSystem/Metalogic/Independence/BehSeparatedness.lean). All six citation sites record the cut. NOT PINNABLE, as for app:Structure
app:valid|DANGLING|NEVER EXISTED; earlier revisions cited it at a bogus line number, corrected to cor:perpetuity-valid
thm:M5-valid|DANGLING|fully COMMENTED OUT in the paper (2026-09-17 wave); retained above as a DANGLING entry; no live citation
cor:tm-decidability|DANGLING|fully COMMENTED OUT in the paper; retained above as a DANGLING entry
def:BL-model|DANGLING|label removed by the paper; retained above as a DANGLING entry
def:BLplus-defined|DANGLING|label removed when the paper collapsed BL^+ into BL; the defined temporal operators now sit inside def:BLplus-language's block. Retained above as a DANGLING entry
def:BLplus-semantics|DANGLING|label removed when the paper collapsed BL^+ into BL; the since/until truth clauses are now clauses of def:BL-semantics. Retained above as a DANGLING entry
def:TMplus-c|DANGLING|renamed by the paper to def:BX-r, which IS pinned; cited only where the tree records the rename
def:TMplus-d|DANGLING|renamed by the paper to def:BX-d, which IS pinned; cited only where the tree records the rename
def:TMplus-f|DANGLING|renamed by the paper to def:BX-z, which IS pinned; cited only where the tree records the rename
def:behavior-presheaf|DANGLING|the Ddef defining Beh(F)(l) as the convex histories on [0, l] with restriction along Tr p. app:Structure was cut from the paper IN FULL under an explicit % SECTION CUT record ("Topological and Categorical Structure" (app:Structure) in full) and the surviving commented block carries a bare % CHECK; the author has not finished reviewing it, and this anchor went with the cut. FORMALIZED as Beh and its presheaf action (FormalSystem/Semantics/Presheaf/Behavior.lean); the citation site records the cut. NOT PINNABLE, as for app:Structure
def:directed|DANGLING|label removed; the supseteq-directed definition was folded inline into def:frame's opening clause. Retained above as a DANGLING entry
def:interval-site|DANGLING|the Ddef defining the interval site Int(D): objects the positive cone, morphisms the translations Tr p, with the Johnstone coverage. app:Structure was cut from the paper IN FULL under an explicit % SECTION CUT record ("Topological and Categorical Structure" (app:Structure) in full) and the surviving commented block carries a bare % CHECK; the author has not finished reviewing it, and this anchor went with the cut. FORMALIZED as Obj/Tr/Tr.comp and the coverage trio (FormalSystem/Semantics/Presheaf/Site.lean); the citation site records the cut. NOT PINNABLE, as for app:Structure
def:strongest|DANGLING|label removed by the paper in the 2026-10-15 BX/TM demotion wave; Str survives as an \aitem{Str} key inside def:key-terms, with the L subscript dropped and the primed Str' notion gone. Retained above as a DANGLING entry. NO live in-tree citation: measured at retirement time, the only occurrence outside this file is the inert Check 1 entry at typst/sync-check-whitelist.txt:104, which suppresses nothing because no typst chapter cites the anchor any more. No docstring quotes its text
lem:fibers|DANGLING|label removed 2026-08-17; content absorbed into lem:admissible's proof; retained above
thm:BLplus-NextPrevious|DANGLING|label removed with the BL^+ fragment cluster. Retained above as a DANGLING entry
thm:BLplus-PastFuture|DANGLING|label removed with the BL^+ fragment cluster. Retained above as a DANGLING entry
thm:ConservativeExtension|DANGLING|NEVER a paper label; cited only where the tree records that it is not one
cor:after-negation-stable|DANGLING|the Cthm asserting that Stability-After(phi,top) -> (dstab-not-After(phi,psi) <-> dstab-After(phi,not-psi)) is valid over every task frame, and likewise with the universal Stability in place of both occurrences of the existential one. NOT IN THE TRACKED PAPER: it is cut material, living in appendix_cut_material.tex under the header "Negation under the event operators, stably", which this record does not track, so --resolve structurally cannot read it. Marked DANGLING on that ground rather than because the label went away, exactly as thm:nomic-primitive is. BOTH READINGS ARE FORMALIZED as after_negation_stable_dstab and after_negation_stable_stab (FormalSystem/PlusLanguage/PlusValidity.lean), stated natively in L+ rather than transported along ofFormula, which provably cannot carry a top-level stab (ofFormula_ne_stab); both instantiate the same language-generic TruthClauses.after_negation that after_negation_valid does. The citation sites record the cut
cor:deterministic-completeness|DANGLING|the Cthm asserting that the stability logic is sound and complete over the Deterministic task frames. NOT IN THE TRACKED PAPER: the only occurrence in possible_worlds.tex is inside a commented-out line, and the live \label sits in appendix_cut_material.tex under the header "The stability logic and its completeness over the deterministic frames", which this record does not track, so --resolve structurally cannot read it. Marked DANGLING on that ground rather than because the label went away, exactly as cor:after-negation-stable and thm:nomic-primitive are. The RESULT is in the tree under FormalSystem/Metalogic/Deterministic/ (detSoundness, detSoundnessDet and the completeness family). The citing docstring in FormalSystem/PlusLanguage/PlusReversal.lean does not cite the Cthm as an authority for anything it proves: it cites the one sentence of the Cthm's soundness half that states the extension of lem:time-reflection to the stability language, the sentence that module formalizes, and says in the same breath that the passage is cut material living in appendix_cut_material.tex
thm:nomic-primitive|DANGLING|the Tthm giving primitive-level forms of the nomic properties: clause (1) characterizes Static by a two-point equation on the relativized relation, clause (2) Lawful by a three-point condition, and clauses (3) and (4) restate them for partial histories and finite Z-time paths. NOT IN THE TRACKED PAPER: it is cut material, living in appendix_cut_material.tex under the header "Primitive-level characterization of the nomic frames", which this record does not track, so --resolve structurally cannot read it. Marked DANGLING on that ground rather than because the label went away. Clause (1) IS FORMALIZED as NomicFrame.static_iff_taskRel_eq (FormalSystem/Semantics/Nomic/Recovery.lean), which cites the clause by file and header, not as a paper anchor; clause (2) is not ported, since its three-point partial history needs a well-definedness argument with no precedent in the tree, and the cut note records (3) and (4) as having no consumer
thm:occurrence|DANGLING|renamed by the paper to cor:occurrence; cited only where the tree records the rename
thm:s4|DANGLING|folded by the paper into thm:s5; retained above as a DANGLING entry
thm:sym|DANGLING|folded by the paper into thm:s5; retained above as a DANGLING entry
```
<!-- KNOWN-ANCHORS:END -->

**Adding a row here is a decision, not a formality.** Before adding a `LIVE-UNPINNED` row, confirm
the anchor really does resolve to a non-commented `\label{}` in the live paper. Before adding a
`DANGLING` row, confirm it really does not, and fix the citation site to say so. If neither is
true, the citation is a typo and the fix is to correct the citation, not to add a row.

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

  > In this case, the conclusion of \textbf{\ref{thm:extension}} becomes effective without appeal
  > to Zorn's lemma: since $W$ is finite, the forward and backward orbits extending a bounded
  > convex history must each revisit a world state, so every bounded convex history extends to a
  > possible world that is eventually periodic in both directions--- a finite prefix plus a finite
  > cycle each way--- and is therefore finitely representable, licensing a finite certificate that
  > a given bounded history is a fragment of a possible world.

  Re-quoted 2026-09-07 from the live paper alongside the `def:world-history` vocabulary
  alignment: the footnote formerly read "bounded world history" in both places and now reads
  "bounded convex history", and it gained a comma after "In this case". This source is
  **untracked** — it carries no `sha256:` line and no manifest row, and is not read by
  `scripts/check-paper-definitions.sh` — so re-quoting it moves no pin and re-runs no checker.
  `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean`, which block-quotes the same
  footnote in its module docstring, was re-quoted in the same change.

- **What the formalisation preserves**: the doubly ultimately-periodic extension and the finite
  certificate, both in full. "Without appeal to Zorn's lemma" is preserved as *no Zorn* — an
  import-graph fact — and **not** as choice-freedom in Lean's sense, which is a claim about a
  different axiom. The measured accounting lives in `extend_periodic`'s own docstring.

### The alternative-semantics footnote (convex-index evaluation)

- **Location**: `JPL/possible_worlds.tex`, in the footnote attached to the discussion of
  evaluating `◇P p_w` at a time after a finished game has ended, immediately before the paper
  states logical consequence (at the time of recording, line 1106). No `\label`, no `\aitem`.
  It is recorded here as prose anchored to `def:logical-consequence`, the definition it proposes
  an alternative to.
- **Relied on by**: `FormalSystem/Semantics/ConvexTruth.lean`, which quotes it in its module
  docstring and transcribes it clause for clause as `TruthAtConvex`, `ValidC3` and
  `ConsequenceC3`; and the `FormalSystem/Metalogic/ConvexConsequence/` cluster,
  which determines what that alternative validates.
- **Text**:

  > Alternatively, one might evaluate sentences at any convex history $\tau$ together with a time
  > $x \in \dom{\tau}$, taking $\Box$ to quantify over all convex histories $\sigma$ where
  > $x \in \dom{\sigma}$, restricting $\Past$ and $\Future$ to the times in $\dom{\tau}$, and
  > adapting logical consequence to replace $D$ with $\dom{\tau}$.
  > Since evaluating sentences only at possible worlds excludes no course of events by
  > \textbf{\ref{thm:extension}}, the present account retains the stronger tense logic.

  Quoted 2026-09-21 from the live paper. Between the two sentences the source carries a
  **commented-out** third sentence (a `%` line), which is not part of the paper's text and is not
  quoted: it predicts that under this alternative the seriality axiom `TS` and its past dual
  fail at the final move of a finished game. The repository does not rely on that sentence; it
  proves the prediction instead (`refute_C3_serial_future`, `refute_C3_serial_past`).

  This source is **untracked**, and cannot be otherwise: a footnote carries neither a `\label`
  nor an `\aitem`, the two anchor kinds `resolve_text` supports, so a manifest row for it would be
  a dangling anchor. It carries no `sha256:` line and is not read by
  `scripts/check-paper-definitions.sh`. If the paper's wording moves, nothing here goes red; the
  quotation in `ConvexTruth.lean`'s module docstring and this entry must be re-quoted together
  by hand.

- **What the formalisation preserves**: all four clauses of the first sentence. "Any convex
  history `τ` together with a time `x ∈ dom τ`" is the pair of binders `τ.IsConvex` and
  `τ.domain x` on `ValidC3`; "`□` over all convex histories `σ` where `x ∈ dom σ`" is the `box`
  clause of `TruthAtConvex`, one-point histories included; "restricting `P` and `F` to the times
  in `dom τ`" is the domain conjunct on the witness and on the guard times of the `untl` and
  `snce` clauses, which is how the restriction reads for the paper's primitive `U` and `S`;
  "replace `D` with `dom τ`" is the final binder of `ValidC3` and `ConsequenceC3`. The second
  sentence is the paper's reason for *not* adopting the alternative, and the repository follows
  it: `TruthAt` and `SemanticConsequence` are untouched, and C3 is a relation defined beside
  them. C4 (`ValidC4`, interval indices only) and the cut-back box range `TruthAtConvexCut` are
  repository-native refinements with no counterpart in the footnote.

## Invocation from CI, skills or hooks — decision (CI wired 2026-09-17)

`scripts/check-paper-definitions.sh` now runs in `.github/workflows/ci.yml` as the step
`Check paper definitions (scripts/check-paper-definitions.sh)`. CI still has no visibility into
the maintainer's local `~/Philosophy/Papers/` checkout, a different repository that is not
vendored, so on the runner
the script takes its **skip-and-report-neutral** path: it prints `SKIP (neutral): paper not found
at ...` and exits 0 (see `docs/development/CI_CD_PROCESS.md`, "Wiring a New Check Script"). What CI
does enforce is that the record stays parseable, since a missing record file is still exit 2. The
real drift check runs wherever the paper is present, which means locally, by hand, as before.

A skill preflight hook for the `paper-refactor` topic remains the strongest candidate for automatic
local invocation and is still not implemented. A git pre-commit hook in this repository stays
rejected: commits here never touch the paper, so it would never fire on the event that causes drift.
