# Anchor-Document Verification: `specs/ROADMAP.md` and `FormalSystem/Metalogic/README.md`

**Scope**: verify, against Lean source and the invariant scripts, every defect the task
description asserts in the two anchor documents; establish the ground-truth replacement values;
and record the defects the task description does *not* list but which sit in the same lines and
would be propagated by a pass that trusts the two anchors.

**Method**: no claim below is taken from another document. Axiom counts come from enumerating
`inductive Axiom`; axiom profiles from `#print axioms` (via `lean_verify`) and the C2 baseline;
file/line inventories from a reimplementation of the invariant script's own `live_files` walk
(`scripts/check-module-invariants.sh:212-219`, `Boneyard/` pruned).

**Gate runs performed for this report**:

| Command | Result |
|---------|--------|
| `bash scripts/check-module-invariants.sh` | **ALL CHECKS PASSED** (exit 0), at commit `e0d92a930` |
| `bash scripts/readme-lint.sh` | **FAIL** — 9 missing READMEs, 5 broken references (pre-existing) |

Both are the baselines the task's verification gate must be measured against.

---

## 1. Verdict summary

| Site | Task's claim | Verdict | Notes |
|------|--------------|---------|-------|
| A1 | ROADMAP `:109-115` "bridge is MISSING" is superseded | **CONFIRMED** | plus an unlisted knock-on at `:27-31` — see §2.2 |
| A2 | "42 in 6 layers" at `:15`, `:356-357`; actual 45 | **CONFIRMED** | 45 by enumeration; §3.1 |
| A3 | layer table `:363-443` missing a 7th Dedekind layer | **CONFIRMED but INCOMPLETE** | three layers missing, three phantom rows present, all 45 line citations stale; §3.2 |
| A4 | `:348-350` C2 list omits `completeness_dedekind` | **CONFIRMED, with a caveat** | it is *not* in C2's baseline; §3.3 |
| B1 | README `:214` records `sorryAx` for `completeness` | **CONFIRMED FALSE** | C2 baseline is clean; §4.1 |
| B2 | README `:235-246` "exactly one structural sorry" | **CONFIRMED FALSE** | C3 = zero; theorem relocated; §4.2 |
| B3 | sibling-aggregator convention violated | **CONFIRMED, but mis-cited** | the instance is `BXCanonical/README.md:13`, not `Metalogic/README.md:13`; §4.3 |
| B4 | README `:147-150` Lake root wrong | **CONFIRMED, and the task's replacement is itself wrong** | §4.4 |
| B5 | file/line counts stale | **CONFIRMED, and ~3x larger than listed** | §4.5 |

Two findings require a decision before implementation and are called out in §6.

---

## 2. Scope A1 — the `isValid`-to-validity bridge

### 2.1 The primary site (`specs/ROADMAP.md:109-115`) — confirmed stale

The bullet reads "No declaration anywhere takes `DecisionProcedure.isValid` … as its subject in a
semantic theorem." Refuted by source:

- `FormalSystem/Metalogic/Decidability/Correctness.lean:100` —
  `theorem sound_of_isValid {φ} (r : DecisionResult φ) (h : r.isValid = true) : ⊨ φ`
- `FormalSystem/Metalogic/Decidability/Correctness.lean:111` —
  `theorem isValid_sound (φ : Formula) (fc : FrameClass) (h : isValid φ fc = true) : ⊨ φ`

with the sibling forms `decide_isValid_sound` (`:117`), `isTautology_sound` (`:124`),
`isContradiction_sound` (`:131`), `decideBlocking_isValid_sound` (`:172`),
`decideAuto_isValid_sound` (`:180`), and the three frame-class-relativized forms (`:150`, `:157`,
`:164`).

**What is genuinely still open**, and the house formulation for it, is already written in-source
at `Correctness.lean:209-224` — the implementer should transcribe from there rather than
re-phrase. Its content: the *completeness* direction `⊨ φ → isValid φ fc = true`, hence the
biconditional and the four `Decidable (⊨ φ)` instances, requires `valid_iff_allClosed`, which
needs the fuel/termination side and the truth-lemma gate on top of `ruleSound_of_mem_allRulesForFC`
(`Verified/Decidable.lean:3155`, confirmed present), and must additionally account for
`serialityRule` and `timeLinearity`, the two rules scheduled outside `allRulesForFC`.

