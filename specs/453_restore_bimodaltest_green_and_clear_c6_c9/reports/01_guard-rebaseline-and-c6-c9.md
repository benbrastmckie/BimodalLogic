# Research: restore `BimodalTest` green and clear C6 / C9

**Task type**: lean4
**Session**: sess_1787033965_d6c07f_453
**Dispatch**: 2 (orchestrator mode)
**HEAD at measurement**: `11ad049b8`
**Toolchain**: Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1`

---

## 1. Executive summary

Every claim in the task brief that could be checked mechanically was checked, and all of them
hold. Three additions to the brief's scope were found, all of them documentation-only and all of
them inside the same three files the brief already names:

1. **The seven guards are confirmed, exactly.** `lake build BimodalTest` exits 1 with exactly
   seven `#guard_msgs` docstring mismatches and no other error. `lake build` (FormalSystem alone)
   exits 0. The seven generated replacement strings are transcribed verbatim in §3 — the
   implementer should not need to re-run anything to obtain them, only to verify.

2. **The "stale expectations, not a regression" verdict is confirmed** on all four of the brief's
   lines of evidence, independently re-measured (§4). In particular W1 and W7 now generate
   *byte-identical* output, which is the invariant W7 exists to test, and the `P2 current` values
   recorded in the three in-source "Re-baseline record" headers are byte-identical to what Lean
   generates today (zero drift since 2026-08-11).

3. **Three stale-prose sites the brief does not name** must be repaired in the same commit or the
   files will contradict themselves after the re-record (§5.2). The most serious is
   `RegionGateProbe.lean:63-66`, whose module docstring still asserts "All nine rows report
   `gate=true`" — false for rows A, B, C and H. There is also a duplicated-sentence defect in the
   "Re-baselined in this file" line, present in six probe modules (three of them in scope).

4. **C6: all seven unmanifested modules compile cleanly** (`lake build <module>` exits 0 for each),
   so adding seven plain manifest lines clears C6 with no `broken:` prefix needed (§6). One
   correction to the brief: six of the seven are *already* compile-checked transitively, because
   C6 runs `lake build` on their manifested sibling aggregators, which imports them. Only
   `OuterGateFaithful` is genuinely compile-unchecked today.

5. **C9 is a one-line prose edit** whose surrounding context makes the durable-anchor replacement
   obvious: the "task 3" is an item in a numbered list *within the same docstring*, not a
   task-management reference at all (§7).

**No `.lean` semantics change is required anywhere.** Every edit this task needs is a docstring, a
comment, or a manifest line. The §5 "STOP" condition in the brief was not triggered.

---

## 2. Verified build state

```
$ lake build                 → exit 0
$ lake build BimodalTest     → exit 1
```

Error inventory from the `lake build BimodalTest` log — seven `#guard_msgs` mismatches, plus the
three per-module `Lean exited with code 1` lines and the final `build failed`, and nothing else:

| Module | `#guard_msgs` error line | Elaboration time |
|---|---|---|
| `Tests/BimodalTest/BoxSpreadProbe.lean` | 165 | 1.9 s |
| `Tests/BimodalTest/RegionGateProbe.lean` | 299, 330 | 2.3 s |
| `Tests/BimodalTest/TableauConformance.lean` | 873, 885, 910, 916 | 28 s |

Lint warnings elsewhere in the target (`linter.unusedSimpArgs` and friends) are non-fatal and
unrelated.

**C2 axiom baseline re-measured independently** (compiling a scratch `#print axioms` file against
the built library, exactly as `check-module-invariants.sh` does):

```
'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Byte-identical to the `AXIOM_BASELINE` heredoc in `scripts/check-module-invariants.sh:120-125`. C3
passes (sole structural sorry still `countermodel_discrete` in
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`). So the "C2 and C3 unchanged" verification
clause has a measured before-value to compare against.

