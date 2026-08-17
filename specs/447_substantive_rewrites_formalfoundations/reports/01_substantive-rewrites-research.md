# Research Report: Substantive Rewrites in FormalFoundations.typ

## Metadata
- **Task**: `447 - Substantive rewrites in FormalFoundations.typ: proof repair, axiom presentation, section restructure`
- **Started**: `2026-08-17T08:20:00-04:00`
- **Completed**: `2026-08-17T08:50:00-04:00`
- **Effort**: ~1 session (hard-mode research, single pass)
- **Dependencies**: Task 446 (which depends on Task 445)
- **Sources/Inputs**:
  - Authoritative source: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (4174 lines, verified readable)
  - Target: `/home/benjamin/Projects/BimodalLogic/typst/FormalFoundations.typ` (1090 lines)
  - Style sources: `typst/template.typ` (the `items` construct), `typst/notation/bimodal-notation.typ`
  - Task state: `specs/TODO.md` entries 445/446/447
  - Build check: `typst compile FormalFoundations.typ` (run 2026-08-17)
- **Artifacts**: `specs/447_substantive_rewrites_formalfoundations/reports/01_substantive-rewrites-research.md` (this report)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- All six FIX anchors named in the task were verified against the live `.tex`: `thm:extension` (tex:2855), `def:task-topology` (tex:2633), `lem:step` (tex:2829), `cor:spherical-finite` (tex:2843), `def:S5` (tex:3799), `def:BX` (tex:3817) all exist. One cited anchor is dead: `cor:tm-decidability` (tex:3995) is **commented out** in the live paper (relevant to the 445 footnote at typ:511, not to this task's six rewrites).
- The Extension proof's dependency chain in the paper is a seven-link ladder — `def:constraints` -> `lem:nesting` -> `lem:nonempty` -> `lem:constraint` -> `lem:fibers` -> `lem:admissible` -> `lem:step` — none of which is currently stated live in `FormalFoundations.typ`. The 446 restorations do NOT supply them: the commented block at typ:257 only *describes* the Step Lemma's role; it never states it. The `:244` repair must therefore introduce new statements regardless of 446.
- The "seventeen named keys" claim for BX is **confirmed exactly**: 2 rules (TN, TD) + 15 axiom schemata (TB, TL, CN; TA, UE, UT, UI, UC, UF, UG, SU; NP, NF, NA, NB). All 17 are transcribed in full below with source line numbers.
- The paper defines ten proof systems across two sites: BL-level **TM** and its four extensions (tex `sub:Logic`, 1148-1255), and BL+-level **S5**, **BX**, **BX**_f, **BX**_d, **BX**_c, **TM**+ and its three extensions (tex `app:ProofTheory`, 3791-3940). The full containment lattice is given in Findings 4.
- The current build **succeeds** (exit 0; only "new computer modern sans" font warnings from the thmbox package), and `@brastmckie2026possibleworlds` resolves (`typst/bibliography.bib:12`; live citations at typ:162, typ:167 compile).
- One contradiction was found and resolved (Findings 4, Adversarial Self-Verification): the paper's live `cor:tm-completeness` (tex:3942-3952) claims strong completeness of TM+ over all task frames, while `FormalFoundations.typ:482-497` documents the base case as outstanding with `sorryAx`. The `:369` rewrite must transcribe system *definitions* only and must not import the paper corollary's completeness claims.

## Context & Scope

Six substantive FIX directives in `typst/FormalFoundations.typ` require new mathematical exposition grounded in `possible_worlds.tex`. This report makes each executable: exact source anchors, full transcriptions where the planner needs them (axioms), the target line ranges, the house style to imitate, and the ordering/collision analysis against tasks 445 (39 commented footnotes) and 446 (6 commented prose/proof blocks), both currently `[NOT STARTED]`.

Reference grounding tier: **Tier 1 (literature-backed)**. Every claim about paper content below cites a `\label` anchor and/or line number in `possible_worlds.tex` (cited as `tex:NNNN`); target locations cite `FormalFoundations.typ` (cited as `typ:NNN`). Line numbers for the typ file are as of the current working tree (git `main` at 2c359cc12 plus uncommitted edits).

## Findings

### Source-to-Target Mapping Table (H3 Tier 1, primary artifact)

| Source anchor (possible_worlds.tex) | tex lines | Content | Target in FormalFoundations.typ | Status in typ |
|---|---|---|---|---|
| `def:constraints` | 2749-2751 | Constraints on a duration z | new, before Extension (insert ~typ:239) | absent |
| `lem:nesting` | 2753-2764 | Fibers/segments nest | new (may be folded into Directedness proof) | absent |
| `lem:nonempty` | 2770-2777 | Every constraint nonempty | new (may be folded into Directedness proof) | absent |
| `lem:constraint` | 2783-2792 | Constraints form directed family of nonempty sets | new, before Step Lemma | absent |
| `lem:fibers` | 2799-2813 | Membership in all constraints iff task-related to all assignments | new (may be folded into Admissibility) | absent |
| `lem:admissible` | 2819-2827 | Adjoining (z,u) yields a partial history iff u meets all constraints | new; cites Nullity | absent |
| `lem:step` | 2829-2837 | Step Lemma: extend to X ∪ {z}; sole *Spherical* site | new, immediately before Extension | mentioned only in commented prose typ:257-261 (task 446) |
| `cor:spherical-finite` | 2843-2852 | Finite W satisfies *Spherical* choice-free | new or footnote-level | mentioned only in commented prose typ:260 (task 446) |
| `thm:extension` + proof | 2855-2867 | Extension theorem, Zorn + Step | typ:240-250 (statement live, proof commented) | proof commented, inadequate |
| `cor:occurrence` + proof | 2882-2890 | Occurrence; uses Nullity + Extension | typ:252-255 (statement live) | live |
| `lem:nullity` | 2649-2657 | Zero loops | typ:213 (statement live); proof at typ:215-219 commented | proof restoration is task 446 (:214) |
| `def:task-topology` | 2633-2643 | Six labeled sub-items | typ:266-274 | live, compressed prose; rewrite target `:267` |
| `app:topology-t1`, `app:topology-r0` | 2664-2690 | Separation | typ:276-284 | statement live; proof commented (task 446 `:277`) |
| `def:S5` | 3799-3812 | S5: MK, MT, M5, MP, MN | typ:352-359 | live, inline prose; rewrite target `:353` |
| `def:BX` | 3817-3861 | BX: 17 named keys | typ:361-367 | live, names only, no statements; rewrite target `:362` |
| `def:TMplus-f` | 3866-3880 | **BX**_f = BX + UZ, Z1 | typ:370-389 region | table row only; rewrite target `:369` |
| `def:TMplus-d` | 3886-3897 | **BX**_d = BX + DN, NN | typ:370-389 region | table row only |
| `def:TMplus-c` | 3903-3920 | **BX**_c = BX + Prior-U, Sep (K+/K− defined; CO derived) | typ:370-389 region | table row only |
| `def:TMplus` | 3926-3940 | TM+ = S5 + BX + MF; TM+_f/d/c | typ:370-372 | one sentence; rewrite target `:369` |
| `sub:Logic` (TM definition) | 1148-1172 | BL-level TM: MP, MN, MK, MT, M5, MF; TD, TK, T4, TB, TA, TL | referenced throughout typ but never defined | absent; candidate for `:369` |
| `sub:Extension` (TM extensions) | 1244-1255 | DF, DN, CO; TM_f, TM_d, TM_c, TM_dc | DF/DN/CO appear at typ:416 (Correspondence) undefined as axioms | absent |
| `def:derivability` | 3602-3604 | ⊢ for TM | absent | candidate for `:369` |
| `def:logical-consequence` | 3597-3600 | ⊨, validity | typ:335-340 | live |
| Section `app:Soundness`/`app:ProofTheory` content | 3590-4007 | What the typ's §2 covers | typ:391-537 (`sec:key-theorems`) | rewrite target `:393` (intro only) |

### 1. Extension proof (`:244`)

**What the theorem states** (`thm:extension`, tex:2855-2860): "Every partial history τ : X → W over a frame F = ⟨W, D, ⟹⟩ is extended by some total world history σ ∈ H_F." Its footnote (tex:2857-2859) records: the proof uses Zorn's lemma, so the derivation of *Occurrence* from *Seriality* and *Spherical* in `cor:occurrence` is a theorem of ZFC, in contrast with the choice-free derivations in `lem:nullity` and `cor:spherical-finite`.

**The actual proof in the paper** (tex:2862-2867), verbatim in substance:
1. Partial histories extending τ are partially ordered by extension; every chain is bounded above by its union, "which restricts on any pair of times to a single member of the chain and so is itself a partial history."
2. Zorn's lemma yields a maximal partial history σ : T → W extending τ.
3. If T ≠ D, then σ extends to a partial history on T ∪ {z} for any z ∈ D \ T **by `lem:step`**, contradicting maximality.
4. Thus T = D, whence σ ∈ H_F by `def:world-history`.

**The lemmas that proof invokes, and their own dependency chain** (the "real ones from the source"):

| # | Anchor | Statement (condensed but faithful) | Proof depends on |
|---|---|---|---|
| D | `def:constraints` (tex:2749) | For partial history τ : X → W and z ∈ D \ X, the *constraints on z* are the segments [τ(t), τ(s)]_{z−t}^{s−z} for t, s ∈ X with t < z < s when assignments flank z, and the fibers Fib(τ(t), z−t) for t ∈ X otherwise | — |
| L1 | `lem:nesting` (tex:2753) | Fibers imposed by times nearer z are included in those imposed by times farther (on each side); segments nest likewise | Compositionality, converse convention |
| L2 | `lem:nonempty` (tex:2770) | Every constraint imposed on z is nonempty | Seriality (fibers), Compositionality (segments) |
| L3 | `lem:constraint` (tex:2783) | The constraints imposed on z form a **directed family of nonempty sets** | L1, L2, `def:constraints` |
| L4 | `lem:fibers` (tex:2799) | u belongs to every constraint on z iff τ(t) ⟹_{z−t} u for every t ∈ X | `def:constraints` |
| L5 | `lem:admissible` (tex:2819) | τ ∪ {⟨z, u⟩} is a partial history on X ∪ {z} iff u belongs to every constraint on z | L4, **`lem:nullity`** (the zero loop u ⟹₀ u at z itself, tex:2825) |
| L6 | `lem:step` (tex:2829) | **Step Lemma**: every partial history extends to a partial history on X ∪ {z} for any z ∈ D | L3, *Spherical*, L5; closing remark (tex:2836): *Spherical* is not needed when the family has a ⊆-least member, as L1 provides whenever X contains a nearest assignment to z on each occupied side |
| C1 | `cor:spherical-finite` (tex:2843) | Every frame with finite W satisfies *Spherical*, choice-free | `def:directed` only |

**What is present vs. missing in FormalFoundations.typ**: the Extension *statement* is live (typ:240-242) and Occurrence is live (typ:252-255); `def:directed` is live (typ:193-196); Nullity's *statement* is live (typ:213). **None of D, L1-L6, C1 is stated anywhere in the typ document** — the current commented proof (typ:245-250) name-drops "the Step Lemma" with no referent.

**Dependency on task 446**: the 446 restorations at `:214` (Nullity proof, typ:215-222) and `:257` (Step-Lemma role prose + `lem:step`/`cor:spherical-finite` footnote, typ:257-261) do **not** contain the Step Lemma's statement or any of D/L1-L5. Conclusion: **447's `:244` repair does not require 446's material mathematically** (Nullity's statement, which L5 cites, is already live), but it interlocks editorially: the 446 prose at typ:257-261 ("the Step Lemma is the sole application site of *Spherical*... Extension is the sole consumer of the Step Lemma") only makes sense *after* 447 has put a live Step Lemma into the document, and both edits land in the same 20-line region. See Findings 6 for ordering.