**Stale sub-citation in the same bullet**: `:111-112` cites `decide_sound'` at
`Correctness.lean:66`. It is at **`:71`**.

### 2.2 UNLISTED knock-on at `specs/ROADMAP.md:27-31` — inside the DO-NOT-TOUCH block

The task says lines 21-46 are verified current and must not be touched, and that `:27-31` survive
"because they say 'biconditional'". Only the second half of that sentence survives. Verbatim:

> 1. **A theorem can be absent rather than merely unproven.** `DecisionProcedure.isValid`
>    (`…DecisionProcedure.lean:317`) has no theorem anywhere relating it to semantic validity —
>    no `isValid φ fc = true → ⊨ φ` biconditional exists, proven or otherwise…

- "has no theorem anywhere relating it to semantic validity" — **false**, by `isValid_sound`.
- "no … biconditional exists" — **true**.
- The bullet's own headline, "a theorem can be absent rather than merely unproven", no longer
  applies to `isValid`: the sound direction is present. The illustrative force now rests entirely
  on the biconditional.

This is the same false claim A1 exists to remove, in the section the task forbids editing. See
§6.1 for the decision this forces.

`DecisionProcedure.lean:317` is correct (`def isValid (φ : Formula) (fc : FrameClass := .Base) : Bool`).
The other two items in that block were spot-checked and are current: `verifyProof` is
`fun _ _ => true` at `ProofExtraction.lean:345`, and
`FormalSystem/Metalogic/Decidability/Verified/Refutation/` does not exist.

---

## 3. Scope A — the axiom count and the layer table

### 3.1 The count is 45 (A2 confirmed)

`inductive Axiom` runs `FormalSystem/ProofSystem/Axioms.lean:99-517`; `inductive FrameClass`
begins at `:519`. Enumerating the constructors gives **45**, `prop_k` … `sep`.

Two independent in-source confirmations, one of which contradicts the other:

- `Axioms.lean:578` (the `Axiom.minFrameClass` docstring): "Total: 45 axiom constructors",
  broken down as Base 37 / Dense 2 / Discrete 3 / Dedekind 3. **This is consistent with
  enumeration and is the reliable in-source anchor.**
- `Axioms.lean:58` (the module docstring): "**Total**: 42 axiom constructors (32 base + 5
  uniformity + 2 prior + 1 Z1 + 2 density)". **Stale** — it predates the three Reynolds Dedekind
  axioms.

The ROADMAP's `:357` explicitly cites `Axioms.lean:55-59` as its authority — i.e. it inherits the
stale block. The rewrite must re-anchor to `Axioms.lean:571-582` (the `minFrameClass` docstring)
or to the enumeration itself, or the same error will be re-derivable from the cited source.

**Do not trust the `-- Layer N` comments either.** Two of them disagree with enumeration:
`:123` says Layer 3 is "(20 = 10 future + 10 past-mirrors)" — it is **18**; `:349` says Layer 8 is
"Density Axiom (1)" — it is **2** (`density`, `dense_indicator`, and `minFrameClass:580` agrees
it is 2). Only enumeration is authoritative.

### 3.2 The layer table (A3) — three layers missing *and* three phantom rows

The task describes A3 as "missing a 7th layer for the three Dedekind axioms". That is true but
would produce a table that sums to 45 for the wrong reasons. The actual arithmetic:

```
ROADMAP as written:  4 + 5 + 24 + 2 + 5 + 2                  = 42
Actual by source:    4 + 5 + 18 + 4 + 1 + 5 + 2 + 1 + 2 + 3  = 45
```

**Three rows in the ROADMAP are not `Axiom` constructors at all:**

