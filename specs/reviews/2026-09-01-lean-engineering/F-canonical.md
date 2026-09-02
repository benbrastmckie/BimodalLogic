# Territory F: Canonical-Model Infrastructure (Bundle, Algebraic, RestrictedMCS) — Findings

## 1. Architecture assessment

The territory is two very different codebases wearing one name.

**`Algebraic/FlowFrame.lean` is the good half, and it is genuinely good.** The frame axioms of
`def:frame` are discharged exactly once, D-generically, on `multiFamTaskFrameGen`
(`FlowFrame.lean:153-199`); `bundleFlowFrame` is a `def` whose body is an application of it, so
it owes the structure no fields; the module docstring says so explicitly and forbids counting it
as a second construction site (`FlowFrame.lean:76-85`). The paper anchors are cited by `\label`
rather than line number, the derived-vs-cited distinction is marked (`:56-58`), and the one truth
lemma in the territory (`bundleFlow_truth_lemma`, `:678`) carries a case inventory in prose.
There are **zero** `set_option maxHeartbeats` overrides anywhere in the 9,760 lines. `LimitMCS.lean`
reaches for Mathlib's `Filter`/`Ultrafilter`/`Ultrafilter.of` rather than hand-rolling, and its
docstring argues, from Reynolds' actual page numbers, why the limit set is *not* maximal — the
best piece of mathematical writing in the territory.

**`Bundle/` is the other half, and it is largely archaeology.** Of its 15 modules, three
(`Construction.lean`, `CanonicalFrame.lean`, `UntilSinceCoherence.lean` — 611 lines) have no live
consumer for any declaration, and `CanonicalFrame.lean` is the one the directory README advertises
as the centrepiece. `ModalSaturation.lean` is 100% mis-titled: everything named "saturation" in it
is dead, while six route modules import it for five general S5/propositional derivation helpers
that belong in `Theorems/`. `Bundle/Construction.lean` contains an empty `## History` heading and
two "## REMOVED:" sections; `SuccRelation.lean:444-540` carries ~85 lines of first-person proof
diary ("Hmm, this may need additional infrastructure. Let me check.") wrapped around an 8-line
proof, citing a module (`SuccExistence.lean`) that does not exist.

The dominant structural defect is **future/past mirror duplication**. Every temporal fact in the
territory is written twice — `iterF`/`iterP`, `CanonicalTask_forward`/`_backward`,
`forward_temporal_witness_seed_consistent`/`past_...`, `limitSetBelow`/`Above`,
`some_future_all_future_neg_absurd`/`some_past_...` — by textual mirroring with
`allFuture↔allPast`, `untl↔snce`, `right_mono_until↔right_mono_since`. Conservatively 1,400 lines
of the 9,760 are one half of a mirror pair. Worse, the repository *already owns* the abstraction
that would collapse a third of it: `Formula.swapTemporal` and `DerivationTree.temporal_duality`
are used correctly exactly once (`FlowFrame.lean:618-628`, `past_tf_deriv`) and nowhere else.

Third theme: **the territory re-derives what the library above it already proves**. The pattern
`DerivationTree.axiom [] _ (Axiom.right_mono_until φ ψ Formula.top) trivial` appears inline 14
times in `Bundle/`, and `Theorems/TemporalDerived.lean:407` already names it `fMono` (`:418`
`pMono`).

Finally, an invariant claimed by `Metalogic/README.md` is false: there are **three** directory-level
cycles, not two — `Bundle ↔ Algebraic` exists, and unlike the two documented ones it is breakable
by moving a single dead declaration.

---

## 2. Consumer map (Q1), frame-construction inventory (Q3), truth-lemma inventory (Q4)

### Q1 — Consumer map

Method: `grep -rl "import FormalSystem.Metalogic.<M>"` excluding `Boneyard/`, plus a per-declaration
scan for cross-file references. "Orphan" below = *no live cross-file reference to any declaration*.
Note `Bundle.lean` (the aggregator) has **no importer at all** and lies outside every Lake target's
import closure (`Metalogic/README.md`, "Aggregator Convention"), so being imported only by
`Bundle.lean` is equivalent to being dead.

| Module | Live importers (excl. `Bundle.lean`) | Live cross-file exports | Verdict |
|---|---|---|---|
| `Bundle/TemporalContent` | `BXCanonical/Frame`, `BXCanonical/Chronicle/ChronicleTypes`, `WeakCanonical/ReflexiveCanonical`, + 3 in-dir | `GContent`, `HContent`, `FContent`, `PContent` | **true shared core** (all 3 routes) |
| `Bundle/WitnessSeed` | `BXCanonical/Frame`, `BXCanonical/Chronicle/RRelation`, `WeakCanonical/TruthLemma`, + 2 in-dir | the 4 seed-consistency theorems, 2 duality theorems, `some_*_absurd` | **true shared core** (all 3 routes) |
| `Bundle/TemporalCoherence` | `Algebraic/FlowFrame`, `BXCanonical/Chronicle/ChronicleMonadicBridge`, + 2 in-dir | `RestrictedTemporallyCoherent`, `Restricted{Forward,Backward}UntilSinceCoherent` | shared core (2 routes); 22 of 26 decls orphaned |
| `Bundle/ModalSaturation` | `BXCanonical/Chronicle/ChronicleTypes`, + 2 in-dir | `boxDneTheorem`, `negBoxToBoxNegBox`, `axiom5NegativeIntrospection`, `SetMaximalConsistent.contrapositive`, `..neg_box_implies_box_neg_box` — **all five are generic derivation helpers, none is about saturation** | mis-titled; saturation layer dead |
| `Bundle/FMCSDef` | `BXCanonical/CanonicalModel`, + 2 in-dir | `FMCS` | core |
| `Bundle/BFMCS` | `BXCanonical/CanonicalModel`, + 3 in-dir | `BFMCS` only | 4 of 5 decls orphaned |
| `Bundle/RealExtensionBundle` | 4× `BXCanonical/Chronicle/ChronicleLimit*` | `BFMCS.toRealBundle`, `LimitFutureWitness`, `LimitGuard*` | live |
| `Bundle/SuccRelation` | 2 in-dir only | `Succ`, `single_step_forcing`, `single_step_forcing_past`, `Succ_implies_h_content_reverse` | in-directory only |
| `Bundle/CanonicalTaskRelation` | **`Core/RestrictedMCS/Basic`** only | `iterF`, `iterP`, `closureFBound`, `closurePBound`, `iter_{F,P}_not_mem_closureWithNeg` — **syntax facts only** | see F-02 |
| `Bundle/LimitMCS`, `LimitMCSCoherence`, `RealExtension` | in-dir chain to `RealExtensionBundle` | limit/extension API | live via chain |
| `Bundle/UntilSinceCoherence` | `BXCanonical/Chronicle/ChronicleToCountermodelBasic` | **declares nothing** (`:36`) | import-forwarding shim (F-06) |
| `Bundle/CanonicalFrame` | `BXCanonical/Frame` (**unused import**), `SuccRelation`, `CanonicalTaskRelation` | `ExistsTask`, referenced once, by an orphan | **dead** (F-01) |
| `Bundle/Construction` | none | none — all 11 decls orphaned | **dead** (F-01) |
| `Algebraic/FlowFrame` | `BXCanonical/{Completeness, DiscreteCarrierProbe}`, `BXCanonical/Chronicle/{ChronicleToCountermodelBasic, ChronicleMonadicBridge}`, `WeakCanonical/GroupModel/CountermodelBase`, `Z1Countermodel`, **`Bundle/LimitMCS`** | `bundleFlow*`, `multiFamTaskFrameGen`, `sInter_nonempty_of_directed_subsingleton` | **true shared core** |
| `Algebraic/{LindenbaumQuotient, BooleanStructure, InteriorOperators, UltrafilterMCS}` | each other only | **none** — 2,081 lines with zero live consumers | standalone (F-11..F-13) |
| `Core/RestrictedMCS/Basic` | (own consumers outside territory) | `RestrictedMCS`, `restricted_lindenbaum`, `restricted_mcs_{F,P}_bounded` | live |

