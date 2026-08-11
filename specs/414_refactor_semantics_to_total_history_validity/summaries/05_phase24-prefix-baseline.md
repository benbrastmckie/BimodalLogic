# Phase 24 — Pre-fix baseline capture and narrowed verification target

**Status**: COMPLETED. This phase edited no Lean file. It is a measurement record only.

**Measured on**: 2026-08-11, green tree, branch `main`, HEAD `b5a4c6056`
(`task 414: revise plan (v4) — seriality-witness termination fix`).

**Purpose**: freeze what the tree and the probe suite say *before* the `trivialEventWitnessed`
guard lands (Phase 25), so that the Phase 29 re-baseline is a diff against a measurement rather
than against memory, and so that the ten pre-existing `#guard_msgs` mismatches are enumerated
before anything can launder them into that re-baseline.

---

## 1. `check-paper-definitions.sh` — outcome case (b), PASS

```
[paper-definitions] notice: possible_worlds.tex changed (source: live working tree,
new checksum efd0503ce905545fe8bbff5751081ee54e35da152ec2c93c412cbf8f2b07919f,
last-touching commit a042869d54710d7d052adfa79f12ba091ef9f204)
but all 26 recorded definitions are unchanged -- pass.
```

| Field | Value |
|---|---|
| Outcome case | **(b)** — source file changed, all recorded definitions unchanged, pass |
| Exit code | `0` |
| Recorded definition count | **26** |
| Case (c) STOP triggered? | No |

---

## 2. Tree-wide `lake build` baseline — matches expected 2331 / 1 / 0

| Metric | Expected (plan) | Measured | Verdict |
|---|---|---|---|
| Job count | 2331 | **2331** | MATCH |
| Live non-Boneyard `sorry` | 1 | **1** | MATCH |
| Strict `axiom <ident>` outside Boneyard | 0 | **0** | MATCH |

- `Build completed successfully (2331 jobs).`, exit `0`. Reproduced twice (cold-ish and warm),
  same job count both times.
- The single live non-Boneyard sorry is
  **`FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1084`**. Measured via
  `.claude/scripts/lean-sorry-census.sh FormalSystem/`, filtered on `Boneyard`. Stripper reports
  161 sorries tree-wide; 160 of those are under `FormalSystem/Boneyard/**`.
- Strict axiom census used `^axiom +<ident> *[:({\[]`. A naive `^axiom ` grep yields three hits
  (`Semantics/Extension/Extension.lean:175`, `Semantics/FrameAxioms.lean:22`, `:262`); all three
  were inspected and are **wrapped docstring prose** ("axiom of choice", "axiom it consumes…",
  "axiom ranges over"), not declarations. Strict declaration count is 0.

**Caveat on the census cross-check.** `lean-sorry-census.sh --cross-check` reported
`cross_check: MISMATCH (stripper=161, compiler=0)`. The `compiler=0` figure is an artifact of a
fully-cached incremental build — Lean does not re-emit `declaration uses 'sorry'` warnings for
modules it did not recompile. It is **not** evidence that the tree has zero sorries. The
authoritative live figure here is the source-level one: **1**.

---

## 3. `BoxNegReachabilityProbe.lean` — verbatim current expectation text, rows 1-12

Source text only. **The probes were not run**; `lake build BimodalTest` was not invoked
(see §5).