**Structural invariants pass, current state** (`scripts/check-module-invariants.sh --no-build`):
B0, C3, C4, C5, C8, C10 PASS; C6 and C9 FAIL; C1 and C2 skipped by the flag.

---

## 3. The seven replacements, verbatim

These are Lean's generated `info:` strings, copied from the build log. **The docstring line is one
above the reported error line** in every case (the error is reported at the `#guard_msgs` command).

> **Match by content, not by line number.** The comment rewrites required by §5 will shift line
> numbers within each file. Every one of these seven old strings is unique in its file.

### 3.1 `Tests/BimodalTest/BoxSpreadProbe.lean` — row C (`.Dense`), docstring at line 164

```
-  /-- info: "OPEN spread=false anchor=false grid=false |W|=2 |T|=8" -/
+  /-- info: "OPEN spread=false anchor=false grid=false |W|=2 |T|=6" -/
```

Only `|T|` moves, `8 → 6`. `spread`, `anchor`, `grid` and `|W|` are unchanged — the three
conditions this probe exists to report are all still `false`, which is the row's whole content.

### 3.2 `Tests/BimodalTest/RegionGateProbe.lean` — row C (`.Dense`), docstring at line 298

```
-  /-- info: "OPEN |W|=2 |T|=8 total=true gate=true check=true cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3], [1, 1, 1, 1, 1, 1, 1, 1, 1]]" -/
+  /-- info: "OPEN |W|=2 |T|=6 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0]]" -/
```

This is the one row that changes a verdict rather than only a size. See §5.3.

### 3.3 `Tests/BimodalTest/RegionGateProbe.lean` — row H (row B under `.Dense`), docstring at line 329

```
-  /-- info: "OPEN |W|=2 |T|=10 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]" -/
+  /-- info: "OPEN |W|=2 |T|=6 total=true gate=false check=false cands=[[3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0]]" -/
```

Note rows C and H now generate the *same* string. The row-H comment's claim that "`|T|` is unmoved
at `10` here — the `◇(G q)` shape still forces the same density mints" is now false and is one of
the §5.2 repairs.

### 3.4 `Tests/BimodalTest/TableauConformance.lean` — W1, docstring at line 872

```
-  /-- info: total=true knownTimes=[9, 5, 3, 4, 8, 1, 6, 2, 0] constraints=[(6, 1), (9, 3), (9, 5), (8, 9), (1, 8), (6, 8), (2, 6), (3, 5), (4, 0), (0, 3), (0, 2), (0, 1)] incomparable=[] -/
+  /-- info: total=true knownTimes=[4, 7, 5, 6, 1, 2, 3, 0] constraints=[(2, 1), (2, 6), (2, 7), (7, 5), (6, 7), (1, 6), (2, 5), (4, 3), (3, 0), (0, 2), (0, 1)] incomparable=[] -/
```

### 3.5 `Tests/BimodalTest/TableauConformance.lean` — W3, docstring at line 884

```
-  /-- info: total=true knownTimes=[10, 3, 4, 7, 9, 8, 1, 0] constraints=[(7, 3), (7, 10), (9, 7), (8, 9), (1, 8), (3, 10), (4, 0), (0, 3), (0, 8), (0, 1)] incomparable=[] -/
+  /-- info: total=true knownTimes=[4, 8, 9, 2, 5, 6, 7, 1, 3, 0] constraints=[(8, 2), (8, 5), (6, 9), (8, 6), (7, 8), (1, 7), (5, 6), (2, 5), (4, 3), (3, 0), (0, 2), (0, 1)] incomparable=[] -/
```

W3 is the one row that **grows** (`|knownTimes|` 8 → 10), against the general shrinking trend. That
is consistent with the guard: `trivialEventWitnessed` changes *which* witnesses are minted, and
renumbering can leave a row with more surviving times, not fewer. It is not evidence against the
verdict, and W3 still reports `total=true incomparable=[]`.

### 3.6 `Tests/BimodalTest/TableauConformance.lean` — W6 (control), docstring at line 909