**Boneyard candidates**: `Bundle/Construction.lean` (253), `Bundle/CanonicalFrame.lean` (312),
`Bundle/UntilSinceCoherence.lean` (46).
**The genuine shared core consumed by all three routes**: `TemporalContent`, `WitnessSeed`,
`FMCSDef`/`BFMCS`, `TemporalCoherence`, `Algebraic/FlowFrame`.

### Q3 — Frame-construction inventory

The answer is better than the question assumes: **the frame axioms are already discharged once.**

| Site | Fields discharged by hand | Status |
|---|---|---|
| `Algebraic/FlowFrame.lean:153` `multiFamTaskFrameGen` | all 6 (`nullity_identity`, `comp`, `converse`, `serial`, `limit`, `spherical`) | **the single generic constructor** |
| `Algebraic/FlowFrame.lean:~500` `bundleFlowFrame` | 0 — definitional specialization | correct, documented `:76-85` |
| `WeakCanonical/IntegerModel/ReynoldsBridge.lean:767` `multiFamTaskFrame` | **all 6, again, at `D := ℤ`** | redundant (F-04) |
| `Bundle/CanonicalFrame.lean` | — **constructs no frame at all**, despite its name | misnamed (F-01) |
| `BXCanonical/Frame.lean` | — constructs no `FrameOver`; only `BXPoint` + `BxLe` | fine |
| `WeakCanonical/ReflexiveCanonical.lean` | — constructs no `FrameOver` | fine |

So there is exactly one real duplicate frame-construction site (F-04), and it is a
copy-paste of the generic one certified `rfl`-equal to it two declarations later.

### Q4 — Truth-lemma inventory

There is **one** truth lemma in the repository: `bundleFlow_truth_lemma`
(`Algebraic/FlowFrame.lean:678-802`), consumed at `FlowFrame.lean:813` and `Bundle/LimitMCS.lean:471`.
The files named `TruthLemma.lean` do not contain one:

- `BXCanonical/TruthLemma.lean` (312 lines) — per-connective MCS bridges (`imp_iff_mcs:84`,
  `G_iff_mcs:136`, `box_iff_mcs:162`), no induction over `Formula`.
- `WeakCanonical/TruthLemma.lean` (206 lines) — likewise (`G_forward_mcs:68`, `H_backward_mcs:155`).

Both re-prove `bot_not_in_mcs` from scratch with the same tactic script
(`BXCanonical/TruthLemma.lean:69-77`, `WeakCanonical/TruthLemma.lean:57-64`), and
`bundleFlow_truth_lemma`'s `| bot` case inlines it a **third** time (`FlowFrame.lean:695-703`) —
see F-09. So the answer to "are they instances of one Hintikka-style lemma" is: they are not
variants of a truth lemma at all, they are three copies of its per-connective *lemma set*, and the
one real truth lemma re-inlines them rather than calling them.

The coherence hypotheses the truth lemma needs are already isolated — but as three loose
arguments threaded through three theorems, one of which is unused (F-05).

---

## 3. Findings

### F-01. `Bundle/CanonicalFrame.lean` and `Bundle/Construction.lean` are dead; the live route re-proves their contents

- **Severity**: High
- **Category**: organization / duplication
- **Anchors**: `Bundle/CanonicalFrame.lean:73,85,142,173,212,235,268,296`;
  `Bundle/Construction.lean:48,54,112,142,180,209`; `BXCanonical/Frame.lean:11,223-244`;
  `Bundle/README.md:53,"Main Theorems"` table
- **Description**: All 11 declarations of `CanonicalFrame.lean` and all 11 of `Construction.lean`
  have zero live cross-file consumers. `BXCanonical/Frame.lean:11` imports
  `Bundle.CanonicalFrame` and references none of its declarations (verified: `ExistsTask`,
  `canonical_forward_F`, `canonical_backward_P`, `canonical_forward_U`, `canonical_backward_S`,
  `existsTask_transitive`, `h_content_chain_transitive` all occur 0 times in that file). The one
  export with a cross-file reference, `ExistsTask`, is used once — by
  `SuccRelation.lean:96` `Succ_implies_CanonicalR`, itself an orphan.

  Meanwhile the live route re-proves the module's headline theorems. `canonical_forward_F`
  (`CanonicalFrame.lean:142-165`: seed-consistency → `set_lindenbaum` → subset transport) is
  reproduced verbatim in bundled-subtype form as `bx_forward_witness`
  (`BXCanonical/Frame.lean:223-230`), and `canonical_backward_P` as `bx_backward_witness`
  (`:235-244`). Both files are advertised in `Bundle/README.md`'s "Main Theorems" table as
  SORRY-FREE deliverables.
- **Impact**: 565 lines of maintained, compiled, README-advertised code that no proof depends on,
  including four theorems the README calls "the property that all 12 chain-based approaches failed
  to prove". A reader orienting from `Bundle/README.md` starts at the wrong file.
- **Recommendation**: Move both files to `Boneyard/`. Before deleting `CanonicalFrame.lean`,
  relocate `ExistsTask`/`ExistsTaskPast` to `TemporalContent.lean` (where `GContent`/`HContent`
  live) if `SuccRelation` is kept. Drop the unused import at `BXCanonical/Frame.lean:11`. Update
  `Bundle/README.md`'s architecture block and Main Theorems table, which currently list four files
  that do not exist (`FMCS.lean`, `CanonicalIrreflexivity.lean`, `SuccExistence.lean`) and omit
  five that do (`LimitMCS`, `LimitMCSCoherence`, `RealExtension`, `RealExtensionBundle`,
  `UntilSinceCoherence`).
- **Effort**: M
- **Depends on**: -

### F-02. Breaking the `Core ↔ Bundle` cycle costs 3 Lean files, not 9 — the blocking declarations are pure syntax

- **Severity**: High
- **Category**: organization
- **Anchors**: `Core/RestrictedMCS/Basic.lean:12` (the sole reverse edge), `:469,488,573,593`;
  `Bundle/CanonicalTaskRelation.lean:74-194` and `:707-849`;
  `Syntax/SubformulaClosure/NestingDepth.lean:23,83,106,167`; `Metalogic/README.md:115-119`
- **Description**: The edge exists for exactly four theorems —
  `restricted_mcs_iter_F_bound:469`, `restricted_mcs_F_bounded:488`, `restricted_mcs_iter_P_bound:573`,
  `restricted_mcs_P_bounded:593` — which need `iterF`, `iterP`, `closureFBound`, `closurePBound`,
  `iter_F_not_mem_closureWithNeg` and `iter_P_not_mem_closureWithNeg`.

  Every one of those is a **pure syntax fact**. `iterF` is `n`-fold `Formula.someFuture`; its
  supporting lemmas speak only of `Formula.complexity`, `fNestingDepth` and `closureWithNeg`.
  Nothing in the block mentions `Succ`, `CanonicalTask`, MCSs or the canonical model. Decisively,
  `Syntax/SubformulaClosure/NestingDepth.lean` already names them in its own docstrings
  ("This is the key measure for proving that iterF eventually leaves closureWithNeg", `:23`) — the
  syntax layer was written to host them and they were placed one layer too high. A repo-wide grep
  confirms `iterF`/`iterP`/`closure{F,P}Bound` are referenced from **only** these two files.

  The README's "9 files, 5 of them markdown" measures a *different* move (relocating
  `Core/RestrictedMCS/Basic.lean` itself into `Bundle/`), which requires a module rename and
  therefore carries dangling-import risk. The move proposed here renames nothing.
- **Impact**: A documented, deliberately-declined structural defect is cheaper than recorded; the
  decision rests on a measurement of the wrong plan.
- **Recommendation**: Create `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean`; move
  `CanonicalTaskRelation.lean:74-194` and `:707-849` (~260 lines, 24 declarations) into it verbatim.
  Then `Core/RestrictedMCS/Basic.lean:12` imports that instead of `Bundle.CanonicalTaskRelation`,
  and `CanonicalTaskRelation.lean` imports it too. **Three Lean files** (one new, two edited),
  zero renames, no dangling-import surface. Then update `Metalogic/README.md:115-119` to record
  the cycle as broken rather than as declined.
- **Effort**: M
- **Depends on**: -

### F-03. A third directory cycle, `Bundle ↔ Algebraic`, exists and is undocumented — and it is caused by one orphaned declaration