**Repair options** (decision for the planner; recommendation in Recommendations):
- (a) *Full transcription*: add D, L1-L6 (and optionally C1) as live `#definition`/`#lemma` blocks with proofs adapted from tex:2749-2852, then restore the Extension proof with its Step-Lemma citation now resolving. Cost: ~40-60 lines of Typst; matches the paper's own architecture; makes the document self-contained.
- (b) *Condensed transcription*: add D; one lemma "Directedness" = L3 with L1+L2 folded into its proof; one lemma "Admissibility" = L5 with L4 folded in; then L6 and the Extension proof. Cost: ~30-40 lines; every citation in the Extension proof still resolves to a live statement.
- Either way the Extension proof itself should follow tex:2862-2867, and the verification criterion "must cite lemmas that are actually present in the document or in the cited source" is met by both.

### 2. Task Topology (`:267`)

**House style for "indented definitions"**: the construct is `#items[...]` imported from `template.typ` (typ:27), defined at `template.typ:128-135` — a block that styles `+`-enum items with `numbering: "(1)"`, `indent: 0.5em`. The definitions "above" use the pattern `+ *Name*: body` inside `#items`; exemplars: `def:task-relation`'s Fiber/Cone/Segment items at typ:186-190, `def:frame`'s four constraints at typ:202-210, `def:world-history`'s five items at typ:228-237.

