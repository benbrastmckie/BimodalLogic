# README Correction: Verification of the Top-Level and `FormalSystem/**` Documentation Layers

**Scope**: verify every defect asserted by the task description in `README.md` (Scope A) and the
`FormalSystem/**/README.md` layer (Scope B) against Lean source, `#print axioms`, and the two
invariant scripts; supply the ground-truth replacement values; and record the defects the task
does *not* list but which sit in the same lines and would survive a pass that only fixes what is
listed.

**Method**: no status claim below is taken from another markdown document. Axiom counts come from
`Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean:571-597`) and from the enumeration
verified by the anchor task; axiom profiles from `lean_verify` (`#print axioms`) and check C2;
file/line inventories from direct `wc -l` and `find` over the working tree; declaration existence
from `grep` over live (non-`Boneyard/`) `.lean` files.

**Anchor documents treated as ground truth** (per the dispatch): `specs/ROADMAP.md` and
`FormalSystem/Metalogic/README.md` as corrected by the anchor task. Where this report diverges
from them, the divergence is called out explicitly in §6.3.

## Gate baselines (measured for this report, working tree at `e0d92a930` + uncommitted edits)

| Command | Result |
|---------|--------|
| `bash scripts/check-module-invariants.sh` | **ALL CHECKS PASSED** (exit 0) |
| `bash scripts/readme-lint.sh` | **FAIL** — 9 missing READMEs, 5 broken references |
| `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .` | 539 files / 170,898 code / 96,290 comment |

C3 reports **structural sorry inventory is ZERO across `FormalSystem/`** (`Boneyard/` excluded).
That single line refutes A1 outright.

`readme-lint.sh` takes `ROOT="${1:-FormalSystem}"` (`scripts/readme-lint.sh:17`), so **the
top-level `README.md` is outside its coverage entirely**. Scope A link integrity had to be checked
by hand; see §2.9.

---

## 1. Verdict summary

### Scope A — `README.md`

| Item | Task's claim | Verdict | Section |
|------|--------------|---------|---------|
| A1 | "Active sorry obligations" section is false; delete | **CONFIRMED** (C3 = zero) | §2.1 |
| A2 | `:129`, `:136` mark Discrete completeness pending | **CONFIRMED** | §2.2 |
| A3 | `:135`, `:150` mark Continuous sound/complete as absent | **CONFIRMED, with a binder caveat the task omits** | §2.3 |
| A4 | "Continuous" is not the source's class name | **CONFIRMED** | §2.4 |
| A5 | `:129-152` conflate completeness with strong completeness | **CONFIRMED**; all four citations exact | §2.5 |
| A6 | No Decidability subsection | **CONFIRMED** | §2.6 |
| A7 | `:19-21` metrics stale (301/109,364/50,913) | **ALREADY APPLIED in the working tree, uncommitted; one formatting slip remains** | §2.7 |
| A8 | Project Structure block shows nonexistent `Bimodal/` | **CONFIRMED, and larger than listed** | §2.8 |
| A9 | `:92`, `:164` say 44 constructors; actual 45 | **CONFIRMED** | §2.10 |
| A10 | `:129` "axiom-free" is false | **CONFIRMED** | §2.11 |
| A11 | `:98` WeakCanonical description undercounts | **CONFIRMED** | §2.12 |
| A12 | `:149`/`:150` per-class counts wrong | **CONFIRMED** (Dense 38→39, Continuous/Dedekind 39→42) | §2.13 |
| — | "all 13 relative links resolve, no link work needed" | **CONFIRMED** (12 non-URL links, all resolve) | §2.9 |

### Scope B — `FormalSystem/**/README.md`

| Item | Verdict | Section |
|------|---------|---------|
| B1 | **CONFIRMED** — `FormalSystem/README.md:285`, `:289-290` | §3.1 |
| B2 | **CONFIRMED, and larger** — 3 contradictory scope statements, not 2 | §3.2 |
| B3 | **CONFIRMED, and larger** — **four** phantom results, not three | §3.3 |
| B4 | **CONFIRMED, but the task has the two files backwards** | §3.4 |
| B5 | **CONFIRMED** — 9 sites in `FormalSystem/README.md`, 3 in `ProofSystem/README.md` | §3.5 |
| B6 | **CONFIRMED** | §3.6 |
| B7 | **CONFIRMED, and larger** — plus a fourth phantom `truth_lemma` | §3.7 |
| B8 | **CONFIRMED** — `:70`, `:72-73`, `:170` (task cited `:70-72`, `:171`) | §3.8 |
| B9 | **CONFIRMED** — `Decidability/README.md:11` | §3.9 |
| B10 | **CONFIRMED, and larger** — all four line counts stale, not just `Axioms.lean` | §3.10 |
| B11 | **PARTIALLY ALREADY FIXED** — `BXCanonical/README.md:13` was repaired by the anchor task; 2 sites remain | §3.11 |
| B12 | **CONFIRMED, and larger** — a fifth typeclass exists | §3.12 |
| B13 | **CONFIRMED, and larger** — *all nine* root-file line counts are wrong, not three | §3.13 |
| B14 | **CONFIRMED**; all five targets located | §3.14 |

**Three findings require a decision before implementation** and are called out in §6.

---

## 2. Scope A — `README.md` (223 lines)

### 2.1 A1 — the "Active sorry obligations" section (`:154-156`) is false

C3 of `scripts/check-module-invariants.sh` prints, on this working tree:

```
PASS  C3   structural sorry inventory is ZERO across FormalSystem/ (Boneyard/ excluded)
```

The section names `WeakCanonical/Transfer.lean` and `WeakCanonical/Separation/` as carrying
sorries. Neither does. `theorem countermodel_discrete` — the result the section is really about —
is at `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean:142` and is
axiom-clean. **Delete `:154-156` entirely.** This is the single most damaging line in the file:
it advertises open obligations in a tree that has none.

### 2.2 A2 — Discrete completeness is proven

