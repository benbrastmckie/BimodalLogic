# Research Report: Task #605

**Task**: 605 - Reconcile Burgess A7a provenance and add axiom-source footnote
**Started**: 2026-09-18T07:43:28Z
**Completed**: 2026-09-18T08:05:00Z
**Effort**: Small (docstring + record-doc edits only; no proof changes)
**Dependencies**: 588
**Sources/Inputs**: - Codebase (`FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Metalogic/Soundness.lean`, `docs/reference/paper-definitions-of-record.md`, `docs/reference/axiom-reference.md`, git history), literature source (Burgess 1982 NDJFL 23(4) §§1.2-1.6; Burgess 1984 "Basic Tense Logic" §0.3/§2.7; Xu 1988 JPL 17 §§1,3,4), paper source (`~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` lines 1236-1262, 4105-4116)
**Artifacts**: - specs/605_reconcile_burgess_a7a_provenance_and_add_axiom_source_footnote/reports/01_burgess-a7a-provenance.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- **The paper is right and the Lean NOTE is wrong.** CN (`linear_until`, "BX7") is *exactly* Burgess 1982 axiom A7a, and it is sound under Burgess's own semantics, which is the *same* strict/open-guard semantics this tree uses (`x < z < y`, Burgess 1982 §1.2). The tree already proves it sound (`linear_until_valid`, `Metalogic/Soundness.lean:696`).
- **Root cause of the NOTE**: an earlier constructor `linear_until_a7a` (added in commit `e037d1a7c`, removed in `2e08257e7`) was a *mis-transcription* of A7a. Burgess writes `U(event, guard)`; the transcription copied his argument positions into the guard-first `untl(guard, event)` constructor without swapping, so Burgess's *fixed guard* `q∧s` became a *fixed event* `ψ∧θ`. That fixed-event formula is genuinely unsound (the NOTE's countermodel is correct for it), but it is not A7a. The NOTE's secondary claim that Burgess uses closed-guard semantics (`t ≤ r ≤ s`) is also false.
- Xu 1988 prints A7a verbatim as his formula (10) (mirror (11)); §3 puts it in Σ₄, complete for the class 𝒞₄ of linear frames, and §4 (proof of Thm 4.4) proves (10) *defines* the first-order condition (10)*, a right-linearity-of-intervals condition. So "confirmed by Xu as defining linear frames" is directionally right but imprecise.
- Full attribution map verified: TN = half of TG, TS = §1.6 "No Last Element" `F⊤`, UC = A1a, UG = A2a, SU = A3a (Xu (3)), UF = A5a (Xu (7)), UI = A6a (Xu (9)), CN = A7a (Xu (10)). Burgess's A4a is the one 1982 axiom the system omits (matches the existing "REMOVED: BX14" note and Xu's remark that some of Burgess's axioms can be deleted).
- Two paper-side footnote defects found (outside this repo): (i) "UE follows from UC taking ψ = ⊤" is wrong — it follows from **UG** taking χ = ⊤ (with TN for `G(φ→⊤)`), since `F` is defined as `⊤Uψ`; (ii) Xu has no frame class `𝖵₃` — his classes are `𝒞₀`-`𝒞₅`; TL is instead *literally* Burgess 1984 §0.3 axiom (A2a), and Xu's closest formula is (13) `Fp → G(p ∨ Fp ∨ Pp)` (right-connectedness, §4 Thm 4.3).
- **Recommended approach**: replace the `linear_until` NOTE with a corrected provenance note, add Burgess/Xu source tags to the docstrings of the 8 attributed constructor pairs, add a module-level "Axiom sources" section, disambiguate Burgess 1982 A7a from Burgess 1984 A7a in three Chronicle files, and close the "Open opportunity" paragraph in `paper-definitions-of-record.md`. No proof, statement, or axiom change; zero sorry/axiom risk.

## Context & Scope

The paper's `def:BX` footnote (pinned verbatim at `docs/reference/paper-definitions-of-record.md:1330-1342`, sha256-pinned; do not edit the quoted block) attributes BX's schemata to Burgess and Xu. `FormalSystem/ProofSystem/Axioms.lean:239-244` carries a NOTE stating Burgess's A7a was removed as unsound under open guard. The record file's "Open opportunity" paragraph (lines 145-152) flags this contradiction and asks for reconciliation rather than verbatim copying. Scope: decide which claim is correct against the primary sources, and specify the provenance text to install.