**What the source says** (`def:task-topology`, tex:2633-2643): six labeled sub-items, verbatim labels:
1. **Basic Opens**: B_F := {(w)_x : w ∈ W and x ∈ D with x > 0}.
2. **Topology**: T_F := ⟨W, O_F⟩ where O_F is the result of closing B_F under arbitrary union and finite intersection.
3. **Discrete**: a topology is *discrete* just in case every subset of W is open.
4. **Closure**: S̄ := {w ∈ W : O ∩ S ≠ ∅ for every open O ∈ T_F where w ∈ O} for S ⊆ W.
5. **T1**: a topology is *T1* just in case {w}̄ = {w} for all w ∈ W.
6. **R0**: a topology is *R0* just in case w ∈ {u}̄ iff u ∈ {w}̄ for all w, u ∈ W.

**Current typ state** (typ:266-274): all of items 1, 2, 4, 5, 6 compressed into three prose sentences; item 3 (**Discrete**) is omitted entirely. The FIX footnote at typ:274 (task 445) notes the topology is carried by world states, not by H_F or D.

**Sub-definitions to break out**: Basic Opens, Topology, Closure, T1, R0 — five items minimum, in `#items` with `+ *Name*: ...` style. Decision needed on the sixth (**Discrete**): nothing live downstream in this document or in the live paper uses it (its sole consumer `app:topology-nondiscrete`, tex:2694-2711, is commented out in the paper). Recommendation: omit it and stay silent, or include it for anchor-faithfulness; omitting is the lower-risk choice since the typ document elsewhere prunes paper content it does not consume. Note the cone notation (w)_x is already defined at typ:188 (`def:task-relation`), so the topology definition needs no restatement of it.

### 3. Axioms (`:353` S5, `:362` BX) — full enumeration

Notation mapping used below (paper glyph -> typ macro): `\Box` -> `square.stroked`, `\Diamond` -> `diamond.stroked`, `\Future` (universal future, G) -> `#allfuture`, `\future` (existential, F) -> `#somefuture`, `\Past` (universal past, H) -> `#allpast`, `\past` (existential, P) -> `#somepast`, `\until` -> `#until`, `\since` -> `#since`, `\Next` -> `#Nxt`, `\Previous` -> `#Prev`, `\always` -> `#always`, `\sometimes` -> `#sometimes`. Macro sources: `FormalFoundations.typ:81-86` (BL, BLplus, since, until, Nxt, Prev — local) and `typst/notation/bimodal-notation.typ:29-37, 47-49, 66` (allpast H, allfuture G, somepast P, somefuture F, always, sometimes, taskframe, Dur, worldstate, satisfies); `#model` is imported via `bimodal-notation.typ` from shared-notation (comment at its line 56) and compiles.