```
-  /-- info: total=true knownTimes=[3, 4, 5, 0, 2, 1] constraints=[(3, 0), (5, 3), (5, 0), (2, 4), (3, 1), (1, 2), (0, 1)] incomparable=[] -/
+  /-- info: total=true knownTimes=[3, 4, 0, 2, 1] constraints=[(4, 0), (2, 3), (1, 2), (0, 1)] incomparable=[] -/
```

### 3.7 `Tests/BimodalTest/TableauConformance.lean` — W7 (W1 at fuel 2000), docstring at line 915

```
-  /-- info: total=true knownTimes=[9, 7, 5, 3, 4, 8, 1, 6, 2, 0] constraints=[(6, 1), (6, 8), (6, 9), (7, 3), (7, 5), (9, 7), (8, 9), (1, 8), (6, 7), (2, 6), (3, 5), (4, 0), (0, 3), (0, 2), (0, 1)] incomparable=[] -/
+  /-- info: total=true knownTimes=[4, 7, 5, 6, 1, 2, 3, 0] constraints=[(2, 1), (2, 6), (2, 7), (7, 5), (6, 7), (1, 6), (2, 5), (4, 3), (3, 0), (0, 2), (0, 1)] incomparable=[] -/
```

**W7's new value is byte-identical to W1's new value** (§3.4). See §4.3.

---

## 4. The verdict re-verified: stale expectations, not a regression

The brief's four lines of evidence were each re-measured rather than taken on trust.

### 4.1 The value changes match `trivialEventWitnessed`'s documented signature

Six of the seven rows shrink their time domain (`|T|` 8→6 and 10→6; `|knownTimes|` 9→8, 6→5) with
constraint lists shrinking correspondingly; one (W3) renumbers upward. That is the "fewer known
times, renumbered indices" signature the three in-source Re-baseline records already attribute to
the guard for the 29 rows they *did* re-record. The seven excluded rows move the same way.

### 4.2 Every asserted property still holds

| Row | Property the row exists to assert | Still holds? |
|---|---|---|
| W1, W3, W6, W7 | `total=true`, `incomparable=[]` | Yes, all four |
| BoxSpread C | `spread=false anchor=false grid=false` | Yes, verbatim; only `\|T\|` moved |
| RegionGate C, H | the probe's own `gate` agrees with the library's `check` | Yes — `false`/`false` on both |

The RegionGate rows are the interesting case: the module's designed cross-check is `gate` (computed
in the probe) against `check` (computed by the library). Agreement is the invariant; the shared
*value* is the measurement. Both rows still agree.

### 4.3 W1 ≡ W7 — the row's own stated invariant, now satisfied

W7's comment (`TableauConformance.lean:913-914`) reads: "W1 at fuel 2000, five times W1's own
`linearityFuel`. **Identical**, so the flip to `total=true` is `timeLinearity` firing and not a
budget artifact."

- The **pinned** pair is not identical (W1 has 9 known times, W7 has 10, and their constraint
  lists differ).
- The **generated** pair is byte-identical (§3.4 vs §3.7).

So current engine behaviour satisfies the invariant the row was written to test, and the recorded
expectation does not. This is the strongest single item of evidence and it should be quoted in the
attribution note.

### 4.4 The pinned values were never build-verified, and have not drifted since

The `P2 current` values enumerated in the three in-source "Re-baseline record" headers
(`TableauConformance.lean:126-138`, `RegionGateProbe.lean:120-124`, `BoxSpreadProbe.lean:104`)
were compared against today's generated output:

- `BoxSpreadProbe:165` — full string, exact match.
- `RegionGateProbe:299` and `:330` — full strings, exact match.
- `TableauConformance:910` — full string, exact match.
- `TableauConformance:873`, `:885`, `:916` — recorded truncated with a trailing `...`; every
  recorded prefix matches today's output exactly.