## Literature Proof Structure

**Source**: Burgess, "Axioms for Tense Logic I: Since and Until", NDJFL 23(4), 1982, §§1.2-1.3; Xu, "On Some U,S-Tense Logics", JPL 17, 1988, §§1, 3, 4.
**Strategy**: provenance verification by symbol-level transcription, not a proof.

### Step Map
1. Fix Burgess's semantics — §1.2: `V(U(α,β)) = {x : ∃y (x<y ∧ y∈V(α) ∧ ∀z (x<z<y ⊃ z∈V(β)))}`. **Event first, guard second, strict/open interval.** Identical to this tree's `truth_at` for `untl` modulo argument order.
2. Read A7a — §1.3: `U(p,q) ∧ U(r,s) ⊃ U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`. Guard `q∧s` is **fixed** across all three disjuncts; events vary (`p∧r`, `p∧s`, `q∧r`).
3. Transcribe to guard-first with p=ψ (event₁), q=φ (guard₁), r=θ (event₂), s=χ (guard₂):
   `untl(φ,ψ) ∧ untl(χ,θ) → untl(φ∧χ, ψ∧θ) ∨ untl(φ∧χ, ψ∧χ) ∨ untl(φ∧χ, φ∧θ)`.
   This is **character-for-character** the current `Axiom.linear_until` (Axioms.lean:225-233) and the paper's CN (`possible_worlds.tex:1260`: `(φ∧χ)U(ψ∧θ) ∨ (φ∧χ)U(ψ∧χ) ∨ (φ∧χ)U(φ∧θ)`, guard-first infix).
4. Soundness — Burgess §1.4 asserts every axiom valid over all linear orders under the strict semantics; the tree's `linear_until_valid` proves it by `lt_trichotomy s₁ s₂`, matching Xu's proof in Thm 4.4 (cases (a) t₁=t₂, (b) t₁<t₂, (c) t₂<t₁).
5. Xu corroboration — Xu §1 semantics clause (iv) is the same strict semantics; §3 lists (10) = A7a verbatim and (11) its mirror in Σ₄ with `TL_US(Σ₄) = Th(𝒞₄)`, 𝒞₄ = linear frames; §4 Thm 4.4 proof: "(10) defines (10)*", where (10)* is `∀xyz(x<y ∧ x<z → y=z ∨ (y<z ∧ ∀u(x<u<y → u<z)) ∨ (z<y ∧ ∀u(x<u<z → u<y)))`.
6. Diagnose the removed constructor — git `e037d1a7c` added `linear_until_a7a` with disjuncts `untl(φ∧χ, ψ∧θ) ∨ untl(φ∧θ, ψ∧θ) ∨ untl(χ∧ψ, ψ∧θ)` and docstring "All three disjuncts share the same event (ψ ∧ θ)". With `untl` already guard-first at that commit (`truth_at`: `untl φ ψ` = ∃s>t, ψ(s) ∧ ∀r∈(t,s), φ(r)), this is Burgess's formula with his positions copied unswapped — his fixed guard landed in the event slot. `2e08257e7` then correctly found that formula unsound and removed it, but attributed the unsoundness to Burgess.

### Dependencies
- Step 3 depends on Steps 1-2 (argument convention). Step 6 depends on Step 3.

### Potential Formalization Challenges
- None: no statement changes. The only hazard is the same argument-order swap that caused the original error (see memory "Guard-first transcription of untl/snce"). Every Burgess formula quoted in a docstring must stay in Burgess's own `U(event, guard)` rendering, per the file's existing notation table (Axioms.lean:15-28).

## Findings

### Codebase Patterns
- `Axioms.lean` header (lines 15-28) already fixes the notation convention: a quoted Burgess formula is rendered in Burgess's own order. `enrichment_until`/`enrichment_since` (lines 176-194) are the model to copy: "(Burgess A3a, Xu axiom (3))" plus a `Burgess:` line and a guard-first line.
- The `BX` numbering in docstrings (BX2G, BX3, BX5, BX6, BX7, BX13) is the tree's own; the Burgess numbers do not line up with it (BX3 = A1a, BX2G = A2a, BX13 = A3a). Docstrings should carry both.
- Stale A7a mentions:
  - `FormalSystem/ProofSystem/Axioms.lean:239-244` — the wrong NOTE (primary fix).
  - `FormalSystem/Boneyard/DeadCanonicalModel/Substitution.lean:334` — same claim; Boneyard is unbuilt archive, record-file policy is to leave Boneyard untouched. Leave it.
  - `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean:24`, `ChronicleLimitGuardWitness.lean:31`, `ChronicleRealExtension.lean:970` — these cite **Burgess 1984** A7a, which is a *different axiom*: Burgess 1984 §0.3 `(A7a) Fp ∧ FG¬p → F(HFp ∧ G¬p)` (Dedekind completeness), used at §2.7 pp.109-110. The citations are correct but ambiguous next to the 1982 A7a; recommend appending "(Burgess 1984's Dedekind-completeness axiom, not the 1982 Until-linearity axiom of the same number)" on first mention in each file.
