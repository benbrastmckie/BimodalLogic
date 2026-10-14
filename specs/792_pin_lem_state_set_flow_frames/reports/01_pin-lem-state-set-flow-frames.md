# Research Report: Task #792

**Task**: 792 - Pin `lem:state-set` to the tree by discharging its remaining hypothesis
**Started**: 2026-10-14T00:00:00Z
**Completed**: 2026-10-14T00:00:00Z
**Effort**: small (≈20 lines of Lean + docstrings; one 3-row record-file append)
**Dependencies**: None (no blocking dependency; one territory coordination point — see Risks)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Independence/StateSetTruth.lean`,
  `FormalSystem/Metalogic/Independence/OrderTransfer.lean`,
  `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean`,
  `FormalSystem/Semantics/Extension/Extension.lean`,
  `FormalSystem/Semantics/Extension/Completion.lean`,
  `FormalSystem/Metalogic/Independence/README.md`
- Gate sources: `scripts/check-module-invariants.sh` (C15, C34a/C34b, C2, C14, C9, C33,
  `--emit-inventory`), `scripts/check-paper-definitions.sh`, `scripts/check-phantom-citations.sh`,
  `docs/development/MODULE_INVARIANTS.md`
- Literature source: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
  (`def:state-set`, `def:flow`, `lem:state-set`, `cor:occurrence`, `prop:nomic-tense-free`)
- lean-lsp MCP: `lean_run_code` (compiled probes), `lean_local_search` index state
**Artifacts**:
- `specs/792_pin_lem_state_set_flow_frames/reports/01_pin-lem-state-set-flow-frames.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All four deliverable declarations compile, verified by a single `lean_run_code` probe against
  the built library, with zero new imports.** `FormalSystem.Semantics.Extension.Extension` is
  already in `StateSetTruth.lean`'s transitive import closure (via
  `PlusLanguage.PlusValidity → Semantics.Validity`), so `PartialHistory.occurrence` is in scope
  in both `OrderTransfer.lean` and `StateSetTruth.lean` as they stand. No import line, no new
  module, no `FormalSystem.lean` regeneration (C33), no aggregator change.
- **`StateOccurs.of_isRegular` is definitionally `PartialHistory.occurrence`.** `StateOccurs F`
  unfolds to `∀ (w : F.WorldState) (x : F.Duration), ∃ τ : WorldHistory F, τ.state x = w`, which
  is `occurrence`'s statement verbatim; the proof is `fun w x => PartialHistory.occurrence F w x`.
- **Axiom profiles came out exactly as the dispatch's AXIOM NOTE predicted.** The four new
  declarations report `[propext, Classical.choice, Quot.sound]`; the originals are untouched at
  `plusTruthAt_iff_mem_satSet → [propext]` and `determined_of_orderFlow → [propext, Quot.sound]`.
- **One blocking gate collision, and it is the reason this task is not a pure Lean edit.** C15
  (`check-module-invariants.sh`) requires every `def:`/`thm:`/`lem:`/`cor:`/`app:`/`rmk:` anchor
  cited anywhere under `FormalSystem/` to have a row in `docs/reference/paper-definitions-of-record.md`'s
  MANIFEST or KNOWN-ANCHORS block. `def:flow`, `def:state-set` and `lem:state-set` have **no row
  in either**. The dispatch's required docstring citations therefore fail C15 until three
  `LIVE-UNPINNED` KNOWN-ANCHORS rows are added — and that file is in concurrent sibling task 756's
  declared `file_scope` for this same cycle.
- **Recommended approach**: keep both new sites inside the two existing files; add the three
  KNOWN-ANCHORS rows (pointer-only, no verbatim quotation, so no `check-paper-definitions.sh`
  drift surface is created); refresh the `Independence/README.md` generated inventory; and keep
  every one of the four constraint names (*Compositionality*, *Seriality*, *Limit*, *Saturation*)
  out of the new docstrings so C34b never fires.

## Context & Scope

Researched: what exactly is missing between the tree's two-hypothesis state-set development and
the paper's `lem:state-set`, where the discharge and the three corollaries should live, what they
cost in axioms, and which repository gates the edit touches.

