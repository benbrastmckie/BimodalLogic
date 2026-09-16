# Sweep Evidence Report: Task #584

**Task**: 584 — Reconcile the Lean tree with the paper's renamed vocabulary and re-pin the record
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence. Three naming decisions here are the user's; nothing should be renamed before they are made.
**Effort**: Large if the renames are adopted (`swapTemporal` alone has 925 occurrences); Small if all three are recorded as deliberate divergences.
**Dependencies**: None, but it should be **sequenced before** any other task that edits `Conservativity/`, `Semantics/` or `Syntax/` prose, to avoid two passes over the same files.
**Sources/Inputs**:
- `bash scripts/check-paper-definitions.sh` (full drift output)
- `specs/paper-definitions-of-record.md` (the pinned record and its manifest)
- Live tree: `FormalSystem/Semantics/`, `FormalSystem/Syntax/`, `FormalSystem/Metalogic/Conservativity/`
- `specs/reviews/review-2026-09-16.md`, Finding H2

## Executive Summary

- **`check-paper-definitions.sh` reports case (c): 16 of the recorded definitions drifted**, plus
  one anchor (`thm:M5-valid`) that no longer resolves at all. Case (c) is the script's FAIL
  outcome and means at least one *recorded definition block* changed, not merely that the paper
  moved.
- **Most of the sixteen are reflow. Three are substantive**, and one of those touches a term the
  Lean tree uses roughly a thousand times.
- **This is a decision task before it is an editing task.** For each of the three, the user
  chooses: adopt the paper's new name, or record a deliberate divergence in
  `specs/paper-definitions-of-record.md`. Both are legitimate; neither should be chosen by an
  implementer mid-dispatch.
- The paper is **read-only input edited in a separate repository this one cannot see**. The
  script exists precisely because "every wave silently invalidates task specs that quote the
  paper" — twice while a dispatch against it was in flight. Treat its output as ground truth
  about the paper and as a prompt for a decision here, never as an instruction to edit the paper.

## The three substantive renames

### 1. "converse convention" → "reflection convention"

`def:task-relation` now reads:

> …extended to negative durations by the *reflection convention* $w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$ for $x \geq 0$…

where the pinned text says *converse convention*. The mathematical content is byte-identical;
only the name changed.

Live-tree exposure:

| Form | Occurrences (live tree, Boneyard excluded) |
|---|---|
| "converse convention" in prose/docstrings | 35 |
| `FrameOver.converse` (the API name) | 9 |
| "reflection convention" | **0** |

Sample sites: `FormalSystem/Semantics.lean:160`, `Semantics/PartialHistory.lean:52,56,150`,
`Semantics/README.md:72`, `Metalogic/Algebraic/FlowFrame.lean:61,214,219`,
`Metalogic/Independence/LoopingDuration.lean:55`,
`Metalogic/Independence/ForwardDeterministicFrame.lean:20,141`,
`Metalogic/Independence/ClockFrame.lean:43`.

Note `FlowFrame.lean:214` cites the convention *to the paper anchor* (`def:task-relation`), so
this is not purely cosmetic: a citation that names the paper while using the paper's old word is
a citation a reader cannot follow.

### 2. Metarule `\aref{TD}` → `\aref{TR}`

`def:BX` changed from "…closed under the metarules **TN** and **TD**…" to "…extends **CPL** to
include the metarules **TN** and **TR**…". Read alongside rename 1, this is consistently a
*duality → reflection* renaming of the same rule.

Live-tree exposure:

| Form | Occurrences |
|---|---|
| `swapTemporal` (the implementing function) | 925 |
| "temporal duality" in prose | 77 |
| `TemporalDuality` | 4 |
| bare `TD` as the rule name in docstrings | ~14 files |

Sites naming `TD` as the rule include `FormalSystem/Metalogic.lean:60`,
`Conservativity/Plus/PlusSoundness.lean:20,22`, `Deterministic/Soundness.lean:30`,
`Conservativity/Backward.lean:64`, `Conservativity/MinusLanguageSoundness.lean:428,447`,
`Syntax/Formula.lean:665`, `Syntax/PlusLanguage/Formula.lean:51`,
`Semantics/MinusFrame.lean:65`, and the `Conservativity/{Plus,Star}` READMEs and aggregators.

**The 925 is why this decision must precede the work.** A full adoption touches the single
most-referenced identifier in the conservativity layer. A partial adoption — renaming the prose
`TD` but leaving `swapTemporal` — is a defensible middle path (the Lean name is descriptive of
what the function does, not of what the paper calls the rule) but must be chosen deliberately.

### 3. Derived-operator names: "Past"/"Future" → "Some Past"/"Some Future"

`def:BLplus-language` renamed its item labels:

```
- \item[\it Past:]   $\past\varphi  \coloneq \top\since\varphi$   →   \item[\it Some Past:]
- \item[\it Future:] $\future\varphi \coloneq \top\until\varphi$  →   \item[\it Some Future:]
```