- `docs/reference/axiom-reference.md` § Paper Key Correspondence (lines 310-343) has no source column; adding a "Burgess / Xu source" column there is the natural home for the full map.

### External Resources

Verified attribution map (Burgess 1982 = B82 §1.3 unless noted; Xu = X88 formula numbers):

| Paper key | Lean constructor(s) | Source | Verdict on footnote |
|---|---|---|---|
| TN | `temporal_necessitation` rule | B82 §1.3 TG ("from α infer Gα and Hα"), G half | correct |
| TS | `serial_future` / `serial_past` | B82 §1.6 table, No Last Element `F⊤` | correct |
| UC | `right_mono_until` / `_since` | B82 A1a `G(p⊃q) ⊃ (U(p,r) ⊃ U(q,r))`; X88 (1) first conjunct | correct |
| UG | `left_mono_until_G` / `_since_H` | B82 A2a `G(p⊃q) ⊃ (U(r,p) ⊃ U(r,q))`; X88 (1) second conjunct | correct |
| SU | `enrichment_until` / `_since` | B82 A3a/A3b; X88 (3)/(4) | correct (already in tree) |
| UF | `self_accum_until` / `_since` | B82 A5a/A5b; X88 (7)/(8) | correct |
| UI | `absorb_until` / `_since` | B82 A6a/A6b; X88 (9) | correct |
| CN | `linear_until` / `_since` | B82 A7a/A7b; X88 (10)/(11) | **correct**; "defining linear frames" is loose (see below) |
| UE | `until_F` / `since_P` | not numbered in B82; derivable | **footnote wrong**: follows from UG with χ=⊤ (+TN), not UC with ψ=⊤ |
| TL | `temp_linearity` / `_past` | Burgess 1984 §0.3 (A2a/A2b) verbatim; closest X88 formula is (13) §4 Thm 4.3 | **footnote wrong**: Xu has no `𝖵₃`; better cited to Burgess 1984 |
| TC, UT, NP, NF, NA, NB | — | not in B82/X88 | correct as "own additions"; note UT is a definitional instance under `Fφ := ⊤Uφ` (paper line 1070, tree `Formula.someFuture`) |
| (omitted) | — | B82 A4a/A4b | not in BX; consistent with X88 §3 "we could delete some formulas" |

Precise Xu wording for CN: Xu §3 places (10) in the axiom set Σ₄ with `TL_US(Σ₄) = Th(𝒞₄)` (𝒞₄ = all linear frames), and §4 (proof of Thm 4.4) shows (10) defines the first-order condition (10)* (future witnesses linearly ordered with nested intervals). (10) alone does not define linearity; Σ₄ ∖ {(10)} = Σ₅ is complete for the past-connected class 𝒞₅.

UE check: paper UG is `G(φ→χ) → ((φUψ) → (χUψ))`; with χ = ⊤ and TN giving `G(φ→⊤)`, the conclusion is `(φUψ) → (⊤Uψ) = Fψ`. Paper UC with ψ = ⊤ gives `(χUφ) → (χU⊤)`, which is not UE.

### Recommendations
1. **Axioms.lean NOTE (lines 239-244)** — replace with a corrected historical note, e.g.:
   ```
   -- NOTE: `linear_until`/`linear_since` ARE Burgess 1982 A7a/A7b (Xu 1988 (10)/(11)).
   -- Burgess writes U(event, guard); A7a's three disjuncts share the fixed GUARD q∧s.
   -- A former constructor pair `linear_until_a7a`/`linear_since_a7a` transcribed A7a
   -- without swapping to guard-first order, yielding a fixed-EVENT variant; that variant
   -- is unsound (φ=χ=⊤, ψ only at s₁, θ only at s₂, s₁≠s₂) and was removed. It was a
   -- transcription error, not a defect of A7a: Burgess's semantics (1982 §1.2) is the
   -- same strict/open-guard semantics used here.
   ```