Constraints taken as given from the dispatch: `lake build FormalSystem` green, no new `sorry`,
the choice-free originals and the `Independence/DeterminismUndefinable.lean` axiom pin left
untouched, and the three corollaries stated at `[F.IsRegular] (h : OrderFlow F)` alone.

Evidence tier: LSP-backed. `lean_run_code` succeeded against the built library on the first
attempt, which also establishes that the import chain's `.olean`s are current at HEAD.

## Literature Proof Structure

**Source**: `possible_worlds.tex` — `def:state-set` (line 3424), `def:flow` (3441),
`lem:state-set` (3447), `cor:occurrence` (2919), `prop:nomic-tense-free` (3654)
**Strategy**: induction on complexity, proving the biconditional for all `τ ∈ H_F` and `x ∈ D`
at once, with `cor:occurrence` consumed in exactly two places.

### Step Map

1. `def:flow` fixes the frame condition: `W` linearly ordered by `<` and every possible world
   `τ ∈ H_F` an order-isomorphism of `⟨D, <⟩` onto `⟨W, <⟩`. — [Source] `def:flow`
2. `def:state-set` gives the recursion over BL + `Stability`, appealing to `<` and the sets
   `|p_i|` alone. — [Source] `def:state-set`
3. `lem:state-set`, sentence 1 (the bridge): `M,τ,x ⊨ φ` iff `τ(x) ∈ |φ|`. Atom, `⊥` and `→`
   from `def:BL-semantics` and the IH. — [Source] `lem:state-set`
4. `lem:state-set`, `until`/`since` cases: the order-isomorphism carries times `z > x` onto
   states `v > τ(x)` and each interval `(x, z)` onto `(τ(x), τ(z))`. — [Source] `lem:state-set`
5. `lem:state-set`, `□` case: **every world state occurs at every time by `cor:occurrence`**, so
   `{ρ(x) | ρ ∈ H_F} = W`. — [Source] `lem:state-set`, citing `cor:occurrence`
6. `lem:state-set`, `Stability` case: every `σ ∈ ⟨τ⟩_x` has `σ(x) = τ(x)`, and `τ` is one such.
   — [Source] `lem:state-set`
7. `lem:state-set`, sentence 2: `|⊡φ| = |φ|`, so `⊨_F φ → Stability φ`. — [Source] `lem:state-set`
8. `lem:state-set`, sentence 3: `⊨_F φ` iff `|φ| = W` under every assignment; the (⇒) half again
   **consumes `cor:occurrence`** ("each `w ∈ W` is `τ(x)` for some `τ ∈ H_F`"). — [Source]
   `lem:state-set`

### Dependencies

- Steps 3–8 depend on Steps 1–2.
- **Steps 5 and 8 are the only two that consume `cor:occurrence`** — and they are exactly the two
  places `StateOccurs` appears in the tree's proofs (`StateSetTruth.lean:148` in the `box` case,
  and `StateSetTruth.lean:211` in `plusValidOn_iff_satSet_univ`'s forward direction).
- Step 7 depends on Step 3 alone and needs no occurrence fact at all — which is why
  `determined_of_orderFlow` reports `[propext, Quot.sound]` rather than carrying `Classical.choice`:
  it consumes `h2` only by routing through `plusValidOn_iff_satSet_univ`.

### Potential Formalization Challenges

- **None remaining in the mathematics.** Steps 1–8 are already formalized: Step 1 is `OrderFlow`,
  Step 2 is `satSet`, Steps 3–6 are `plusTruthAt_iff_mem_satSet`, Step 7 is
  `determined_of_orderFlow`, Step 8 is `plusValidOn_iff_satSet_univ`. The sole gap is that the
  tree states Steps 5 and 8's occurrence fact as a hypothesis (`StateOccurs`) rather than deriving
  it, so the three results do not read as `lem:state-set` does.
- **Notation translation, `□` clause**: the paper writes `|□φ| := W if |φ| = W else ∅`; the tree
  writes `{_w | ∀ v, v ∈ satSet V φ}`. These are extensionally equal, and `StateSetTruth.lean`'s
  module docstring already records why the ignoring-set form is the one chosen (deciding the set
  equality would pull `Classical.choice` into the *definition*). **No change is wanted here** —
  the encoding is a recorded decision, not drift.
