# Research Report: Writing the Counterfactual (Part III) and Constitutive (Part IV) Chapters of BimodalReference

**Task**: 317 — write_bimodalreference_part_v_logos_chapters_const
**Session**: sess_1783410218_f83296_317
**Date**: 2026-07-07
**Sources read this session** (all line references verified against the live files):
- `/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` (2,277 lines; the published paper, cited as `@brastmckie2025counterfactualworlds`)
- `/home/benjamin/Projects/Logos/Theory/typst/manual/chapters/02-constitutive.typ` (1,623 lines), `03-dynamics.typ` (475 lines), `07-proof-theory.typ` (127 lines)
- `/home/benjamin/Projects/Logos/Theory/typst/notation/{basic,logos,extended}-notation.typ`
- `/home/benjamin/Projects/Logos/Theory/Logos/Foundations/Constitutive/Frame.lean` (Lean ground truth for the constitutive layer)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/typst/` — `BimodalReference.typ`, `template.typ`, `notation/{bimodal,shared}-notation.typ`, `bibliography.bib`, `SYNC-MAP.md`, `sync-check-whitelist.txt`, chapters `00-introduction`, `01-syntax`, `02-semantics`, `p3-vlach-blstar`, `p4-dual-verification`, `p5-counterfactual`, `p5-constitutive`
- `specs/313_design_full_extent_bimodalreference_book/reports/01_teammate-b-findings.md` (B-F1/F2/F5)

**Baseline verified this session**: `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 (one benign font warning from thmbox); `bash scripts/typst-sync-check.sh` PASSES (0 violations / 459 candidates, count freshness OK).

---

## 1. Executive Summary

Both target chapters are currently 10-line placeholders (`chapters/p5-counterfactual.typ`, `chapters/p5-constitutive.typ`). All mathematical content exists in two mutually consistent sources (the paper and the Logos manual), and all template infrastructure needed (`example`, `principles`/`principle`/`pr`, `chapter-header`, `notation-env`, `proposition`, `corollary`) was already ported into `Theories/Bimodal/typst/template.typ` by task 313 — no template work is required. The remaining work is:

1. **Write `p5-counterfactual.typ` (Part III)** from paper §§2.2 (working definitions), 3.3 (propositions), 4 (semantics + CL/CML/CTL + countermodels), 5 (Vlach/tense), Appendix (derivations + soundness elements), cross-checked against Logos `03-dynamics.typ` and `07-proof-theory.typ`.
2. **Write `p5-constitutive.typ` (Part IV)** from paper §§3.1–3.2 and 6.2 (Containment) + Appendix (World Space theorems, Fine-constraint derivations) cross-checked against Logos `02-constitutive.typ` (propositional subset only), closing with the Part-I comparison figure.
3. **Create `notation/constitutive-notation.typ`** with the state-space symbol layer (Section 7 below), avoiding two live name collisions (`taskrel`, `worldstate`).
4. **Extend `bibliography.bib`** with ~10 entries (Fine, Lewis, Stalnaker, Goodman, Jackson, Kripke, bilattice refs) — currently absent (Section 8).
5. Small enabling edits: a referenceable label on the Part-I Vlach chapter heading, and (only if backticked Lean names are used) whitelist entries for external Logos identifiers.

The critical design decision this report resolves (Section 3) is how to stage content given the **user-decided inverted order** (counterfactual Part III *before* constitutive Part IV): Part III follows the paper's own §2.2 device of working over Fine's world spaces with a *temporarily primitive* set of possible states `P`, and Part IV then de-primitivizes `P` via the task relation over all states — making "possible and world states defined, not primitive" Part IV's punchline and the Part-I comparison figure its close. This matches the paper's own §2→§3 order and requires no forward dependency violations.

---

## 2. Verified Source Map (B's staging list re-verified against counterfactual_worlds.tex)

Teammate B's 9-item dependency list (B-F2) re-verified at drafting time, per task instruction. All items confirmed; line references corrected/confirmed below (B's were approximately right; exact anchors follow):