`theorem completeness_discrete` is at
`FormalSystem/Metalogic/BXCanonical/Completeness.lean:296` (docstring runs from `:290`), and C2
pins it at `[propext, Classical.choice, Quot.sound]`. Both `:129` ("continuous and discrete
completeness have remaining obligations") and the mermaid node at `:136`
(`Sound ✓ · Complete ⧖`) are stale.

### 2.3 A3 — Continuous/Dedekind soundness and completeness are both proven

| Theorem | Site | `lean_verify` |
|---------|------|---------------|
| `soundness_dedekind` | `FormalSystem/Metalogic/Soundness.lean:1927` | `[propext, Classical.choice, Quot.sound]` |
| `completeness_dedekind` | `FormalSystem/Metalogic/StrongCompleteness.lean:469` | `[propext, Classical.choice, Quot.sound]` |

`StrongCompleteness.lean:456` describes it in-source as "**Weak completeness for
`FrameClass.Dedekind` — the headline result — unconditional.**"

**Caveat the task description omits, and which the rewrite must not drop.** Both results are
stated against `ValidDedekindDense`, *not* `ValidDedekind`. `Axioms.lean:499-502` records why:
because `Dense ≤ Dedekind`, `density` and `dense_indicator` are admissible in a Dedekind
derivation and both are FALSE on `ℤ`, which is nonetheless conditionally complete — so
"the soundness theorem for this class must target the *dense* Dedekind predicate
`ValidDedekindDense`, not the density-free `ValidDedekind`." A README row that reads simply
"Sound ✓ · Complete ✓" for a class whose standard model is `ℝ` is accurate; one that implies the
result holds at the density-free binder set is not. One clause suffices.

### 2.4 A4 — the class is `Dedekind`, and TM⁺_c is a genuine gap

`inductive FrameClass` (`Axioms.lean:519-524`) is `Base | Dense | Discrete | Dedekind`. There is
no `Continuous`. `Axioms.lean:479-481` records that `FrameClass.Dedekind` is the paper's **TM⁺_dc**
(dense complete / real flow), not TM⁺_c.

`Axioms.lean:503-513` is the transcription source for the accompanying gap note, and it is
emphatic that renaming without it would hide something: TM⁺_c is completeness *simpliciter*, its
models are exactly `{ℤ, ℝ}` up to isomorphism, and "**No element of `FrameClass` picks that class
out** … adding one would require an axiom set for `Th(ℤ) ∩ Th(ℝ)` that this tree does not have."
The task's instruction to add a one-line note alongside the rename is correct and load-bearing.

### 2.5 A5 — the three-way strong-completeness status, all four citations verified exact

`StrongCompleteness.lean:25-41` is the terminology source ("strong completeness is reserved for
infinite premise sets"; `Context` is `List Formula`, so every context here is finite).

| Claim | Site | Verified |
|-------|------|----------|
| `CompactBase` — open obligation | `FormalSystem/Metalogic/SetConsequence.lean:219` | exact |
| `CompactDense` — open obligation | `FormalSystem/Metalogic/SetConsequence.lean:263` | exact |
| `strongCompletenessDiscrete_refuted` | `FormalSystem/Metalogic/DiscreteNonCompactness.lean:280` | exact; `lean_verify` → `[propext, Classical.choice, Quot.sound]` |
| Dedekind — not stated | `SetConsequence.lean` defines `SetSemanticConsequenceDedekindDense` (`:103`) but **no** `StrongCompletenessDedekind` and **no** `CompactDedekind` | confirmed by enumeration of every `def` in the file |

`FormalSystem/Metalogic.lean:83-101` already states the three-way split in house prose, including
the phrase "**unavailable on the primary source's own terms**" for Dedekind (Reynolds 1992
Theorem 7 is weak-only). **Transcribe from there rather than re-phrasing.**

### 2.6 A6 — the Decidability subsection

The README never mentions decidability. The transcription source named by the task,
`FormalSystem/Metalogic/Decidability.lean:118-160`, is current and precise. Verified against
source:

- `sound_of_isValid` — `FormalSystem/Metalogic/Decidability/Correctness.lean:100`
- `isValid_sound` — `Correctness.lean:111`; `lean_verify` → `[propext, Classical.choice, Quot.sound]`
- `valid_iff_allClosed` — **zero occurrences** anywhere in live `FormalSystem/`, confirming "open"
- `ruleSound_of_mem_allRulesForFC` — present in `Verified/Decidable.lean`

`Correctness.lean:183-224` ("Retired as vacuous") is the fuller statement of what is still owed
and why no `isValid`-shaped biconditional is written before it can be proved. Note that
`Decidability.lean`'s status section deliberately cites **files without line numbers**; the README
should copy that discipline, since these are the citations most likely to drift.

### 2.7 A7 — metrics: already applied in the working tree, uncommitted

`git blame` shows `README.md:19-21` as "Not Committed Yet". The working tree already reads
539 / ~170,898 / ~96,290, and `cloc` run exactly as the README prints it at `:23-26` returns
**539 files / 170,898 code / 96,290 comment** — an exact match.

Two residual items:

1. **Formatting slip introduced by that edit**: line 21 is `| Comment lines | ~96,290|` — the
   space before the closing pipe was dropped. Restore it.
2. The edit is **uncommitted**, so it is not attributable to any task. The implementation should
   carry it forward rather than reverting it, and the summary should record that A7 arrived from
   the working tree rather than from this task's own edit.

### 2.8 A8 — the Project Structure block (`:87-105`) — no line is copy-pasteable

Verified against the filesystem:

| Block says | Reality |
|-----------|---------|
| tree rooted `ProofChecker/` | repo is `BimodalLogic`; Lake lib root is `FormalSystem` (`lakefile.lean:17-19`, `srcDir := "."`, `roots := #[`FormalSystem]`) |
| `FormalSystem/Bimodal/` | **does not exist** |
| 8 subdirectories under `Bimodal/` | actual `FormalSystem/` top level is **10**: `Automation/ BaseLanguage/ Boneyard/ Examples/ FrameConditions/ Metalogic/ ProofSystem/ Semantics/ Syntax/ Theorems/` |
| `BaseLanguage/`, `Boneyard/` | **both absent from the diagram** |
| `Tests/` | actual tests live at `Tests/BimodalTest/` (plus `Tests/BimodalTest.lean`) |
| `docs/` | correct; repo top level is `build/ data/ docs/ FormalSystem/ latex/ other/ scripts/ specs/ Tests/ typst/` |

Regenerate from the filesystem. Note `Boneyard/` is 156 archived files and should be labelled as
the archive so its presence is not read as live code.

### 2.9 Relative links — verified, no work needed

All 12 non-URL markdown links in `README.md` resolve (`docs/**` ×8, `FormalSystem/Examples/BimodalProofs.lean`,
`FormalSystem/Metalogic/README.md`, `latex/BimodalReference.pdf`, `LICENSE`). The task said 13;
the count is 12, and the substance — no link work needed — holds. Because `readme-lint.sh` does
not cover the repository root, any *new* link added here must be checked by hand.

### 2.10 A9 — 44 → 45

`README.md:92` ("Axioms (44 constructors, 7 layers)") and `:164` ("all 44 constructors"). Ground
truth: **45 constructors in nine layers**, per `Axiom.minFrameClass`'s docstring
(`Axioms.lean:578`: "Total: 45 axiom constructors") and the anchor task's verified enumeration.
The "7 layers" at `:92` is also wrong — nine.

`docs/reference/axiom-reference.md`, which `:164` links to, is outside this task's file scope and
is presumably also stale; it is on the downstream 42→45 sweep list rather than here.

### 2.11 A10 — "axiom-free" is false

`README.md:129` reads "All soundness results are sorry-free and axiom-free (no `sorryAx`
dependency)". Every flagship result depends on `[propext, Classical.choice, Quot.sound]`. House
phrasing, verbatim from `FormalSystem/Metalogic.lean:48`:

> `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice, Quot.sound)`

Never "axiom-free". The anchor task removed this phrase from both anchors; this README is the
remaining live occurrence in the top-level layer.

### 2.12 A11 — the `WeakCanonical/` one-liner (`:98`)

"`WeakCanonical/ # Reynolds/Doets discrete pipeline`" undercounts. Measured contents (live,
`Boneyard/` excluded): **19 loose modules and 8 subdirectories**, including
`DenseModelSurgery/` (9 files, 7,568 lines) and `RealModel/` (7 files, 6,643 lines) — the
Dedekind/real route — and `GroupModel/` (6 files, 3,357 lines), which hosts the discharged
`countermodel_discrete`.

### 2.13 A12 — per-class axiom counts (`:147-150`)

`Axiom.minFrameClass` (`Axioms.lean:588-597`) partitions the 45 as **Base 37 / Dense 2 /
Discrete 3 / Dedekind 3**, and `Dense ≤ Dedekind` (`Axioms.lean:526-533`), so Dedekind inherits
the two Dense axioms.

| Row | README says | Correct | Verdict |
|-----|------------:|--------:|---------|
| Base | 37 | 37 | ✓ already correct |
| Discrete | 40 | 40 (37+3) | ✓ already correct |
| Dense | 38 | **39** (37+2) | fix |
| Continuous → Dedekind | 39 | **42** (37+2+3) | fix |

The same table's Continuous row gives Soundness and Completeness as `—` / `—`; both are proven
(§2.3). The mermaid nodes at `:132-136` carry the same per-class counts and must move together
with the table, or the two will disagree.

`:152` ("Burgess-Xu temporal (22)") is also wrong on the anchor's verified enumeration: BX
Temporal is **18** plus a separate "Additional BX Temporal" layer of **4**. Writing 22 as a single
figure is defensible only if the prose says so explicitly; the layer structure is 18 + 4.

---

## 3. Scope B — the `FormalSystem/**/README.md` layer

### 3.1 B1 — `FormalSystem/README.md:285`, `:289-290` overstate the headline open problem

Verbatim:

> `| 2 | Metalogic | **Complete** (Soundness, Completeness, Deduction, Decidability) |`
>
> **Key Results**: Soundness theorem, completeness theorem (Dense and Discrete variants),
> deduction theorem, and decidability are all fully proven.

Two distinct errors:

1. **Decidability is not fully proven.** Only the sound direction exists (§2.6). `valid_iff_allClosed`
   has zero occurrences; the biconditional and the four `Decidable (⊨ φ)` instances are open.
   `Correctness.lean:183-224` is the required reading before rewriting: two declarations —
   `validity_decidable` and `validity_has_decision_procedure` — previously papered over exactly
   this gap and were retired precisely because "their *names* claimed a decidability result their
   *proofs* did not contain." Reintroducing the claim in prose repeats the retired defect.
2. **"(Dense and Discrete variants)" undercounts.** `completeness` (Base,
   `BXCanonical/Completeness.lean:196`) and `completeness_dedekind`
   (`StrongCompleteness.lean:469`) both land. All four classes have weak completeness.

Row `| 1 | FrameConditions | Complete (Base, Dense, Discrete soundness) |` at `:284` has the same
three-of-four omission.

### 3.2 B2 — `Algebraic/README.md`: two phantom rows and three mutually inconsistent scope statements

Directory contents are exactly `BooleanStructure.lean` (441), `FlowFrame.lean` (806),
`InteriorOperators.lean` (176), `LindenbaumQuotient.lean` (393), `UltrafilterMCS.lean` (1,071) —
5 files, 2,887 lines, matching the anchor's inventory.

| Site | Claim | Reality |
|------|-------|---------|
| `:32` | `AlgebraicCompleteness.lean` \| Main completeness theorem \| **Sorry-free** | **file does not exist** — delete the row |
| `:55` | `DovetailedChain.lean` \| Dovetailed chain (active, deprecated) | **file does not exist** — delete the row |

The scope statements are inconsistent *three* ways, not two as the task states:

- `:3` "Contains the primary completeness path via deterministic chains" and `:8` "The
  deterministic chain construction (primary completeness path)"
- `:18-19` "The main completeness proof uses `Bundle/` (BFMCS). This algebraic path is
  supplementary infrastructure, **not required for the current proof architecture**."
- `:179` "[Bundle README](../Bundle/README.md) - **Primary** BFMCS completeness approach"

All three are wrong against the corrected anchor (`FormalSystem/Metalogic/README.md:36-45`):
**`BXCanonical` is the wired entry point**, and `Algebraic/` is not optional — `BXCanonical`
imports `Algebraic.FlowFrame` from four files (`Completeness.lean:13`,
`Chronicle/ChronicleToCountermodelBasic.lean:10`, `Chronicle/ChronicleMonadicBridge.lean:15`,
`DiscreteCarrierProbe.lean:7`), so it participates in the live proof. `:49-55` correctly records
the deterministic-chain modules as archived, which is what makes `:3` and `:8` self-contradictory
within the same file.

### 3.3 B3 — `WeakCanonical/README.md`: **four** phantom Key Results, not three

`:44-47` advertises four results. `grep` across every live (non-`Boneyard/`) `.lean` file:

| Advertised | Live occurrences |
|-----------|-----------------:|
| `weak_completeness` | **0** |
| `truth_lemma` | **0** (the task lists only three; this is a fourth) |
| `transfer_theorem` | **0** |
| `normal_form_reduction` | **0** |

`TruthLemma.lean` contains only `bot_not_in_mcs`, `G_forward_mcs`, `G_backward_mcs`,
`H_forward_mcs`, `H_backward_mcs` — no `truth_lemma`. The real termini are:

- `countermodel_discrete` — `WeakCanonical/GroupModel/CountermodelBase.lean:142`
- `truth_transfer` — `WeakCanonical/Transfer.lean:359`

**Measured inventory for the `:12-33` Modules table.** 19 loose modules (the table lists 14) and
8 subdirectories (the table lists 6):

| Missing loose module | Lines |
|---|---:|
| `BackAndForth.lean` | 265 |
| `ColourOrders.lean` | 328 |
| `MixedSum.lean` | 558 |
| `PriorDefsDense.lean` | 408 |
| `PriorExpressivenessDense.lean` | 412 |

Also stale: `OrderedSum.lean` 52 → **57**.

| Subdirectory | README | Actual files | Actual lines |
|---|---:|---:|---:|
| `DenseModelSurgery/` | *absent* | 9 | 7,568 |
| `EFGames/` | 8 / 11,872 | 8 ✓ | 11,872 ✓ |
| `Expressiveness/` | 5 / 9,503 | 5 ✓ | 9,503 ✓ |
| `GroupModel/` | 6 / 3,357 | 6 ✓ | 3,357 ✓ |
| `IntegerModel/` | 6 / 5,503 | 6 ✓ | **5,700** |
| `Kamp/` | 99 / 71,246 | **116** | **77,619** |
| `RealModel/` | *absent* | 7 | 6,643 |
| `Separation/` | 3 / 926 | 3 ✓ | 926 ✓ |

`:51-63` (Architecture block) references `ExpressiveCompleteness/`, which was consolidated into
`FormalSystem/Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness` — remove it from the live
architecture diagram.

`readme-lint.sh` Check 2 independently flags exactly this set (`BackAndForth.lean`,
`ColourOrders.lean`, `MixedSum.lean`, `PriorDefsDense.lean`, `PriorExpressivenessDense.lean`,
`DenseModelSurgery/`, `RealModel/`), so **Check 2's output is a free mechanical checklist for
B3 and B13** and should be re-run after each edit.

### 3.4 B4 — the contradiction is real, but the task attributes it to the wrong file

| Site | Text |
|------|------|
| `FormalSystem/README.md:97` | "37 Base constructors …, **3 Discrete-only, 2 Dense-only**" |
| `FormalSystem/ProofSystem/README.md:37` | "37 Base constructors, **2 Discrete-only, 3 Dense-only**" |

`Axiom.minFrameClass` (`Axioms.lean:589-594`) settles it: **2 Dense** (`density`,
`dense_indicator`), **3 Discrete** (`prior_UZ`, `prior_SZ`, `z1`).

**So `FormalSystem/README.md:97` is already correct and `ProofSystem/README.md:37` is the wrong
one.** The task description presents the pair without saying which side wins; an implementer
following it literally could "fix" the correct site. Both nevertheless omit the 3 Dedekind
axioms, which is why both totals read 42. Each layer table is internally consistent with its own
prose (`FormalSystem/README.md:82-89` sums 4+5+22+1+5+2+1+2 = 42; `ProofSystem/README.md:26-35`
likewise) — both need the ninth layer added and the BX Temporal row split 18 + 4.

### 3.5 B5 — the 42 → 45 sweep sites, enumerated

| File | Lines |
|------|-------|
| `FormalSystem/README.md` | `:79` ("**42 constructors** organized into 8 layers"), `:92`, `:94`, `:200`, `:252`, `:282` |
| `FormalSystem/ProofSystem/README.md` | `:12`, `:22`, `:40` |

Nine sites, as the task states. `:79` and `ProofSystem/README.md:22` also say "8 layers" —
the anchor task fixed the ROADMAP to **nine**, and that is the value this pass should converge on.

`ProofSystem/README.md:39-41` ("The root README references '21 axiom schemata'") is a dangling
cross-reference: the top-level `README.md` no longer contains the string "21 axiom schemata".
`FormalSystem/README.md:92-95` repeats the same schema-vs-constructor note. Both need the count
updated and the cross-reference either repointed or dropped.

### 3.6 B6 — "three variants" is now four

- `FormalSystem/README.md:138` — "TM logic has three variants based on frame conditions", with
  sections for Base / Dense / Discrete at `:140-165` and no Dedekind section.
- `FormalSystem/ProofSystem/README.md:5-6` — "all three TM logic variants (Base, Dense,
  Discrete)".

`completeness_dedekind` appears in neither file. A `### TM Dedekind (Base + 2 Dense + 3 Dedekind
constructors)` section modelled on the existing three, citing `soundness_dedekind`
(`Metalogic/Soundness.lean`) and `completeness_dedekind` (`Metalogic/StrongCompleteness.lean`)
against `ValidDedekindDense` (§2.3), plus the TM⁺_c gap note (§2.4), closes it.

`:167-169` ("Variant Incompatibility: Dense and discrete extensions are incompatible") is correct
but now incomplete — `Axioms.lean:481-483` adds that Discrete and Dedekind are likewise
incomparable and `Dedekind ≰ Dense`.

### 3.7 B7 — `BXCanonical/README.md` scoped to two classes of four, plus a fourth phantom

- `:3` and `:5` scope the directory to "Dense and Discrete TM completeness".
- `:24-28` Key Results lists `completeness_dense`, `completeness_discrete`, and `truth_lemma`.

Verified: `completeness` (Base) is at `BXCanonical/Completeness.lean:196` — the theorem that
closed last and the reason the tree is sorry-free — and the Dedekind route lives at
`BXCanonical/CompletenessDedekind.lean` (607 lines). Both are absent. And **`truth_lemma` does
not exist in `BXCanonical/` either** (`TruthLemma.lean` holds `bot_not_in_mcs`, `imp_iff_mcs`,
`G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`, `F_from_witness`, `P_from_witness`,
`until_forward_mcs`, `since_forward_mcs`) — a third phantom-declaration site, matching §3.3.

**Measured Modules table corrections** (`:13-22`):

| File | README | Actual |
|------|-------:|-------:|
| `CanonicalChain.lean` | 110 | **119** |
| `CanonicalModel.lean` | 794 | **855** |
| `Completeness.lean` | 439 | **432** |
| `Frame.lean` | 710 | **728** |
| `OrderedSeedConsistency.lean` | 254 | **261** |
| `TruthLemma.lean` | 302 | **312** |
| `CompletenessDedekind.lean` | *absent* | **607** |
| `DiscreteCarrierProbe.lean` | *absent* | **94** |
| `Chronicle/` | 7 files | **14** files, 18,018 lines |
| `Filtration/` | 1 file ✓ | 1 file, 139 lines |
| `Quasimodel/` | 6 files | **5** files, 1,691 lines |

Row `:13` (the sibling-aggregator row) was already repaired by the anchor task and is correct.

### 3.8 B8 — `Bundle/README.md` hedges against sorries that do not exist

| Line | Text | Problem |
|------|------|---------|
| `:70` | "**Active sorries in Bundle/**: 0 in core completeness chain." | the qualifier "in core completeness chain" asserts sorries elsewhere |
| `:72-73` | "Any remaining sorries are in optional or experimental files that do not affect the primary completeness theorems." | asserts live sorries; C3 says zero |
| `:170` | "**Eliminate temporal sorries**: Add temporal_backward_G/H properties to FMCS" | dead Future Work item |

C3 is directory-wide and unconditional. Both qualifiers go; `:170` goes. `:159` ("Archived the
previous 30-sorry Representation development to `Boneyard/Metalogic_v5/`") is a *historical*
statement about the archive and survives.

### 3.9 B9 — `Decidability/README.md:11` is stale

> "`decide_sound` (`Correctness.lean`) is **the one direction** that is machine-checked"

Stale since `sound_of_isValid` (`Correctness.lean:100`) and `isValid_sound` (`:111`) landed —
`isValid_sound` verified at `[propext, Classical.choice, Quot.sound]`. Mirror
`Decidability.lean:141-153`, which separates the two claims correctly: `decide_sound` is the
corollary at the empty context, while the `isValid`-shaped sound direction is a separate landed
result. `:12-15` (the biconditional is not established, with the pointer to the "Retired as
vacuous" section) is **already correct** and should be preserved unchanged. Otherwise this is the
most accurate README of the set.

### 3.10 B10 — `ProofSystem/README.md`: phantom module and four stale line counts

| Site | Claim | Reality |
|------|-------|---------|
| `:15` | `Substitution.lean` \| 459 lines | **file does not exist** (`ProofSystem/` holds exactly `Axioms.lean`, `Derivable.lean`, `Derivation.lean`, `LinearityDerivedFacts.lean`) |
| `:64` | `Formula.subst`: Atom substitution preserving derivability | **zero occurrences** of `Formula.subst` or `def subst` anywhere in `Syntax/` or `ProofSystem/` |
| `:12` | `Axioms.lean` 468 | **625** |
| `:13` | `Derivation.lean` 385 | **386** |
| `:14` | `Derivable.lean` 221 | **228** |
| `:16` | `LinearityDerivedFacts.lean` 82 | **88** |

The task lists only `Axioms.lean`; all four are stale. "Inference Rules (7 total)" is **correct** —
`inductive DerivationTree` has exactly 7 constructors (`axiom`, `assumption`, `modus_ponens`,
`necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening`).

### 3.11 B11 — sibling-aggregator convention: one of three sites already fixed

The convention is stated at `FormalSystem/Metalogic/README.md:119-136`. C8 passes, so no
*filesystem* violation exists; these are documentation violations only.

| Site | Status |
|------|--------|
| `BXCanonical/README.md:13` | **already repaired** by the anchor task — now reads "`../BXCanonical.lean` \| 43 \| … **Sibling aggregator**, at `FormalSystem/Metalogic/BXCanonical.lean` — not a file inside this directory" |
| `Algebraic/README.md:26` | `\| `Algebraic.lean` \| Module root, re-exports all components \|` — violates; the sibling is `FormalSystem/Metalogic/Algebraic.lean`, **40** lines |
| `Core/README.md:21` | `\| `Core.lean` \| Module root, re-exports components \|` — violates; the sibling is `FormalSystem/Metalogic/Core.lean`, **37** lines |

The repaired `BXCanonical/README.md:13` row is the **house pattern to copy verbatim** for the
other two. `Core/README.md:39` also draws `Core.lean (aggregator)` inside the directory's
dependency flowchart — the same error in ASCII form.

Also at `Core/README.md:25`: "`RestrictedMCS/` … (2 files)" — the directory holds exactly one
`.lean` file (`Basic.lean`) plus its README.

### 3.12 B12 — `FrameConditions/README.md`

| Site | Claim | Reality |
|------|-------|---------|
| `:22` | `FrameClass` inductive at `ProofSystem/Axioms.lean:378` | **`:519`** |
| `:3-4` | "distinguishing the Base, Dense, and Discrete variants" | four variants |
| `:4` | "Four modules, **816 lines**" | 4 modules ✓, **892** lines |
| `:10` | "`FrameClass.lean` \| 220 \| **The four marker typeclasses**" | **292** lines, and there are **five** classes |
| `:11` | `Validity.lean` 204 | **209** |
| `:12` | `Soundness.lean` 190 | **204** |
| `:13` | `Compatibility.lean` 176 | **187** |
| `:42` | "Live importers … **1** — `FormalSystem/Bimodal.lean`, the library root" | the count **1** is correct; the file is `FormalSystem/FormalSystem.lean:13` — `FormalSystem/Bimodal.lean` does not exist |

The fifth typeclass is `DedekindTemporalFrame` (`FrameConditions/FrameClass.lean:182`). Its
docstring at `:165-178` is unusually explicit and should be transcribed rather than paraphrased:
it is "a **side-car, not the load-bearing layer**" — neither soundness nor completeness consumes
it, exactly as neither consumes `DenseTemporalFrame` or `DiscreteTemporalFrame`; the load-bearing
predicates are `ValidDedekind` / `ValidDedekindDense` in `Semantics/Validity.lean`.

The measured dependency-direction claims at `:37-41` are **correct** and must be preserved:
0 files under `Metalogic/` import `FormalSystem.FrameConditions`, and the module's only external
importer is the library root. Only the filename at `:42` is wrong.

(`FrameConditions/FrameClass.lean:21-24` lists only four classes in its own module docstring —
the same stale count, in a `.lean` file outside this task's declared file scope. Recorded for a
downstream pass.)

### 3.13 B13 — the low-severity set, all confirmed and all larger than listed

**`FormalSystem/README.md:183-193` — every one of the nine root-file line counts is wrong, and
the first row names a file that does not exist.**

| README row | Claimed | Actual |
|-----------|--------:|-------:|
| `Bimodal.lean` | 86 | **file does not exist** — the roots are `FormalSystem.lean` (repo root, **50**) and `FormalSystem/FormalSystem.lean` (**107**) |
| `Automation.lean` | 92 | **102** |
| `Examples.lean` | 27 | **33** |
| `FrameConditions.lean` | 52 | **68** |
| `Metalogic.lean` | 55 | **199** |
| `ProofSystem.lean` | 73 | **88** |
| `Semantics.lean` | 86 | **137** |
| `Syntax.lean` | 68 | **75** |
| `Theorems.lean` | 74 | **88** |
| `BaseLanguage.lean` | *absent* | **34** |

The `Bimodal.lean` row is the same defect as A8 in table form. The two-file Lake root pair is
described precisely at `scripts/check-module-invariants.sh:402-407` (C8's own comment), which the
anchor task already transcribed into `Metalogic/README.md` — reuse that wording.

**`Semantics/README.md:6-15`** lists 7 of 12 loose modules. Missing: `DurationClassification.lean`
(259), `FrameAxioms.lean` (239), `IntTransfer.lean` (366), `PartialHistory.lean` (213),
`PartialHistoryOrder.lean` (238), plus the `Extension/` subdirectory (5 files). The table has no
Lines column, so no line-count work is needed there.

**`Theorems/README.md:10-21`** omits `ContextualProofs.lean` (474) and `DiscreteUnfolding.lean`
(476). Every listed line count is also stale: `Combinators.lean` 675 → **747**,
`DedekindDerived.lean` 400 → **413**, `GeneralizedNecessitation.lean` 240 → **241**,
`ModalS4.lean` 468 → **421**, `ModalS5.lean` 859 → **781**, `Perpetuity.lean` 88 → **95**,
`TemporalDerived.lean` 366 → **801**. `Perpetuity/` holds 3 `.lean` files; `Propositional/` holds
3 ✓.

**`FormalSystem/Theorems.lean`** — the PROVEN/SORRY-FREE conflation is at `:41`, `:42`, `:45`,
`:46` ("COMPLETE (…, zero sorry)" as a single status token). `:49-54` use the correct
"PROVEN (zero sorry)" form and are the in-file model to copy. `:84` links
`[Propositional.lean](Theorems/Propositional.lean)` — `FormalSystem/Theorems/Propositional` is a
**directory** (`Connectives.lean`, `Core.lean`, `Reasoning.lean`, `README.md`) with no
`Propositional.lean`; repoint to `Theorems/Propositional/README.md`. The other four links in that
block resolve.

**`Core/README.md:25`** — `RestrictedMCS/` "(2 files)" → 1. (Covered in §3.11.)

### 3.14 B14 — the 5 broken references, all targets located

`readme-lint.sh` Check 3 scans every `[text](path)` markdown link in every non-`Boneyard/`
README under `FormalSystem/` (`scripts/readme-lint.sh:98-122`).

| Broken reference | Correct target (verified to exist, with a README) |
|------------------|---------------------------------------------------|
| `WeakCanonical/EFGames/README.md:39` → `../ExpressiveCompleteness/README.md` | `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` |
| `WeakCanonical/Expressiveness/README.md:34` → `../ExpressiveCompleteness/README.md` | `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` |
| `WeakCanonical/Separation/README.md:42` → `DedekindZ/README.md` | `../../../Boneyard/Kamp/KampWeakCanonical/Separation/DedekindZ/README.md` |
| `WeakCanonical/Separation/README.md:43` → `Hierarchy/README.md` | `../../../Boneyard/Kamp/KampWeakCanonical/Separation/Hierarchy/README.md` |
| `Theorems/Perpetuity/README.md:46` → `Bridge.lean` | `MonotonicityDuality.lean` |

The last one needs more than a path swap. `Theorems/Perpetuity/` contains `Helpers.lean`,
`MonotonicityDuality.lean`, `Principles.lean` — no `Bridge.lean`. Verified declaration names and
locations:

| Principle | Declaration | Site |
|-----------|-------------|------|
| P1 | `perpetuity_1` | `Principles.lean:77` |
| P2 | `perpetuity_2` | `Principles.lean:308` |
| P3 | `perpetuity3` | `Principles.lean:443` |
| P4 | `perpetuity4` | `Principles.lean:512` |
| P5 | `perpetuity5` | `Principles.lean:811` |
| P6 | `perpetuity6` | `MonotonicityDuality.lean:560` |

So `Perpetuity/README.md:45` ("**P1-P5**: `perpetuity_1` through `perpetuity_5` in
`Principles.lean`") is *also* wrong: the underscore is present only on P1 and P2, and there is no
`perpetuity_5`. Enumerate the six exact names rather than writing a range. `Perpetuity/README.md`
additionally omits `MonotonicityDuality.lean` from its inventory (flagged by Check 2).

Alternatively, since all three `ExpressiveCompleteness` / `DedekindZ` / `Hierarchy` targets are
now archived, deleting those four "Related Documentation" bullets also takes the count to 0 and
avoids live docs linking into the archive. **Recommendation: repoint rather than delete**, and
label each as archived — the existing `Metalogic/README.md:38` precedent already links to
`FormalSystem/Boneyard/README.md` from live documentation, so linking into the archive is
established house practice.

---

## 4. Unlisted defects found in the same lines

These sit inside the task's file scope and would be propagated by a pass that fixes only the
enumerated items.

1. **`FormalSystem/README.md:266-267` ships a build command that fails.** The block reads
   `lake build Bimodal`. `lakefile.lean` declares exactly two libs, `FormalSystem` and
   `BimodalTest`; there is no `Bimodal` target. Same class of defect as A8: a copy-pasteable
   block that cannot be copy-pasted. Correct form: `lake build FormalSystem`.

2. **`FormalSystem/README.md:307` — `**Parent**: [Project Root](../../)`.** From `FormalSystem/`,
   `../../` resolves above the repository root. Should be `../`. `readme-lint.sh` Check 3 does not
   catch it because the path exists on disk.

3. **Stale `Bimodal.*` module references throughout the layer — invisible to C5.** C5's regex is
   `\b(?:FormalSystem|BimodalTest)(?:\.[A-Z][A-Za-z0-9_]*)+`
   (`scripts/check-module-invariants.sh:279`), so it never sees a name beginning `Bimodal.`.
   Residue of the root-namespace rename, 40+ occurrences repo-wide. Inside this task's scope:
   `WeakCanonical/README.md:67-68`, `BXCanonical/README.md:50-51`, `Algebraic/README.md:173`,
   `FrameConditions/README.md:37,39,40,41,42,55`. All 17 distinct names were test-resolved under
   the `Bimodal.X → FormalSystem.X` rewrite using C5's own resolution rule; **every one resolves**,
   so the rename is safe. See the warning at §6.2 before applying it.

4. **`FormalSystem/README.md:233-243` Submodule Navigation omits `BaseLanguage/` and
   `Boneyard/`.** See §6.1 — adding `BaseLanguage/` naively will *fail the verification gate*.

5. **`FormalSystem/README.md:152` and `ProofSystem/README.md:30`** give BX Temporal as a single
   layer of 22. Source structure is 18 + 4 across two layers (§2.13).

6. **`ProofSystem/README.md:39-41`** cross-references a "21 axiom schemata" figure that no longer
   appears in the top-level README.

---

## 5. What must not be touched

Verified current and precise; these are transcription *sources*, not edit targets:

- `FormalSystem/Metalogic.lean` (`:19-131` especially — the four-class status block, the
  three-way strong-completeness split at `:83-101`, and the house SORRY-FREE phrasing at `:48`)
- `FormalSystem/Metalogic/Decidability.lean` (`:118-160`)
- `FormalSystem/Metalogic/WeakCanonical.lean`
- `FormalSystem/Metalogic/StrongCompleteness.lean` (`:25-41` terminology, `:456` headline phrasing)
- `FormalSystem/Metalogic/SoundnessLemmas/README.md`
- `FormalSystem/ProofSystem/Axioms.lean` (`:479-513` for the Dedekind/TM⁺_c note,
  `:571-597` for `minFrameClass`)
- `FormalSystem/Metalogic/Decidability/Correctness.lean:183-224` ("Retired as vacuous")
- `FormalSystem/FrameConditions/FrameClass.lean:159-191` (the `DedekindTemporalFrame` side-car note)
- The two anchor documents corrected by the prior task: `specs/ROADMAP.md`,
  `FormalSystem/Metalogic/README.md`, and the single repaired row at
  `FormalSystem/Metalogic/BXCanonical/README.md:13`

---

## 6. Decisions required before implementation

### 6.1 Adding `BaseLanguage/` to the Submodule Navigation table will break the gate

`FormalSystem/BaseLanguage/README.md` **does not exist** — it is one of the 9 missing READMEs
that Check 1 reports, and the task's gate declares the missing-README count out of scope. But
Check 3 scans *every* markdown link in every README under `FormalSystem/`. Adding a row shaped
like its eight siblings —

```
| [BaseLanguage/](BaseLanguage/README.md) | Yes | ... |
```

— creates a **new broken reference**, taking Check 3 from the target 0 back to 1 and failing the
gate that B14 exists to satisfy.

Options:

- **(a) List `BaseLanguage/` without a link** and mark the README column "No" — the table already
  has a README column, so an honest "No" is the table's own idiom. Zero gate risk.
  **Recommended.**
- **(b) Create `FormalSystem/BaseLanguage/README.md`** as part of this task. This closes a Check 1
  item (9 → 8) as a bonus but adds a new file outside the declared file scope and outside the
  "prose and markdown only, correcting existing documents" framing.
- **(c) Omit `BaseLanguage/` from the table.** Leaves the layer incomplete and leaves Check 2
  flagging it.

`Boneyard/` is unaffected — `FormalSystem/Boneyard/README.md` exists, so it can be linked
normally, and it should be labelled as the archive.

### 6.2 The `Bimodal.*` → `FormalSystem.*` rename is safe but changes what C5 checks

Every one of the 17 distinct names resolves under the rewrite (§4.3), so applying it inside this
task's scope is safe **today**. The trap is structural rather than immediate: these strings are
currently invisible to C5, and renaming them makes them **permanently visible** to it. Any future
module relocation will then break C5 at these sites, where before it would have passed silently.
That is a net improvement — C5 exists to catch exactly this — but it should be a deliberate
choice, not a side effect.

Options:

- **(a) Rename only within this task's file scope** (6 files, 11 lines). Consistent with the
  task's framing; leaves ~30 occurrences elsewhere. **Recommended**, with the remainder handed to
  a downstream sweep.
- **(b) Rename repo-wide** (40+ occurrences across ~20 READMEs). Larger than the declared scope,
  and mixes a mechanical rename into a semantic-correction pass, making the diff harder to review.
- **(c) Leave them.** The `FormalSystem/Bimodal.lean` filename at `FrameConditions/README.md:42`
  must still be fixed regardless, since that is a *file path*, not a module name.

### 6.3 Two figures in the corrected anchor do not reproduce, and must not be copied forward

`FormalSystem/Metalogic/README.md:44-45` states:

> - `BXCanonical → WeakCanonical` — 2 import lines
> - `BXCanonical → Algebraic` — 2 import lines

Re-derived by `grep -rn "^import FormalSystem.Metalogic.{WeakCanonical,Algebraic}"` over
`FormalSystem/Metalogic/BXCanonical/`:

- **`BXCanonical → WeakCanonical`: 9 import lines** across 4 files (`CompletenessDedekind.lean:8`,
  `Completeness.lean:12`, `Chronicle/ChronicleMonadicBridge.lean:7,8,9,11,12,13`,
  `Chronicle/ChronicleToCountermodel.lean:8`)
- **`BXCanonical → Algebraic`: 4 import lines** (`Chronicle/ChronicleToCountermodelBasic.lean:10`,
  `DiscreteCarrierProbe.lean:7`, `Completeness.lean:13`, `Chronicle/ChronicleMonadicBridge.lean:15`)

The anchor's *substantive* claim — that `BXCanonical` imports from both, so all three routes
participate in the live proof — is **correct and strengthened** by the true counts. Only the
numerals are stale (they predate `ChronicleMonadicBridge.lean` and `CompletenessDedekind.lean`).

`FormalSystem/Metalogic/README.md` is outside this task's file scope and is the document
everything else realigns against, so:

- **Recommended**: do **not** edit the anchor here. Do **not** transcribe "2 import lines" into
  `Algebraic/README.md` when rewriting its scope statements (§3.2) — cite the fact ("`BXCanonical`
  imports `Algebraic.FlowFrame`") without the numeral. Hand the two numerals to a follow-up.
- If the orchestrator prefers, a one-line correction to the anchor is defensible on the same
  reasoning the prior task used for its own gated deviation, but it should be declared as a
  deviation rather than taken silently.

---

## 7. Scope correction: `file_scope` is missing four files

The dispatch declares 13 files. **B14 requires four files that are not among them**:

- `FormalSystem/Metalogic/WeakCanonical/EFGames/README.md`
- `FormalSystem/Metalogic/WeakCanonical/Expressiveness/README.md`
- `FormalSystem/Metalogic/WeakCanonical/Separation/README.md`
- `FormalSystem/Theorems/Perpetuity/README.md`

Without them the gate "broken-reference count must drop from 5 to 0" is unsatisfiable. The plan
should extend `file_scope` to 17 files.

Conversely, `FormalSystem/Metalogic/BXCanonical/README.md` remains in scope for B7 even though
its B11 row was already fixed upstream.

---

## 8. Verified ground-truth reference (for the implementer)

Every figure below was measured for this report. None is copied from another markdown document.

**Axiom partition** — `Axiom.minFrameClass`, `Axioms.lean:588-597`:

| Class | Own axioms | Cumulative (with `Dense ≤ Dedekind`) |
|-------|-----------:|-------------------------------------:|
| Base | 37 | 37 |
| Dense | 2 (`density`, `dense_indicator`) | 39 |
| Discrete | 3 (`prior_UZ`, `prior_SZ`, `z1`) | 40 |
| Dedekind | 3 (`prior_U_gap`, `prior_S_gap`, `sep`) | **42** (37 + 2 + 3) |
| **Total constructors** | | **45**, in **nine** layers |

**Flagship theorems** — all `[propext, Classical.choice, Quot.sound]`, all sorry-free:

| Theorem | Site | Verified by |
|---------|------|-------------|
| `completeness` (Base) | `Metalogic/BXCanonical/Completeness.lean:196` | C2 |
| `completeness_dense` | `Metalogic/BXCanonical/Completeness.lean` | C2 |
| `completeness_discrete` | `Metalogic/BXCanonical/Completeness.lean:296` | C2 |
| `Chronicle.countermodel_dense` | `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | C2 |
| `soundness_dedekind` | `Metalogic/Soundness.lean:1927` | `lean_verify` |
| `completeness_dedekind` | `Metalogic/StrongCompleteness.lean:469` | `lean_verify` |
| `isValid_sound` | `Metalogic/Decidability/Correctness.lean:111` | `lean_verify` |
| `strongCompletenessDiscrete_refuted` | `Metalogic/DiscreteNonCompactness.lean:280` | `lean_verify` |
| `countermodel_discrete` | `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean:142` | prior C2-adjacent run |

**Open / refuted:**

| Statement | Status | Site |
|-----------|--------|------|
| `valid_iff_allClosed`, `isValid φ fc = true ↔ ⊨ φ`, the four `Decidable (⊨ φ)` instances | **open** — zero occurrences | `Correctness.lean:209-224` |
| `CompactBase`, `StrongCompletenessBase` | **open** | `SetConsequence.lean:219`, `:211` |
| `CompactDense`, `StrongCompletenessDense` | **open** | `SetConsequence.lean:263`, `:256` |
| `StrongCompletenessDiscrete` | **refuted** | `DiscreteNonCompactness.lean:280` |
| Strong completeness, Dedekind | **not stated** — no `CompactDedekind`, no refutation | `Metalogic.lean:98-101` |

**Phantom declarations advertised in documentation (all zero live occurrences):**
`weak_completeness`, `transfer_theorem`, `normal_form_reduction`, `truth_lemma` (both in
`WeakCanonical/README.md:45` and `BXCanonical/README.md:28`), `Formula.subst`, `perpetuity_5`,
`perpetuity_6`.

**Phantom files advertised in documentation:**
`FormalSystem/Bimodal/` (dir), `FormalSystem/Bimodal.lean`,
`Metalogic/Algebraic/AlgebraicCompleteness.lean`, `Metalogic/Algebraic/DovetailedChain.lean`,
`ProofSystem/Substitution.lean`, `Theorems/Perpetuity/Bridge.lean`,
`Theorems/Propositional.lean` (is a directory),
`Metalogic/WeakCanonical/ExpressiveCompleteness/`, `.../Separation/DedekindZ/`,
`.../Separation/Hierarchy/` (last three archived under `Boneyard/Kamp/KampWeakCanonical/`).

---

## 9. Suggested phase decomposition

Territory is disjoint between Phase group A (`README.md` alone) and group B, so the two can run
in parallel. Within group B, phases 3-7 touch disjoint files.

| Phase | Files | Content | Verification |
|------:|-------|---------|--------------|
| 1 | `README.md` | A1 (delete `:154-156`), A10 (`:129` house phrasing), A2/A3/A5 — rewrite `:127-152` prose, mermaid, and axiom table against `Metalogic.lean:19-131` and `StrongCompleteness.lean:25-41` | `grep -c 'axiom-free'` = 0; every named theorem re-grepped |
| 2 | `README.md` | A4 (rename Continuous → Dedekind + TM⁺_c gap note from `Axioms.lean:503-513`), A12 (Dense 39, Dedekind 42), A9 (45 / nine layers), A6 (new Decidability subsection from `Decidability.lean:141-160`), A8 (regenerate the tree), A7 (restore the dropped space at `:21`) | tree matches `ls`; hand-check all links (readme-lint does not cover the repo root) |
| 3 | `FormalSystem/README.md` | B1, B4 (leave `:97` alone — it is correct), B5, B6, B13 root-file table, §6.1 decision, plus the two unlisted `lake build Bimodal` / `../../` fixes | `readme-lint.sh` Check 2 for this file; Check 3 not regressed |
| 4 | `ProofSystem/README.md` | B4 (`:37` is the wrong one), B5, B6, B10 | layer table sums to 45 across nine layers |
| 5 | `Metalogic/{Algebraic,WeakCanonical,BXCanonical}/README.md` | B2, B3, B7, B11 (Algebraic row), inventory refresh from §3.2/§3.3/§3.7 | `readme-lint.sh` Checks 2 and 3 |
| 6 | `Metalogic/{Bundle,Decidability,Core}/README.md`, `FrameConditions/README.md` | B8, B9, B11 (Core row + flowchart), B12 | C8 still passes |
| 7 | `Semantics/README.md`, `Theorems/README.md`, `Theorems.lean`, and the four §7 scope additions | B13 remainder, B14 | **`readme-lint.sh` broken references 5 → 0** |
| 8 | — | Gate: `check-module-invariants.sh` ALL CHECKS PASSED (C5, C8, C9 in particular); `readme-lint.sh` broken refs 0, missing READMEs unchanged at 9; `git diff --stat` shows no `.lean` change except `FormalSystem/Theorems.lean` (docstring only) | — |

**Gate note on Phase 8**: `readme-lint.sh` will still exit FAIL on its 9 missing READMEs; that is
the recorded baseline and is explicitly out of scope. The gate is the *broken-reference* count.
`FormalSystem/Theorems.lean` is the one `.lean` file in scope, and only its module docstring
(`:41-46`, `:84`) may change — no declaration, signature, import, or tactic.

---

## 10. Tactic survey

Not applicable. This task is prose-and-markdown only; no proof goals are in scope and no `.lean`
declaration may change. The Lean tooling used for this report was `lean_verify` (`#print axioms`)
for four axiom profiles, plus `scripts/check-module-invariants.sh` and `scripts/readme-lint.sh`,
which are the task's own verification gate.

---

*Last verified: 2026-08-25*