- **`def:flow` vs. `OrderFlow` + `[F.IsRegular]`**: `def:flow` says "a task frame satisfying
  Flow". In the tree, "task frame" plus the four `def:frame` constraints is `TaskFrame` plus
  `[F.IsRegular]`, and "every possible world is an order-isomorphism onto `⟨W, <⟩`" is `OrderFlow`'s
  three fields (`strictMono`, `hits_future`, `hits_past`). So `[F.IsRegular] (h : OrderFlow F)`
  **is** def:flow's hypothesis set, with nothing left over — this is the whole content of the pin.

## Findings

### Codebase Patterns

**What already exists** (confirmed by reading, not inferred):

| Declaration | File:line | Hypotheses | Axioms |
|---|---|---|---|
| `satSet` | `StateSetTruth.lean:80` | — | — |
| `plusTruthAt_iff_mem_satSet` | `StateSetTruth.lean:129` | `(h1 : OrderFlow F) (h2 : StateOccurs F)` | `[propext]` |
| `plusValidOn_iff_satSet_univ` | `StateSetTruth.lean:205` | same | — |
| `determined_of_orderFlow` | `StateSetTruth.lean:228` | same | `[propext, Quot.sound]` |
| `OrderFlow` | `OrderTransfer.lean:83` | — | — |
| `StateOccurs` | `OrderTransfer.lean:183` | — | — |
| `PartialHistory.occurrence` | `Extension.lean:341` | `[F.IsRegular]` | — |

`StateOccurs F` (`OrderTransfer.lean:183`) and `PartialHistory.occurrence`'s conclusion
(`Extension.lean:341`) are the **same statement**, modulo argument order:

```lean
-- OrderTransfer.lean:183
def StateOccurs (F : TaskFrame) : Prop :=
  ∀ (w : F.WorldState) (x : F.Duration), ∃ τ : WorldHistory F, τ.state x = w

-- Extension.lean:341
theorem occurrence (F : TaskFrame) [F.IsRegular] (w : F.WorldState) (x : F.Duration) :
    ∃ τ : WorldHistory F, τ.state x = w
```

**Import closure — no new import is required.** Computed over the whole `FormalSystem/` tree:
`StateSetTruth.lean`'s transitive closure is 53 modules and **already contains**
`FormalSystem.Semantics.Extension.Extension` (reached through
`Metalogic.Independence.OrderTransfer → PlusLanguage.PlusValidity → Semantics.Validity`). The
same holds for `OrderTransfer.lean`. The compiled probe below confirms this at the elaborator
rather than at the import graph.

**Naming precedent.** `Completion.lean:325` carries `completion_of_isRegular [F.IsRegular] :
Completion F` — the same shape (a `def ... : Prop` predicate discharged from the bundling class)
as `StateOccurs`. The dispatch names `StateOccurs.of_isRegular`, which is both Mathlib-idiomatic
and consistent with the existing `StateOccurs.state_image` dot-namespace in the same file; adopt
the dispatched name and treat `completion_of_isRegular` as the shape precedent, not the spelling
precedent.

**`[F.IsRegular]` is a bundling class and the tree gates claims made over it.** `IsRegular`
(`TaskFrame.lean:2657`, `abbrev IsRegular (G : TaskFrame) : Prop := G.toFibre.IsRegular`) bundles
all four of `def:frame`'s constraints. `occurrence` itself carries **no** `Constraints consumed:`
marker, whereas `extension`, `isTotal_of_isMax` and `isRestriction_of_isRegular`
(`Extension.lean:203,238,265`) each carry `Constraints consumed: Compositionality, Seriality,
Limit, Saturation`. See Recommendations for how this bears on the new docstrings.

### External Resources

**Paper anchors, and their status in the citation record of record.** Checked against
`docs/reference/paper-definitions-of-record.md`'s MANIFEST and KNOWN-ANCHORS blocks directly:

| Anchor | MANIFEST row | KNOWN-ANCHORS row | C15 status if cited under `FormalSystem/` |
|---|---|---|---|
| `cor:occurrence` | yes (sha pinned) | — | resolves |
| `cor:no-characterization` | — | `LIVE-UNPINNED` | resolves |
| `app:drift` | — | `LIVE-UNPINNED` | resolves |
| `def:deterministic` | yes | — | resolves |
| **`def:flow`** | **no** | **no** | **FAILS C15** |
| **`def:state-set`** | **no** | **no** | **FAILS C15** |
| **`lem:state-set`** | **no** | **no** | **FAILS C15** |
| `prop:nomic-tense-free` | no | no | not checked — `prop:` is absent from C15's prefix set |

C15's resolution rule, read off `check-module-invariants.sh:2623-2700`: a citation resolves if it
has a MANIFEST row (a pinned anchor, hash-checked against the paper by
`check-paper-definitions.sh`) **or** a KNOWN-ANCHORS row with status `LIVE-UNPINNED` or
`DANGLING`. Scope is `FormalSystem Tests BimodalTools typst docs README.md` over
`*.lean`/`*.md`/`*.typ`, excluding `Boneyard/` and the record file itself. `specs/**` is excluded,
so this report may cite the three anchors freely; a `.lean` docstring may not, yet.

**Gates reviewed and their verdicts for this change:**

| Gate | Bearing on this task |
|---|---|
| C15 paper-anchor integrity | **BLOCKING** until three KNOWN-ANCHORS rows exist (above) |
| C34b hypothesis-honesty trigger | **Conditional**: fires if a new `[F.IsRegular]`-binder declaration's docstring names *Compositionality*/*Seriality*/*Limit*/*Saturation* together with negation or consumption vocabulary (`not`, `never`, `without`, `consumed`, `reach…`, …). Remedy is one `Constraints consumed:` marker line |
| C34a structural half | Only applies to a marker that **omits** a constraint its own binder supplies. Avoided entirely by writing no marker, or by writing the full four-constraint marker |
| C9 zero task-number citations under `FormalSystem/` | **BLOCKING if violated**: the nomic forward-pointer docstring must cite `prop:nomic-tense-free`, never a task number |
| C2 axiom baseline | Not affected — no `Independence/` declaration is in C2's pinned roster |
| C14 stale axiom/sorry counts | Not affected — trips only on the literals 14/21/42/44/45 near "axiom" |
| C20 Tier 1 `file.lean:NNN` citations | Avoid line-numbered citations in the new docstrings |
| C31 `[key]` References citations | Not affected — the house style here is `* JPL paper <anchor>` prose, not `[key]` |
| C32 relative markdown links in `.lean` comments | Not affected — backticked paths, not `[text](path)` links |
| C33 `FormalSystem.lean` byte-currency | Not affected **provided no new module is created** |
| `--emit-inventory` staleness (INV) | **Will go stale**: `Independence/README.md:149,158` pin `OrderTransfer.lean` at 197 lines and `StateSetTruth.lean` at 236 lines, and both counts change |
| `check-phantom-citations.sh` | Not affected — its scope is `specs/state.json` descriptions, `docs/**/*.md` and `specs/ROADMAP.md`, not `.lean` files |
| `check-paper-definitions.sh` | Not affected by a `LIVE-UNPINNED` row; a MANIFEST pin would add a hash to maintain |