| Phantom row | ROADMAP site | Reality |
|-------------|--------------|---------|
| `temp_k_dist` | `:386` (Layer 3) | derived theorem `Theorems.TemporalDerived.temporalKDistDerived` (`Axioms.lean:59`, `:96`, `:124`) |
| `temp_4` | `:387` (Layer 3) | derived theorem `Theorems.TemporalDerived.temporal4Derived`. A **different** `temp_4` does exist at `FormalSystem/BaseLanguage/Axioms.lean:99`, on `BLFormula` — not this inductive |
| `temp_future` | `:421` (Layer 4) | derived from MF + T + Modal 4 (`Axioms.lean:56`); the only surviving uses are in `Boneyard/` |

**Three layers are absent entirely** (six constructors):

| Layer | Source comment | Constructors | `minFrameClass` |
|-------|----------------|--------------|-----------------|
| 7 | `:337` Z1 Axiom | `z1` (`:347`) | `.Discrete` |
| 8 | `:349` Density | `density` (`:358`), `dense_indicator` (`:369`) | `.Dense` |
| 9 | `:371` Reynolds Dedekind (3) | `prior_U_gap` (`:431`), `prior_S_gap` (`:441`), `sep` (`:452`) | `.Dedekind` |

**Every `Axioms.lean:NN` citation in the table is stale** (e.g. `prop_k` is cited at `:71`, is at
`:103`). Ground-truth line numbers, by layer, for the rewrite:

- **Layer 1, Propositional (4)** — `prop_k` 103, `prop_s` 106, `ex_falso` 108, `peirce` 110
- **Layer 2, S5 Modal (5)** — `modal_t` 113, `modal_4` 115, `modal_b` 117, `modal_5_collapse` 119,
  `modal_k_dist` 121
- **Layer 3, BX Temporal (18)** — `serial_future` 128, `serial_past` 132, `left_mono_until_G` 138,
  `left_mono_since_H` 144, `right_mono_until` 149, `right_mono_since` 153, `connect_future` 158,
  `connect_past` 162, `enrichment_until` 171, `enrichment_since` 179, `self_accum_until` 189,
  `self_accum_since` 194, `absorb_until` 201, `absorb_since` 205, `linear_until` 211,
  `linear_since` 220, `until_F` 241, `since_P` 246
- **Layer 3b, Additional BX Temporal (4)** — `temp_linearity` 253, `temp_linearity_past` 261,
  `F_until_equiv` 270, `P_since_equiv` 275
- **Layer 4, Modal-Temporal Interaction (1)** — `modal_future` 283
- **Layer 5, Uniformity (5)** — `discrete_symm_fwd` 291, `discrete_symm_bwd` 296,
  `discrete_propagate_fwd` 302, `discrete_propagate_bwd` 308, `discrete_box_necessity` 316
- **Layer 6, Prior for Integers (2)** — `prior_UZ` 330, `prior_SZ` 335
- **Layer 7, Z1 (1)** — `z1` 347
- **Layer 8, Density (2)** — `density` 358, `dense_indicator` 369
- **Layer 9, Reynolds Dedekind (3)** — `prior_U_gap` 431, `prior_S_gap` 441, `sep` 452

Recommended headline phrasing for `:15` and `:356`: **"45 axiom constructors in nine layers"**
(the source numbers them 1-9 with Layer 3 split into 3 and 3b). Note that
`FormalSystem/README.md:79` and `FormalSystem/ProofSystem/README.md:22` say "42 constructors in
**8** layers" — those are downstream sites, out of scope here, but the "nine" chosen here should
be the value the downstream sweep converges on.

**Out-of-scope sites for the 42→45 sweep** (recorded so the downstream task can consume this
enumeration rather than redo it): `FormalSystem/ProofSystem/Axioms.lean:58`, `:84`;
`FormalSystem/README.md:79`, `:92`, `:94`, `:200`, `:282`;
`FormalSystem/ProofSystem/README.md:12`, `:22`, `:23`, `:40`;
`FormalSystem/Automation/Tactics/Helpers.lean:33`, `:1103`;
`FormalSystem/Automation/ProofSearch/Core.lean:322`;
`FormalSystem/Metalogic/Decidability/ProofExtraction.lean:27`;
`Tests/BimodalTest/Automation/ProofFirstTests.lean:36`;
`typst/SYNC-MAP.md:149`, `:216`, `:246`, `:283`, `:302`, `:350`;
`docs/research/competitive-landscape.md:101`, `:341`, `:344`.