Zero drift since the three-point measurement of 2026-08-11. The seven values are stable, which is
what makes re-recording them safe rather than chasing a moving target.

The brief's provenance claims (last known-green `1b7636703`; red in the `1b7636703..d49b977c0`
window; `59faf7304` recording the target as unmeasured; `86eb8963c` taking 40 mismatches → 7) were
**taken from the brief and not independently bisected** — they are historical attribution, they do
not gate any edit, and re-deriving them would cost several full builds. The in-source headers and
today's measurement are the load-bearing evidence, and both were checked directly.

---

## 5. Documentation work: what must change beyond the seven docstrings

### 5.1 The three "Re-baseline record" exclusion blocks

Each of the three files carries a `**EXCLUDED — left pinned and unedited**` block that enumerates
exactly these rows and states they *stay pinned*. After the re-record those blocks are false and
must be rewritten:

| File | Block location | Rows enumerated |
|---|---|---|
| `Tests/BimodalTest/TableauConformance.lean` | block 69-139, exclusion list 104-138 | 483, 513, 578, **873, 885, 910, 916** |
| `Tests/BimodalTest/RegionGateProbe.lean` | block 75-125, exclusion list 110-124 | **299, 330** |
| `Tests/BimodalTest/BoxSpreadProbe.lean` | block 59-105, exclusion list 94-104 | **165** |

Note `TableauConformance`'s block also lists 483, 513 and 578, each recorded as
`P2 current: (now matches the pinned value — the guard repaired this row)`. Those three are **not**
in the failing set and must not be touched beyond whatever restructuring the rewrite does; they are
already green.

The rewrite must, per the brief's deliverable (b):
- attribute the seven to the 2026-08-10/11 engine window (semantics refactor + tableau-engine
  work that rewrote `Tableau.lean` and `Saturation.lean` and added
  `Verified/Termination/MintBound.lean`), **not** to `trivialEventWitnessed`, which is the
  separately-owned change the exclusion was protecting;
- record that W1 and W7 now agree, as §4.3 describes;
- confirm RegionGate row C's gate loss, as §5.3 describes;
- record that the values have been stable since the 2026-08-11 measurement (§4.4), which is what
  makes this a settlement of recorded debt rather than a fresh baseline.

### 5.2 Stale narrative prose the brief does not name

These are in the same three files and will contradict the re-recorded values if left:

| Site | Current text | Why stale |
|---|---|---|
| `RegionGateProbe.lean:63` | "**All nine rows report `gate=true`**" | Rows A, B, C, H report `gate=false`. Rows A/B/H were already false before this task; row C joins them now. |
| `RegionGateProbe.lean:65-66` | "row A has `\|T\| = 7` and three eligible labels per region; row B's second world falls to one" | Row A is now `\|T\|=4` with world 1 all-zero; row B likewise. Both were re-baselined by `86eb8963c`; the summary paragraph was not updated with them. |
| `RegionGateProbe.lean:325-327` | row H: "Unlike row C, `\|T\|` is unmoved at `10` here" | H is now `\|T\|=6`, and C and H generate identical strings. |
| `RegionGateProbe.lean:292-294` | row C: "The one moved two-world row that keeps its gate ... `\|T\|` shrinks `10 → 8` ... world 1's per-region count falls `3 → 1` rather than to `0`" | Directly contradicted: `\|T\|=6`, world 1 vector is all-zero, gate lost. |
| `BoxSpreadProbe.lean:161-163` | row C: "`\|T\|` shrinks to `8`" | `\|T\|=6`. |
| `BoxSpreadProbe.lean:29` | "**The anchor and the grid are now false as well** (rows A, B, C)" | Rows A and B now report `grid=true` (both at `\|T\|=4`). Pre-existing staleness from the `86eb8963c` re-baseline, not created by this task, but in the same paragraph the reader will consult. |
| `TableauConformance.lean:806-807` | "W1-W4 order eight to ten times each" | W2 now orders 7. A one-word fix; low priority. |