**Nomic machinery is absent from the tree by recorded decision.** `FormalSystem/StarLanguage/README.md:143`
and `FormalSystem/OpenLanguage/README.md:79` both record the nomic operator as **excluded** ("a
manuscript operator with no formalization in this tree"), and a `\bnomic\b` sweep over
`FormalSystem/` returns only those two rows plus one `OpenLanguage.lean` docstring line. So
deliverable (4) is a pure forward-pointer, with nothing to wire to.

### Recommendations

A single sorry-free path exists, it was compiled end to end during this research, and nothing in
it requires a deferral, a placeholder, or an axiom.

**R1 — Place `StateOccurs.of_isRegular` in `OrderTransfer.lean`, directly after
`StateOccurs.state_image`.** That is the `## (H2) — every state is occupied at every time`
section, which is where (H2) is defined and where the existing docstring already explains why it
is a hypothesis. Verified to elaborate under that file's ambient `variable {F : TaskFrame}`, with
the explicit `(F : TaskFrame)` binder shadowing it:

```lean
theorem StateOccurs.of_isRegular (F : TaskFrame) [F.IsRegular] : StateOccurs F :=
  fun w x => PartialHistory.occurrence F w x
```

**R2 — Place the three corollaries in `StateSetTruth.lean`, in a new trailing section after
`determined_of_orderFlow`.** They must be in a section of their own: adding `[F.IsRegular]` to
the file's existing `variable {F : TaskFrame} [LinearOrder F.WorldState]` (line 119) would change
the originals' signatures, which the dispatch forbids and
`Independence/DeterminismUndefinable.lean` consumes. Verified shape:

```lean
section Regular
variable {F : TaskFrame} [LinearOrder F.WorldState] [F.IsRegular]

theorem plusTruthAt_iff_mem_satSet_of_isRegular (h : OrderFlow F)
    (M : TaskModel F) (φ : PlusFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ :=
  plusTruthAt_iff_mem_satSet h (StateOccurs.of_isRegular F) M φ

theorem plusValidOn_iff_satSet_univ_of_isRegular (h : OrderFlow F) (φ : PlusFormula) :
    F.PlusValidOn φ ↔ ∀ V : F.WorldState → Atom → Prop, satSet V φ = Set.univ :=
  plusValidOn_iff_satSet_univ h (StateOccurs.of_isRegular F) φ

theorem determined_of_orderFlow_of_isRegular (h : OrderFlow F) (φ : PlusFormula) :
    F.PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow h (StateOccurs.of_isRegular F) φ
end Regular
```

**R3 — Name the corollaries by mechanical `_of_isRegular` suffixing of the originals**, as above.
Rationale: each name greps straight back to the two-hypothesis original it specializes; the suffix
is the tree's existing marker for "the bundling class discharged this"
(`completion_of_isRegular`, `isRestriction_of_isRegular`); and the paper cites them as
`Independence.plusTruthAt_iff_mem_satSet_of_isRegular` etc., matching the
`\leanproof{\texttt{Independence.…}}` convention already used at `app:drift` and
`cor:no-characterization`. `determined_of_orderFlow_of_isRegular` carries a double `_of_`; that is
accepted as the price of mechanical derivability, and is preferred over a prettier
`determined_of_flow` that would no longer name its own parent.

**R4 — Add three `LIVE-UNPINNED` KNOWN-ANCHORS rows to
`docs/reference/paper-definitions-of-record.md`, before writing any docstring that cites them.**
This is the C15 unblock. Keep them pointer-only, following the `cor:no-characterization` /
`app:drift` precedent ("cited as a pointer, text never quoted"), so that
`check-paper-definitions.sh` gains no new hash to maintain:

```
def:flow|LIVE-UNPINNED|the Flow frame condition (Ddef): W linearly ordered and every possible world an order-isomorphism of ⟨D,<⟩ onto ⟨W,<⟩; OrderTransfer.lean's OrderFlow is this condition, cited as a pointer, text never quoted
def:state-set|LIVE-UNPINNED|the state-set recursion (Ddef) over BL with Stability; StateSetTruth.lean's satSet is this recursion, with the □ clause in an extensionally equal decidability-free encoding, cited as a pointer, text never quoted
lem:state-set|LIVE-UNPINNED|truth over a Flow frame is membership in the state set (Lthm); StateSetTruth.lean's _of_isRegular corollaries are its three sentences, cited as a pointer, text never quoted
```

Rows go inside the `<!-- KNOWN-ANCHORS:BEGIN -->` block in its existing alphabetical position
(`def:flow` and `def:state-set` among the `def:` rows, `lem:state-set` among the `lem:` rows).

**R5 — Keep all four constraint names out of the new docstrings, and write no
`Constraints consumed:` marker.** The AXIOM NOTE's content is expressible without them: "routes
through `cor:occurrence`, hence `thm:extension` and Zorn, so these forms carry
`Classical.choice`." This is the same vocabulary `OrderTransfer.lean:179-181` already uses for
(H2) and it keeps C34b from firing. If the implementer judges that naming *Seriality* and
*Saturation* makes the docstring materially better, the remedy is one line —
`Constraints consumed: Compositionality, Seriality, Limit, Saturation` — copying
`Extension.lean:238`'s marker verbatim (all four, since `occurrence` routes through `step`, which
reaches all four; a marker omitting any of them would then face C34a).