- **Severity**: High
- **Category**: organization / documentation
- **Anchors**: `Bundle/LimitMCS.lean:8` and `:461-473` (`fc_theorem_true_in_bundle_flow_model`);
  `Algebraic/FlowFrame.lean:9`; `Metalogic/README.md:88` ("There are exactly **two**
  directory-level cycles in `Metalogic/`") and its layering diagram, which places `Algebraic/`
  strictly *below* `Bundle/`
- **Description**: `Algebraic/FlowFrame.lean:9` imports `Bundle.TemporalCoherence`, and
  `Bundle/LimitMCS.lean:8` imports `Algebraic.FlowFrame`. One edge each way — a genuine
  directory-level cycle that the README asserts does not exist and its diagram contradicts.

  The Bundle→Algebraic edge has exactly one cause: `fc_theorem_true_in_bundle_flow_model`
  (`LimitMCS.lean:461-473`), the only declaration in the file that touches anything from
  `FlowFrame` (verified: `bundleFlow*`/`multiFam*`/`TruthAt` occur nowhere else in the file). That
  declaration is *about* the bundle flow model, sits under `namespace ...Bundle` in a module whose
  stated subject is the ℝ-limit of a rational family, and is itself an orphan — no live consumer
  anywhere.
- **Impact**: The repository's central architectural document understates its own coupling, and
  `check-module-invariants.sh` does not catch it. The fix is two files.
- **Recommendation**: Move `fc_theorem_true_in_bundle_flow_model` to `Algebraic/FlowFrame.lean`,
  beside `bundleFlow_completeness_from_neg_membership`, into namespace
  `FormalSystem.Metalogic.Algebraic`; delete `Bundle/LimitMCS.lean:8`. (Or simply delete it — it
  has no consumer.) Then correct `Metalogic/README.md:88` and consider adding a `check-module-
  invariants.sh` check that enumerates directory-level cycles from the import graph rather than
  asserting a hand-counted number.
- **Effort**: S
- **Depends on**: -

### F-04. `multiFamTaskFrame` re-discharges all six frame fields that `multiFamTaskFrameGen` already discharges, then proves itself `rfl`-equal to it

- **Severity**: High
- **Category**: duplication
- **Anchors**: `WeakCanonical/IntegerModel/ReynoldsBridge.lean:767-793` vs
  `Algebraic/FlowFrame.lean:153-199`; `ReynoldsBridge.lean:803` `multiFamTaskFrame_eq_gen`;
  `BXCanonical/Chronicle/ChronicleMonadicBridge.lean:144` `multiFamTaskFrameGen_int`
- **Description**: `multiFamTaskFrame FamIdx : FrameOver intOrder` is written as a full
  `where`-block discharging `nullity_identity`, `comp`, `converse`, `serial`, `limit`, `spherical`
  — the same six fields, in the same order, with the same proof shapes as
  `multiFamTaskFrameGen`, differing only in `omega` for `abel`. The `spherical` body
  (`ReynoldsBridge.lean:785-793`) is character-for-character the generic one
  (`FlowFrame.lean:191-199`) and even calls back into
  `Algebraic.sInter_nonempty_of_directed_subsingleton`. Immediately below,
  `multiFamTaskFrame_eq_gen:803` proves `multiFamTaskFrame FamIdx = multiFamTaskFrameGen intOrder
  FamIdx := rfl`. The *same* `rfl` theorem is stated a second time, reversed, at
  `ChronicleMonadicBridge.lean:144-145`.
- **Impact**: The one thing `FlowFrame.lean`'s docstring goes out of its way to promise — that
  frame-axiom obligations are discharged once and only once — is not true of the `ℤ` frame the
  discrete completeness route actually uses. Any change to `FrameOver` must be applied twice.
- **Recommendation**: Replace the `where`-block with
  `noncomputable def multiFamTaskFrame (FamIdx : Type) [Nonempty FamIdx] : FrameOver intOrder :=
  Algebraic.multiFamTaskFrameGen intOrder FamIdx`. `multiFamTaskFrame_eq_gen` becomes `rfl` by
  construction; the four `_serial`/`_interpolates`/`_limit`/`_spherical` restatements stay as the
  citable verbatim-shape wrappers they already are. Delete one of the two duplicate `rfl`
  certifications.
- **Effort**: S
- **Depends on**: -

### F-05. The truth lemma takes an unused coherence hypothesis; the three coherence arguments should be one structure

- **Severity**: High
- **Category**: api-ergonomics / abstraction
- **Anchors**: `Algebraic/FlowFrame.lean:680` `(_h_rtc : B.RestrictedTemporallyCoherent root)`;
  `:807-809` and `Bundle/LimitMCS.lean:464-471` (call sites that must supply it);
  `Bundle/TemporalCoherence.lean:277,308,489,526,541,558,589` (seven coherence predicates)
- **Description**: `bundleFlow_truth_lemma` binds `_h_rtc` with a leading underscore — it is
  declared, demanded of every caller, and never used. Both consumers
  (`bundleFlow_completeness_from_neg_membership:806`, `fc_theorem_true_in_bundle_flow_model:461`)
  thread it through, and their own callers must construct it.

  More broadly, `TemporalCoherence.lean` defines **seven** `Prop`-valued coherence predicates plus
  a `TemporalCoherentFamily` structure, with bridge lemmas between them
  (`temporally_coherent_implies_restricted:319`, `forward_implies_restricted_forward:574`,
  `backward_implies_restricted_backward:605`, `split_until_since_coherent:617`,
  `until_since_coherent_{backward,forward}:629,639`). Only three of the seven have live consumers.
  Each of the three truth-lemma-family theorems repeats the same three-argument prefix.
- **Impact**: Adding or removing a coherence condition edits three signatures and every call site.
  The unused hypothesis is a live trap: a caller who cannot prove `RestrictedTemporallyCoherent`
  believes the truth lemma is out of reach when it is not.
- **Recommendation**: Bundle them, as Q4 anticipates:
  ```lean
  /-- The coherence conditions the canonical truth lemma consumes, at root `root`. -/
  structure BFMCS.CanonicalCoherence (B : BFMCS (fc := fc) D) (root : Formula) : Prop where
    temporal        : B.RestrictedTemporallyCoherent root
    untilSince_fwd  : B.RestrictedForwardUntilSinceCoherent root
    untilSince_bwd  : B.RestrictedBackwardUntilSinceCoherent root

  theorem bundleFlow_truth_lemma (B : BFMCS (fc := fc) D) (root : Formula)
      (hc : B.CanonicalCoherence root) (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
      (fam : {fam // fam ∈ B.families}) (w₀ t : D) :
      φ ∈ fam.val.mcs (w₀ + t) ↔ TruthAt (bundleFlowModel B) (bundleFlowHistory fam w₀) t φ
  ```
  The `temporal` field then documents an obligation the box case *ought* to need even if the
  current proof routes around it via `fmcs_box_persistent`, and the signature stops churning. Prune
  the four coherence predicates with no live consumer while you are there.
- **Effort**: M
- **Depends on**: -

### F-06. `Bundle/UntilSinceCoherence.lean` is a 46-line module that declares nothing, kept alive to forward two imports

- **Severity**: Medium
- **Category**: organization
- **Anchors**: `Bundle/UntilSinceCoherence.lean:1-46` (`:36`: "This file intentionally retains its
  import block (preserving transitive imports for its importer) and declares nothing.");
  sole importer `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`
- **Description**: The file's entire content is a copyright header, two imports
  (`Bundle.TemporalCoherence`, `Bundle.SuccRelation`), and 36 lines of archival prose describing
  six declarations that now live in `Boneyard/SorriedDeclExcisions/`.
- **Impact**: An import-forwarding shim in the shared core. `Bundle.lean:15` imports it, the
  aggregator table in `Bundle.lean:31` lists it as a coherence module, and a reader looking for
  "Until/Since coherence" lands on an empty file.
- **Recommendation**: Have `ChronicleToCountermodelBasic.lean` import `Bundle.TemporalCoherence`
  and `Bundle.SuccRelation` directly; delete the file; move its archival narrative into
  `Boneyard/SorriedDeclExcisions/README.md` where the archived declarations are.
- **Effort**: S
- **Depends on**: -

### F-07. `single_step_forcing_past`: an 8-line proof under 85 lines of first-person proof diary citing a nonexistent module

- **Severity**: High
- **Category**: documentation / proof-elegance
- **Anchors**: `Bundle/SuccRelation.lean:406-553` (147 lines); the real proof is `:415-431` and
  `:544-553`; the diary is `:432-543`; `SuccExistence.lean` cited at `:32,444,455` does not exist
- **Description**: The theorem's body contains twelve abandoned proof attempts written in the first
  person — "Actually, we need the predecessor deferral property from SuccExistence." (`:444`),
  "Hmm, this may need additional infrastructure. Let me check." (`:481`), "For now we mark this
  step." (`:521`), "Let me find or add this lemma." (`:516`) — followed by a `-- For now, let me
  use ...` and then the actual eight-line proof, which simply applies the hypothesis
  `h_p_step : PContent v ⊆ u ∪ PContent u` that was added to the signature to close the gap the
  diary is agonising over. `SuccExistence.lean`, named three times as the source of the missing
  property, does not exist in the tree (it is also listed in `Bundle/README.md:56` and referenced
  from `TemporalContent.lean:40,76`).
- **Impact**: The largest declaration in the territory, and the least publishable. A reader cannot
  tell which of the twelve narrated approaches is the one taken.
- **Recommendation**: Delete `:432-543`. Replace with a two-sentence docstring note: the P-step
  property dual to `Succ`'s F-step is *not* derivable from `Succ` alone and is therefore taken as
  the hypothesis `h_p_step`, supplied by the predecessor construction at the call site. Consider
  making `Succ` symmetric (adding the P-step conjunct) so the hypothesis disappears — the diary
  itself proposes this at `:524`. Remove the three `SuccExistence.lean` references and the two in
  `TemporalContent.lean`.
- **Effort**: S
- **Depends on**: -

### F-08. Four ~85-line witness-seed consistency proofs share one factorizable core, and two of the four seeds are the same set under two names

- **Severity**: High
- **Category**: duplication / abstraction
- **Anchors**: `Bundle/WitnessSeed.lean:150` `ForwardTemporalWitnessSeed` vs `:379`
  `UntilWitnessSeed` (both `{ψ} ∪ GContent M`); `:181-269`, `:290-377`, `:408-486`, `:488-565`
  (the four proofs); `:154,159` vs `:383,388` (duplicated membership/subset lemmas)
- **Description**: `ForwardTemporalWitnessSeed M ψ := {ψ} ∪ GContent M` (`:150`) and
  `UntilWitnessSeed M ψ := {ψ} ∪ GContent M` (`:379`) are the same definition, with duplicated
  `psi_mem_*` and `g_content_subset_*` lemmas. The code itself proves the second is unnecessary:
  `since_witness_seed_consistent:488` reuses `PastTemporalWitnessSeed` rather than introducing a
  `SinceWitnessSeed`, so the asymmetry is unmotivated.

  All four proofs open with the identical ~60-line argument: case on `ψ ∈ L`; in the `∈` branch
  filter, `deductionTheorem`, `generalizedTemporalK`, `closed_under_derivation`; in the `∉` branch
  `generalizedTemporalK` to `G⊥`, then `prop_s` + `temporalKDistDerived` to `G(¬ψ)`. Only the last
  three lines differ (F-vs-Until contradiction, G-vs-H mirror).
- **Impact**: ~350 lines where ~140 suffice, quadrupling the edit cost of any change to
  `SetConsistent`, `generalizedTemporalK`, or the seed shape.
- **Recommendation**: Extract the shared core:
  ```lean
  /-- If `{ψ} ∪ GContent M` is inconsistent then `G ¬ψ ∈ M`. -/
  theorem allFuture_neg_of_gseed_inconsistent {fc} {M} (h_mcs : SetMaximalConsistent (fc := fc) M)
      (ψ : Formula) (h : ¬ SetConsistent (fc := fc) ({ψ} ∪ GContent M)) :
      Formula.allFuture ψ.neg ∈ M
  ```
  plus its `H`/`HContent` mirror. Each of the four theorems then reads: apply the core, then
  `some_future_all_future_neg_absurd` (resp. past) against `F ψ ∈ M` — obtained directly for the
  F/P cases and via `untilImpF`/`sinceImpP` for the U/S cases. Delete `UntilWitnessSeed` and its
  two lemmas in favour of `ForwardTemporalWitnessSeed`.
- **Effort**: M
- **Depends on**: F-14 (the mirror abstraction subsumes the G/H half of this)

### F-09. `bot_not_in_mcs` is proved three times with the same script, none of them in `Core/`

- **Severity**: Medium
- **Category**: duplication
- **Anchors**: `BXCanonical/TruthLemma.lean:69-77`; `WeakCanonical/TruthLemma.lean:57-64`;
  `Algebraic/FlowFrame.lean:695-703` (inlined in the truth lemma's `| bot` case);
  consumers at `WeakCanonical/Transfer.lean:455,892,986,1036` reach across to the `BXCanonical`
  copy despite a local one existing
- **Description**: The same three-line tactic script — `intro h_bot; exact h_mcs.1 [Formula.bot]
  (…) ⟨DerivationTree.assumption …⟩` — appears three times. `Core/MCSProperties.lean`, which owns
  `negation_complete`, `implication_property` and `closed_under_derivation`, does not have it.
  `WeakCanonical/Transfer.lean` imports the `BXCanonical` copy at four sites while
  `WeakCanonical/TruthLemma.lean` defines its own.
- **Impact**: The most basic MCS fact in the development has no canonical home; three route files
  each own a private copy, and the cross-route reference at `Transfer.lean:455` is an accidental
  `WeakCanonical → BXCanonical` dependency added for a one-liner.
- **Recommendation**: Add `SetMaximalConsistent.bot_not_mem` to `Core/MCSProperties.lean` in the
  `{fc}`-generic form already used at `BXCanonical/TruthLemma.lean:69`; delete the other two;
  replace `FlowFrame.lean`'s inlined `| bot` branch with a call. The four `Transfer.lean` sites then
  point at `Core`.
- **Effort**: S
- **Depends on**: -

### F-10. `CanonicalTask_backward` is a redundant inductive: it is provably `CanonicalTask_forward` with arguments swapped

- **Severity**: Medium
- **Category**: abstraction / duplication
- **Anchors**: `Bundle/CanonicalTaskRelation.lean:286-296` (the inductive), `:262`
  (`step_inv`), `:332` (`_zero`), `:402-424` (`_comp`), `:477-499` (`backward_to_forward`),
  `:501-511` (`forward_backward_flip`), `:517-558` (`converse`)
- **Description**: `CanonicalTask_forward_backward_flip:501` proves
  `CanonicalTask_forward u n v ↔ CanonicalTask_backward v n u`. The backward relation is therefore
  not a new relation, and its four supporting lemmas re-prove, by a second induction each, facts
  already available on the forward side. `CanonicalTask_backward_comp:402` in particular needs a
  22-line `induction n generalizing v` because it cannot reuse `CanonicalTask_forward_comp:369`.
- **Impact**: ~90 lines and five declarations that exist only because a definitional identity was
  encoded as a theorem.
- **Recommendation**: Replace the inductive with
  `def CanonicalTask_backward (u : Set Formula) (n : Nat) (v : Set Formula) : Prop :=
  CanonicalTask_forward v n u`. Then `forward_backward_flip` is `Iff.rfl`, `_zero` and `step_inv`
  are one-liners off the forward versions, `_comp` is `fun h1 h2 => CanonicalTask_forward_comp …`
  with the arguments commuted, and `CanonicalTask_converse:517`'s three-way `match` shrinks to the
  sign analysis alone. (Note: this whole family is currently unconsumed outside its own file — see
  F-02 — so the cheapest variant is to Boneyard it and keep only the `iterF`/`iterP` layer.)
- **Effort**: M
- **Depends on**: F-02

### F-11. The Boolean-algebra/ultrafilter layer reimplements `Mathlib.Order.PrimeIdeal`

- **Severity**: Medium
- **Category**: abstraction / duplication
- **Anchors**: `Algebraic/UltrafilterMCS.lean:44-59` (bespoke `structure Ultrafilter (α)
  [BooleanAlgebra α]`), `:62-77` (`Membership` instance, `ext`), `:81` (`empty_not_mem`, a restated
  field); Mathlib: `Order.Ideal.IsPrime`, `Order.IsPFilter`, `Order.Ideal.IsMaximal.isPrime`
  (`Mathlib.Order.PrimeIdeal`), `Order.Ideal.IsProper.exists_le_maximal` (`Mathlib.Order.Ideal`)
- **Description**: The module defines its own six-field `Ultrafilter` on a Boolean algebra —
  shadowing Mathlib's `Ultrafilter` in the same file that `LimitMCS.lean` uses Mathlib's genuine
  `Ultrafilter Rat` — and then proves by hand the facts Mathlib supplies. Concretely: the `compl_or`
  field is the prime property, free from `Order.Ideal.IsMaximal.isPrime` in a `DistribLattice`;
  the `compl_not` field is `IsProper`; `mem_of_le`/`inf_mem` are the `Order.PFilter` axioms; and
  `Order.Ideal.IsProper.exists_le_maximal` is an algebra-level Lindenbaum lemma already in Mathlib.
  Given `instance : BooleanAlgebra LindenbaumAlg` (`BooleanStructure.lean:421`) all of this is
  available.
- **Impact**: 1,071 lines carrying a private duplicate of a Mathlib order-theory API, with a name
  collision on `Ultrafilter` that will bite anyone who later wants both in scope.
- **Recommendation**: Either (a) express the ultrafilter side as `{F : Order.PFilter LindenbaumAlg
  // (Order.Ideal.ofPFilterCompl F).IsMaximal}` — or the dual `Order.Ideal … .IsPrime` — and
  reuse the Mathlib API, or (b) if the bespoke structure is retained for readability, rename it
  `BAUltrafilter` to stop shadowing, and prove the bridge
  `BAUltrafilter α ≃ {I : Order.Ideal α // I.IsMaximal}` once so the Mathlib lemmas are reachable.
- **Effort**: L
- **Depends on**: -

### F-12. The MCS↔ultrafilter bijection is stated as an anonymous existential, so both round trips are then re-proved from scratch

- **Severity**: Medium
- **Category**: api-ergonomics / duplication
- **Anchors**: `Algebraic/UltrafilterMCS.lean:782-908` (`ultrafilter_correspondence`, 127 lines),
  `:983-1054` (`ultrafilter_mcs_round_trip`, 72 lines), `:1057-1071` (`mcs_ultrafilter_round_trip`);
  the tell is `:988` `obtain ⟨f, g, h_left, _⟩ := …ultrafilter_correspondence` followed by `:990`
  "We need to show this for our specific definitions" and a fresh proof
- **Description**: `SetMaximalConsistent.ultrafilter_correspondence` is stated as
  `∃ f g, Function.LeftInverse g f ∧ Function.RightInverse g f`. Because the witnesses are
  existentially bound, the inverse facts cannot be applied to the *named* maps `mcsToUltrafilter`
  and `ultrafilterToMcs`, so `ultrafilter_mcs_round_trip` destructures the existential, discards
  it, and redoes the whole argument. `mcs_ultrafilter_round_trip` likewise.
- **Impact**: ~200 lines where ~130 suffice; the headline result of the module is in a shape no
  consumer can use.
- **Recommendation**: State it as an `Equiv` and derive the existential form if it is still wanted:
  ```lean
  noncomputable def SetMaximalConsistent.ultrafilterEquiv :
      {Γ : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) Γ} ≃ Ultrafilter LindenbaumAlg where
    toFun    := mcsToUltrafilter
    invFun   := ultrafilterToMcs
    left_inv := ultrafilter_mcs_round_trip
    right_inv := mcs_ultrafilter_round_trip
  ```
  with the two round trips proved first and `ultrafilter_correspondence` reduced to
  `⟨_, _, ultrafilterEquiv.left_inv, ultrafilterEquiv.right_inv⟩`.
- **Effort**: M
- **Depends on**: F-11

### F-13. `fold_le_of_derives` hand-rolls a `List.foldl` meet that Mathlib exposes as `Multiset.inf`

- **Severity**: Low
- **Category**: abstraction
- **Anchors**: `Algebraic/UltrafilterMCS.lean:565-666` (102 lines), especially `:596-600`
  ("We need to relate fold from (⊤ ⊓ [φ]) with fold from ⊤"); Mathlib `Multiset.inf_coe`
  (`(↑l).inf = List.foldr (· ⊓ ·) ⊤ l`), `List.foldr_inf_eq_inf_toFinset`
- **Description**: The statement uses `List.foldl (fun acc φ => acc ⊓ toQuot φ) ⊤ L`. `foldl`
  threads the accumulator through the recursion, so the cons step must relate a fold started at
  `⊤ ⊓ [φ]` to one started at `⊤` — the source of roughly half the proof's length. With `foldr`,
  the cons step is `List.foldr_cons` and the induction is immediate; and `Multiset.inf_coe` then
  connects the whole thing to `Finset.inf`, whose `le` API (`Finset.inf_le`, `Finset.le_inf`)
  supplies the surrounding lemmas.
- **Impact**: One of the longest proofs in `Algebraic/`, fighting an accumulator that need not exist.
- **Recommendation**: Restate as `((L.map toQuot : List LindenbaumAlg) : Multiset _).inf ≤ toQuot ψ`
  (or `List.foldr (· ⊓ ·) ⊤ (L.map toQuot)`), and reuse the `Multiset.inf`/`Finset.inf` API.
- **Effort**: S
- **Depends on**: -

### F-14. Future/past mirroring is done textually 30+ times, though `swapTemporal` + `temporal_duality` already exist and are used once

- **Severity**: High
- **Category**: duplication / abstraction
- **Anchors**: the one correct use — `Algebraic/FlowFrame.lean:618-628` `past_tf_deriv`, which
  derives `□φ → H□φ` from `□φ → G□φ` via `Formula.swapTemporal` and
  `DerivationTree.temporal_duality`. The textual mirrors:
  `WitnessSeed.lean:59/81`, `:107/128`, `:150/271`, `:181/290`, `:408/488`, `:573/602`;
  `TemporalContent.lean:157/212`; `SuccRelation.lean:149/315`, `:246/406`;
  `CanonicalTaskRelation.lean:74-194 / 707-849`, `:619/906`, `:661/1008`;
  `TemporalCoherence.lean:66/82`, `:98/117`, `:178/204`, `:225/247`, `:339/365`, `:393/418`;
  `LimitMCS.lean:136/143`, `:156/177`, `:203/211`, `:225/233`, `:255/267`;
  `LimitMCSCoherence.lean:92/158`, `:110/188`, `:131/211`, `:259/298`, `:278/315`
- **Description**: Roughly 30 declaration pairs are produced by substituting
  `allFuture→allPast`, `someFuture→somePast`, `untl→snce`, `right_mono_until→right_mono_since`,
  `temporal_necessitation→pastNecessitation`, `temporalKDistDerived→pastKDist`, `max→min`, `<→>`.
  Conservatively 1,200-1,400 lines are the second half of a mirror. `past_tf_deriv` demonstrates
  the machinery to avoid this is present and works.
- **Impact**: Every temporal change is a two-site change, and the two sites drift: e.g. the past
  analogue of `existsTask_transitive:268` is stated as `h_content_chain_transitive:296` on raw
  `HContent ⊆` rather than on `ExistsTaskPast`, so the pair no longer reads as a pair.
- **Recommendation**: Two complementary moves.
  (a) *Derive, don't retype*: wherever a past statement is the `swapTemporal` image of a future one
  (all of `WitnessSeed`'s duality helpers, `TemporalCoherence.lean:66/82` and `:98/117`,
  `TemporalContent.lean:157/212`), prove the future form and obtain the past form by
  `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution`, exactly as
  `past_tf_deriv` does.
  (b) *Parameterize where duality does not apply* (the order-theoretic mirrors in `LimitMCS`/
  `LimitMCSCoherence`, where the mirror is `<`↔`>` not `swapTemporal`): introduce
  ```lean
  /-- One temporal direction: its universal/existential operators and its order. -/
  structure TemporalSide where
    all  : Formula → Formula      -- allFuture / allPast
    some : Formula → Formula      -- someFuture / somePast
    lt   : ℝ → ℝ → Prop           -- (· < ·) / (· > ·)
  ```
  and state `limitSet`, `limitSet_mono_directed`, `limitSet_consistent`, and the four
  `LimitMCSCoherence` families once, instantiating at `future`/`past`.
  Even doing (a) alone removes an estimated 400+ lines.
- **Effort**: L
- **Depends on**: -

### F-15. `Axiom.right_mono_until … Formula.top` is inlined 14 times; `fMono`/`pMono` already name it

- **Severity**: Medium
- **Category**: duplication
- **Anchors**: `Theorems/TemporalDerived.lean:407-419` (`fMono`, `pMono`, with docstrings that say
  exactly this); the 14 inline re-derivations at `Bundle/TemporalContent.lean:174,203,222,247`,
  `Bundle/WitnessSeed.lean:67,90,113,134`, `Bundle/SuccRelation.lean` (6 sites, incl. `:214,380`);
  the same pattern also at `BXCanonical/Chronicle/RRelation.lean:1264,1287`
- **Description**: The four-step idiom `notNotIntro` → `temporal_necessitation` →
  `DerivationTree.axiom [] _ (Axiom.right_mono_until φ ψ Formula.top) trivial` → `modus_ponens`,
  producing `⊢ Fφ → Fψ`, is written out in full 14 times inside the territory. `fMono` is that
  axiom instantiation under a name, and it is already `{fc}`-generic (via `FrameClass.base_le`),
  which several of the inline copies are not — they build at `.Base` then `DerivationTree.lift`.
- **Impact**: Four lines become one; and the `lift`-vs-`base_le` inconsistency disappears.
- **Recommendation**: Replace each inline block with `fMono φ ψ` / `pMono φ ψ` applied to the
  necessitated implication. Consider adding the two derived rules the sites actually want:
  `someFuture_mono : (⊢[fc] φ.imp ψ) → ⊢[fc] φ.someFuture.imp ψ.someFuture` (necessitate, then
  `fMono`), and its past dual — that turns each site into a single application.
- **Effort**: S
- **Depends on**: -

### F-16. `ModalSaturation.lean` delivers five general derivation helpers under a name describing a dead saturation layer

- **Severity**: Medium
- **Category**: organization / naming
- **Anchors**: live exports `boxDneTheorem:262`, `axiom5NegativeIntrospection:422`,
  `negBoxToBoxNegBox:502`, `SetMaximalConsistent.contrapositive:281`,
  `SetMaximalConsistent.neg_box_implies_box_neg_box:511` — imported by
  `BXCanonical/{CanonicalModel, CompletenessDedekind, Frame}`,
  `BXCanonical/Chronicle/{ChronicleToCountermodel, ChronicleToCountermodelBasic, ChronicleTypes,
  MCSMixedCase}`, `WeakCanonical/{IntegerModel/ReynoldsBridge, GroupModel/CountermodelBase}`,
  `Bundle/RealExtensionBundle`. Dead: `needs_modal_witness:60`, `IsModallySaturated:76`,
  `is_modally_saturated_iff_no_needs_witness:84`, `diamond_eq:105`,
  `diamond_excludes_box_neg:114`, `diamond_and_not_psi_implies_neg:128`,
  `diamond_implies_psi_consistent:153`, `saturated_modal_backward:333`, `SaturatedBFMCS:377`,
  `SaturatedBFMCS.modal_backward:386`, `dneTheorem:229`, `dniTheorem:238`,
  `modal5CollapseTheorem:404`
- **Description**: Nine route modules import a file called `ModalSaturation` to obtain S5 axiom
  derivations and two MCS lemmas. Nothing anywhere consumes the saturation predicate, the
  saturated-bundle structure, or `saturated_modal_backward`. The module docstring (`:18`) still
  says its purpose is "enabling the elimination of the `modal_backward` sorry in Construction.lean"
  — a sorry that no longer exists, in a file (F-01) that is dead. Section headings read
  "## Phase 1:" (`:56`).

  The same misplacement occurs on a smaller scale elsewhere: `gDneTheorem`/`hDneTheorem`
  (`TemporalCoherence.lean:66,82`) and `pastTempA` (`WitnessSeed.lean:567`) are pure
  derivation-building `def`s living in canonical-model modules; `pastTempA` is also *misdescribed*
  — its docstring says "Derived from temp_a via temporal duality" but the body is a direct
  `Axiom.connect_past` application, and the axiom name `temp_a` it cites does not exist
  (the axiom is `Axiom.connect_future`, `ProofSystem/Axioms.lean:170`).
- **Impact**: The import graph misrepresents what depends on what; a reader tracing "why does
  `CountermodelBase` need modal saturation?" finds it does not.
- **Recommendation**: Split. Move the five live helpers plus `gDneTheorem`, `hDneTheorem`,
  `pastTempA`, `dneTheorem`, `dniTheorem`, `boxDneTheorem` into `Theorems/ModalDerived.lean`
  (or extend `Theorems/Combinators.lean`); the nine importers then say what they mean. Boneyard the
  saturation layer, or keep it in a `Bundle/ModalSaturation.lean` that contains only saturation.
  Fix `pastTempA`'s docstring and drop `noncomputable` (it is a plain `DerivationTree.axiom`).
- **Effort**: M
- **Depends on**: F-01

### F-17. `LimitMCS` proves the same finite-intersection argument twice — once hand-rolled with thresholds, once via the `Filter` API

- **Severity**: Medium
- **Category**: abstraction
- **Anchors**: hand-rolled: `Bundle/LimitMCS.lean:136,143` (`limitSetBelow`/`Above`),
  `:156-199` (`_mono_directed`, `max`/`min` induction), `:203-218` (`_finite_subset_mem`),
  `:225-240` (`_consistent`). Filter-based, same argument: `:316-327` (`limitFilterBelow`),
  `:393-424` (`limitMCSBelow_finite_subset_mem` via `Filter.inter_mem`).
  Mathlib: `Filter.Eventually`, `Filter.eventually_all_finite`, `Filter.comap`, `nhdsWithin`,
  `Filter.NeBot.nonempty_of_mem`
- **Description**: `limitSetBelow m r = {A | ∃ z < r, ∀ q ∈ (z,r), A ∈ m q}` is exactly
  `{A | ∀ᶠ q in limitFilterBelow r, A ∈ m q}` — the filter is defined 180 lines later in the same
  file. Consequently `limitSetBelow_mono_directed` (a bespoke 23-line `max`-threshold induction) is
  `Filter.eventually_all_finite`, and `limitSetBelow_finite_subset_mem` is
  `Filter.NeBot.nonempty_of_mem`. The file then does the identical reasoning correctly, via
  `Filter.inter_mem`, for `limitMCSBelow`. `limitFilterBelow` itself is
  `Filter.comap (Rat.cast : ℚ → ℝ) (𝓝[<] r)`, from which `limitFilterBelow_neBot:337` follows from
  the density of `ℚ` in `ℝ` rather than from a bespoke `exists_rat_btwn` argument.
- **Impact**: ~85 lines duplicating Mathlib, and two incompatible idioms for the same notion inside
  one module — which is also why `limitSetBelow_*` and `limitMCSBelow_*` need parallel coherence
  lemma families in `LimitMCSCoherence.lean` (five of which, `:110,131,174,188,211`, are now dead).
- **Recommendation**: Define `limitFilterBelow` first, as the `comap`; define
  `limitSetBelow m r := {A | ∀ᶠ q in limitFilterBelow r, A ∈ m q}`; delete `:156-218` in favour of
  `Filter.eventually_all_finite` + `Filter.NeBot.nonempty_of_mem`. Keep the explicit-threshold
  characterisation as a single `mem_limitSetBelow` unfolding lemma for the coherence proofs that
  want it. Boneyard the five dead `limitSetBelow_*` coherence lemmas.
- **Effort**: M
- **Depends on**: F-14(b)

### F-18. `Bundle.lean` imports `FMCSDef` twice

- **Severity**: Low
- **Category**: organization
- **Anchors**: `Bundle.lean:11` and `:12`, both `import FormalSystem.Metalogic.Bundle.FMCSDef`
- **Description**: The aggregator lists `FMCSDef` on two consecutive lines. Since `Bundle.lean` is
  outside every Lake target's import closure and is only compile-checked by the C6 manifest, no
  build stage flags it.
- **Impact**: Trivial, but it is in the file that is meant to be the directory's index.
- **Recommendation**: Delete line 12. Consider having `check-module-invariants.sh` flag duplicate
  import lines while it is already parsing them for the dangling-import check.
- **Effort**: S
- **Depends on**: -

### F-19. Naming inconsistencies across the shared core

- **Severity**: Low
- **Category**: naming
- **Anchors**: as listed
- **Description**:
  - `def iterF` (`CanonicalTaskRelation.lean:74`, correct lowerCamelCase) but its lemmas are
    `iter_F_zero:80`, `iter_F_succ:84`, `iter_F_complexity:107`… — Mathlib would snake-case `iterF`
    to `iterF`, giving `iterF_zero`. Same for the 11 `iter_P_*`. Contrast `closureFBound:160`,
    which is correct.
  - `theorem CanonicalTask_forward.step_inv:222` uses dot notation; `theorem
    CanonicalTask_forward_zero:318` and `CanonicalTask_forward_comp:369` do not, for the same type.
  - `def lindenbaumMCS` (`Construction.lean:112`) vs `def LindenbaumMCSSet` (`:142`): same return
    type `Set Formula`, opposite capitalization, ten lines apart.
  - `@[simp] lemma ExistsTask_def` (`CanonicalFrame.lean:77`) vs `ExistsTask_past_def` (`:89`) —
    the latter names the definition `ExistsTaskPast` as `ExistsTask_past`, so grepping the
    definition name does not find its own simp lemma. Both are stated as `Eq` between `Prop`s
    (`ExistsTask M M' = (GContent M ⊆ M')`) where Mathlib would use `↔`.
  - `theorem Succ_implies_CanonicalR` (`SuccRelation.lean:96`) concludes `ExistsTask u v`;
    `CanonicalR` appears nowhere in the file (nor in `Bundle/`).
  - `theorem` vs `lemma`: `Bundle/` uses 109 `theorem` and 63 `lemma` with no discernible rule
    (`WitnessSeed.lean` uses `lemma` for `some_future_all_future_neg_absurd:59` and `theorem` for
    `forward_temporal_witness_seed_consistent:181`, both substantive); `Algebraic/` uses 87
    `theorem` and 0 `lemma`. Two halves of one shared core with opposite conventions.
- **Impact**: Discoverability. A reader who knows the definition name cannot guess the lemma names.
- **Recommendation**: Rename `iter_F_*`→`iterF_*`, `iter_P_*`→`iterP_*`; `ExistsTask_past_def`→
  `ExistsTaskPast_def` and restate both as `↔`; `Succ_implies_CanonicalR`→`Succ.to_existsTask`;
  unify `lindenbaumMCS`/`LindenbaumMCSSet` (moot if F-01 lands). Pick one of `theorem`/`lemma` and
  record the choice in `Metalogic/README.md`.
- **Effort**: M
- **Depends on**: -

### F-20. The `fc` frame-class parameter reads backwards at 130 call sites

- **Severity**: Low
- **Category**: api-ergonomics
- **Anchors**: `Bundle/FMCSDef.lean:98` `structure FMCS (fc : FrameClass := FrameClass.Base)`
  with `D` supplied by `variable (D : Type) [Preorder D]` at `:96`; `BFMCS.lean:91` likewise;
  130 occurrences of `FMCS (fc := …)` / `BFMCS (fc := …)` in the live tree
- **Description**: Because `D` comes from a `variable` and `fc` is an explicit field parameter with
  a default, the applied form is `FMCS (fc := fc) D` — the second parameter written first, by name,
  at essentially every use. Signatures such as
  `bundleFlow_truth_lemma (B : BFMCS (fc := fc) D) … (fam : {fam : FMCS (fc := fc) D // …})`
  carry the noise twice.
- **Impact**: 130 named-argument annotations; the type that names the whole approach reads
  awkwardly everywhere it appears.
- **Recommendation**: Declare the parameters in reading order —
  `structure FMCS (D : Type) [Preorder D] (fc : FrameClass := FrameClass.Base)` — so uses become
  `FMCS D fc`, or `FMCS D` when the default applies. Mechanical (`FMCS (fc := X) D` → `FMCS D X`).
  While editing, consider `{D : Type*}`: `Bundle/` and `FlowFrame` are universe-monomorphic in 11
  binders, and `FlowFrame.lean:801` records the restriction as a caveat rather than a choice.
- **Effort**: M
- **Depends on**: -

### F-21. Docstrings that misdescribe the code

- **Severity**: Medium
- **Category**: documentation
- **Anchors**: as listed
- **Description**: Several docstrings state facts the tree contradicts.
  - `SuccRelation.lean:143` and `:131-141` assert `F(phi) = neg(G(neg(phi)))  [def someFuture]` as
    definitional. `WitnessSeed.lean:47-49` records the opposite — "`someFuture`/`somePast` are no
    longer definitionally `neg(allFuture/allPast(neg _))`" — which is precisely why
    `some_future_all_future_neg_absurd` exists. The `SuccRelation` reasoning is correct; its
    justification is not.
  - `UltrafilterMCS.lean:26`: "Contains sorries pending MCS helper lemmas." The file is sorry-free
    (check C3 asserts zero repo-wide).
  - `ModalSaturation.lean:18`, `TemporalCoherence.lean:517,556`, `Construction.lean:86,91,250`:
    prose about sorries that no longer exist.
  - `WitnessSeed.lean:561,565-566,572`: cites an axiom `temp_a` that does not exist
    (`Axiom.connect_future`/`connect_past`, `ProofSystem/Axioms.lean:170,174`), and describes
    `pastTempA` as "derived via temporal duality" when it is a direct axiom application.
  - `CanonicalFrame.lean:262-267`: the docstring of `existsTask_transitive` contains a
    self-correction mid-sentence — "But wait - we need: `G phi ∈ M` implies `phi ∈ M''`."
  - `BFMCS.lean:169-175`: `BFMCS.transitivity`'s docstring says "Actually, transitivity in S5 says:
    Box phi -> Box Box phi (4 axiom). For our purposes, we prove the more useful direction".
  - `Construction.lean:23` is an empty `## History` heading; `:71,83` are "## REMOVED:" sections;
    `FMCSDef.lean:129-133` and `BFMCS.lean:200-202,229-231` are "Unused … removed:" changelog
    comments in source.
  - The terminology glossary (MCS / FMCS / BFMCS) is restated in `FMCSDef.lean:35-39` and
    `BFMCS.lean:19-23`, in different order, and nowhere else — there is no single glossary.
- **Impact**: For a development being prepared for publication, these are the passages a referee
  will read first. Several would lead a reader to a wrong conclusion about the proof system.
- **Recommendation**: Fix the four factual errors; delete the changelog and self-correction prose
  (`git log` is the history); replace the two glossary copies with one section in
  `Bundle/README.md` referenced from both modules. `LimitMCS.lean`'s module docstring is the model
  to follow — it states a claim, gives the counterexample, and cites a page number.
- **Effort**: S
- **Depends on**: -

### F-22. `restricted_mcs_F_bounded` / `_P_bounded`: 154 lines of hand-rolled well-founded minimum

- **Severity**: Medium
- **Category**: proof-elegance / abstraction
- **Anchors**: `Core/RestrictedMCS/Basic.lean:488-572` (84 lines) and `:593-663` (70 lines, exact
  mirror); also `restricted_mcs_negation_complete:137-273` (136 lines)
- **Description**: Both `_bounded` proofs build `S : Set Nat := {n | n ≥ 2 ∧ iterF n phi ∉ M}`
  (`:520`), prove it nonempty, invoke `WellFounded.has_min`, then reason by hand that `min_n - 1 ∉ S`
  to recover the boundary point — with `Nat` subtraction and an `omega`-guarded `min_n ≥ 2` case
  split. Mathlib's `Nat.find` (with `Nat.find_spec` / `Nat.lt_find_iff` / `Nat.find_min'`) states
  exactly "least `n` such that `P n`" and gives the predecessor fact directly, avoiding both the
  well-foundedness plumbing and the truncated subtraction.
- **Impact**: The two largest proofs in `RestrictedMCS/Basic.lean` after
  `restricted_mcs_negation_complete`, and mirror duplicates of each other.
- **Recommendation**: Restate via `Nat.find` on `fun n => iterF (n+1) phi ∉ M` (the `+1` shift
  removes the `≥ 2` bookkeeping and the `min_n - 1`), which should reduce each to ~20 lines. Then
  factor the two into one lemma over an abstract `iter : ℕ → Formula → Formula` with the two
  hypotheses actually used (`iter 1 phi = op phi`, `iter n phi ∉ closureWithNeg phi` for large `n`)
  and instantiate at `iterF`/`iterP` — combining with F-02's relocation, this is one 25-line lemma
  instead of 154.
- **Effort**: M
- **Depends on**: F-02

---

## 4. Proposed core utilities

Ranked by (lines discharged) × (number of findings closed).

**1. `structure BFMCS.CanonicalCoherence` — home: `Bundle/TemporalCoherence.lean`**
```lean
structure BFMCS.CanonicalCoherence (B : BFMCS (fc := fc) D) (root : Formula) : Prop where
  temporal       : B.RestrictedTemporallyCoherent root
  untilSince_fwd : B.RestrictedForwardUntilSinceCoherent root
  untilSince_bwd : B.RestrictedBackwardUntilSinceCoherent root

theorem bundleFlow_truth_lemma (B : BFMCS (fc := fc) D) (root : Formula)
    (hc : B.CanonicalCoherence root) (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (fam : {fam // fam ∈ B.families}) (w₀ t : D) :
    φ ∈ fam.val.mcs (w₀ + t) ↔ TruthAt (bundleFlowModel B) (bundleFlowHistory fam w₀) t φ
```
Stabilizes three signatures, removes the unused-hypothesis trap, and makes the Hintikka structure
of the argument visible to a logician: "these are the conditions a bundle must satisfy for
membership to be truth." Discharges **F-05**; enables pruning the four dead coherence predicates.

**2. The temporal-duality discipline — home: `Bundle/` (pattern), one worked example already at
`Algebraic/FlowFrame.lean:618`**
```lean
/-- Obtain the past-side statement as the `swapTemporal` image of the future-side one. -/
theorem mirror {φ : Formula} (h : ⊢[fc] futureForm φ) : ⊢[fc] pastForm φ
```
Adopt `DerivationTree.temporal_duality` + `Formula.swap_temporal_involution` as the default for
every past-side *derivation*, and a `TemporalSide` parameter for every past-side *order* statement.
Discharges **F-14**, half of **F-08**, and the mirror halves of **F-10**, **F-17**, **F-22**.
Largest single line reduction available (est. 400-800).

**3. `theorem allFuture_neg_of_gseed_inconsistent` (+ past mirror) — home: `Bundle/WitnessSeed.lean`**
```lean
theorem allFuture_neg_of_gseed_inconsistent {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula)
    (h : ¬ SetConsistent (fc := fc) ({ψ} ∪ GContent M)) : Formula.allFuture ψ.neg ∈ M
```
The one argument shared by all four seed-consistency theorems. Discharges **F-08** (~210 lines).

**4. `FormalSystem/Syntax/SubformulaClosure/IteratedTemporal.lean` — new module**
Hosts `iterF`, `iterP`, `closureFBound`, `closurePBound` and their 20 complexity/nesting lemmas,
which are pure syntax. Breaks the `Core ↔ Bundle` cycle for three Lean files and no renames.
Discharges **F-02**, unblocks **F-10** and **F-22**.

**5. `SetMaximalConsistent.bot_not_mem` — home: `Core/MCSProperties.lean`**
```lean
theorem SetMaximalConsistent.bot_not_mem {fc : FrameClass} {S : Set Formula}
    (h : SetMaximalConsistent (fc := fc) S) : Formula.bot ∉ S
```
Discharges **F-09**; removes an accidental `WeakCanonical → BXCanonical` dependency.

**6. `Theorems/ModalDerived.lean` — new module**
Rehomes the eight derivation helpers currently hiding in `Bundle/ModalSaturation.lean`,
`Bundle/TemporalCoherence.lean` and `Bundle/WitnessSeed.lean` (`boxDneTheorem`,
`negBoxToBoxNegBox`, `axiom5NegativeIntrospection`, `dneTheorem`, `dniTheorem`, `gDneTheorem`,
`hDneTheorem`, `pastTempA`). Nine route modules stop importing "ModalSaturation" for S5 axioms.
Discharges **F-16**.

**7. `someFuture_mono` / `somePast_mono` — home: `Theorems/TemporalDerived.lean`**
```lean
theorem someFuture_mono {fc : FrameClass} {φ ψ : Formula} (h : ⊢[fc] φ.imp ψ) :
    ⊢[fc] φ.someFuture.imp ψ.someFuture :=
  DerivationTree.modus_ponens [] _ _ (fMono φ ψ) (DerivationTree.temporal_necessitation _ h)
```
Collapses the 14 inline `right_mono_until`/`_since` blocks to one application each.
Discharges **F-15**.

**8. `SetMaximalConsistent.ultrafilterEquiv : {Γ // SetMaximalConsistent Γ} ≃ Ultrafilter LindenbaumAlg`
— home: `Algebraic/UltrafilterMCS.lean`**
Replaces the anonymous existential with the object every consumer would actually want, and makes
the two round trips its fields rather than independent 70-line proofs. Discharges **F-12**;
natural first step toward **F-11**.

---

## 5. Metrics

| | |
|---|---|
| Territory size | 9,760 lines / 22 files (`Bundle/` 6,106+52; `Algebraic/` 2,899+40; `Core/RestrictedMCS/Basic.lean` 663) |
| Modules with **zero** live cross-file consumers | 3 (`Construction` 253, `CanonicalFrame` 312, `UntilSinceCoherence` 46) = **611 lines** |
| Modules with zero live consumers *outside their own group* | +4 (`Algebraic/{LindenbaumQuotient, BooleanStructure, InteriorOperators, UltrafilterMCS}`) = **2,081 lines** |
| Declarations with no live cross-file reference | **≈195** (see §2) |
| Directory-level cycles found | **3** (`Core↔Bundle`, `Bundle↔Algebraic`, plus `BXCanonical↔WeakCanonical` outside territory); `Metalogic/README.md:88` asserts 2 |
| Files needed to break `Core↔Bundle` | **3 Lean** (1 new, 2 edited), 0 renames — README states 9 files for a different plan |
| Files needed to break `Bundle↔Algebraic` | **2 Lean**, 1 declaration moved |
| Declarations > 60 lines | **26** (largest: `single_step_forcing_past` 147, `restricted_mcs_negation_complete` 136, `ultrafilter_correspondence` 127, `bundleFlow_truth_lemma` 124, `le_sup_inf_quot` 118) |
| `set_option maxHeartbeats` / `maxRecDepth` overrides | **0** |
| Structural `sorry` | **0** (confirmed) |
| `FrameOver` construction sites in completeness infra | 2 (`multiFamTaskFrameGen`, `multiFamTaskFrame`) — of which 1 is a redundant `rfl`-equal copy |
| Truth lemmas | **1** (`bundleFlow_truth_lemma`); 2 files named `TruthLemma.lean` contain none |
| `bot_not_in_mcs` proofs | **3** |
| Inline `Axiom.right_mono_until/_since … Formula.top` re-derivations in territory | **14** (named `fMono`/`pMono` at `TemporalDerived.lean:407,418`) |
| Future/past textual mirror pairs | **≈30 declaration pairs**, est. 1,200-1,400 lines |
| `FMCS (fc := …)` / `BFMCS (fc := …)` named-argument sites | **130** |
| `theorem` : `lemma` ratio | `Bundle/` 109:63, `Algebraic/` 87:0 |
| Stale/incorrect docstring claims identified | **10** (F-21) |
| Dangling module references in prose | `SuccExistence.lean` ×5, `FMCS.lean`, `CanonicalIrreflexivity.lean` (`Bundle/README.md` + 2 source files) |
| Estimated line reduction from the 8 proposed utilities | **≈1,800-2,400** (18-25% of territory), with no loss of theorem content |