The `RegionGateProbe.lean:63-66` "measured verdict" paragraph is the one that genuinely misleads a
reader and should be treated as required, not optional.

### 5.3 RegionGateProbe row C's gate loss — the confirmation the brief asks for

The brief asks for one sentence of confirmation, not an investigation. The reading holds, and here
is the evidence for it:

1. **The gate is a declared over-approximation.** `RegionGateProbe.lean:53-59` heads a section
   titled "Two deliberate over-approximations" and states they "make the gate **harder** to pass
   than the induction will need, so passing it is informative and **failing it would not by itself
   refute anything**." Row C failing is therefore within the module's own declared tolerance.

2. **The cause is already documented and already pinned by three sibling rows.** The unsound
   cross-world temporal copies (the six group-3 blocks in `.boxNeg`/`.diamondPos`) were the only
   route by which `T(Gφ)`/`T(Hφ)` reached a freshly minted world; with them gone a minted world
   receives none. Rows A, B and H — every other two-world row in the file — already pin
   `gate=false` with world 1's candidate vector all-zero for exactly that reason.

3. **The resulting rule is clean and checkable**: after this task, *every* two-world row in
   `RegionGateProbe.lean` reports `gate=false` with world 1 all-zero (A `:279`, B `:290`,
   C `:298`, H `:329`), and *every* single-world row reports `gate=true` (D `:305`, E `:311`,
   F `:316`, G `:321`, I `:334`). Row C was the last two-world holdout; the file is now uniform.
   That uniformity is a better statement of the finding than "one row keeps its gate" ever was.

4. **The probe's own cross-check still agrees.** `gate` (probe-computed) and `check`
   (library-computed) both moved to `false` together on row C, so the module's designed
   self-consistency measurement is unbroken.

Nothing here is a new defect; row C simply joined the group its siblings already occupy.

### 5.4 A shared template defect worth fixing in passing

Six probe modules carry a duplicated sentence fragment in their "Re-baselined in this file" line:

```
... at line(s) N, M — each carrying its own `RE-BASELINED (guard)` note with the old and new
value.— each carrying its own `RE-BASELINED (guard)` note with the old and new value.
```

Occurrences: `TableauConformance.lean:102`, `RegionGateProbe.lean:108`, `BoxSpreadProbe.lean:92`
(all three in scope), plus `UntlSnceCopyProbe.lean:136`, `RayRegionProbe.lean:88`,
`TemporalWitnessProbe.lean:222` (out of scope). It is a copy-paste artifact of the block that
generated these headers. Fixing the three in-scope ones is free — the block is being rewritten
anyway. The other three should be left alone or handled separately.

---

## 6. C6: the seven unmanifested unreachable modules

### 6.1 Confirmed failure

```
FAIL  C6   7 unreachable live module(s) absent from scripts/module-invariants-manifest.txt
            FormalSystem.Metalogic.Algebraic.BooleanStructure
            FormalSystem.Metalogic.Algebraic.InteriorOperators
            FormalSystem.Metalogic.Algebraic.LindenbaumQuotient
            FormalSystem.Metalogic.Algebraic.UltrafilterMCS
            FormalSystem.Metalogic.Bundle.Construction
            FormalSystem.Metalogic.SoundnessLemmas.CoValidity
            FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGateFaithful
```

### 6.2 All seven compile cleanly — no `broken:` prefix is needed

Each was built in isolation with the same command C6 uses (`lake build <module>`, which builds
transitive dependencies first):

| Module | `lake build` exit | `error:` lines |
|---|---|---|
| `FormalSystem.Metalogic.Algebraic.BooleanStructure` | 0 | 0 |
| `FormalSystem.Metalogic.Algebraic.InteriorOperators` | 0 | 0 |
| `FormalSystem.Metalogic.Algebraic.LindenbaumQuotient` | 0 | 0 |
| `FormalSystem.Metalogic.Algebraic.UltrafilterMCS` | 0 | 0 |
| `FormalSystem.Metalogic.Bundle.Construction` | 0 | 0 |
| `FormalSystem.Metalogic.SoundnessLemmas.CoValidity` | 0 | 0 |
| `FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGateFaithful` | 0 | 0 |