**R6 — Write deliverable (3)'s note in `StateSetTruth.lean`'s module docstring, stating the
current design rather than a change to it.** `.claude/rules/no-record-versioning-in-deliverables.md`
forbids phrasing relative to an unstated past, so write "(H2) is **derivable** for regular frames
(`StateOccurs.of_isRegular`), and the two-hypothesis forms are retained because
`Independence/DeterminismUndefinable.lean` discharges (H2) by explicit affine witnesses and so
stays choice-free" — not "is now derived". Add the three corollary names to the module docstring's
`## Main Results` list in the same edit.

**R7 — Write deliverable (4)'s forward-pointer citing `prop:nomic-tense-free`, with no task
number.** C9 asserts zero task-number citations under `FormalSystem/`, and the no-task-references
rule binds the whole repository outside `specs/**`. Suggested placement: the `## References`
section of `StateSetTruth.lean`'s module docstring, noting that `prop:nomic-tense-free` runs the
same state-set induction over the tense-free fragment `{p_i, ⊥, →, □, Nomic}` with `□` and
`Nomic` sharing one clause, that its `□` case consumes `cor:occurrence` and its `Nomic` case
consumes `lem:nomic-occurrence` (`cor:occurrence` applied to the relativized frame `F^w`), and
that no nomic machinery exists in the tree — which `StarLanguage/README.md` and
`OpenLanguage/README.md` record as a deliberate exclusion. `prop:` is outside C15's prefix set, so
this citation needs no record row; a planner may still prefer to add one for consistency.

**R8 — Refresh the generated inventory and the hand-written description column.** After the Lean
edits, run `bash scripts/check-module-invariants.sh --emit-inventory` to rewrite the line counts
in `FormalSystem/Metalogic/Independence/README.md:149,158` (currently 197 and 236), then hand-edit
those two rows' trailing description column and the `Main Results` bullet at line 190 to name the
new declarations. `scripts/readme-inventory.sh` is a deprecated shim that exits 2 — do not call it.

**R9 — Verification sequence.** `bash scripts/check-module-invariants.sh --no-build` (seconds;
covers C15, C34, C9, C33 and inventory staleness) first, then the guarded scoped build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.StateSetTruth`
detached, then the full `-- build` as final verification. Re-confirm the six axiom profiles with
`lean_verify` or a commented `#print axioms` probe rather than trusting the research probe, since
the implementer's file differs from the probe's standalone snippet.

**Optional, not required by the dispatch**: no test under `Tests/` references `satSet`,
`StateOccurs` or `OrderFlow`, so nothing needs updating there. A `Tests/BimodalTest/` axiom pin
for the three corollaries (on the `SaturationFiniteAxiomTest.lean` /
`PeriodicExtensionAxiomTest.lean` pattern) would be a reasonable addition but is out of scope.

## Decisions

- **Both new sites go in existing files; no new module.** This keeps C33 (`FormalSystem.lean`
  byte-currency) and C8 (one aggregator per directory) untouched, and — since the import closure
  already reaches `Extension.lean` — buys nothing in exchange for the extra module.
- **The corollaries go in `StateSetTruth.lean`, not `OrderTransfer.lean`.** They mention `satSet`
  and `PlusValidOn`, which `OrderTransfer.lean` does not import or discuss; and deliverable (3)'s
  note belongs beside them.
- **`StateOccurs.of_isRegular` over `stateOccurs_of_isRegular`.** The dispatch names the former,
  and the file already hosts `StateOccurs.state_image` in that namespace. The
  `completion_of_isRegular` precedent is recorded above as the shape, not the spelling.
- **Pointer-only KNOWN-ANCHORS rows over MANIFEST pins.** A MANIFEST row would require a verbatim
  transcription plus a sha that `check-paper-definitions.sh` then has to keep matching against a
  paper in another repository. Nothing in this task's docstrings needs to quote the paper, so the
  lighter commitment is the right one. If a later task *does* quote `lem:state-set` verbatim, the
  row is upgraded to a pin then.