| # | Content item | Paper location (verified) | Logos manual location (verified) |
|---|---|---|---|
| 1 | State space ⟨S,⊑⟩ complete lattice; fusion ⨆X; null □ := ⨆∅; full ■ := ⨆S; finite fusion s.t | lines 627–633 | `02-constitutive.typ:260–293` (defs state-fusion, general-fusion, null-state, full-state) |
| 2 | Task space: task relation, trivial task, connectedness s∼t, possible states P defined; Restricted Reflexivity (731–738); transient states (740–743); Parthood L/R (750–756); contingent/necessary states, Nullity (764–777); Maximality (785–795); task space def (807) | lines 719–810 | `02-constitutive.typ:247–258` (task frame), `333–337` (possible), `344–384` (compat/maximal/world/connected/necessary), `432–459` (Parthood/Containment/Maximal constraints) |
| 3 | Derived: Possibility, Nonempty, World Space (Fine's primitives now theorems) | Appendix `app:Possibility` 1771–1780, `app:Nonempty` 1786–1793, `app:Worldspace` 1798–1816 | (stated as constraints/defs, not derived, in Logos manual) |
| 4 | Compatible part, maximal compatible parts, **imposition defined**; Fine's four constraints derived | defs 656–663; derivations: Inclusion 1682–1689, Actuality 1695–1705, Incorporation 1713–1730, Completeness 1738–1744 | defs `02-constitutive.typ:396–409`; imposition remark `03-dynamics.typ:379–382` |
| 5 | World histories / possible worlds (equivalence classes under time-shift ≈); worlds as **maximal possible evolutions** + Containment constraints + M_Z = H_Z | histories/worlds 819–832; Containment §6.2 at 1435–1455; theorem `app:Containment` 1822–1842 | `03-dynamics.typ:103–122` (def-dynamics, thm-containment) |
| 6 | Bilateral propositions: closed/exclusive/exhaustive ⟨V,F⟩ | 855–864 | (FOL generalization: `02-constitutive.typ:473–516` dynamical model verifier/falsifier functions) |
| 7 | Exact inclusive semantics ⊗/⊕/∧/∨/¬ on propositions; truth clauses; **□→ in imposition form (946) AND basic mereological form (954–956)** | 914–956 | `03-dynamics.typ:359–382` (Alt-worlds form + imposition remark) |
| 8 | Logics CL (R1, C1–C7, 982–1003) ⊂ CML (M1–M5, □A := ⊤□→A at 1014) ⊂ CTL (TK/TD/GP/TR/LN/DF/NF/UF, 1051–1075); derivations D1–D11 (1004–1009, 1030–1049, Appendix 1511–1657); S5 claim (1046–1048); twelve invalid schemata #1–#12 (1088–1104); interpreted countermodels for #1 (1110–1133), #8 (1138–1173, also covers #1 and #11), #9/STA (1178–1208, Sobel-sequence footnote 1202); ModelChecker note `"disjoint" = True` (footnote at 1106) | | `07-proof-theory.typ:53–114` (R1, C1–C7, P1–P6, T/M1–M5); soundness + open completeness `116–125` |
| 9 | Extensions/limitations: extensional-antecedent restriction (876–899); iterated-modality motivation for ⊤/⊥ (1012–1014 + ModelChecker-extension footnote at 1013); events/processes (1399–1428); continuous time + DN/CO axioms (1461–1487) | | (not in Logos manual) |

**Motivation material** (for chapter openings): Totality + Nixon example `(N)` (391–458); Restriction, SDA (486–509), STA (514–521), the "no space in the dialectic" framing (538–545); INT/LL derivation of STA from SDA (555–567); Fine's Universal Realizability/Verifiability (585–595); Fine's four imposition constraints as *assumptions* (608–614); the anti-primitive argument (597–618, 666–674).

**Vlach material** (paper §5, 1220–1370): N′ motivation (1223–1242); store ↑ᵢ/recall ↓ⁱ syntax + clauses (1251–1270); regimentations (n) `past(B □→ future H)` (1233), (n′) `↓¹(B □→ future H)` (1275), (n″) `↑²↓¹(B □→ ↓² H)` (1288); Jackson jump case with (d) `↓²(J □→ ↓³ D)`, (u) `↓²(J □→ ↓¹ U)`, (l) `↓²(J □→ ↓³ L)` (1302–1353); Icosahedron backwards case (1355–1366). Logos parallel: `03-dynamics.typ:325–355` (store/recall clauses + tensed-counterfactual example `↑¹P(φ □→ ↓¹ψ)`).

**Soundness elements** (Appendix `app:Soundness`, 1847–2219): closure lemmas (Associativity 1860, Fusion-closure 1875, prop closure `app:Closure` 1924, `app:Proposition` 1957, `app:Extensional` 1982); validity of R1 (2033), L1/L2 helper lemmas (2047, 2066), C2 (2082), C3 (2095), C5 (2113), Trivial-imposition lemma (2127), M3 (2145), M4 (2163), M5 (2183), and `PT6` □GA ↔ □A (2204). **The paper itself says** (1855): "For brevity, I will establish the validity of a collection of characteristic axiom schemata for CTL since the others are similar" — the chapter must report soundness at exactly this strength (characteristic schemata proven in the paper; full completeness open, per paper 969 and 1500, and `07-proof-theory.typ:122–125`).

---

## 3. Staging Under the Inverted Book Order (counterfactual THEN constitutive)

The user decision places the counterfactual chapter (Part III) *before* the constitutive chapter (Part IV), inverting the logical dependency (the state construction grounds the counterfactual semantics). The clean resolution mirrors the paper's own architecture:

- The paper's §2.2 defines imposition over **Fine's world spaces**, taking the set of possible states `P` as *temporarily primitive* ("Since these proofs do not concern the task relation, we may take the set of possible states P to be primitive for present purposes" — Appendix, 1675). Everything Part III needs (state space, P, compatibility, world states W, compatible parts, maximal compatible parts, imposition, bilateral propositions) is available at this level.
- Part IV then executes the paper's §3 move: replace primitive `P` with the **task relation over all states**, derive Possibility/Nonempty/World Space as theorems, derive Fine's four imposition constraints, and characterize worlds as maximal possible evolutions (Containment). This gives Part IV a genuine payoff rather than a rehash, and its final section can close the book with the comparison figure: *the bimodal task frame of Part I is the world-state shadow of this structure*.

**Recommended chapter blueprints:**

### 3.1 `p5-counterfactual.typ` (Part III) — "Tensed Counterfactual Logic and Derived Modality"

1. **Motivation** — Totality (Nixon `(N)`, similarity theories) and Restriction (SDA vs STA; INT/LL argument); the paper's stated aim: validate SDA without STA, interpret tensed counterfactuals, no counterfactual primitive in the metalanguage. (paper §1, condensed to ~2 pages of prose.)
2. **States, world states, and imposition (working definitions)** — state space as complete lattice; possible states P *taken as given in this chapter, with an explicit pointer to Part IV where P is defined and Fine's constraints are derived*; compatibility, world states, World Space; compatible part / maximal compatible parts / imposition **defined** (paper 656–663); Fine's four constraints *stated* here as facts proven in Part IV (forward @-reference).
3. **Bilateral propositions** — closed/exclusive/exhaustive ⟨V,F⟩ (855–864), impossible states rationale (640 footnote, 695–706), cite `@brastmckie2021identity` for the defense; ⊗/⊕ and the ∧/∨/¬ operations (914–928); bilattice footnote (923–928) optional.
4. **Grammar with the extensional-antecedent restriction** — reproduce the two-sorted grammar exactly: `φ ::= pᵢ | ⊤ | ⊥ | ¬φ | φ∧φ | φ∨φ` (extensional) and `A ::= … | HA | GA | φ □→ A` (876–899). **The restriction φ ∈ ext(L) is load-bearing**: without it the axiom schemata are ill-formed. State plainly (footnote, from paper 1013) that ModelChecker implements an unrestricted extension which is *not* adopted here. NOTE: the book's Part-I basis is Until/Since with H/G derived — see Divergence 4 resolution in Section 4.
5. **Task semantics** — truth clauses (938–947); □→ given in **both** forms: imposition form (946) and basic mereological form (954–956); logical consequence (963–967).
6. **The logics CL ⊂ CML ⊂ CTL** — via the template's `principles`/`principle`/`pr()` lists:
   - CL: rule R1 + C1–C7 with the paper's names (Identity, Counterfactual Modus Ponens, Weakened Transitivity, disjunction axioms; 982–1003); derived D1 (Finite Conjunction) and D2 (Classical Weakening).
   - CML: M1–M5 (1014–1029) after **the headline definition □A := ⊤ □→ A** (1014) — with the explanation of *why* CL cannot define □ (iterated modalities ill-formed under the extensional restriction, 1012–1013).
   - **Headline theorem**: derived D3–D10 (1030–1049), with T (=D5), Brouwer M3, S4 M4 ⇒ **CML entails S5** — "S5 is derived from counterfactual logic without any frame constraints; metaphysical modality is the strongest objective modality" (1046–1048). Soundness only; completeness open — state honestly.
   - CTL: TK/TD/GP/TR/LN/DF/NF/UF (1051–1071) with derived PD11 □A → △A (1649–1657) — this is the **perpetuity re-derivation**: cross-reference Part I's perpetuity chapter (05-theorems, P1–P6) and note that the principle *imposed/proven semantically* in Part I here *falls out of the counterfactual axioms*. Logos `07-proof-theory.typ:85–94` gives the P1–P6 list in matching triangle notation.
7. **Countermodels #1–#12** — the twelve invalid schemata (1088–1104) as a display list, then `example` environments for the three fully interpreted countermodels: **#1** (red ball/Mary, 1110–1133), **#8** (Boris/Olga contraposition-with-false-components; also invalidates #1 and #11; 1138–1173), **#9/STA** (party case with the Sobel-sequence footnote; 1178–1208). Include the ModelChecker-reproducibility note (footnote 1106): each is reproducible with `"disjoint" = True`. Honesty note: the paper details these three (plus #11/#12 by argument, 1170–1173); the remaining schemata are listed as invalid without interpreted models — the chapter must not claim twelve worked models.
8. **Tensed counterfactuals via Vlach store/recall** — motivate with N′ (1223–1242); syntax + ↑ᵢ/↓ⁱ clauses (1251–1270), **explicitly presented as reusing Part I's store/recall operators** (cross-reference `p3-vlach-blstar.typ` — see Section 6 for the label prerequisite); regimentations n / n′ / n″; the Jackson backtracking dialogue with d/u/l; the Icosahedron case; Suppositional Accommodation remark (1343).
9. **Soundness and open problems** — soundness at the paper's actual strength ("characteristic schemata"; enumerate which are proven in the paper's Appendix: R1, C2, C3, C5, M3, M4, M5, □GA↔□A); completeness open (969, 1500); limitations honestly stated: events/processes idealized as states (1399–1428), discrete vs continuous time with the DN/CO alternative axioms (1461–1487); **not formalized in this repository** — external Logos Lean formalizes the constitutive/dynamical layer (see Section 6 discipline).