So seven plain (unprefixed) manifest lines will clear C6's "absent from manifest" failure **and**
pass C6's compile-check pass in the same run. No entry needs the `broken:` prefix.

### 6.3 Structural cause, per module — the justification the manifest lines need

The manifest's own rules require each entry to say why the module is unreachable. Measured
importer graph:

**Six of the seven are children of an already-manifested unreachable aggregator.** The manifest
already lists `FormalSystem.Metalogic.{Core,Bundle,Algebraic,SoundnessLemmas}` as sibling
aggregators that "deliberately have no importer". A child reached *only* through such an aggregator
inherits its unreachability:

| Module | Only importers | Note |
|---|---|---|
| `Algebraic.BooleanStructure` | `Algebraic.lean`, `Algebraic/InteriorOperators.lean` | both unreachable |
| `Algebraic.InteriorOperators` | `Algebraic.lean`, `Algebraic/UltrafilterMCS.lean` | both unreachable |
| `Algebraic.LindenbaumQuotient` | `Algebraic.lean`, `Algebraic/BooleanStructure.lean` | both unreachable |
| `Algebraic.UltrafilterMCS` | `Algebraic.lean` only | |
| `Bundle.Construction` | `Bundle.lean` only | |
| `SoundnessLemmas.CoValidity` | `SoundnessLemmas.lean` only | |

The contrast case that proves the pattern: `Algebraic/FlowFrame.lean`, the fifth file in the same
directory, is imported directly by `BXCanonical/Completeness.lean:13` and
`BXCanonical/Chronicle/ChronicleMonadicBridge.lean:15`, so it *is* reachable and correctly absent
from the manifest. The four `Algebraic/` modules above have no such direct consumer.

**The seventh is a genuine orphan.** `OuterGateFaithful` has **no importer anywhere in the live
tree**. Its sibling aggregator `Kamp/NfMultiAnchorBridge.lean` *is* reachable (imported by
`Kamp/KampPrior.lean:10`) and imports `NfMultiAnchorBridge.OuterGate` at line 141 — but not
`OuterGateFaithful`. The only reference to it in the tree is prose:
`FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean:246` names it as one of "the
bridge interface and the six trichotomy arms" of the faithful re-base. Its own module docstring
describes it as restating `OuterGate.lean` against the faithful `HasFaithfulDedekindINF`/`SUP`
carriers.

### 6.4 One correction to the brief

The brief says `UltrafilterMCS` "at 81 occurrences is the single largest `FrameClass.Base` consumer
in the tree and is currently compile-unchecked." The first half stands; the second is not quite
right. C6's compile-check runs `lake build FormalSystem.Metalogic.Algebraic` on the manifested
aggregator, and `lake build` compiles transitive dependencies — so `UltrafilterMCS` and its three
`Algebraic/` siblings, `Bundle.Construction` and `SoundnessLemmas.CoValidity` are all **already
compile-checked today**, indirectly, on every full C6 run.

`OuterGateFaithful` is the only one of the seven that is genuinely unchecked: no reachable module
and no manifest entry causes it to be built. Adding it to the manifest is a real coverage gain, not
just a bookkeeping fix. This does not change the recommended action (all seven still need manifest
lines, because C6 fails on *absence from the manifest* independently of compile coverage) — it only
changes what the justification comment should claim.

### 6.5 Recommended action, and the alternative that is out of scope

**Recommended**: add all seven as plain manifest entries under two commented blocks, one for the
six aggregator children and one for the orphan, following the existing BiLasso block's precedent
(that block already lists every child *and* its aggregator, so listing children is the established
convention here, not a new one).