### 3.3 A4 — `completeness_dedekind` and the C2 list (`:348-350`)

`FormalSystem.Metalogic.completeness_dedekind` exists at
`FormalSystem/Metalogic/StrongCompleteness.lean:469` (namespace opens at `:139`). `lean_verify`
returns:

```
axioms: [propext, Classical.choice, Quot.sound]   -- no sorryAx
```

`FormalSystem/Metalogic.lean:57-60` pins it at that set in prose (the task's cited `:60-64` is the
`consequence_completeness_dedekind` entry, `:61-66`).

**Caveat that changes how this must be written.** The ROADMAP paragraph at `:348-350` is headed
"**C2 axiom baseline**", and C2's baseline lists exactly four theorems
(`scripts/check-module-invariants.sh:127-132`): `completeness`, `completeness_dense`,
`completeness_discrete`, `Chronicle.countermodel_dense`. `completeness_dedekind` is **not** among
them. Appending it to a paragraph attributed to C2 would make the ROADMAP assert something C2
does not check — which its own rule at `:44-46` classifies as a defect in the document. The fix
must attribute `completeness_dedekind` to `Metalogic.lean:57-60` / a `#print axioms` run, kept
typographically separate from the C2 four. (Note also that the task's cited line range `:349-352`
is off by one at the top: the block is `:348-350`.)

---

## 4. Scope B — `FormalSystem/Metalogic/README.md`

### 4.1 B1 — the axiom baseline block (`:213-218`) is false

Confirmed. The README records `completeness [propext, sorryAx, Classical.choice, Quot.sound]`.
The live C2 run (this report's gate run) prints:

```
'FormalSystem.Metalogic.BXCanonical.completeness'           depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_dense'     depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete'  depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
```

matching `scripts/check-module-invariants.sh:127-132` exactly.

The task's preferred fix — replace the block with a pointer to the script — is the right one, and
`:220-222` ("a hard stop, not a new baseline") already reads correctly against a pointer. Cite the
script path and the check name (C2), not a line number, so the pointer does not itself drift.

### 4.2 B2 — the sorry inventory (`:233-248`) is false

Confirmed on both counts.

- C3 passes: "structural sorry inventory is ZERO across `FormalSystem/` (`Boneyard/` excluded)".
- `theorem countermodel_discrete` is at
  `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean:142`, not in
  `WeakCanonical/Transfer.lean`, and is axiom-clean.
- `Transfer.lean:25-31` now *documents* the move; its remaining `sorry` occurrences are all inside
  prose (`:542`, `:622`, `:628`, `:718`, `:725`) describing sorry-*freeness*, not structural
  sorries.
- Consequently `:239-242` ("This is why `completeness` depends on `sorryAx` …") must go entirely —
  it explains a dependency that does not exist.

`FormalSystem/Metalogic.lean:48-52` carries the current, correct statement of where the Base-frame
discrete branch lives and is the transcription source. The task's instruction to keep the
"locate by content, not line number" guidance at `:244-246` is sound and independently corroborated
by C3's own header comment (`scripts/check-module-invariants.sh:11`: "asserted BY CONTENT (never
by line number)"). `:248` ("Sorries inside the archive are archived dead ends") also survives: B0
confirms 156 archived files are excluded.

### 4.3 B3 — the aggregator-convention violation is in a different file

`Metalogic/README.md:13` does **not** violate the convention; it is a sentence about
`Boneyard/README.md`. The real instance is
**`FormalSystem/Metalogic/BXCanonical/README.md:13`**, whose "Modules" table lists
`BXCanonical.lean | 28 lines` as a file inside `BXCanonical/`. It is a **sibling**, at
`FormalSystem/Metalogic/BXCanonical.lean`, and it is **43** lines, not 28.