- **No `Constraints consumed:` marker, by avoiding constraint vocabulary.** Chosen over writing
  the four-constraint marker because the AXIOM NOTE's content ("Zorn, hence `Classical.choice`")
  is cleaner stated through `thm:extension` than through the constraints `step` consumes, and
  because `occurrence` — the declaration being specialized — carries no marker either.
- **The paper's `□` clause encoding is left alone.** The divergence between `def:state-set`'s
  `if |φ| = W then W else ∅` and `satSet`'s `{_w | ∀ v, v ∈ satSet V φ}` is a recorded decision
  with a stated reason (keeping `Classical.choice` out of the *definition*), not drift to repair.

## Risks & Mitigations

- **Territory: `docs/reference/paper-definitions-of-record.md` is in concurrent sibling task 756's
  declared `file_scope` for this same `/orchestrate` cycle.** R4 requires appending three rows to
  it. Mitigation, per `context/contracts/territory.md`: re-read the KNOWN-ANCHORS block
  immediately before editing; insert three whole new lines rather than modifying any existing row;
  stage by explicit file list and review `git diff --staged` to confirm only those three lines are
  present. If a foreign commit or a foreign uncommitted modification to that file is observed,
  STOP and report rather than proceeding. If the planner prefers zero cross-territory edits, the
  only compliant fallback is to serialize behind task 756 by adding a dependency edge
  (`update-task-status.sh --depends-on-add`) — **not** to drop the docstring citations, which the
  dispatch requires.
- **C15 is checked by `--no-build`, so the failure is cheap to discover but easy to postpone.**
  Mitigation: do R4 **before** the docstring edits, and run
  `check-module-invariants.sh --no-build` immediately after the first docstring lands rather than
  at phase end.
- **Axiom-pin prose in `DeterminismUndefinable.lean` could be read as newly false.** Its docstring
  asserts the generic argument is choice-free and that `fzero_stateOccurs`/`f1_stateOccurs` are
  discharged by explicit affine witnesses rather than by `cor:occurrence`. **Both statements
  remain true** — adding a sibling theorem does not change any existing declaration's axiom set,
  which the probe confirms (`plusTruthAt_iff_mem_satSet` still `[propext]`). The dispatch's
  instruction to leave that pin untouched is therefore also the correct instruction; no edit to
  that file is needed or wanted.
- **Generated-inventory staleness is a silent gate failure mode.** The INV check fails whenever a
  `BEGIN GENERATED` block has gone stale, and the line counts change by construction here.
  Mitigation: R8, with `--emit-inventory --check` as the confirmation.
- **C34b's trigger vocabulary is broad** (`reach\w*` and `no` both count). Mitigation: R5, plus
  running `--no-build` once the docstrings are written, rather than reasoning about the regex.
- **Concurrent builds.** Five sibling research dispatches share this working tree this cycle.
  Mitigation: route every build through `lake-build-guard.sh` as R9 specifies, and treat a failure
  in a file outside this task's two-file scope as possibly a sibling's in-flight edit.

## Tactic Survey Results

The implementation is term-mode delegation throughout — every goal closes by applying an existing
theorem to `StateOccurs.of_isRegular F` — so no tactic search was needed and none was run.
`lean_run_code` was used instead as a whole-deliverable compiled probe, twice, both green.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `StateOccurs F` under `[F.IsRegular]` | term mode, `fun w x => PartialHistory.occurrence F w x` | success | no new imports |
| bridge at `[F.IsRegular] (h : OrderFlow F)` | term mode, `plusTruthAt_iff_mem_satSet h (StateOccurs.of_isRegular F) M φ` | success | — |
| validity corollary, same hypotheses | term mode, `plusValidOn_iff_satSet_univ h (StateOccurs.of_isRegular F) φ` | success | — |
| *Determined*, same hypotheses | term mode, `determined_of_orderFlow h (StateOccurs.of_isRegular F) φ` | success | — |

Axiom profiles reported by the same probe:

| Declaration | `#print axioms` |
|---|---|
| `StateOccurs.of_isRegular` | `[propext, Classical.choice, Quot.sound]` |
| `plusTruthAt_iff_mem_satSet_of_isRegular` | `[propext, Classical.choice, Quot.sound]` |
| `plusValidOn_iff_satSet_univ_of_isRegular` | `[propext, Classical.choice, Quot.sound]` |
| `determined_of_orderFlow_of_isRegular` | `[propext, Classical.choice, Quot.sound]` |
| `plusTruthAt_iff_mem_satSet` (original) | `[propext]` |
| `determined_of_orderFlow` (original) | `[propext, Quot.sound]` |