**The alternative, deliberately not recommended**: `OuterGateFaithful` could instead be *wired in*
by adding one `import` line to `Kamp/NfMultiAnchorBridge.lean` — arguably the more correct repair,
since every one of its ~38 siblings in that directory is already reachable and the aggregator's
own comments explain at length why edges are landed there rather than left to rot. But that is a
`.lean` build-graph change, which the task's §5 verification clause explicitly forbids ("every edit
is a docstring, a comment, or a manifest line"), and it would pull the module into `lake build` with
whatever elaboration cost that carries. **Recommendation: manifest it now with a comment recording
that wiring it into `NfMultiAnchorBridge.lean` is the eventual fix, and scope that as a separate
task.**

### 6.6 Provenance (informational)

File-addition commits: the four `Algebraic/` modules and `Bundle/Construction` landed in
`5359fef7d` (2026-07-26) alongside `Algebraic.lean` itself; `SoundnessLemmas/CoValidity` in
`62c9cb1db` (2026-07-28); `OuterGateFaithful` in `c443b4fd9` (2026-07-28). The manifest was last
edited `d5eac65c7` (2026-08-17). I did **not** bisect when C6 first went red — it does not gate any
edit, and the current-state measurement is what the fix needs.

---

## 7. C9: the single task-number citation

**Check definition** (`scripts/check-module-invariants.sh:449-451`): case-insensitive grep over
`--include='*.lean' --include='*.md'` under `FormalSystem`, excluding `/Boneyard/`, for

```
\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b
```

**Sole hit**: `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean:185`

```
This is the plan's task 3, discharged in full. Every step of the chartered composition that the
tree supports is taken here; the only thing standing between this and an unconditional
`uSExpressivelyCompleteOverDensePrior` is the obligation above.
```

**The context makes the fix trivial.** The docstring immediately above (lines ~228-250 of the same
file, in the `**Source status**` region) contains a numbered list `1.` … `4.` enumerating the four
pieces of the faithful re-base — item 3 being "the bridge interface and the six trichotomy arms".
The "task 3" in the C9-flagged sentence refers to *that list item*, not to a task-management
number. It is a false positive against the rule's intent but a true positive against its regex, and
it is trivially rewritten:

> `This is item 3 of the composition enumerated above, discharged in full.`

Any wording works provided it does not match the regex. Concretely, avoid `task N`, `tasks N`,
`task #N`, `task-N` in any case. Safe substitutes: "item 3", "step 3", "the third piece", "the
bridge-interface rung".

**Implementation warning**: the write-time hook `validate-no-task-references.sh` blocks writes to
non-`specs/**` paths containing task-number patterns. Editing this file with a replacement that
still contains `task 3` will be blocked at the tool boundary, not merely flagged by C9.

---

## 8. Verification plan

Run in this order; the first three are cheap, the last is the expensive one.

1. `bash scripts/check-module-invariants.sh --no-build` — expect C6 and C9 to flip to PASS,
   B0/C3/C4/C5/C8/C10 unchanged. Catches both invariant fixes in ~seconds without a build.
2. `lake build` — expect exit 0 (unchanged; no `FormalSystem/` file is edited except the one C9
   comment, which is inside a docstring).
3. `lake build BimodalTest` — expect exit 0. Iterate here if any guard still mismatches.
4. `bash scripts/check-module-invariants.sh` (full, with build) — expect C1 both lines PASS, C2
   matching the baseline in §2, C3 PASS, C6 PASS on all four of its sub-assertions (manifested /
   no phantom / no stale-reachable / all compile), C9 PASS.

**Regeneration**: there is no script. `scripts/check-evidence-probes.sh` compiles the sorry-free
evidence probes and is unrelated; `scripts/check-module-invariants.sh` guards axiom baselines and
module reachability, not `#guard_msgs`. The process is manual: run the module, copy the generated
`info:` line into the docstring. This report's §3 supplies all seven generated lines so that step
should be a transcription, not a measurement.