Cite `@brastmckie2025counterfactualworlds` at the chapter head (as the placeholder already does) and throughout.

### 3.2 `p5-constitutive.typ` (Part IV) — "Constitutive Structure"

1. **Opening** — the anti-primitive program: Lewis posits similarity, Fine posits imposition, Part III posited possible states P; this chapter replaces `P` with the task relation over all states, deriving everything Part III assumed (paper 666–678, 708–713, 1380–1392). Interpretation of states (§3 opening, 689–706): static, partial, specific; impossible states and their role.
2. **State lattice** — complete lattice ⟨S,⊑⟩, fusion, null/full state, proper part; optionally atomic/composite states (Logos `02-constitutive.typ:301–322`, propositional-friendly and Lean-anchored in the external repo).
3. **Task relation over all states** — duration-parameterized `s ⟹_d t` with compositionality (Divergence 1 resolution: use the parameterized form matching Part I's `02-semantics.typ` and Logos Lean `TaskFrame.taskRel : S → Q → S → Prop` + `Compositional`; note the paper's unparameterized simplification in a remark). Connectedness, **possible states DEFINED** (Divergence 2: Lean form `s ⟹₀ s`, `StatePossible` in `Foundations/Constitutive/Frame.lean`; remark on the paper's connectedness form and transient states, paper 731–743, and Restricted Reflexivity under which they coincide). Compatible, maximal, **world states defined** (`StateWorld = StatePossible ∧ StateMaximal`), necessary states, Nullity (764–777).
4. **Frame constraints and derived theorems** — Parthood L/R (750–756; Logos `432–438`), Maximality (785–795; Logos `455–459`), Nullity; then the theorems: Possibility (Fine's constraint now derived, 1771–1780), Nonempty (1786–1793), World Space (1798–1816). Task-space definition (807).
5. **Imposition defined and Fine's constraints as theorems** — recall Part III's definitions (compatible part, [w]_t, imposition), then derive Inclusion / Actuality / Incorporation / Completeness (Appendix 1682–1744) — "the constraints Fine assumes are theorems here."
6. **Worlds as maximal possible evolutions** — evolutions, evolution parthood, world histories; possible worlds as time-shift equivalence classes (819–832); Containment L/R constraints (1447–1452) and the theorem M_Z = H_Z (1822–1842; Logos `thm-containment`, `03-dynamics.typ:116–118`): the purely task-theoretic characterization coincides with the world-history characterization.
7. **Ground and essence pointer** — brief section: the same bilateral state semantics supports the hyperintensional treatment of propositional identity, ground, and essence; cite `@brastmckie2021identity` (as the placeholder already does) and point to the Logos manual (`02-constitutive.typ` Essence and Ground, PI¹ proof system in `07-proof-theory.typ:12–51`) for the full development — the book stays propositional and does not reproduce the FOL/lambda machinery (Divergence 3 resolution).
8. **Closing comparison figure** — *the bimodal frame of Part I as the world-state shadow of this structure*: a figure/table mapping Part I's primitives to Part IV's constructions: `W` primitive ↦ world states defined as maximal possible states; task relation on `W` (with Nullity-identity, Reflection/converse, Compositionality — `02-semantics.typ:35–50`) ↦ task relation on all `S` (Compositionality + Parthood/Containment/Maximality/Nullity); valuation into subsets of W ↦ bilateral propositions ⟨V,F⟩; histories over convex domains ↦ maximal possible evolutions; □ primitive over histories ↦ □A := ⊤ □→ A derived (Part III). Include the honest note that Part I's frame assumes two constraints (nullity-as-identity, Reflection) that the general task space does *not* impose on all states (see Divergence 5, Section 4) — the shadow claim is a restriction/specialization statement, not an isomorphism claim.

---

## 4. Divergence Resolutions (the 4 documented + 3 found this session)

Resolutions for B-F5's four divergences, as directed by the task, plus three additional ones discovered in this session's reading:

1. **Duration-parameterized vs bare task relation** → **Use the duration-parameterized relation** `s ⟹_d t` (matches Part I's `02-semantics.typ` and Logos Lean `TaskFrame`); add a remark that the paper works with the unparameterized relation and unit-step evolutions over ℤ (819–822), which is the special case d ranging over unit durations. Evolutions in Part IV should be presented in the Logos form (`03-dynamics.typ:109`: τ over a convex X ⊆ Q with `τ(x) ⟹_{y−x} τ(y)`), which also matches Part I's world-history definition verbatim.
2. **Possible-state definition** → **Lean is ground truth**: `StatePossible f s := f.taskRel s 0 s` (`Logos/Theory/Logos/Foundations/Constitutive/Frame.lean`, verified this session; manual `02-constitutive.typ:333–337` agrees). Present `s ⟹₀ s` as the definition; add a remark on the paper's connectedness definition (`P := {s | ∃t. s∼t}`, line 731), transient states (740–743), and Restricted Reflexivity (738) under which the two coincide for the states that matter. Note the Lean `StateConnected` (∃d. s ⟹_d t ∨ t ⟹_d s) matches the paper's connectedness.
3. **Propositional vs first-order** → **Stay propositional.** Adapt only `02-constitutive.typ`'s propositional subset (Task Frame, Atomic/Composite, State Modalities, Constraints §§236–461) and treat sentence letters as 0-place predicates (the manual's own `rem-trivial-cases`, `02-constitutive.typ:518–524`, licenses exactly this restriction: `|p|⁺,|p|⁻ : Set(S)`). Point to LogosManual for the FOL/lambda generalization at the ground/essence pointer section.
4. **Until/Since basis** → **State CTL over the book's basis.** Part I's primitives are Until/Since with H/G/P/F *derived* (`01-syntax.typ:17, 104, 135`); the paper's CTL is axiomatized over primitive H/G. Present the CTL axioms in H/G form (they are perfectly well-formed over derived operators, which unfold definitionally), with an explicit remark: the paper's language takes H/G primitive and is strictly weaker than the book's Until/Since language (Kamp), so CTL-over-derived-H/G is the natural transposition, and nothing in the paper's soundness argument is affected. Do NOT restate the axioms with Until/Since directly.
5. **(New) Part I frame constraints vs task-space constraints.** Part I's `TaskFrame` (over world states) assumes **Nullity-as-identity** (`w ⟹₀ u ↔ w = u`) and **Reflection/converse** (`w ⟹ₓ u ↔ u ⟹₋ₓ w`) (`02-semantics.typ:35–50`); the paper's task space imposes neither on general states (footnote 753: symmetry/transitivity "will not be required"), and Logos Lean's `TaskFrame` imposes only Compositionality (as a separate `Compositional` class). The closing comparison figure MUST state this asymmetry plainly: restricting the general structure to world states does not automatically yield Part I's Reflection/nullity-identity — these are additional constraints Part I's frame class imposes. Phrase the shadow claim as "Part I's frames live at the world-state level of this structure, with further frame constraints" rather than claiming derivability.
6. **(New) Unilateral vs bilateral truth clauses.** The paper's truth semantics is **unilateral** (single ⊨ with classical ¬-clause, 938–947; bilaterality lives in the propositions ⟨V,F⟩); the Logos manual gives **bilateral truth/falsity clauses** (⊨ and ⫣) because it evaluates at non-maximal evolutions (`03-dynamics.typ:149–153`). **Follow the paper** in Part III (evaluation only at world histories; bivalence holds by World Space, 950); optionally remark that the Logos generalization evaluates at partial evolutions and restricts consequence to world-histories (its `thm-bivalence`).
7. **(New) Countermodel coverage honesty.** The paper presents twelve invalid schemata but interpreted countermodels only for #1, #8 (which also covers #1 and #11), and #9; #12's failure is derived by argument from D6 (1170–1173). The task phrase "countermodels 1–12 as example environments" must be implemented as: the full twelve-schema list, `example` environments for the three interpreted models, and the #11/#12 argument — with the ModelChecker note that minimal countermodels for the rest are machine-findable (`"disjoint" = True`, footnote 1106).

**Also carried over verbatim from the task (non-negotiable content constraints):** extensional-antecedent restriction in the grammar (Section 3.1 item 4); plain textbook prose, no sync-class banners or status symbols (banner system retired in task 319 — confirmed in `SYNC-MAP.md` header); state openly what is published (paper results), what is adapted (Logos manual transcriptions), what is not formalized (no local Lean for Parts III–IV; external Logos Lean formalizes the constitutive layer only partially — soundness elements, not completeness).

---

## 5. Existing Infrastructure (verified present; no template work needed)

`template.typ` already provides everything the chapters need (ported by task 313):
- `definition, theorem, lemma, axiom, remark, proof` + `proposition, corollary, example, notation-env` (lines 70–92)
- `principles` / `principle(number, name:, body)` / `pr(name)` auto-labeled axiom lists (143–168) — exactly right for R1/C1–C7/M1–M5/TK…UF/D1–D11 with stable cross-references (labels are `pr-<kebab-name>`)
- `chapter-header(description:, dependencies:, connections:)` (105–124) — both chapters should carry one, following the `p4-dual-verification.typ` house style (verified: heading, then `#chapter-header(...)`, then sections)
- `leansrc`/`leanref` (98–101), fletcher + cetz available, `part-divider` already invoked by `BimodalReference.typ` for Parts III/IV (lines 217–241; part scope blurbs already written and match the task description)
- Level-1 headings get supplement "Chapter" with a custom ref show-rule (`BimodalReference.typ:52–61`), so `@`-references to chapter headings render as "Chapter N" — give both new chapters' level-1 headings labels (e.g. `<ch:counterfactual>`, `<ch:constitutive>`) so 00-introduction and each other can cross-reference.

House style reference: `p4-dual-verification.typ` (adapted-from-Logos chapter with external-repo citation discipline — footnote pattern "external repository, commit-pinned by citation; not a local Lean name").

---

## 6. Verification Constraints (typst compile + sync-check MUST pass)

`scripts/typst-sync-check.sh` (verified green at baseline) runs two checks:
1. **Backtick name resolution**: every `` `span` `` in `typst/**/*.typ` must resolve against live Lean source under `Theories/Bimodal/` (excluding Boneyard) or appear in `sync-check-whitelist.txt`. **Consequence for these chapters**: external Logos Lean names (`Foundations.Constitutive.Frame`, `TaskFrame`, `StatePossible`, `StateWorld`, `Foundations.Dynamical.Truth`, etc.) do NOT resolve locally. Either (a) mention them without backticks (italics/prose, following the p4 footnote pattern), or (b) add whitelist entries with a comment block. Recommendation: (a) for prose mentions, (b) only if `#leansrc(...)` blocks are reproduced (leansrc renders as a raw block, which contains no backtick spans in source — actually safe: `leansrc` produces `raw(...)` from string args, and Check 1 scans *source* text for backtick spans, so `#leansrc("Foundations.Constitutive.Frame", "TaskFrame")` passes without whitelisting; verify during implementation).
2. **Count freshness**: `generated/status.typ` vs regeneration — unaffected by these chapters unless they import counts (they should not).

Also: `#show "TM": strong` is document-global (`BimodalReference.typ:64`) — any literal "TM" in the new prose bolds automatically; write accordingly.

**Cross-reference prerequisite**: `p3-vlach-blstar.typ` (Part I, task 315, `[NOT STARTED]`) is a 10-line placeholder whose heading `= Vlach Operators and the BL⋆ Tower` carries **no label**. The Vlach section of Part III must cross-reference it. Minimal enabling edit within task 317's scope: add a label (e.g. `<ch:vlach-blstar>`) to that heading (one-line change, no conflict with task 315 since generated TODO shows 315 not started; flag the label in the summary so task 315 preserves it). Same consideration: `00-introduction.typ:84` already promises "genuine cross-history counterfactual structure is the subject of Part III" — no edit needed there.

**Store/recall notation ownership**: neither `bimodal-notation.typ` nor `shared-notation.typ` defines store/recall symbols yet (task 315 will need them too). Recommendation: define `store(i)` = `$arrow.t^#i$` and `recall(i)` = `$arrow.b^#i$` in `notation/bimodal-notation.typ` (Part I owns the operators; Part III reuses them), NOT in constitutive-notation — and note this in the implementation summary for task 315 coordination. (Paper glyphs ↑ᵢ/↓ⁱ vs Logos ↑^i/↓^i differ only in sub/superscript position of the index; Logos superscript form recommended, matching `03-dynamics.typ:331–344` and the book's future Lean anchors.)

---

## 7. `notation/constitutive-notation.typ` — Required Contents and Collision Analysis

New file, imported by both p5 chapters (add `#import "../notation/constitutive-notation.typ": *` after the template import, or have the chapters import it directly — do NOT add it to `template.typ`'s imports, to avoid leaking symbols into Part I/II chapters).

**Collisions to avoid** (verified against `bimodal-notation.typ` + `shared-notation.typ`, both `*`-imported by every chapter via `template.typ`):
- `taskrel` — already `$R$` in `bimodal-notation.typ:56`. Do NOT rebind. The book-wide task arrow is `taskto(x)` = `$arrow.r.double.long_#x$` (`bimodal-notation.typ:59`); reuse it for the general task relation `s taskto(d) t`.
- `worldstate = $W$`, `histories = $H$`, `Dur = $cal(D)$`, `model`, `tuple`, `define`, `nec`, `poss` — already defined with compatible meanings; reuse, do not rebind.
- Typst-reserved/ambient names to avoid: `since`/`until` (Logos extended-notation uses `$triangle.l$/$triangle.r$`; the book renders Until/Since as `U(φ,ψ)`/`S(φ,ψ)` — do not import the Logos triangles).

**Symbols to define** (source: `Logos/Theory/typst/notation/extended-notation.typ`, adapted; paper glyph noted where different):

| Name | Suggested definition | Notes |
|---|---|---|
| `statespace` | `$cal(S)$` | Logos `extended-notation.typ:101` |
| `parthood` | `$subset.sq.eq$` | Logos `:110`; paper ⊑ same glyph |
| `properpart` | `$subset.sq$` | |
| `fusion` | `$union.sq$` | binary; Logos `:108`. Add remark reconciling the paper's `s.t` dot notation (627–631) — recommend a `notation-env` in the chapter, not dual glyphs |
| `Fusion` | `$union.sq.big$` | ⨆X; Logos `:109` |
| `nullstate` | `$square.stroked.small$` | Logos `:104`; paper □ |
| `fullstate` | `$square.filled.small$` | Logos `:105`; paper ■ |
| `compat` | `$circle.small$` | paper's ∘ (642); simpler than Logos's shrunken-⊤ glyph (`:339`) and matches `02-constitutive.typ`'s usage in the maximal-compatible-parts def as rendered |
| `incompat` | negated form (e.g. `$circle.small.slash$` or `cancel`) | Logos has `ncompat` |
| `iparthood(t)` | `$scripts(subset.sq.eq)_#t$` | s ⊑_t w; Logos `:395` |
| `maxcompat(s, t)` | `$[#s]_#t$` | Logos `:398`; paper writes `w_t` (659) — use the bracketed Logos/Lean form, remark on the paper's |
| `connected` | `$tilde$` | paper 729; Logos `:357` |
| `possible` | `$P$` | set of possible states |
| `necessary` | `$N$` | paper 772 |
| `maximalstates` | `$M$` | optional (Logos world-state def) |
| `imposition(w)` | e.g. `$arrow.r.triangle_#w$` if available, else a `math.attach`/composed arrow | paper's `\rightarrowtriangle_w` (610). Typst has no exact match; implementer should test candidates (`arrow.r.triple` NO; try `sym.arrow.r` + triangle overlay, or use `harpoon`-free fallback `$attach(arrow.r.long, br: #w)$` with a distinct head via `text` composition). A pragmatic fallback used by Logos (`03-dynamics.typ:380`) is the verbal form; the paper glyph is preferred — budget a small experiment |
| `prodop` / `sumop` | `$times.circle$` / `$plus.circle$` | ⊗/⊕ for verifier products/sums (914–916) |
| `evolutions` | `$E$` (with `^diamond.stroked` where needed) | paper 1763 |
| `maxevolutions` | `$M_(bb(Z))$`-style helper or inline | paper 1765 |

Keep the file small (~40–60 lines) with a header comment mirroring `bimodal-notation.typ`'s reconciliation notes (the task-313 note at `bimodal-notation.typ:10–25` explicitly promises this file: "that is follow-up task 317's `notation/constitutive-notation.typ`"). The `sync-check-whitelist.txt` header mentions a "Planned notation file (referenced in a source comment; not yet created)" — after creating the file, check whether a whitelist entry for `notation/constitutive-notation.typ` exists and can be retired.

---

## 8. Bibliography Additions Required

`bibliography.bib` currently has 17 entries (verified); none of the paper's philosophical apparatus. Needed for the two chapters (keys suggested in the book's existing style):

- `fine1975critical` — Fine, "Critical Notice of Lewis, Counterfactuals," *Mind* 84(335):451–458, 1975 (the Nixon example).
- `fine2012counterfactuals` — Fine, "Counterfactuals Without Possible Worlds," *Journal of Philosophy* 109(3):221–246, 2012 (imposition, C1–C7, Suppositional Accommodation).
- `fine2012difficulty` — Fine, "A Difficulty for the Possible Worlds Analysis of Counterfactuals," *Synthese* 189(1):29–57, 2012.
- `fine2017truthmakercontent1` — Fine, "A Theory of Truthmaker Content I," *JPL* 46(6):625–674, 2017 (exact semantics, world states).
- `fine2017truthmakersemantics` — Fine, "Truthmaker Semantics," in *A Companion to the Philosophy of Language*, 2017.
- `lewis1973counterfactuals` — Lewis, *Counterfactuals*, 1973.
- `lewis1979timesarrow` — Lewis, "Counterfactual Dependence and Time's Arrow," *Noûs* 13:455–476, 1979.
- `stalnaker1968theory` — Stalnaker, "A Theory of Conditionals," 1968.
- `jackson1977causal` — Jackson, "A Causal Theory of Counterfactuals," *AJP* 55(1):3–21, 1977 (the jump case).
- `kripke1963semantical` — Kripke, "Semantical Considerations on Modal Logic," 1963 (intro framing).
- `goodman1947problem` — Goodman, "The Problem of Counterfactual Conditionals," *J. Phil* 44:113–128, 1947 (wet match, STA).
- Optional (only if the bilattice footnote is kept): `ginsberg1988multivalued`, `fitting1990bilattices`.

Verify all publication details against the paper's own `counterfactual_worlds.bib` (`/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.bib`) at implementation time rather than trusting the above from memory. Already present and reusable: `brastmckie2025counterfactualworlds`, `brastmckie2021identity`, `brastmckie2026possibleworlds`, `vlach1973nowandthen`, `kamp1971formalproperties`, `cresswell1990entities`, `blackburn2000hybrid`.

---

## 9. Risks / Cautions

1. **Scope discipline**: the two chapters together will land at roughly 900–1,400 lines of Typst. Suggested phase split for the planner: (P1) notation file + bibliography + Vlach-chapter label + compile green; (P2) p5-constitutive (it is definitionally self-contained and shorter); (P3) p5-counterfactual sections 1–6 (through CTL + headline S5); (P4) countermodels + Vlach + soundness/limitations; (P5) cross-reference sweep + sync-check + polish. Note P2-before-P3 is *drafting* order (definitions flow downhill) even though *book* order is III-then-IV; forward references from III to IV must be inserted in P3 with the IV labels already fixed by P2.
2. **Do not import Logos notation files wholesale** — `extended-notation.typ` rebinds `taskrel`, `since`, `until`, `falseat`, `mframe` and dozens of others that would shadow or clutter the book's namespace. Copy the needed subset only (Section 7).
3. **The imposition arrow glyph** has no obvious Typst builtin; timebox the experiment and fall back to a composed symbol or subscripted plain arrow with a `notation-env` note.
4. **Axiom-vs-theorem bookkeeping**: in the paper, C1–C7 are axioms and D1–D11/PD11 are derived; in Fine 2012 the triviality axioms D9/D10 are basic. Keep the paper's ledger exactly (the chapter's credibility rests on this bookkeeping being right).
5. **No local Lean anchors exist for Parts III–IV**: every formal claim is paper-sourced or external-Logos-sourced. The chapters must say so in plain prose once, up front (per the task's honesty requirement), instead of per-claim markers (banner system retired).
6. **`#show "TM": strong`** will bold any literal "TM" in new prose — harmless but check unintended hits (e.g., inside words is not matched; standalone "TM" only).
7. **Countermodel transcription errors** are the highest-risk mechanical step (the state assignments at 1119–1126, 1149–1156, 1188–1198 use many fusion letters); transcribe directly from the .tex, not from memory; the #8 world set has a typo in the paper (`W = {a.b.f, c.d.f, e.a.g}` at 1154 lists `e.a.g` while the text writes `γ(x) = a.e.g` — same state, order-insensitive fusion; keep the γ(x) form).
8. **Task 316 (JSONL appendix) and 318 (LK results)** touch other files; no file overlap with this task's scope (`chapters/p5-*.typ`, `notation/constitutive-notation.typ`, `bibliography.bib`, one-line label in `p3-vlach-blstar.typ`, whitelist only if needed).

---

## 10. Recommended Next Action

Proceed to `/plan 317`. The plan should follow the 5-phase split in Risk 1, with per-phase verification = `typst compile` + `scripts/typst-sync-check.sh`, and the content blueprints of Section 3 as the section-by-section specification. All source line anchors in this report were verified this session and can be transcribed from directly.