`\Past` (Historical) and `\Future` (Henceforth) keep their labels. This disambiguates the
existential/universal pair, which the old labels collided on. Check `docs/reference/operators.md`
and `NOTATION.md` against the new labels; the Lean constructor names are unlikely to need
changing, but the operator reference tables may.

## The rest of the drift

Mostly reflow and phrasing, but two patterns are worth recording rather than waving through:

- **"is the smallest extension of X closed under…" → "extends X to include…"** across `def:S5`,
  `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus`. This is a proof-theoretic phrasing
  change, not a cosmetic one: "smallest closed under" and "extends to include" are not obviously
  the same claim, and the repository's soundness/completeness prose quotes the old form in
  places. `def:TMplus` compensates by adding an explicit sentence defining $\vdash_\Lambda$ as
  "the smallest relation closed under the axioms and rules for $\Lambda$" — so the closure
  condition moved from the system definitions to the derivation-relation definition. Verify the
  Lean `DerivationTree` docstrings describe it the new way.
- **`def:BX` acquired an axiom-provenance footnote**: **TN** is half of Burgess's necessitation
  rule TG; **TS** his *No Last Element* variant; **UC**, **UG**, **SU**, **UF**, **UI** are his
  A1a, A2a, A3a, A5a, A6a; **CN** is A7a, independently confirmed by Xu as defining linear
  frames; **UE** follows from **UC** at $\psi = \top$; and **TC**, **UT**, **NP**, **NF**, **NA**,
  **NB** are the present system's own additions. `def:BX-z` and `def:BX-d` add matching notes that
  **UZ**/**Z1** and **DN**/**NN** are likewise the paper's own. None of this provenance appears in
  `FormalSystem/ProofSystem/Axioms.lean`. This is an *opportunity*, not a defect: the axiom
  docstrings are the natural home for it and `docs/reference/axiom-reference.md` covers all 45
  constructors already.
- **`def:BX-r`** dropped commented-out material referencing the deleted fragment system TM⁻ and a
  conjecture about **CO** alone axiomatizing the same logic. Confirm nothing in the tree cites
  that conjecture as live.
- **`cor:tm-completeness`** now says the Lean results "are established" (present) rather than
  "have been established", and adds that each system is extended with *Determined* and governing
  axioms in the language with $\Stability$ — i.e. it now describes the TM⁺ layer explicitly.
  Cross-check against `Conservativity/Plus/`.
- **`def:id`** commented out the operator-scope congruence sentence. Check whether anything in the
  tree cites it.

## The dangling anchor

`thm:M5-valid` ("the M5 axiom is valid") is recorded in `specs/paper-definitions-of-record.md`
(§ at line 1354, manifest row at line 1734) but no longer resolves — the `\label` or the
environment structure around it changed. The record file documents a `--resolve` mode
(`check-paper-definitions.sh --resolve "ID|KIND|ENCLOSING|LOCATOR"`) for exactly this: re-derive
the locator against the current paper and update the manifest row.

## Re-pinning protocol

`specs/paper-definitions-of-record.md` documents a **dirty-pin convention** that this task must
follow rather than improvise: the whole-file checksum sentinel is re-pinned only when a drift
*correction* is absorbed, not on every case-(b) coverage extension — "bumping the pin on every
append would make the sentinel a diary of touch-events rather than a record of drift
corrections." This task is a case-(c) correction, so a re-pin **is** warranted here, once the
three decisions are made and any adopted renames have landed.

## Recommended approach

1. Put the three renames to the user as three separate yes/no decisions, with the occurrence
   counts above. Do not bundle them — the "converse convention" rename is 44 sites and obviously
   cheap; the `TD → TR` rename is not.
2. For each adopted rename, do the mechanical pass, including the paper-citing sites
   (`FlowFrame.lean:214` and the C15-tracked anchors) first.
3. For each declined rename, add an explicit divergence row to
   `specs/paper-definitions-of-record.md` saying the tree keeps the old term and why.
4. Re-resolve `thm:M5-valid` via `--resolve` and update its manifest row.
5. Separately consider (it may warrant its own task) folding the Burgess/Xu provenance footnote
   into `ProofSystem/Axioms.lean` docstrings and `docs/reference/axiom-reference.md`.
6. Re-pin the record per the dirty-pin convention and re-run the script to confirm case (a) or (b).

## Verification

- `bash scripts/check-paper-definitions.sh` exits 0 (case (a) or (b), not (c)).
- `bash scripts/check-module-invariants.sh` C15 still resolves all 58 paper-anchor citations.
- Zero occurrences of a declined-rename term in a context that *cites the paper anchor* — if the
  tree keeps "converse convention", no site may attribute that wording to `def:task-relation`.
- `lake build` exits 0; no axiom baseline moves (C2/C14).