| Row | Expectation line | Verbatim expectation | `#eval` subject |
|---|---|---|---|
| 1 | `:101` | `/-- info: true -/` | `rulePos .negPos < rulePos .boxNeg` |
| 2 | `:109` | `/-- info: true -/` | `rulePos .boxNeg < rulePos .impPos` |
| 3 | `:115` | `/-- info: true -/` | `rulePos .boxNeg < rulePos .allFuturePos` |
| 4 | `:143` | `/-- info: true -/` | `reached.all fun bo => bo.1.contains (SignedFormula.pos gp {world := 0, time := 0})` |
| 5 | `:161` | `/-- info: true -/` | `reached.any fun bo => bo.1.contains (SignedFormula.neg gp {world := 1, time := 0})` |
| 6 | `:172` | `/-- info: false -/` | `reached.any fun bo => clashAtFreshWorld bo.1` |
| 7 | `:181` | `/-- info: (1, 1) -/` | `(reached.length, (reached.filter fun bo => !isClosed bo.1 .Base).length)` |
| 8 | `:192` | `/-- info: none -/` | `(reached.head?.bind fun bo => findClosure bo.1 .Base).map …` (tags 1/2/3) |
| 9 | `:219` | `/-- info: (0, 0) -/` | `buildTableau (gp.imp gp.box) 1000 .Base` → `(0,0)`/`(1,len)`/`(2,len)` |
| 10 | `:240` | `/-- info: (false, false, true, false, true) -/` | `decide (gp.imp gp.box)` → `(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)` |
| 11 | `:249` | `/-- info: false -/` | `(decide (gp.imp gp.box)).getCountermodel?.isSome` |
| 12 | `:258` | `/-- info: false -/` | `isValid (gp.imp gp.box)` |

**Plan Scope-Hypothesis claim (iii) — CONFIRMED, no correction.** Rows 9-12 read exactly
`(0, 0)`, `(false, false, true, false, true)`, `false`, `false`.

**Expected-after values declared by report 05 §7** (recorded here so the Phase 29 diff is
checkable; these are *predictions*, not measurements):

| Row | Current | Expected after fix (report 05 §7) |
|---|---|---|
| 9 | `(0, 0)` | `(2, N)`, `N` ≈ 50 at `.Base` — exact `N` must be measured, not predicted |
| 10 | `(false, false, true, false, true)` | `(false, true, false, false, false)` — `.invalid` |
| 11 | `false` | `true`, **conditional on `extractCountermodelSimple` succeeding — unverified** |
| 12 | `false` | stable under both `.fuelExhausted` and `.invalid` |
| 4-8 | as above | may move: rows 4-8 read `reached := run 12` (`:138`); rows 7 and 8 are the exposed ones |

---

## 4. `CrossWorldPropagationProbe.lean` — verbatim current expectation text, rows A-F

| Row | Expectation line | Verbatim expectation | `#eval` subject |
|---|---|---|---|
| A | `:75` | `/-- info: false -/` | `isValid ((Formula.someFuture p).neg.imp ((Formula.someFuture p).neg.box))` |
| B | `:82` | `/-- info: false -/` | `isValid ((Formula.allFuture p).imp ((Formula.allFuture p).box))` |
| C | `:89` | `/-- info: false -/` | `isValid ((Formula.somePast p).neg.imp ((Formula.somePast p).neg.box))` |
| D | `:97` | `/-- info: true -/` | `isValid (p.imp p)` — control, genuine validity |
| E | `:102` | `/-- info: false -/` | `isValid (p.imp q)` — control, genuine invalidity, no temporal content |
| F | `:123` | `/-- info: (false, false, true, false, true) -/` | `decide ((Formula.allFuture p).imp ((Formula.allFuture p).box))` → 5-tuple |

Row F is the deliberate duplicate of `BoxNegReachabilityProbe` row 10; rows A-E all call
`isValid` and therefore cannot distinguish `fuelExhausted` from `invalid`. Report 05 §7 predicts
row F moves from the `fuelExhausted` tuple to the `.invalid` tuple.

---

## 5. The ten pre-existing `#guard_msgs` mismatches — EXCLUDED BY NAME from any re-baseline

These ten rows are a **separate, still-declined item**. They are excluded by name from the Phase
29 re-baseline: no re-baseline in Phase 29.2 may absorb, silence, or re-record any of them.

