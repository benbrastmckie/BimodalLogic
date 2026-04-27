# Teammate D (Horizons): Strategic Analysis — Long-Term Alignment and Phase Specializations

**Task**: #113 — Literature Review for Completeness Techniques
**Role**: Horizons researcher — strategic direction, Phase 3 alignment, long-term goals
**Sources analyzed**: Reynolds 1992, Caleiro-Viganò-Volpe 2013, Xu 1988, Venema 1993, ROADMAP.md

---

## Key Findings

### Finding 1: Doets's Theorem Is the Precise Tool for Task 68 (Dense Completeness)

Reynolds 1992 (Section 8) provides a fully worked statement and proof of Doets's theorem — the exact technique the project needs for task 68 (dense_completeness_fc). The theorem (Reynolds Theorem 6) states:

> Suppose M is a temporal structure in a **finite language** whose flow of time is **countable, dense, and without end points**. Suppose further that for any contemporaneous equivalence relation ~ on M:
> - **D1**: the ~-classes do not end in gaps
> - **D2**: if M/~ is densely ordered, then M/~ has a dense set of singletons
>
> Then for all k < ω, there is a temporal structure with flow of time **the real numbers** satisfying the same monadic first-order sentences of quantifier depth at most k as M does.

**Application to task 68**: The roadmap notes that task 68 needs a separate proof using a dense canonical model (e.g., over Q). The Doets path works as follows:

1. Build a Q-flowed Prior structure M satisfying the target formula (already achievable via the chronicle/Burgess-Xu Corollary 1 with density and no-endpoints axioms added)
2. Verify D1 (no gaps in ~-classes) — follows from Prior-U/Prior-S axioms in any Prior structure (Reynolds Theorem 4)
3. Verify D2 (dense singletons) — follows from the Sep axiom (Reynolds Theorem 5)
4. Apply Doets's theorem to obtain a real-flowed model for the same formulas up to depth k

For the project's purposes, step 4 gives a rational-flowed model (since we want D=Rat completeness, not R), but the technique generalizes: if we want Q-completeness we stop after step 1, and if we want R-completeness we apply Doets.

**Critical prerequisite**: The chronicle construction (task 107) is needed to produce the initial Q-flowed or general linear-flowed Prior structure. Task 68 depends on task 107 being done first.

### Finding 2: Reynolds Provides the Missing Link Between Q and R Completeness

The project's stated ROADMAP goal is "TM is complete with respect to TaskFrames over totally ordered abelian groups." Since totally ordered abelian groups (like Q or R) are dense, the dense completeness track (task 68) is the representation theorem target.

Reynolds 1992 shows a two-step architecture:

- **Step A** (Burgess-Xu + density + no-endpoints): Build a Q-flowed model for any consistent formula. This is exactly what the chronicle construction (task 107) achieves.
- **Step B** (Doets transfer): Promote the Q-flowed model to an R-flowed model using the Prior-U/Prior-S + Sep conditions.

For the ProofChecker project, Step A alone achieves Q-completeness (the representation theorem goal). Step B is a bonus: it would give R-completeness. Reynolds notes (Section 2) that Reynolds's own US/R system adds Prior-U, Prior-S, and Sep on top of the Burgess-Xu base — exactly because those conditions enable the Doets transfer.

**Key implication**: The Burgess-Xu axioms in the project's current axiom system do NOT include Prior-U/S or Sep. This means the chronicle construction achieves general (all strict linear orders) completeness, not R-specific completeness. To get D=Q (or D=R) completeness, the project either (a) restricts to dense models as a separate step or (b) adds density + no-endpoints axioms. This confirms the ROADMAP's structure: task 107 = general completeness (Path A/primary), task 68 = dense completeness (independent track).

### Finding 3: Caleiro-Viganò-Volpe 2013 Provides a Complementary Decidability Path (Not a Completeness Shortcut)