2. **Docstring tags** (mirror the `enrichment_until` pattern, one `Burgess:` line in his order):
   - `right_mono_until`: "(Burgess A1a, Xu axiom (1))"; `right_mono_since`: "(Burgess A1b, Xu (2))".
   - `left_mono_until_G`: "(Burgess A2a, Xu (1))"; `left_mono_since_H`: "(Burgess A2b, Xu (2))".
   - `self_accum_until/since`: "(Burgess A5a/A5b, Xu (7)/(8))".
   - `absorb_until`: "(Burgess A6a, Xu (9))"; `absorb_since`: "(Burgess A6b)".
   - `linear_until/since`: "(Burgess A7a/A7b, Xu (10)/(11))", with `Burgess: U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`.
   - `serial_future`: "(Burgess 1982 §1.6 No Last Element)".
   - `temp_linearity`: "(Burgess 1984 §0.3 axiom A2a)"; `until_F`: "(derived in Burgess from A2a + TG; the paper's UE)".
3. **Module docstring**: add a short `## Axiom Sources` subsection summarising the table above, and fix the header claim at Axioms.lean:32-34 only if in scope (it says "reflexive semantics", contradicting line 13 "irreflexive"; note but optional).
4. **Chronicle files**: disambiguate the three Burgess 1984 A7a mentions as described.
5. **`paper-definitions-of-record.md`**: convert the "Open opportunity" paragraph (lines 145-152) to a closed record: verdict (paper correct, NOTE was a transcription artifact), the verified map, and a "Paper footnote errata (outside the tree)" list with the UE and TL/`𝖵₃` items. Leave the sha256-pinned quoted `def:BX` block untouched.
6. **`axiom-reference.md`**: optionally add a "Burgess / Xu source" column to the Paper Key Correspondence table.

Sorry-free path: trivially yes — comment/docstring edits only; `lake build` of `FormalSystem.ProofSystem.Axioms` is the only verification needed (docstring syntax), plus the task-reference lint.

## Decisions
- Treated Burgess 1982 as the controlling source for "A7a" (the paper cites `\cite[\S1.3]{Burgess1982}`); Burgess 1984's A7a is a distinct axiom and is kept separate.
- Did not re-prove soundness: `linear_until_valid` already exists and matches the source proof case-for-case.
- Boneyard note left untouched per the record file's standing policy.
- Paper-side errata are recorded, not edited: the paper source is outside this repository.

## Risks & Mitigations
- **Argument-order regression** when writing the `Burgess:` lines. Mitigation: quote Burgess in his own `U(event, guard)` order exactly as printed in §1.3, and keep the guard-first line separately, as `enrichment_until` does.
- **Xu (1) typo**: the markdown transcription of Xu (1) reads `U(r,p) → U(q,r)` in the first conjunct, evidently a print/OCR slip for `U(p,r) → U(q,r)`. Cite Xu (1) without quoting its text.
- **Task-reference lint**: new docstrings must not cite task numbers or commit hashes; describe the removed constructor by name only.

## Tactic Survey Results
- Not applicable (no tactic survey performed): the task changes no statements or proofs.

## Context Extension Recommendations
- **Topic**: Burgess/Xu axiom numbering vs. this tree's BX numbering
- **Gap**: no single reference maps BX-n, paper keys, Burgess 1982 A-numbers, Burgess 1984 A-numbers and Xu formula numbers
- **Recommendation**: add a source column to `docs/reference/axiom-reference.md` § Paper Key Correspondence (see Recommendation 6)

## Appendix
- Primary sources read: `~/Projects/Literature/sources/burgess_1982_i/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` (§§1.1-1.6); `~/Projects/Literature/sources/xu_1988/sec01*.md`, `sec03*.md`, `sec04*.md`; `~/Projects/Literature/sources/burgess_1984/Burgess_1984_Basic_Tense_Logic.pdf` (pdftotext, §0.3 postulates and §2.7 completeness lemma).
- Git archaeology: `git log -S"linear_until_a7a"` → `e037d1a7c` (added fixed-event variant), `2e08257e7` (removed, NOTE written).
- Paper: `possible_worlds.tex:1070` (F := ⊤Uφ), `1245-1260` (BX axiom items), `4105-4116` (footnote).