`Metalogic/README.md`'s own aggregator table (`:124-132`) is correct in form — it lists siblings as
siblings — but every line count in it is stale; see §4.5. Recommendation: fix the
`BXCanonical/README.md:13` row under this task (one row, and it is a direct contradiction of the
convention this anchor asserts), and leave the rest of `BXCanonical/README.md` to the downstream
README pass.

### 4.4 B4 — the Lake root paragraph (`:147-150`), and a correction to the task's own fix

README as written: "`lean_lib FormalSystem` sets `srcDir := "FormalSystem"` and
`roots := #[`Bimodal]`", with the pair named as `FormalSystem.lean` + `FormalSystem/Bimodal.lean`.

Ground truth, `lakefile.lean:15-19`:

```lean
@[default_target]
lean_lib FormalSystem where
  srcDir := "."
  roots := #[`FormalSystem]
```

`FormalSystem/Bimodal.lean` does not exist.

**The task description's replacement is also wrong.** It says "the real root is
`FormalSystem/FormalSystem.lean`". With `srcDir := "."`, module `FormalSystem` resolves to the
**repository-root `FormalSystem.lean`** (present, 50 lines); `FormalSystem/FormalSystem.lean` is
module `FormalSystem.FormalSystem`, imported by the root at `FormalSystem.lean:8`. The
allowlisted pair is *both* files.

There is a ready-made, in-repo formulation — `scripts/check-module-invariants.sh:402-407`, C8's
own comment — which the implementer should transcribe rather than re-derive:

> Allowlisted exception: `FormalSystem.lean` + `FormalSystem/FormalSystem.lean`. That pair is the
> Lake `lean_lib FormalSystem` root (`srcDir := "."`, ``roots := #[`FormalSystem]``), so the
> self-named indirection is load-bearing, not a convention violation.

The allowlist is `C8_ALLOW_SELFNAMED = {"FormalSystem/FormalSystem.lean"}`
(`check-module-invariants.sh:407`) — so "allowlists it by name" in the README is accurate and can stay.

### 4.5 B5 — the inventory is stale roughly three times over

Every figure below was recomputed with the script's own `live_files` walk. C7's live total
(`Metalogic 314`) independently confirms the directory rollup.

**Line 6-7** — "210 live `.lean` files, of which 135 sit under `WeakCanonical/`" → **314** and
**179**.

**Directory Inventory (`:154-162`)** and **Three Completeness Routes (`:29-33`)**:

| Directory | README files | Actual | README lines | Actual |
|-----------|-------------:|-------:|-------------:|-------:|
| `Algebraic/` | 9 | **5** | 3,748 | **2,887** |
| `Bundle/` | 12 | **15** | 4,650 | **6,106** |
| `BXCanonical/` | 20 | **28** | 18,527 | **23,256** |
| `Core/` | 4 | 4 ✓ | 2,048 | **2,050** |
| `Decidability/` | 19 | **62** | 9,263 | **52,132** |
| `SoundnessLemmas/` | 3 | **5** | 2,461 | **3,016** |
| `WeakCanonical/` | 135 | **179** | 106,253 | **132,177** |
| `Independence/` | *absent* | **3** | — | **1,097** |

`Independence/` is missing from both tables and from the aggregator table
(`FormalSystem/Metalogic/Independence.lean`, 46 lines, exists).

**Aggregator table (`:124-132`)** — every line count is stale:

| Aggregator | README | Actual |
|------------|-------:|-------:|
| `Algebraic.lean` | 41 | **40** |
| `Bundle.lean` | 43 | **52** |
| `BXCanonical.lean` | 34 | **43** |
| `Core.lean` | 37 | 37 ✓ |
| `Decidability.lean` | 52 | **168** |
| `SoundnessLemmas.lean` | 31 | **34** |
| `WeakCanonical.lean` | 80 | **144** |
| `Independence.lean` | *absent* | **46** |