Caleiro et al. prove decidability for S5 + linear tense logic (the same combination as ProofChecker's TM) using the mosaic method. Their main theorem: satisfiability in L(C, ()) is equivalent to existence of a suitable set of mosaics, and for finite C (e.g., density+no-endpoints), this mosaic set is finite.

**What mosaics give**: Decidability and complexity upper bounds. The mosaic approach proves the Finite Model Property (FMP): if a formula is satisfiable, it is satisfiable in a finite-point structure.

**What mosaics do NOT give**: A canonical model construction, a truth lemma, or a structural correspondence between proof-theoretic and semantic notions. The ROADMAP explicitly states: "Decidability-based completeness is explicitly excluded as a path to the representation theorem."

**Alignment with tasks 82 and 998**: The FMP track (task 82) is the right home for the mosaic approach. Caleiro et al. show the mosaic method is modular with respect to density, discreteness, and endpoint conditions (Section 4, "The treatment is strongly modular"), which means their results could directly feed task 82's completeness-via-FMP track if that track is revived.

**Important caveat**: Caleiro et al. work with G/H (always/has-been) operators, NOT U/S (Until/Since). Their language is `{G, H, ∀}`, not `{U, S, □}`. This is a major difference from the ProofChecker project. The mosaic method would need substantial extension to handle Until/Since in the ProofChecker context.

### Finding 4: Xu 1988 Provides the Axiomatic Foundation, Not the Key New Technique

Xu 1988 proves completeness of TL_US(Σ4) for the class of all linear frames (Theorem 3.4, sketched). The six Burgess-Xu axioms in the project's `Axioms.lean` correspond exactly to Xu's Σ4 = {(7), (8), (9), (10), (11)} plus the base axioms (1)-(4) of TL_US(∅).

Xu's technical contribution here is not a new completeness technique — it is a simplification (removing redundant axioms from Burgess's original set) and a generalization to non-linear frames. The core construction method is still Burgess's Henkin-style maximal consistent set construction from [1].

**Strategic value of Xu 1988 for ProofChecker**: Confirms that the BX axiom set in `Axioms.lean` is complete for linear frames. The project's current axiom system (modified for irreflexive semantics) is the right foundation. Xu's incompleteness results (Section 4) also confirm that individual axioms like (10) (BX7/linear_until) are NOT definable from weaker subsets — validating the full 6-axiom Burgess-Xu set as necessary.

### Finding 5: Venema 1993 Provides the Cleanest Orthodox Technique for Well-Orderings (Not Dense)

Venema 1993 achieves completeness for well-orderings (BW system) and natural numbers (BN = BW + D) using Doets's theorem for well-ordered structures. The technique:

1. Prove every BW-consistent formula has a linear model (via Burgess's B-completeness)
2. Show every BW-model is *definably well-ordered* (using expressive completeness: the Stavi connectives reduce U' to ⊥ in BW-models via axiom W)
3. Apply Doets Theorem 3.8 to transfer to a well-ordered model

**Key difference from Reynolds**: Venema uses a different variant of Doets's theorem for well-orderings, while Reynolds uses the dense/real variant. The two are parallel applications of the same meta-technique.

**Alignment with ProofChecker**: The project does NOT need well-ordering completeness (TM is not well-ordered — it uses Z or Q, which have past elements). Venema's technique is therefore not directly applicable to the main completeness goal. However, if the project ever wanted discrete Z-completeness (not currently on the roadmap), Venema's approach is the right template.

---

## Recommended Approach

### For the Primary Goal (Task 107: General Completeness)

**Continue the chronicle construction as planned.** None of the three surveyed papers provides a better technique for the project's primary goal of completeness over all strict linear orders. The chronicle construction is the right approach because:

- It builds a countermodel via controlled PointInsertion, avoiding the Lindenbaum opacity that blocks BXCanonical
- It directly implements Burgess 1982's original proof strategy
- The 13 remaining sorry sites are engineering gaps, not mathematical impossibilities (confirmed in ROADMAP dead end #37)

The literature confirms this is the standard approach: Burgess 1982 (chronicle) -> Xu 1988 (simplified axioms) -> Reynolds 1992 (extended for reals) -> Venema 1993 (for well-orderings). ProofChecker's task 107 is formalizing the first of these.

### For Task 68 (Dense Completeness)

**Use Doets's theorem via Reynolds's framework.** The path is:

1. Complete task 107 (chronicle construction gives general completeness over any sparse linear order)
2. For task 68 specifically: add density and no-endpoints axioms to produce a Q-flowed model from the chronicle
3. Verify the Prior-U/Prior-S conditions on the Q-model (or use the Sep axiom if targeting R-completeness)
4. Apply Doets's transfer theorem to reach the desired representation theorem (D=Q or D=R)

The Lean 4 formalization of Doets's theorem would be a substantial effort (Reynolds's proof spans Sections 5-9, about 20 pages). However, the structure is modular: D1 and D2 follow cleanly from Prior axioms and Sep (Reynolds Theorems 4-5), which could be added as task-68-specific axioms.

**Alternative**: Since the ROADMAP goal is D=Rat (totally ordered abelian groups), the project may be able to achieve this without Doets's full machinery, by working directly over Q from the start and showing the chronicle construction lands in Q. This would be simpler than the full Reynolds approach.

### For Decidability (Tasks 82/998)

**Caleiro et al. is directly applicable but needs language extension.** Their mosaic method works for the {G, H, ∀} language but not {U, S, □}. The extension to Until/Since would require adding mosaic conditions for U/S witnesses (similar to Reynolds's expressive completeness argument). This is a non-trivial but bounded research effort that could unlock decidability for TM independently of completeness.

---

## Evidence and Examples

### Doets's Theorem Prerequisites (Evidence for Task 68 Path)

Reynolds's proof (Section 8) shows:
- The Prior-U/Prior-S axioms ensure D1 (Theorem 4, proof uses contradiction on Prior-U applied to a temporal formula R that indicates gap-endings)
- The Sep axiom ensures D2 (Theorem 5, proof shows every dense quotient must have dense singletons by applying Sep to the left endpoint formula C)
- Together D1+D2 enable the Doets transfer (Theorem 6, proof constructs a shuffle of Q-equivalent structures that is Dedekind complete, dense, without endpoints, and has a countable dense subflow — hence isomorphic to R)

This confirms that the chronicle construction (which produces a Prior structure over a countable dense-without-endpoints order) PLUS the Sep axiom would give R-completeness via Doets.

### Mosaic Modularity (Evidence for Future Decidability Track)

Caleiro et al. (Section 3) define separate vertical mosaics (for temporal dimension) and horizontal mosaics (for modal/equivalence dimension) and show their combination works as long as no interaction between dimensions is present. Their saturation conditions SVDns and SVDdsc (Definition 3.5) cleanly separate dense and discrete specializations. For ProofChecker's TM (which combines temporal and S5-modal), the Caleiro framework applies directly except for the U/S language extension noted above.

### Xu's Axiom Necessity Results (Validation of Current Axiom Set)

Xu Theorem 4.4 shows that {BX8/right-connectedness, BX5'/self_accum_since} do NOT derive BX7/linear_until. This means the six axioms in the project's BX system are genuinely independent and cannot be simplified further. This is important for the project's Lean 4 axiom file: no axiom in Σ4 is redundant.

---

## Strategic Questions — Answers

### Q1: How exactly does Doets's theorem work for task 68?

The theorem (Reynolds Theorem 6) uses three structures: a temporal structure M over Q (built by chronicle/Burgess), and for each ~-class E, a corresponding good structure G_E isomorphic to an interval of R. The proof constructs a "shuffle" — a lexicographic sum over R-many copies of Q-equivalent structures — and shows this shuffle is Dedekind complete, dense, without endpoints, and separable (hence isomorphic to R). This gives an R-flowed structure that satisfies the same monadic sentences as M up to quantifier depth k.

For task 68 (Q-completeness rather than R-completeness), the project stops at the M construction phase — the chronicle lands in Q directly when density and no-endpoints axioms are present.

### Q2: How do Venema's techniques relate to Xu/Reynolds/Caleiro?

Venema 1993 is complementary, not conflicting:
- Xu 1988: completeness for all linear orders (general)
- Venema 1993: completeness for well-orderings and natural numbers (discrete, future-only)
- Reynolds 1992: completeness for reals (dense)
- Caleiro et al. 2013: decidability for S5+tense (all four density/discreteness options, but G/H language only)

The approaches do not conflict because they target different frame classes. Venema's technique (definable well-orderedness + Doets well-ordered variant) is the right approach for discrete completeness over Z or ω, which is NOT the ProofChecker project's goal.

### Q3: Does Caleiro's mosaic approach offer a better/complementary path to decidability?

Complementary, not better. The mosaic approach proves decidability via FMP without constructing a canonical model. This is faster (complexity bounds are obtained directly) but provides no structural correspondence. The ROADMAP correctly identifies this as a decidability tool, not a completeness path. For tasks 82/998, Caleiro is the right reference — but the U/S language extension must be addressed first.

### Q4: Which paper provides techniques specifically for D=Rat completeness?

None of the three papers directly target D=Rat (totally ordered abelian groups). Reynolds targets D=R (reals), Venema targets D=WO (well-orderings) and D=ω (naturals), Caleiro targets general linear orders with density/discreteness options.

However, Reynolds's D=R result uses Q as an intermediate step (Burgess-Xu Corollary 1), and this intermediate Q-flowed model IS the representation theorem target for the ProofChecker project. The first half of Reynolds's proof (up to Corollary 1) is exactly what task 107 is building.

### Q5: Could any paper's framework unify the three phases?

Caleiro et al. 2013 comes closest to a unified framework: their mosaic method is explicitly modular with respect to density, discreteness, and endpoints (Section 1: "the treatment is strongly modular"). A single mosaic framework can prove decidability for all three phases. However:
- This unification is for decidability only, not completeness
- The U/S language extension is needed for all phases
- The ProofChecker project's primary goal is completeness with a structural correspondence, not just decidability

For completeness, the three phases remain separate techniques: chronicle (general), Doets (dense/real), and Venema-Doets (discrete/well-ordered).

### Q6: Should the project continue focusing on the chronicle construction (task 107)?

**Yes, absolutely.** The literature analysis confirms:

1. The chronicle construction is the standard Burgess 1982 approach, directly applicable to the project's axiom system
2. No alternative technique from the surveyed literature provides a better path to general completeness over all strict linear orders
3. The 13 remaining sorry sites in the chronicle are engineering gaps (confirmed in ROADMAP), not mathematical impossibilities
4. Dense completeness (task 68) depends on the chronicle construction succeeding first — it adds a Doets-transfer step after the general construction

The highest-priority action for the project is to close the 13 chronicle sorry sites in task 107. Once that succeeds, task 68 becomes the natural next step using the Reynolds-Doets framework.

---

## Confidence Level

**High confidence** on the following:
- Doets's theorem is the right technique for task 68, and Reynolds 1992 provides a worked template
- The chronicle construction (task 107) is the correct primary path with no better alternative in this literature
- Caleiro et al. is relevant to decidability (tasks 82/998) but not to the primary completeness goal
- Xu 1988 confirms the BX axiom set is correct and minimal for linear frame completeness
- The three phases (general, dense, discrete) require genuinely different techniques and cannot be fully unified

**Medium confidence** on:
- Whether the project needs the full Doets machinery for D=Rat completeness, or whether working directly over Q from the start is simpler (the ROADMAP suggests the latter but does not fully specify the path)
- Whether the Caleiro U/S extension effort is within scope for the current project phase

**Low confidence** on:
- Whether Prior-U/Prior-S axioms should be added to the TM axiom system to enable R-completeness (this would change the project's axiom set and may not be desirable)
- Specific Lean 4 formalization challenges for Doets's theorem (requires more detailed study of the proof structure)