## Context Extension Recommendations

- **Topic**: C15 paper-anchor integrity as a pre-condition on docstring citation.
  **Gap**: `context/project/lean4/` has no note that citing a new `def:`/`lem:`/`thm:` anchor in a
  `.lean` docstring requires a record row first. This task's dispatch asked for exactly such
  citations without flagging the dependency, and the collision was only found by reading
  `check-module-invariants.sh`. **Recommendation**: add a short "citing a paper anchor" subsection
  to `context/project/lean4/` (or extend the existing paper-definitions guidance) stating the
  two-row resolution rule, the `prop:` blind spot, and the MANIFEST-vs-KNOWN-ANCHORS choice.
- **Topic**: C34b's trigger vocabulary and the `[F.IsRegular]` binder.
  **Gap**: no context file warns that adding an `[F.IsRegular]` binder puts a declaration's
  docstring under a hypothesis-honesty trigger whose remedy is a marker line.
  **Recommendation**: record the trigger's vocabulary and the full-four-constraint marker
  precedent (`Extension.lean:238`) alongside the existing Lean conventions.

## Appendix

**Searches and probes performed**

- Import-closure computation over all of `FormalSystem/**/*.lean` (Python, transitive `import`
  walk): `StateSetTruth` closure = 53 modules, contains
  `FormalSystem.Semantics.Extension.Extension`. Reverse edges: `StateSetTruth` is imported by
  `Independence.lean`, `DeterminismUndefinable.lean`, `FormalSystem.lean`.
- `lean_run_code` probe 1: the four declarations in a bare `open` context, `#print axioms` on two.
- `lean_run_code` probe 2: the four declarations under the two target files' actual `variable`
  contexts, inside `namespace FormalSystem.Metalogic.Independence`, plus an `example` re-eliding
  `StateOccurs.state_image` to confirm the ambient `variable {F : TaskFrame}` still behaves, plus
  `#print axioms` on all six declarations in the table above.
- Grep sweeps: `occurrence` across `FormalSystem/`; `IsRegular` definition sites;
  `_of_isRegular` naming precedent; `Constraints consumed` markers; `\bnomic\b` across
  `FormalSystem/`; `def:flow`/`def:state-set`/`lem:state-set` across `FormalSystem/`, `docs/`,
  `Tests/`.
- Record-file queries: MANIFEST and KNOWN-ANCHORS block extraction for the six anchors in the
  status table.
- Gate-source reads: `check-module-invariants.sh` C15 (2623-2700), C34 (766-800, 6072-6130), C2
  (1060-1120), C14 (1932-2010), gate roster in `docs/development/MODULE_INVARIANTS.md`;
  `check-paper-definitions.sh` header; `check-phantom-citations.sh` header;
  `scripts/readme-inventory.sh` (deprecated shim).

**Paper references**

- `possible_worlds.tex:3424` `def:state-set`, `:3441` `def:flow`, `:3447` `lem:state-set` with its
  `% PORT:` comment at `:3453`, `:2919` `cor:occurrence`, `:3620` `lem:nomic-occurrence`, `:3654`
  `prop:nomic-tense-free`.
- `app:drift`'s proof (`:3500`ff) is the paper's own worked instance of the pin: it establishes
  Flow for `F°` and then invokes `lem:state-set` directly, with no second hypothesis — which is
  the reading the three corollaries make available to the tree.

**Note on the paper's `% PORT:` comment**

`possible_worlds.tex` is read-only input from another repository. Its `% PORT:` comment under
`lem:state-set` already describes exactly this gap ("no corollary discharging StateOccurs by
PartialHistory.occurrence so that the statement matches def:flow"), and `lem:state-set` currently
carries no `\leanproof{}`. Updating either is a paper-side edit, outside this task's scope; the
`_of_isRegular` names in R3 are chosen so that a later `\leanproof{\texttt{Independence.…}}`
citation needs no further renaming.