**S5** (`def:S5`, tex:3799-3812). "The S5 Modal Logic is the smallest extension of Classical Propositional Logic CPL closed under the following rule schemata and metarule" (sic — the paper's own wording; MK/MT/M5 are axiom schemata, MP a rule, MN a metarule):

| Key | Statement | tex line |
|---|---|---|
| MK | □(φ → ψ) → (□φ → □ψ) | 3804 |
| MT | □φ → φ | 3805 |
| M5 | ◇□φ → □φ | 3806 |
| MP | φ, φ → ψ ⊢ ψ | 3807 |
| MN | If ⊢ φ, then ⊢ □φ | 3808 |

**BX** (`def:BX`, tex:3817-3861). Preamble (tex:3818): "Letting φ_⟨S|U⟩ denote the result of swapping occurrences of ◁ (since) and ▷ (until) in φ, **BX** is the *Base Burgess–Xu Tense Logic* axiomatized below **where the past/since direction of each axiom follows from the future/until direction**"; closing sentence (tex:3860): "The logic BX is [the] smallest extension of CPL closed under all instances of the above." The seventeen named keys, exhaustively:

*Rules* (tex:3822-3823):

| Key | Statement | Role |
|---|---|---|
| TN | If ⊢ φ, then ⊢ Gφ | temporal necessitation |
| TD | If ⊢ φ, then ⊢ φ_⟨S\|U⟩ | temporal duality: swaps ◁ and ▷ throughout a theorem; this is what derives every past-direction axiom from its future-direction mate |

*Seriality, linearity, connectedness* (tex:3827-3832; the paper notes TB and TL are "from TM"):

| Key | Statement |
|---|---|
| TB | F⊤ |
| TL | (Fφ ∧ Fψ) → [F(φ ∧ ψ) ∨ F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ)] |
| CN | [(φ ▷ ψ) ∧ (χ ▷ θ)] → [(φ ∧ χ) ▷ (ψ ∧ θ) ∨ (φ ∧ χ) ▷ (ψ ∧ χ) ∨ (φ ∧ χ) ▷ (φ ∧ θ)] |

*Primary Since/Until axioms* (tex:3833-3847):

| Key | Statement |
|---|---|
| TA | φ → G P φ |
| UE | (φ ▷ ψ) → Fψ |
| UT | Fφ → (⊤ ▷ φ) |
| UI | φ ▷ (φ ∧ (φ ▷ ψ)) → φ ▷ ψ |
| UC | G(φ → ψ) → ((χ ▷ φ) → (χ ▷ ψ)) |
| UF | (φ ▷ ψ) → (φ ∧ (φ ▷ ψ)) ▷ ψ |
| UG | G(φ → χ) → ((φ ▷ ψ) → (χ ▷ ψ)) |
| SU | θ ∧ (φ ▷ ψ) → φ ▷ (ψ ∧ (φ ◁ θ)) |

*Uniformity axioms* (tex:3849-3858; "hold vacuously unless the order is discrete"):

| Key | Statement |
|---|---|
| NP | Next⊤ → Prev⊤ |
| NF | Next⊤ → G Next⊤ |
| NA | Next⊤ → H Next⊤ |
| NB | Next⊤ → □ Next⊤ |