**`:134-136`** — "Two loose files are not aggregators: `Soundness.lean` (1,394 lines) … and
`Metalogic.lean`". There are **five** loose non-aggregators: `Soundness.lean` (**2,022**),
`StrongCompleteness.lean` (807), `SetConsequence.lean` (338), `DiscreteNonCompactness.lean` (334),
`Conservativity.lean` (295). `Metalogic.lean` is 199 lines.

**`:166-168` (Inside `BXCanonical/`)** — the loose list omits `CompletenessDedekind.lean` and
`DiscreteCarrierProbe.lean` (8 loose, 6 listed). Subdirectory counts: `Chronicle/` 8 → **14**;
`Quasimodel/` 5 ✓; `Filtration/` 1 ✓.

**`:172` (Inside `WeakCanonical/`)** — "14 loose modules plus five subdirectories" → **19** loose
plus **eight** subdirectories. The subdirectory table (`:175-181`) omits three entirely:

| Subdirectory | README files | Actual files | README lines | Actual lines |
|--------------|-------------:|-------------:|-------------:|-------------:|
| `Kamp/` | 99 | **116** | 71,246 | **77,619** |
| `EFGames/` | 8 | 8 ✓ | 11,872 | 11,872 ✓ |
| `Expressiveness/` | 5 | 5 ✓ | 9,503 | 9,503 ✓ |
| `IntegerModel/` | 6 | 6 ✓ | 5,503 | **5,700** |
| `Separation/` | 3 | 3 ✓ | 926 | 926 ✓ |
| `DenseModelSurgery/` | *absent* | — | | |
| `GroupModel/` | *absent* | — | | |
| `RealModel/` | *absent* | — | | |

`GroupModel/`'s absence is not cosmetic: B2's corrected sorry text has to name
`WeakCanonical/GroupModel/CountermodelBase.lean`, in a directory this README currently claims does
not exist.

**`:183-190` (under `Kamp/`)** — "49 loose modules plus two large sub-subtrees" → **57** loose plus
**three** (`EANegationFixFaithful/` is new). `NfMultiAnchorBridge/` 43 → **47** files,
41,859 → **41,345** lines; `EANegationFix/` 7 ✓, 3,227 ✓.

**Missing "Last verified" date** — confirmed by `readme-lint.sh` Check 4. House format, e.g.
`FormalSystem/README.md:311`: `*Last verified: YYYY-MM-DD*`.

---

## 5. Constraints the implementation must respect

1. **C9 — zero task-number citations under `FormalSystem/`.** This check currently passes. The
   `Metalogic/README.md` rewrite must contain no "task N" references. (`specs/ROADMAP.md` is
   exempt and already uses them heavily.)
2. **C5 — all module-shaped paths in markdown must resolve.** Any `FormalSystem.Foo.Bar` written
   into either document must exist.
3. **`readme-lint.sh` Check 3 — no broken relative file references.** New paths such as
   `WeakCanonical/GroupModel/CountermodelBase.lean` must be written relative to the README's own
   directory. Current baseline is 5 broken references; the task must not add a sixth.
4. **Prose and markdown only.** No `.lean` declaration, signature, import, or tactic changes.
5. **House phrasing**, verbatim from `FormalSystem/Metalogic.lean:48`:
   `SORRY-FREE (sorryAx-free; axioms: exactly propext, Classical.choice, Quot.sound)`.
   Never "axiom-free".
6. **Prefer pointers to transcription** wherever a script already owns the fact (B1, B4). Every
   figure re-typed into a document is a figure that will be stale again; the two anchors' worst
   defects are all transcriptions that drifted.

---

## 6. Two decisions required before implementation

### 6.1 `specs/ROADMAP.md:27-31` sits inside the DO-NOT-TOUCH block and carries the same false claim A1 removes

The task instructs that `:21-46` were verified current and must not be touched, and that `:27-31`
survive as written. §2.2 shows one clause of `:28-29` — "has no theorem anywhere relating it to
semantic validity" — is false, and that the bullet's headline ("a theorem can be **absent**") no
longer describes `isValid`.

Options:

- **(a) Obey literally.** The anchor keeps a false claim in its most prominent section, and every
  downstream pass realigned against this anchor propagates it — the precise failure mode this task
  exists to prevent.