| File | Total `#guard_msgs` rows in file | Pre-existing mismatches | Row-level locator |
|---|---|---|---|
| `Tests/BimodalTest/TableauConformance.lean` | 29 (verified by count) | 7 | `[UNVERIFIED]` — deferred, see below |
| `Tests/BimodalTest/RegionGateProbe.lean` | 10 (verified by count) | 2 | `[UNVERIFIED]` — deferred, see below |
| `Tests/BimodalTest/BoxSpreadProbe.lean` | 5 (verified by count) | 1 | `[UNVERIFIED]` — deferred, see below |
| **Total** | 44 | **10** | |

**The file-level denominators are measured** — 29 / 10 / 5 come from a direct
`grep -c '#guard_msgs'` on the green tree and independently corroborate the plan's
"7 of 29 / 2 of 10 / 1 of 5" phrasing.

**Row-level identification is `[UNVERIFIED]`, deferred to Phase 29.1's measurement.**
Reason, stated plainly and not guessed at: identifying *which* seven / two / one rows mismatch
requires running the suite, i.e. `lake build BimodalTest`, which is prohibited (§5) and currently
unusable. Two source-level routes to identify them without running were attempted and both came
up empty:

1. A grep across all three files for in-source mismatch annotations
   (`mismatch|pre-existing|stale|known.fail|does not match|out of date|not re-baselined|XFAIL|expected to fail`)
   returned **zero hits** — the files carry no marker distinguishing a mismatching row.
2. Report 05 (`reports/05_seriality-witness-nontermination.md:469-470, :481, :595-596`) names the
   three files and the 7/2/1 split but does **not** pin the individual rows; §7 explicitly records
   that measuring rows in these files "was not measured" and requires `lake build BimodalTest`.

Phase 29.1 owns this measurement. Until it lands, the exclusion is enforceable at file level
(any change to a `#guard_msgs` expectation in these three files is presumptively out of scope for
the Phase 29 re-baseline and must be justified against the Phase 29.1 measurement).

---

## 6. Narrowed verification targets in force until Phase 29

| Fact class | Gate |
|---|---|
| Tree-wide facts | `lake build` (default `FormalSystem` target) — measured green at 2331 jobs |
| Module-local facts (Phase 25/26) | `lake build FormalSystem.Metalogic.Decidability.Tableau` |
| Module-local facts (Phase 25/26) | `lake build FormalSystem.Metalogic.Decidability.Saturation` |

**Standing prohibition.** `lake build BimodalTest` **must not be invoked before Phase 29.1.**
Reason: `Tests/BimodalTest/BoxNegReachabilityProbe.lean`'s `#eval` pinned a core for >45 minutes
and was killed twice. Its outcome is therefore recorded here as
**`[UNVERIFIED] — not run, by hard constraint`**, never as a guessed value. Phase 29.1 owns
actually running it, after the fix lands.

Also in force and **not** relaxed by this phase: no probe file may be weakened, deleted,
`sorry`-ed, fuel-lowered, or excluded from the build; no probe expectation may be re-baselined
before Phase 29.2, which applies the re-baseline with attribution to
`FormalSystem/Metalogic/Decidability/Tableau.lean` (not `Saturation.lean`, not the semantics
refactor).

---

## 7. Plan-time census re-run on the green tree — CONFIRMED, no corrections

### 7.1 `witnessPresent` occurrence census

Command:
`grep -rn "witnessPresent" --include=*.lean FormalSystem/ Tests/ | grep -v Boneyard | awk -F: '{print $1}' | sort | uniq -c`

| File | Plan-time claim | Measured | Verdict |
|---|---|---|---|
| `…/Decidability/Verified/Termination/MintBound.lean` | 111 | **111** | MATCH |
| `…/Decidability/CountermodelExtraction.lean` | 11 | **11** | MATCH |
| `…/Decidability/Verified/Bridge/TemporalSaturation.lean` | 10 | **10** | MATCH |
| `…/Decidability/Verified/Termination/Fuel.lean` | 6 | **6** | MATCH |
| `…/Decidability/Tableau.lean` | 5 | **5** | MATCH |
| `…/Decidability/Verified/Bridge/PropSaturation.lean` | 1 | **1** | MATCH |
| `…/Decidability/Verified/Bridge/BoxSaturation.lean` | 1 | **1** | MATCH |
| **Total** | 145 | **145** | MATCH |