Count check: 2 rules + 3 + 8 + 4 axioms = **17 named keys, confirmed** (the typ footnote at typ:367's "Seventeen named keys" is accurate). Note NB is the one BX key mentioning □ — it belongs to BX as stated in the paper even though □ is interpreted only once S5 is fused in; transcribe as-is per H3 transcription discipline.

**Presentation for `:353`/`:362`**: mirror the paper's grouping (rules; seriality/linearity/connectedness; primary; uniformity) using `#items` with `+ *KEY*: $...$` entries, matching typ:154-161 (`def-operators`) as the closest existing exemplar of formalized indented items. The BX preamble must define the ⟨S|U⟩-swap notation before TD uses it, and should retain the paper's sentence that past-direction axioms are derived by TD, not postulated (this also matches the commented 445 footnote at typ:367).

### 4. Proof systems (`:369`) — systematic account

The paper defines these systems (all anchors verified):

*BL+-level, in `app:ProofTheory`* (tex:3791-3940). Section intro (tex:3793-3794): "This section presents the proof system TM+ for the extended language BL+... All definitions are restated for convenience."

| System | Definition | Anchor / tex lines |
|---|---|---|
| CPL | classical propositional logic (base, undefined further) | named in `def:S5`, tex:3800 |
| S5 | smallest extension of CPL closed under MK, MT, M5, MP, MN | `def:S5`, 3799 |
| BX | smallest extension of CPL closed under the 17 keys above | `def:BX`, 3817 |
| BX_f | *Discrete Burgess–Xu Tense Logic*: BX + all instances of UZ, Z1 | `def:TMplus-f`, 3866 |
| BX_d | *Dense Burgess–Xu Tense Logic*: BX + all instances of DN, NN | `def:TMplus-d`, 3886 |
| BX_c | *Complete Burgess–Xu Tense Logic*: BX + all instances of Prior-U, Sep | `def:TMplus-c`, 3903 |
| TM+ | *Base Logic of Tense and Modality* for BL+: smallest extension of S5 and BX including MF (□φ → □Gφ) | `def:TMplus`, 3926 |
| TM+_f, TM+_d, TM+_c | TM+ plus "the additional axioms that distinguish BX_f, BX_d, and BX_c, respectively" | `def:TMplus`, tex:3931 |

The frame-class axioms, in full (needed because the current typ table at typ:374-384 names them without statements):

| Key | Statement | Source | Gloss (paper's own) |
|---|---|---|---|
| UZ | Fφ → (¬φ ▷ φ) | tex:3871 | nearest future witness with ¬φ throughout the intervening interval (tex:3876) |
| Z1 | G(Gφ → φ) → (FGφ → Gφ) | tex:3872 | backward induction; characteristic of successor-Archimedean frames (tex:3876); with Hölder, BX_f/TM+_f is sound and complete for exactly Z-time (tex:3877) |
| DN | GGφ → Gφ | tex:3891 | coincides with TM's DN (tex:3896) |
| NN | ¬Next⊤ | tex:3892 | specific to TM+; no immediate successor (tex:3896) |
| Prior-U | (φ ▷ ⊤) ∧ F¬φ → φ ▷ (¬φ ∨ K⁺¬φ) | tex:3906 | with K⁺φ := ¬(¬φ ▷ ⊤), K⁻φ := ¬(¬φ ◁ ⊤) (Reynolds 1992; K⁺φ: φ recurs arbitrarily soon; K⁻φ: recurred arbitrarily recently), tex:3904 |
| Sep | K⁺φ ∧ ¬K⁺(φ ∧ (¬φ ▷ φ)) → K⁺(K⁺φ ∧ K⁻φ) | tex:3907 | Reynolds 1992 |
| CO | ⧍(Pφ → F Pφ) → (Pφ → Gφ) — where ⧍ is `#always` and P/F here are `#allpast`/`#somefuture` per tex glyphs (\always, \Past, \future) | tex:3911 | *derived theorem* of BX_c from Prior-U and the BX base, "rather than a further axiom"; "may be omitted from BX_c" (tex:3909-3913) |

Two corrections to the current typ table (typ:374-384) that the rewrite should absorb:
- The table's TM+_c row says "the *Reynolds triple* Prior-U, Prior-S, Sep". The paper postulates only **Prior-U and Sep**; there is no separately named "Prior-S" axiom — "only the future/until direction of Prior-U is stated, its past/since direction following by TD" (tex:3904). "Prior-S" is the TD-image, derived.
- The table's TM+_f row parenthetical is fine in substance (tex:3876-3877) but UZ/Z1 are nowhere stated; both must be.

*BL-level, in `sub:Logic` and `sub:Extension`* (tex:1148-1255). **TM**, the *Logic of Tense and Modality* for BL = ⟨SL, ⊥, →, □, H, G⟩ (tex:1150-1154): the smallest extension of CPL closed under all instances of (tex:1156-1172): rules MP, MN, TD (here TD swaps H and G: φ_⟨P|F⟩); modal axioms MK, MT, M5; the interaction axiom MF (□φ → □Gφ, "the sole bimodal interaction axiom", tex:1180); temporal axioms TK (G(φ→ψ) → (Gφ→Gψ)), T4 (Gφ → GGφ), TB (F⊤), TA (φ → GPφ), TL ((Fφ ∧ Fψ) → [F(Fφ ∧ ψ) ∨ F(φ ∧ ψ) ∨ F(φ ∧ Fψ)]). Extensions (tex:1248-1255): TM_f := TM + DF where DF is (Hφ ∧ φ ∧ F⊤) → F Hφ (tex:1248); TM_d := TM + DN; TM_c := TM + CO; TM_dc := minimal extension of TM_d and TM_c. (Note tex:1170 vs tex:3830: TM's TL and BX's TL list the same three disjuncts in different orders — same content, not a discrepancy to "fix".)

*Rules of inference across systems*: MP (tex:1158, 3807), MN (modal necessitation, tex:1159, 3808), TN (temporal necessitation, BX only, tex:3822), TD (duality: P/F swap at BL level tex:1165, S/U swap at BL+ level tex:3823). *Derivability relation*: `def:derivability` (tex:3602-3604) defines ⊢ for TM as "the smallest relation closed under the axioms and rules for TM as presented in sub:Logic"; the paper gives no separate ⊢ definition per extension (each is "the smallest extension ... to include all instances of ...").

*Containment relations* (all from the definitions above): CPL ⊆ S5; CPL ⊆ BX; BX ⊆ BX_f, BX ⊆ BX_d, BX ⊆ BX_c; S5 ∪ BX ∪ {MF} generates TM+; TM+ ⊆ TM+_f/d/c (adding UZ+Z1, DN+NN, Prior-U+Sep respectively). At the BL level: TM ⊆ TM_f/d/c, TM_d ∪ TM_c generates TM_dc. TM_f and TM_d are jointly inconsistent-motivated ("no temporal order is both discrete and dense", tex:1254 — the *frame classes* are disjoint; the paper's sentence is that TM cannot include both DF and DN "while maintaining consistency"). Cross-level: BL embeds into BL+ under `def-operators` (typ:154-162, tex `def:BLplus-defined`:3444), so each TM-theorem maps into TM+ (backward direction, stated at typ:500-501).

**What a "systematic account" requires for the rewrite** (replacing typ:369-389): (i) each system's axiom set stated in full (S5 and BX from `:353`/`:362`; UZ, Z1, DN, NN, Prior-U, Sep with the K⁺/K⁻ definitions, and derived CO, from this finding); (ii) rules named per system (MP+MN for S5; MP+TN+TD for BX — note MP enters BX via its CPL closure; all of these plus MN for TM+); (iii) the definitional pattern "smallest extension of X closed under all instances of Y" used uniformly; (iv) the TM+ = S5 + BX + MF fusion with MF displayed; (v) the extension table retained but now referring to stated axioms, with the Prior-S correction; (vi) the Hölder paragraph (typ:386-389) retained — it is accurate against tex:3877 and tex:3916-3918. **Scope caution**: do not transcribe `cor:tm-completeness`'s claims (see Adversarial Self-Verification, contradiction C-1); completeness accounting already lives, more carefully, at typ:441-505.

### 5. Section introduction (`:393`)

Line typ:391 opens `= Completeness and Decidability <sec:key-theorems>`; typ:393-402 is the FIX plus a commented-out remark (the rejected "platitude" version, which spends its lines on what completeness "would buy"). Read end-to-end (typ:391-537), the section actually covers, in order:

1. **Soundness** (typ:404-409): ⊢ → ⊨ for TM and its four frame-class extensions over their own classes (`thm:TM-soundness`, tex:3761); characteristic case M5.
2. **Correspondence** (typ:411-425): DF iff Discrete, DN iff Dense, CO iff Complete (`app:discrete`:3043, `app:dense`:3124, `app:complete`:3204), each direction witnessed on the translation flow over D.
3. **Perpetuity and Collapse** (typ:427-439): four TM-theorems collapsing mixed modal-tense prefixes (Pthm:13, 14, 18, 20), bounding the bimodal language's expressive excess and explaining why completeness constructions manage only MF.
4. **Completeness** (typ:441-505): incompleteness of all five BL-level systems over their classes (with TM_f's completeness over the full discrete class explicitly open); three machine-checked BL+-level weak-completeness results (dense, discrete/Z-time, dense-and-complete) with axiom reports; the outstanding base-class obligation (`sorryAx` via dead code `countermodel_discrete`); the strong-vs-weak completeness rider (strong fails for Z and R); the no-conservativity remark.
5. **Decidability** (typ:507-537): open for all five BL-level systems; failure of a uniform finite model property over Z (two witnesses); the verified-sound tableau procedure; the reduction strategy Log(all) = Log(Discrete) ∩ Log(Dense) as target, not result.

A replacement intro of 3-5 sentences can simply walk this list concretely: soundness and the three correspondences; the perpetuity collapse; per-system, per-class completeness with the BL/BL+ asymmetry (nothing positive at BL level, three machine-checked results at BL+ level, base case outstanding); decidability open with the failed uniform-FMP premise retracted and the reduction identity as the live strategy. That is the whole section; no other subsections exist before `= The Completeness Construction` at typ:539.

### 6. Ordering and blast radius

**Declared dependency chain**: 445 (`[NOT STARTED]`) <- 446 (`[NOT STARTED]`, deps: 445) <- 447 (deps: 446). Per `specs/TODO.md:160-233`. So the intended execution order is 445, then 446, then 447. All line numbers in all three task descriptions are "as of scan" and will drift as each task lands; each implementer must re-locate by FIX-tag content, not by stale line number.

**Collision map for 447's six targets** (typ line ranges as of now):

| 447 target | Edit region | 445 footnotes inside region | 446 blocks inside/adjacent |
|---|---|---|---|
| `:244` Extension proof | typ:240-261 (statement typ:240-242 untouched; proof + new lemmas inserted before/around) | :242, :255 | :257 (Step-Lemma prose) — and :214 Nullity proof just above |
| `:267` Task Topology | typ:263-284 | :274, :276 | :263 (cones-basis prose), :277 (Separation proof) |
| `:353` S5 | typ:352-359 | :359 | — |
| `:362` BX | typ:361-367 | :367 | — |
| `:369` proof-systems remainder | typ:369-389 | live footnote at :384 (references `def:TMplus-f/d/c` — keep; anchors verified) | — |
| `:393` section intro | typ:393-402 | — | — |

**Interlocks worth planning around**:
- The `:257` prose (446) asserts "Extension is the sole consumer of the Step Lemma" and "the Step Lemma is the sole application site of *Spherical*" — statements that are only checkable/true in the document once 447's `:244` repair introduces the Step Lemma live. If 446 executes first (per the dependency chain), it restores prose referencing a lemma the document does not yet state; that is tolerable (the prose's own footnote cites `lem:step` in the paper) but the 447 implementer should re-read that restored prose and knit it to the newly-live Step Lemma. Alternatively the planner may deliberately have 446 defer `:257` to 447; flag this in the plan rather than silently reordering.
- The `:263` prose (446: "cones form a basis... topology is separated") is the natural lead-in sentence to 447's rewritten Task Topology definition; the two edits should be reviewed together for flow.
- The new lemma ladder for `:244` inserts material between typ:238 and typ:240, shifting every subsequent line; do `:244` and `:267` in one pass or recompute offsets between passes. Within 447 alone, applying the six rewrites **bottom-up by line number** (`:393`, `:369`, `:362`, `:353`, `:267`, `:244`) keeps earlier targets' line numbers stable while editing.
- Per-target verification: `typst compile typst/FormalFoundations.typ` after each rewrite (currently green — see below).

### 7. Environment facts (recorded per research objectives)

- **Build**: `typst compile FormalFoundations.typ` currently **succeeds** (exit 0). Two warnings: "unknown font family: new computer modern sans" from `@preview/thmbox:0.3.0` — pre-existing, unrelated to this task.
- **Macros**: `#BL`, `#BLplus`, `#since` (`lt.tri`), `#until` (`gt.tri`), `#Nxt`, `#Prev` defined locally at `FormalFoundations.typ:81-86`. `#allpast` (H), `#allfuture` (G), `#somepast` (P), `#somefuture` (F), `#always`, `#sometimes` at `typst/notation/bimodal-notation.typ:29-37`; `#taskframe` (cal F), `#Dur` (cal D), `#worldstate` (W) at :47-49; `#satisfies`/`#notsatisfies` at :66-67; `#model` imported via shared-notation (comment at bimodal-notation.typ:56). `#items` from `template.typ:128-135`.
- **Bibliography**: `@brastmckie2026possibleworlds` exists at `typst/bibliography.bib:12` and resolves (live uses at typ:162, typ:167 compile clean; `#bibliography("bibliography.bib")` at typ:1090).
- **Dead anchor**: `cor:tm-decidability` is commented out in the live paper (tex:3995-4007, `% \begin{Cthm}[Decidability]`). The 445 footnotes at typ:511 and typ:523 cite it. Not one of 447's six targets, but the 447 planner should note it so the `:369` rewrite does not newly cite a dead anchor, and the 445 implementer inherits the flag.

## Decisions

1. **Reference grounding tier**: Tier 1 (literature). Applied throughout; every paper claim above carries a tex anchor/line.
2. **Scope of `:369`**: transcribe proof-system *definitions* (S5, BX, BX_f/d/c, TM+, TM+_f/d/c, and the BL-level TM + TM_f/d/c/dc for completeness of the account); do **not** import the paper's `cor:tm-completeness` claims (contradiction C-1 below). The typ document's own completeness accounting at typ:441-505 stays authoritative for claims.
3. **Prior-S**: treat the current typ table's "Reynolds triple Prior-U, Prior-S, Sep" as a transcription error to correct — the paper postulates Prior-U and Sep, deriving the since-direction by TD (tex:3904).
4. **Dead anchor**: `cor:tm-decidability` flagged rather than silently worked around; disposition belongs to 445's footnote decisions.

## Recommendations

1. **`:244`** — adopt the condensed transcription (option (b) in Findings 1): `#definition("Constraints")` (from `def:constraints`), `#lemma("Directedness")` (= `lem:constraint`, with nesting/nonempty reasoning inline in its proof, citing Compositionality/Seriality/converse convention as the paper does), `#lemma("Admissibility")` (= `lem:admissible` with `lem:fibers` folded in; cites Nullity), `#lemma("Step")` (= `lem:step`, with the paper's closing remark about the ⊆-least-member case, tex:2836), then restore the Extension proof per tex:2862-2867 with "the Step Lemma" now resolving. Add `cor:spherical-finite` as a short corollary or keep it footnote-level (it is already the subject of the 446 `:257` footnote). If the planner prefers maximal fidelity, option (a)'s full seven-link ladder is equally grounded — both options are fully specified in Findings 1.
2. **`:267`** — rewrite `def:task-topology` as `#items` with five `+ *Name*:` entries (Basic Opens, Topology, Closure, T1, R0), following the typ:186-190 exemplar; omit the paper's **Discrete** item (unused downstream) unless the planner opts for anchor-exact fidelity.
3. **`:353`** — restate S5 with the five keys in an `#items` block, each formalized (table in Findings 3), keeping the paper's "smallest extension of CPL" framing.
4. **`:362`** — restate BX with all 17 keys grouped as the paper groups them (rules; TB/TL/CN; eight primary; four uniformity), each formalized (tables in Findings 3), with the ⟨S|U⟩-swap notation defined before TD and the derived-past-direction sentence retained.
5. **`:369`** — replace typ:369-389 with a systematic sequence mirroring tex:3866-3940: BX_f, BX_d, BX_c definitions (axioms stated, K⁺/K⁻ defined, CO's derived status stated), then TM+ = S5 + BX + MF with MF displayed, then TM+_f/d/c; retain the summary table (corrected re Prior-S) and the Hölder paragraph; optionally add the BL-level TM definition (tex:1154-1172) since the document references TM throughout §2 without ever defining it — this is the one genuine self-containedness gap beyond the FIX comments (planner's call on scope).
6. **`:393`** — replace with a 3-5 sentence concrete overview per Findings 5.
7. **Ordering** — within 447, edit bottom-up (`:393`, `:369`, `:362`, `:353`, `:267`, `:244`); compile after each target; remove each FIX tag as its target lands (task requirement, TODO.md:181).
8. **Phase sizing (H8)** — natural phases: (P1) `:393` + `:353` + `:362` (self-contained, no new dependencies, ~80-120 lines), (P2) `:369` (~60-100 lines), (P3) `:267` (~15 lines), (P4) `:244` lemma ladder + proof (~40-60 lines). Each is one agent run.

## Risks & Mitigations

- **Line drift across 445/446/447**: all three tasks cite line numbers "as of scan". Mitigation: locate edits by FIX-tag text; re-scan before each phase; Findings 6 maps regions, not just lines.
- **446 sequencing ambiguity at `:257`**: restored prose references the Step Lemma before it exists. Mitigation: plan notes the interlock; 447's `:244` phase re-reads the restored/current `:257` region and knits it.
- **Notation slip in transcription**: uppercase/lowercase tense glyphs (G/F, H/P) are easy to invert. Mitigation: the mapping table in Findings 3 is normative; UE (`(φ ▷ ψ) → Fψ`) and TB (`F⊤`) use *existential* F; TK/T4/TA/UC/UG use *universal* G.
- **Importing overstated completeness claims**: contradiction C-1. Mitigation: Decision 2 confines `:369` to definitions.
- **Compile regressions from long `#items` blocks in thmbox environments**: low risk (existing definitions already do this, e.g. typ:198-211); compile-per-phase catches it.

## Adversarial Self-Verification

`adversarial_verification_triggered`: **true** (verification pass performed; it corrected one table row claim — Prior-S — and surfaced one dead anchor and one contradiction; no fundamental flaw in research direction, so no Revised Direction section).

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `possible_worlds.tex` exists and is readable at the stated path | 387,438 bytes, 4,174 lines, mtime 2026-08-17 | `ls -la` + `wc -l` + direct Reads of 6 regions | High |
| Anchors `def:S5`, `def:BX`, `thm:extension`, `def:task-topology`, `lem:step`, `cor:spherical-finite` all exist in the tex | tex:3799, 3817, 2855, 2633, 2829, 2843 | `grep -n '\\label{'` full-file scan (two pages, 130+ labels enumerated) + direct Read of each | High |
| BX has exactly seventeen named keys | TN, TD; TB, TL, CN; TA, UE, UT, UI, UC, UF, UG, SU; NP, NF, NA, NB | Direct Read of `def:BX` tex:3817-3861; manual count 2+3+8+4=17; cross-checked against typ:363-367's four-group listing (names agree one-for-one) | High |
| Extension proof invokes exactly Zorn + `lem:step` + `def:world-history`; Step Lemma chain is def:constraints -> nesting -> nonempty -> constraint -> fibers -> admissible -> step | Verbatim `\textbf{\ref{...}}` citations in tex:2862-2867, 2825, 2835-2836, 2788-2791, 2804-2806 | Direct Read of tex:2740-2899, following every `\ref` | High |
| None of the Step-Lemma chain is live in the typ; 446's blocks do not state the Step Lemma | typ:214-222, 245-250, 257-261 contain only Nullity's proof, the inadequate Extension proof, and role-prose | Read of typ:1-470 + `grep -n "FIX:"` full listing + TODO.md task 446 block | High |
| `cor:tm-decidability` is commented out in the live paper | tex:3995 `% \begin{Cthm}[Decidability]` | grep label listing (comment-prefixed) + direct Read tex:3995-4007 | High |
| Current build succeeds; bibliography key resolves | exit 0 with two pre-existing font warnings; `bibliography.bib:12`; live cites typ:162/167 | `typst compile` executed; `grep` of bib + typ | High |
| `#items` is the "indented definitions" construct, defined at template.typ:128-135 | enum numbering "(1)", used at typ:155, 186, 202, 228, 309 | Read of template.typ:120-144 + typ exemplars | High |
| Paper postulates Prior-U and Sep only; "Prior-S" is TD-derived, so typ:380's "Reynolds triple" row misattributes it as an axiom | tex:3904 "only the future/until direction of [Prior-U] is stated, its past/since direction following by [TD]" | Direct Read of `def:TMplus-c` tex:3903-3920; cross-check against typ:380 | High |
| TM (BL-level) is defined at tex:1154-1172 with rules MP, MN, TD and axioms MK, MT, M5, MF, TK, T4, TB, TA, TL; extensions via DF/DN/CO at tex:1248-1255 | verbatim aitem block | Direct Read of sub:Logic and sub:Extension | High |
| 445/446/447 dependency chain and task scopes | TODO.md:160-233; 445 and 446 both `[NOT STARTED]` | Read of TODO.md; state.json query (top-level keys only; task rows read from TODO.md) | Medium (TODO.md is the user-visible mirror; state.json entries not individually inspected — acceptable since scheduling, not math, depends on it) |
| The `:393` section covers exactly the five topics listed | typ:391-537 read end-to-end; next heading at typ:539 | Direct Read | High |

### Contradiction Log

**C-1** — The paper's live `cor:tm-completeness` (tex:3942-3952) states "TM+ Strongly complete over all task frames" and "TM+_d Strongly complete over the dense frames" as carried results (proof: "machine-checked in the Lean 4 repository", tex:3955), while `FormalFoundations.typ:482-497` documents base-class completeness as outstanding with `sorryAx` and strong completeness as "the aim" for TM+ and TM+_d. Precedence ranking applied: the typ document's accounting is grounded in directly-quoted Lean axiom reports (typ:466, 473, 480, 488) — the analogue of "directly-read source > summary" — and the paper's own commented-out Lean-status note (tex:3990-3992) concedes "the base case over all frames is stated with one remaining obligation," contradicting its live statement. Resolution: for every claim about what is *proved*, the typ document's accounting wins; the paper corollary states targets as results. Downstream consequence enforced in Decision 2: the `:369` rewrite transcribes definitions only. (This also means the 445 footnote at typ:448 citing `cor:tm-completeness` for the *incompleteness* theorem cites an anchor whose live statement now says something different — the incompleteness diagnosis survives only in the corollary's commented-out proof text, tex:3963-3981. Flagged for the 445 implementer; no action within 447's six targets.)

**Modified after verification**: Recommendation 5 and Findings 4 were adjusted to (i) correct Prior-S's status and (ii) exclude `cor:tm-completeness` content from the `:369` rewrite. No other findings changed.

## Appendix

- Paper section map used: `sub:Logic` tex:1148; `sub:Extension` tex:1229; `app:TaskSemantics` tex:2590; `app:Soundness` tex:3590; `app:ProofTheory` tex:3791.
- Typ file map: language typ:141-171; frames typ:173-222; histories/topology typ:224-297; models/truth typ:299-348; proof systems typ:350-389; completeness/decidability section typ:391-537; construction section starts typ:539.
- Full FIX-tag inventory for the file: 45 tags total (see `grep -n "FIX:"` output archived in task history); 39 belong to task 445, 6 bare blocks to task 446, 6 substantive to this task.
- Commented-out paper material adjacent to this task's sources, for the planner's awareness only: `rmk:effective-extension` (tex:2874-2880, effective/periodic extension over finite discrete frames — related to Lean-side task on periodic extension), `app:topology-nondiscrete` (tex:2694-2711), `app:gluing` (tex:2729-2747).
