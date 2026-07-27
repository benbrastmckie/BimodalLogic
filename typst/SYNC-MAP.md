# SYNC-MAP: BimodalReference.typ ↔ Lean Source Claim Verification

> **Status (2026-07-15)**: a later revision cut Parts III (Counterfactual Logic) and IV
> (Constitutive Logic) from the book entirely, leaving a two-part reference (Part I: The
> Bimodal System; Part II: Applications). The per-chapter tables below (from the two revision rounds
> vintage) describe the book's now-superseded four/five-part structure at the time each
> claim was verified; they are a historical record and are retained as-is, not rewritten.

> **Status**: this file is a repo-side *development document* recording the
> claim-verification history of the BimodalReference book. It no longer governs the
> compiled PDF: the sync-class banner system (banners, legend, inline ✓/⧖/○/◇ markers)
> was later removed from the book, and the compiled book carries no sync-class
> markings. `scripts/typst-sync-check.sh` now runs two checks only — backtick name
> resolution and count freshness. The legend, enforcement rules, and per-chapter
> assignments below are retained as historical record of how each claim was verified.

Generated during the BimodalReference typst revision.
Lean source ground truth: `Theories/Bimodal/` (excluding `Boneyard/`).
Stamp: 2026-07-06, git commit `a883361bf`.

## Sync-Class Legend — HISTORICAL

Every chapter file included by `BimodalReference.typ` formerly carried a
`#sync-banner(class, ...)` call declaring which of four classes governed its claims
(since removed from the book; retained here as the key to the verification tables below):

| Symbol | Class | Meaning |
|--------|-------|---------|
| ✓ | `"check"` (lean-verified) | Every formal claim in the chapter carries a resolving Lean anchor; either sorry-free or its sorry-status is stated plainly (a ✓ chapter may still *report on* an ⧖ result — e.g. "Completeness is stated ✓, proof has open sorries ⧖" — as long as the sorry-status is not hidden). |
| ⧖ | `"sorries"` (with-sorries) | Lean-anchored, but the chapter's headline claims have open proof obligations (sorries) that are enumerated, not glossed over. |
| ○ | `"paper"` (paper-sourced) | Proved in a cited paper (possible_worlds.tex, counterfactual_worlds.tex, or third-party literature); not formalized in this repository. |
| ◇ | `"outlook"` (outlook-planned) | Design/roadmap content; no proof anywhere yet (Lean or paper). |

**Enforcement rules** (checked mechanically by `scripts/typst-sync-check.sh`, Phase 4):

1. No chapter banner-classed ○ or ◇ may contain an inline "lean-verified"/✓ claim about its
   own headline content (a ○/◇ chapter may still *cite* a ✓ result from another chapter).
2. No backticked Lean identifier or path may appear anywhere in `typst/**/*.typ` that fails
   to resolve under `Theories/Bimodal/` (excluding `Boneyard/`), per the Phase 6 extraction
   method below — external-repo (Logos) names are cited as external and commit-pinned, never
   as if they were local Lean names.
3. Per-claim overrides are allowed *inside* a chapter via inline sync-class markers (e.g. a
   ✓ chapter may inline-mark one paragraph ○ where it is quoting the paper) — the chapter
   banner states the *dominant* class; inline markers state exceptions.
4. Every chapter file included by the main file must carry exactly one `#sync-banner(` call
   near its top-level heading.

**Per-chapter assignment** (stub chapters received their sync-class in a later phase):

| Chapter | Class | Rationale |
|---------|-------|-----------|
| `00-introduction.typ` | ✓/◇ mixed | Project-structure claims ✓; book-map/roadmap paragraphs ◇ |
| `01-syntax.typ` | ✓ | Formula type, primitives, derived operators all Lean-anchored, sorry-free |
| `02-semantics.typ` | ✓ | Task frames, truth conditions Lean-anchored, sorry-free |
| `03-proof-theory.typ` | ✓ | 42-constructor axiom system, 7 rules, Lean-anchored, sorry-free |
| `04-metalogic.typ` | ⧖ | Soundness/deduction/Lindenbaum ✓, but completeness carries the 43-sorry chain |
| `05-theorems.typ` | ✓ | Perpetuity P1-P6 and theorem libraries, sorry-free |
| `06-notes.typ` | ⧖ | Reports the same completeness/decidability sorry-status as 04; discrepancy notes are ✓ (Lean-vs-paper facts) |