- **(b) Surgical narrowing (recommended).** Change only the clause, leaving the item, its headline
  intent, the section, and the rest of `:21-46` untouched — e.g. narrow it to: the *sound*
  direction is proved (`isValid_sound`), while the biconditional, which is the property the name
  `isValid` invites a reader to assume, is absent — no declaration states it, so C3's sorry count
  is silent on it. This preserves the item as a live illustration of the PROVEN-vs-SORRY-FREE
  thesis instead of leaving it as a counterexample to the document's own accuracy.

**Recommendation: (b), surfaced as an explicit gated deviation** rather than taken silently, since
it edits a range the task designates DO NOT TOUCH.

### 6.2 `Axioms.lean:58`'s stale "42" is the ROADMAP's cited authority

`specs/ROADMAP.md:357` points at `Axioms.lean:55-59` — the module-docstring block that still says
42. Fixing the ROADMAP while leaving the citation in place produces a document that contradicts
its own named source.

Options:

- **(a) Re-anchor the ROADMAP only (recommended for this task).** Cite `Axioms.lean:571-582` (the
  `minFrameClass` docstring, which already says 45 and is consistent with enumeration) for the
  count, and keep `:55-59` cited only for the Burgess/Xu/Venema *references*, which are unaffected.
  Zero `.lean` edits; fully inside the file scope.
- **(b) Also fix `Axioms.lean:58`.** The verification gate forbids changing "declaration,
  signature, import, or tactic" — a module docstring is none of these, so this is arguably
  permitted, but the file is outside the task's two-file scope and the site is already on the
  downstream 42→45 sweep list (§3.2).

**Recommendation: (a) here, with `Axioms.lean:58` and `:84` explicitly handed to the downstream
sweep** (this report's out-of-scope list gives it the verified enumeration to work from).

---

## 7. Suggested phase decomposition

| Phase | Content | Verification |
|-------|---------|--------------|
| 1 | ROADMAP A1 (`:109-115`), transcribing the open-obligation text from `Correctness.lean:209-224`; fix the `decide_sound'` citation `:66`→`:71`. Resolve §6.1. | grep the rewritten bullet against `Correctness.lean:100`, `:111` |
| 2 | ROADMAP A2/A3: `:15`, `:356-357` → 45 / nine layers; rebuild the layer table `:363-443` from §3.2 (drop 3 phantoms, add Layers 7/8/9, refresh all 45 line citations). Resolve §6.2. | per-layer counts sum to 45; every cited line matches a constructor |
| 3 | ROADMAP A4 (`:348-350`), keeping `completeness_dedekind` typographically separate from the C2 four. | `lean_verify` on `FormalSystem.Metalogic.completeness_dedekind` |
| 4 | README B1 + B2 — the two actively-harmful defects. Replace `:213-218` with a C2 pointer; rewrite `:233-248` to zero sorries and the `GroupModel/CountermodelBase.lean` location, keeping the by-content guidance. | `check-module-invariants.sh` C2 + C3 |
| 5 | README B4 (`:147-150`), transcribed from `check-module-invariants.sh:402-407`; B3 row in `BXCanonical/README.md:13`. | C8 still passes |
| 6 | README B5 — the full §4.5 sweep, plus `Independence/`, plus the "Last verified" line. | recompute with the `live_files` walk; `readme-lint.sh` no worse than 9/5 |
| 7 | Gate: `check-module-invariants.sh` ALL CHECKS PASSED (C5, C8, C9 in particular); `readme-lint.sh` result recorded and not regressed. | — |

Phases 1-3 and 4-6 touch disjoint files and can be dispatched in parallel with a territory split
on `specs/ROADMAP.md` vs `FormalSystem/Metalogic/README.md` (+ the single `BXCanonical/README.md`
row).

---

## 8. Tactic survey

Not applicable. This task is prose-and-markdown only; no proof goals are in scope, and no `.lean`
declaration may change. The Lean tooling used here was `lean_verify` for axiom profiles, plus the
two invariant scripts, which are the task's own verification gate.