**Iteration cost**: `BoxSpreadProbe` ~1.9 s, `RegionGateProbe` ~2.3 s, `TableauConformance` ~28 s
incremental (the brief's ~49 s figure is a cold-ish upper bound; 28 s was measured on this run).
Prefer per-module iteration (`lake build BimodalTest.BoxSpreadProbe` etc.) over the whole target
while converging.

**STOP condition (from the brief, unchanged)**: if any guard cannot be made to pass by re-recording
alone, stop and report rather than touching the engine. Nothing found in this research suggests
that will happen — all seven generated values are stable and were reproduced byte-for-byte against
the values recorded on 2026-08-11.

---

## 9. Risks and notes for the implementer

1. **Line numbers will shift.** The §5 comment rewrites change line counts in all three files, and
   the "Re-baseline record" headers cite line numbers (`at line(s) 149, 158`, `at line(s) 280,
   291`, etc.). Those citations will themselves go stale as the file is edited. Do the docstring
   re-records first, then the narrative rewrites, then fix the line-number citations last against
   the final file — or drop the line-number citations in favour of row letters, which are stable.

2. **The seven strings are order-sensitive.** `knownTimes` and `constraints` are printed in the
   engine's own list order, not sorted. Copy them verbatim; do not normalise, re-sort, or reflow.
   `#guard_msgs` compares the rendered message, and `TableauConformance`'s rows use
   `#eval IO.print`, so there is no trailing newline to add or drop.

3. **Do not touch the 29 rows re-recorded by `86eb8963c`**, nor `TableauConformance`'s lines 483,
   513, 578 (which the exclusion block lists as already self-repaired). Only the seven in §3 are
   in scope.

4. **`BoxSpreadProbe.lean:29`'s stale `grid` claim (§5.2) predates this task.** Fixing it is a
   correct, safe comment edit, but if the implementer wants to keep the diff tightly scoped to the
   seven rows, this is the one §5.2 item that can defensibly be deferred. `RegionGateProbe:63-66`
   cannot — it will directly contradict the row-C value being landed.

5. **C6's manifest comments are load-bearing documentation**, not decoration: the file's own header
   states that wiring a module into the build graph means *deleting* its line, and C6 fails if a
   manifest entry names a reachable module. The new block must say what would have to change for
   the lines to be removed.

---

## 10. References

**Source files to edit**
- `Tests/BimodalTest/TableauConformance.lean` — Re-baseline record block 69-139; W-rows at docstrings 872,
  884, 909, 915; narrative at 806-807
- `Tests/BimodalTest/RegionGateProbe.lean` — module docstring 63-66; Re-baseline record block 75-125; rows at
  docstrings 298, 329; row narratives 292-294, 325-327
- `Tests/BimodalTest/BoxSpreadProbe.lean` — module docstring 29; Re-baseline record block 59-105; row at
  docstring 164; row narrative 161-163
- `scripts/module-invariants-manifest.txt` — add seven entries with justification block(s)
- `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean:185` — C9 prose

**Checks and their definitions**
- `scripts/check-module-invariants.sh` — C1 `:91-110`, C2 `:113-158`, C3 `:161-193`,
  C6 `:324-388`, C9 `:443-458`
- `scripts/lib/task-reference-patterns.sh`, `.claude/rules/no-task-references-in-deliverables.md`,
  `.claude/context/standards/task-reference-exemptions.md` — the C9 rule and its exemptions

**Context consulted**
- `FormalSystem/Metalogic/Decidability/Tableau.lean` — `trivialEventWitnessed`, the owner of the
  29 already-re-recorded rows (not of these seven)
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/BoxSaturation.lean` — the three `Bool`
  conditions `BoxSpreadProbe` reports
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean:141` — imports `OuterGate`,
  not `OuterGateFaithful`