**Landed**: all seven chapters above carry a `#sync-banner(...)` call
immediately after their level-1 heading; `04-metalogic.typ` and `06-notes.typ` import their
sorry/axiom/rule counts from `typst/generated/status.typ` rather than hand-copying digits
(as do `00-introduction.typ` and `03-proof-theory.typ`, extended opportunistically in the
same pass). This makes both banner-presence and count-freshness mechanically checkable —
input to Phase 4's `scripts/typst-sync-check.sh` (Checks 2 and 4).

## Scope Decisions (Phase 0)

### D1. Primary completeness wiring (verified from live source)

**Primary completeness theorem**: `Bimodal.Metalogic.BXCanonical.completeness`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:135`):

```
theorem completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)
```

with frame-class variants `completeness_dense` (`:234`) and `completeness_discrete` (`:276`),
and alternate form `completeness'` (`:177`).

**Live-source evidence** (imports and theorem locations, not README/ROADMAP sentences):
- `Metalogic.lean` imports `Bimodal.Metalogic.Soundness`,
  `Bimodal.Metalogic.Decidability`, `Bimodal.Metalogic.BXCanonical`,
  `Bimodal.Metalogic.WeakCanonical` — BXCanonical is the wired entry point.
- `BXCanonical/Completeness.lean:4-8` imports `Chronicle.ChronicleToCountermodel`,
  `Chronicle.MCSMixedCase`, and `WeakCanonical` — the proof is wired through
  `countermodel_dense` (`Chronicle/ChronicleToCountermodelBasic.lean:792`, Burgess 1982
  chronicle construction over ℚ, dense case) and the WeakCanonical Reynolds/Doets
  pipeline (`WeakCanonical/Transfer.lean`, discrete case over ℤ), with the mixed case
  eliminated by `mcs_mixed_case_absurd`.

**Status**: Completeness is NOT sorry-free (leaf sorries in Chronicle/WeakCanonical
modules; see counts below). Soundness (`soundness`, `soundness_dense`,
`soundness_discrete`) IS sorry-free.

**Active-secondary approaches** (none silently dropped): `Bundle/` (BFMCS
infrastructure shared by all paths), `Algebraic/` (D-parametric truth lemma /
`ParametricCompleteness`), `WeakCanonical/` (discrete path, also hosts in-progress
Kamp work), `ConservativeExtension/`, `Relational/`.

**Resolution of the three-way doc disagreement**: `Metalogic/README.md` (Bundle/BFMCS
primary) is self-warned stale; `specs/ROADMAP.md` (Chronicle path) is directionally
right — the Chronicle path is the dense-case engine — but the wired top-level theorem
is `BXCanonical.completeness`; the old typst doc (`semantic_weak_completeness`, `FMP/`,
`Representation/`) describes a deleted architecture that survives only in `Boneyard/`.

### D2. Frame-class parametrization scope

IN scope for `03-proof-theory.typ`: the `FrameClass` parameter on `DerivationTree`
(`ProofSystem/Derivation.lean:85+`, constraint `h.minFrameClass ≤ fc`) and the
Base/Dense/Discrete axiom layers are presented in full — they are inseparable from an
accurate 42-constructor presentation. Summary-level in `04-metalogic.typ`: per-frame-class
soundness/completeness variants are named, not proof-sketched. No dedicated frame-class
chapter (deferred).

### D3. latex/ mirror: declared divergence

`latex/BimodalReference.tex` is NOT synced this pass. `typst/README.md` carries an
explicit "latex mirror is stale as of 2026-07-06; typst is authoritative" note.
Full latex sync is a suggested follow-up task.

### D4. Other scope calls

- Kamp separation material appears only as short "work in progress, not
  citable" notes.
- Paper's Objective Modality and 2D Semantics: out of scope (not formalized).
- `docs/reference/*.md` staleness: flagged in the implementation summary, not edited.
- Paper §3.3 Extensions: documented only where Lean-formalized (frame classes);
  otherwise a one-line "not yet formalized" note.