**Both spellings checked, per lesson 4.** The fully-qualified spellings
(`Tableau.witnessPresent`, `Decidability.witnessPresent`,
`FormalSystem.Metalogic.Decidability.Tableau.witnessPresent`) have **0 occurrences** anywhere
outside Boneyard. All 145 occurrences are the bare spelling. No divergence to correct.

### 7.2 `MintBound.lean` / `Fuel.lean` locations — CONFIRMED

Both are under `Verified/Termination/`, not `Verified/Bridge/`:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`

`Verified/Bridge/` contains 17 files and neither of these two.

### 7.3 `PropSaturation.lean` / `BoxSaturation.lean` term-level occurrences — CONFIRMED: none

Plan claim (ii) — that the last two entries are docstring-prose only — is **confirmed**. Neither
file carries any term-level `witnessPresent` occurrence.

- `PropSaturation.lean:23` sits inside the module docstring opened at `:9` (`/-!`), within a
  fenced pseudo-code block (fence at `:21`). Text:
  `else if ruleMintsFreshLabel rule then (if witnessPresent … then none else some …)` — pseudo-code
  illustration with `…` elisions, not compilable Lean.
- `BoxSaturation.lean:241` sits inside the `/-!` block opened at `:223`. Text is running prose:
  "the fresh-label rules are suppressed by `witnessPresent` (`Tableau.lean:1670`), whose test …".

**Minor correction recorded, not silently absorbed**: `BoxSaturation.lean:241`'s prose cites
`Tableau.lean:1670` as `witnessPresent`'s location. On the green tree the definition is at
**`Tableau.lean:1842`**. The prose line reference is stale by 172 lines. This is a comment-only
inaccuracy with no build or behaviour consequence; it is recorded here rather than fixed, because
Phase 24 edits no Lean file.

### 7.4 Bonus measurement — `Tableau.lean`'s five `witnessPresent` sites

Recorded because Phase 25 edits exactly this region and needs the sites pinned pre-change:

| Line | Role |
|---|---|
| `:1842` | `def witnessPresent (rule : TableauRule) (sf : SignedFormula) (branch : Branch)` — **must stay byte-identical** through Phase 25 |
| `:1913` | consultation site, `findApplicableRule` `.linear` arm |
| `:1936` | consultation site, `findApplicableRule` `.branching` arm |
| `:2947` | `saturated_downward_closed` hypothesis clause |
| `:2951` | `saturated_downward_closed` conclusion clause |

Lines `:1913` and `:1936` match the Phase 25 task text exactly. Phase 25's new definition is to be
added after `:1891`, and its two consultation sites are `:1913` / `:1936`.

---

## 8. Verification of this phase

| Plan verification item | Result |
|---|---|
| Baseline record exists, non-empty, contains all six items | YES — §§1-7 above |
| `check-paper-definitions.sh` exits 0, case (a) or (b) | YES — case (b), exit 0 |
| `lake build` GREEN; 2331 / 1 / 0 recorded or divergence explicit | YES — 2331 / 1 / 0, all MATCH |
| Reader can state, without running anything, what every `BoxNegReachabilityProbe` and `CrossWorldPropagationProbe` row said before the guard landed | YES — §3 (rows 1-12), §4 (rows A-F) |
| Which rows are excluded by name from any re-baseline | §5 — file-level enumeration measured; row-level `[UNVERIFIED]`, deferred to Phase 29.1 with reason |

**Lean files edited by this phase**: none. **New `sorry`**: 0. **New `axiom`**: 0.