- `Automation/` and `Examples/` directories: not documented.

## Ground-Truth Counts (Phase 1)

Regenerated from source at 2026-07-06, commit `a883361bf` (do not copy forward).

### Axiom constructors

Command: constructor listing of `inductive Axiom` in `ProofSystem/Axioms.lean:76-400`.

**42 constructors in 8 layers** (source's own layer comments):

| Layer | Count | Constructors |
|-------|-------|--------------|
| 1. Propositional | 4 | prop_k, prop_s, ex_falso, peirce |
| 2. S5 Modal | 5 | modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist |
| 3. BX Temporal | 22 | serial_future/past (BX1/BX1'), left_mono_until_G / left_mono_since_H (BX2G/BX2H), right_mono_until/since (BX3/BX3'), connect_future/past (BX4/BX4'), enrichment_until/since (BX13/BX13'), self_accum_until/since (BX5/BX5'), absorb_until/since (BX6/BX6'), linear_until/since (BX7/BX7'), until_F / since_P (BX10/BX10'), temp_linearity(_past) (BX11/BX11'), F_until_equiv / P_since_equiv (BX12/BX12') |
| 4. Modal-Temporal Interaction | 1 | modal_future (MF) |
| 5. Uniformity | 5 | discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity |
| 6. Prior | 2 | prior_UZ, prior_SZ |
| 7. Z1 | 1 | z1 |
| 8. Density | 2 | density, dense_indicator |

Frame-class assignment (`Axiom.minFrameClass`, `Axioms.lean:456-462`): Base = 37
(layers 1-5), Discrete-only = 3 (prior_UZ, prior_SZ, z1), Dense-only = 2 (density,
dense_indicator).

### Inference rules

7 rules, unchanged (`ProofSystem/Derivation.lean`, `inductive DerivationTree`):
axiom, assumption, modus_ponens, necessitation, temporal_necessitation,
temporal_duality, weakening.

### Sorry counts (genuine `sorry` terms, comments stripped)

Command: Python comment-stripping scan over `Theories/Bimodal/Metalogic/**/*.lean`
(block `/- -/` and line `--` comments removed before counting `\bsorry\b`).

| Metalogic/ subtree | Sorries |
|--------------------|---------|
| Algebraic/ | 3 |
| BXCanonical/ | 4 (Chronicle/ChronicleToCountermodel.lean 3, Frame.lean 1) |
| Bundle/ | 12 (SuccRelation 7, SuccExistence 3, UntilSinceCoherence 2) |
| WeakCanonical/ | 24 (incl. 2 in nested `Kamp/Boneyard/`; 22 excluding it) |
| Core/, ConservativeExtension/, Decidability/, Relational/, SoundnessLemmas/ | 0 |
| Top-level .lean (Completeness, Soundness, Decidability; former DenseSoundness/DiscreteSoundness wrappers archived to Boneyard/SoundnessVariants/) | 0 |
| **Total** | **43** (41 excluding nested `WeakCanonical/Kamp/Boneyard/`) |

Sorry-free confirmations (0 genuine sorries): `Metalogic/Soundness.lean`,
the archived `Boneyard/SoundnessVariants/` wrappers, entire `Theorems/` tree (including
`Perpetuity/` P1-P6), `Syntax/`, `Semantics/`, `ProofSystem/`.

### Frame classes

`FrameClass` inductive (`ProofSystem/Axioms.lean:422-426`): `Base`, `Dense`,
`Discrete`, partially ordered with Base ≤ Dense, Base ≤ Discrete (Dense, Discrete
incomparable). Frame-condition semantics in top-level `Theories/Bimodal/FrameConditions/`
(FrameClass.lean, Validity.lean, Soundness.lean, Compatibility.lean).

## Claim Verification Table (Phase 1)

Verdicts: `verified` (resolves in live source, meaning matches), `stale` (resolves
only in Boneyard or meaning changed), `not-found`, `fixed` (replaced during the revision).
Locations abbreviated: PS = ProofSystem, SEM = Semantics, ML = Metalogic, TH = Theorems.

### BimodalReference.typ (main file)

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 119 | `semantic_weak_completeness` | stale (Boneyard only) | replace with `completeness` (ML/BXCanonical/Completeness.lean:135) |

### 00-introduction.typ

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 85 | `Bimodal/` | verified | Theories/Bimodal/ |
| 86 | `Syntax/` | verified | dir exists |
| 87 | `ProofSystem/` + "14 schemata" | stale count | 42 constructors (Axioms.lean:76) |
| 88 | `Semantics/` | verified | dir exists |
| 89 | `Metalogic/` + "completeness via semantic canonical model" | stale narrative | BXCanonical completeness, not sorry-free |
| 90 | `Theorems/` | verified | dir exists |

### 01-syntax.typ

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 15 | `Formula` | verified | Syntax/Formula.lean:76 |
| 16 | primitives {atom,⊥,→,□,H,G} | stale | {atom, bot, imp, box, untl, snce} (Formula.lean:76-92) |
| 17 | `String` atoms | stale | `Atom` structured type (Syntax/Atom.lean); `atom_s` helper for strings |
| 29-34 | `atom s`,`bot`,`imp`,`box`,`all_past`,`all_future` as primitives | partly stale | all_past/all_future are derived defs (Formula.lean:141-155) |
| 61-63 | `neg`,`and`,`or` | verified | Formula.lean |
| 84 | `pos` | stale name | `diamond` (Formula.lean, def diamond) |
| 108-111 | `some_past`,`some_future`,`always`,`sometimes` | verified | Formula.lean:118-132, 157+ |
| 119 | `swap_temporal` | verified | Formula.lean:570 (defined on untl/snce) |

### 02-semantics.typ

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 34-38 | Task frame: Nullity + Compositionality (2 constraints) | stale | 3 fields: nullity_identity, forward_comp, converse (SEM/TaskFrame.lean:93-131); paper: Nullity/Reflection/Compositionality (possible_worlds.tex:902-907) |
| 85-90 | strict `<` truth conditions for H/G | verified (preserve) | SEM/Truth.lean:10-17, 120-131 |
| — | missing untl/snce truth clauses | gap | added from Truth.lean:125-130 |

### 03-proof-theory.typ

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 12 | "14 axiom schemata" | stale | 42 constructors, 8 layers |
| 91-99 | `Axiom.prop_k/prop_s/ex_falso/peirce/modal_t/modal_4/modal_b/modal_5_collapse/modal_k_dist` | verified | PS/Axioms.lean:80-108 |
| 100 | `Axiom.temp_k_dist` | stale | derived: `temp_k_dist_derived` (TH/TemporalDerived.lean:184) |
| 101 | `Axiom.temp_4` | stale | derived: `temp_4_derived` (TH/TemporalDerived.lean:239) |
| 102 | `Axiom.temp_a` | stale | axiom renamed: `connect_future` (BX4, Axioms.lean:152) |
| 103 | `Axiom.temp_l` (stated as △φ→GHφ) | stale (name and formula) | `temp_linearity` (BX11, Axioms.lean:262); paper TL is future-linearity (possible_worlds.tex:1103) |
| 104 | `Axiom.modal_future` | verified | Axioms.lean:297 |
| 105 | `Axiom.temp_future` | stale | derived: `temp_future_derived` (TH/Combinators.lean:661) |
| 165-171 | `DerivationTree.*` 7 rule constructors | verified | PS/Derivation.lean (axiom rule now takes `h_fc : h.minFrameClass ≤ fc`) |
| 182 | `DerivationTree Gamma phi` | stale signature | `DerivationTree fc Γ φ` with FrameClass parameter (Derivation.lean:85) |

### 04-metalogic.typ (pre-rewrite; all stale refs deleted in rewrite)

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 12,119,246,304,337,420,478,489,558,574 | `semantic_weak_completeness` | stale (Boneyard only) | `completeness` (BXCanonical/Completeness.lean:135) |
| 118,334,477 | `Representation/` | stale (deleted; not even in Boneyard under that path) | removed |
| 304,337,420,443,478 | `FMP/SemanticCanonicalModel.lean` | stale (Boneyard only) | removed; NOTE live `Decidability/FMP/` is a different module (tableau FMP) |
| 137 | `SemanticTaskRelV2` | not-found | removed |
| 144 | `SemanticWorldState` | not-found | removed |
| 148,151,419 | `IndexedMCSFamily` | not-found | removed |
| 162 | `truth_lemma` in `Metalogic/Representation/TruthLemma.lean` | stale path | live truth-lemma work: BXCanonical/TruthLemma.lean, WeakCanonical/TruthLemma.lean |
| 172,186 | `representation_theorem`, `strong_representation_theorem` | not-found | removed |
| 207 | `deduction_theorem` | verified | ML/Core/ (Core/Deduction) |
| 210,104 | `set_lindenbaum` | verified | ML/Completeness.lean, Core |
| 213 | `MaximalConsistent` | verified | ML/Core (SetMaximalConsistent variant used at set level) |
| 229,284 | `main_strong_completeness` | not-found | removed |
| 256,295 | `main_provable_iff_valid` | not-found | removed |
| 272-276 | `Context = List Formula`, `Set Formula` | verified | Syntax/Context.lean |
| 281 | `Boneyard/Metalogic_v2/Applications/Compactness.lean` | stale path | removed |
| 316 | `FiniteWorldState` | not-found | removed |
| 324 | `sorry_free_weak_completeness` | not-found | removed |
| 356 | `decide_sound` | verified | ML/Decidability/Correctness.lean |
| 360,475 | `ContextDerivable` | stale as decidability return type | live only in Bundle/Construction.lean; decision procedure uses `DerivationTree` |
| 419-482 | directory tree (Core, Soundness/, Representation/, FMP/, Completeness/, Algebraic/, Compactness/, Decidability/) | stale | live tree: Core/, Bundle/, Algebraic/, BXCanonical/, WeakCanonical/, ConservativeExtension/, Decidability/, Relational/, SoundnessLemmas/ + 5 top-level .lean files |
| 488-509 | "20 sorries, all deprecated" | stale | 43 genuine sorries (see counts), NOT all deprecated |
| 552 | `soundness` | verified | ML/Soundness.lean |
| 25,436,476 | "15 axiom schemata" | stale | 42 constructors |
| 154 | reflexive-semantics design note | stale | strict/irreflexive is current (Truth.lean:10-17) |

### 05-theorems.typ

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 49-54 | `perpetuity_1`..`perpetuity_6` | verified | TH/Perpetuity/Principles.lean (+Bridge.lean for P6); sorry-free |
| 187 | `Perpetuity.lean` | verified (re-export) | TH/Perpetuity.lean + Perpetuity/ subdir (Principles, Bridge, Helpers) |
| 188-189 | `ModalS5.lean`, `ModalS4.lean` | verified | TH/ |
| 190 | `Propositional.lean` | stale | `Propositional/` subdir (Core, Connectives, Reasoning) |
| 191-192 | `Combinators.lean`, `GeneralizedNecessitation.lean` | verified | TH/ |
| — | missing `ContextualProofs.lean`, `TemporalDerived.lean` | gap | added |
| 198 | "228 theorems" | unverifiable-stale | replaced with structure description |

### 06-notes.typ

| Line | Claim | Verdict | Live location / replacement |
|------|-------|---------|------------------------------|
| 23-24 | "14 axioms" | stale | 42 constructors |
| 59-64 | `Axiom.temp_k_dist/temp_4/temp_a/temp_l/temp_future` | stale | see 03 table above |
| 83 | `semantic_truth_lemma_v2` | not-found | removed |
| 84 | `semantic_weak_completeness` | stale (Boneyard) | `completeness` |
| 85 | `main_provable_iff_valid` | not-found | removed |
| 118-126 | "Reflexive Temporal Semantics (Current)" | stale (contradicts 02-semantics) | strict/irreflexive current (Truth.lean:10-17) |
| 162-163 | `temp_t_future`, `temp_t_past` | not-found (T-axioms invalid under strict) | removed |
| 301-311 | "TM uses reflexive semantics" history table | stale conclusion | rewritten: strict/irreflexive landed |

## Post-Rewrite Verification (Phase 6)

Re-run stamp: 2026-07-06, commit `a883361bf` (chapters revised in working tree).
Extraction re-run over the seven revised chapters + main file: *271 unique backticked
names*, every one resolving under `Theories/Bimodal/` excluding `Boneyard/` (checked
via `grep -rn --include='*.lean' -F <name> Theories/Bimodal --exclude-dir=Boneyard`;
file and directory paths checked against the filesystem; the deliberate historical
references to `Boneyard/` and the nested `WeakCanonical/Kamp/Boneyard/` archive resolve
as existing paths). Zero `stale` / `not-found` names remain in the revised text.

Count re-derivation at gate time: `inductive Axiom` constructor count = 42
(`awk '/^inductive Axiom/,/deriving Repr/' ProofSystem/Axioms.lean | grep -c '^  | '`);
`DerivationTree` rule constructors = 7 (Derivation.lean:92-164); sorry counts as
tabulated above. Chapter text matches. `typst compile BimodalReference.typ
build/BimodalReference.pdf` exits 0 (font-substitution warnings only).

## Expanded Chapters: Verification and Re-Stamp

Re-run stamp: 2026-07-07, commit `c44216042` (chapters revised in working tree; the
expansion phases landed sequentially as separate commits on top of the first-revision baseline
`a883361bf`).

The book grew from the seven first-revision chapters to a five-part, nineteen-chapter-or-stub
living monograph: a template/bibliography port (Phase 1), the
generated status-counts script (Phase 2), per-chapter sync-class banners (Phase 3), the
`scripts/typst-sync-check.sh` drift detector (Phase 4), the five-part restructure with 12
new chapter/stub files (Phase 5), a rewritten AI-practitioner introduction (Phase 6), and
five new content chapters: Frame Classes and Extensions, Decidability in Practice, Proof
Automation, The BMLogic Dataset Pipeline, and Dual Verification and Worked Examples
(Phases 7-11).

`scripts/typst-sync-check.sh` (which supersedes and automates the Phase-6 manual
extraction method above) was run against the final Phase-11 tree: **485 unique backticked
candidates** across all fifteen real chapters plus the twelve part-5/stub files, **zero
violations** -- every non-whitelisted candidate resolves under `Theories/Bimodal/`
(excluding `Boneyard/` unless the candidate itself names a historical `Boneyard/` path),
every included chapter carries a `#sync-banner(` call, no paper/outlook chapter carries a
conflicting lean-verified banner, and `typst/generated/status.typ` matches a live
regeneration exactly (42 axiom constructors / 7 rules / 43 sorries -- zero drift from the
first-revision baseline despite five intervening phases and concurrent unrelated Lean work
elsewhere in the repository during Phase 5, see the Phase-5 handoff's transient-drift note).

**Three discrepancies were found and corrected during Phase 7-11 verification** (not
present at the first-revision baseline; introduced by over-attribution in that revision's own
drafting, caught by per-result re-verification against live source rather than assumed):

1. `FrameConditions/FrameClass.lean` does not contain the `FrameClass` inductive or its
   partial order (those are in `ProofSystem/Axioms.lean:422-442`); `FrameConditions/
   FrameClass.lean` is a separate typeclass hierarchy. See `chapters/p2-frame-classes.typ`.
2. `Metalogic/ConservativeExtension/`'s only theorem, `lift_derivation_qfree`, is a
   fresh-atom naming lemma supporting the irreflexivity argument, not a formalization of
   the paper's base-language-vs-Until/Since-extended-language conservativity as an earlier
   revision of `06-notes.typ` implied. Corrected in both `chapters/p2-frame-classes.typ`
   and `06-notes.typ`'s discrepancy register.
3. `Examples/README.md` claims "dense and discrete" concrete temporal-structure instances;
   `Examples/TemporalStructures.lean` only concretely instantiates the discrete (`Int`)
   case plus a fully generic version. Noted in `chapters/p4-dual-verification.typ`.

Whitelist (`sync-check-whitelist.txt`) additions during the expansion: type-signature/turnstile
illustrations, typst/template API names, planned-but-not-yet-created files (follow-up
tasks), external paper filenames/appendix/theorem labels (`possible_worlds.tex`,
`counterfactual_worlds.tex`), external-repo (Logos) chapter citations, external URLs, and
`lake exe` target names not resolvable as Bimodal Lean identifiers.
