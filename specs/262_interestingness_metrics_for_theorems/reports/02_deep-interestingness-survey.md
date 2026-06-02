# Deep Research Report: Interestingness Metrics for Theorems -- Literature and Design Survey

- **Task**: 262 - Interestingness Metrics for Theorems
- **Started**: 2026-06-02T14:00:00Z
- **Completed**: 2026-06-02T15:30:00Z
- **Effort**: high (12-20 hours)
- **Dependencies**: 01_interestingness-metrics.md (Round 1 report)
- **Sources/Inputs**: See Section 12 (References) -- extensive web research covering 40+ sources
- **Artifacts**: specs/262_interestingness_metrics_for_theorems/reports/02_deep-interestingness-survey.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## 1. Executive Summary

This deep-dive report extends the Round 1 survey with an extensive literature review covering the full landscape of interestingness measures in automated mathematical discovery, modal/temporal logic-specific considerations, and practical reward signal design for RL-based theorem provers. The key findings are:

1. **Philosophical foundations** (Hardy, Lakatos, Schmidhuber) converge on a small number of core principles: significance arises from connectedness to other ideas, surprise from compression progress, and beauty from the combination of unexpectedness, inevitability, and economy.

2. **Operational systems** (HR, Graffiti/TxGraffiti, MATHsAiD, IsaCoSy/Hipster, FERMAT) have developed concrete, computable interestingness measures that fall into three families: syntactic complexity, empirical informativeness, and proof-structural richness.

3. **Modal/temporal logic** provides domain-specific interestingness criteria not captured by generic measures: frame correspondence (Sahlqvist theorems), cross-modal interaction depth, admissible-but-underivable rules, and the distinction between trivially valid, routinely valid, and deeply valid formulas.

4. **Modern RL reward design** (AlphaProof, DeepSeek-Prover, HTPS, STP, SPEED-RL) has converged on binary correctness rewards augmented with curriculum difficulty signals, where intermediate-difficulty problems maximize the gradient signal-to-noise ratio.

5. **Quality-diversity approaches** (MAP-Elites in AlphaEvolve, novelty search) offer a direct paradigm for theorem discovery: maintain a diverse archive of solutions across behavioral dimensions rather than optimizing a single scalar reward.

6. A **concrete three-tier scoring architecture** is proposed: fast syntactic gate, proof-structural score, and domain-specific modal/temporal bonus. This architecture can serve simultaneously as training filter, RL reward signal, and curriculum ordering.

---

## 2. Philosophical Foundations of Mathematical Interestingness

### 2.1 Hardy's Criteria (1940)

G.H. Hardy's "A Mathematician's Apology" articulated criteria that remain the implicit standard by which mathematicians judge results. Hardy identified two essential qualities of serious mathematics:

**Generality**: A significant idea "can be connected, in a natural and illuminating way, with a large complex of other mathematical ideas." Generality has three components: (a) the idea functions in many mathematical constructs, (b) a theorem, "even if stated originally in a quite special form, is capable of considerable extension and is typical of a whole class of theorems," and (c) the relations revealed by the proof connect many different mathematical ideas.

**Depth**: Hardy acknowledged depth as "still more difficult to define" than generality. He suggested mathematical ideas exist in stratified layers, with deeper ideas typically harder to grasp. Depth involves fundamental structural concepts (like irrationality) rather than elementary ones (like divisibility).

**Beauty**: For proofs, Hardy emphasized "a very high degree of unexpectedness, combined with inevitability and economy." A beautiful proof surprises with intriguing connections between disparate areas while feeling, in retrospect, like the only natural path.

**Significance vs. Triviality**: Hardy distinguished "serious" from "trivial" mathematics by whether the ideas possess appreciable connectedness to distinctly different mathematical domains. A result that stands isolated, connecting to nothing else, is trivial regardless of its difficulty.

**Implications for our metrics**: Hardy's criteria map to: Lemma Utility (connectedness/generality), Proof Depth Ratio (depth), Structural Novelty (unexpectedness), and Operator Diversity (breadth of cross-domain connection). The isolation criterion directly supports our Semantic Non-Triviality gate.

### 2.2 Lakatos's Proofs and Refutations (1976)

Imre Lakatos's philosophical framework treats mathematical development as a dialectical process rather than monotonic accumulation of truths. His key methodological concepts:

**Monster-barring**: When a counterexample appears to a conjecture, one response is to declare the counterexample illegitimate ("not a real polyhedron"). This is the most conservative response and indicates the conjecture boundary needs clarification, not that the result is uninteresting.

**Exception-barring**: Modify the conjecture to exclude known counterexamples while preserving the core insight. The resulting, more carefully stated theorem is often more interesting than the original.

**Lemma-incorporation**: The most productive response -- analyze *why* the counterexample works, extract a structural lemma capturing the essential property, and incorporate it into the proof. This creates genuinely new mathematical knowledge.

**Proof-generated concepts**: The most interesting mathematical concepts arise not from definitions but from proofs -- when the proof itself reveals what the "right" definition should be. In our context, theorems that require novel proof techniques or reveal unexpected structural connections between the modal and temporal components of TM are intrinsically more interesting.

**Implications for metrics**: Lakatos's framework suggests interestingness is inherently *relational* -- a theorem is interesting in the context of what was known before. This supports the Structural Novelty dimension and suggests we should track how a theorem extends or refines the known theory, not just its absolute complexity.

### 2.3 Schmidhuber's Compression Progress (2008)

Juergen Schmidhuber proposed a unifying principle: all subjective experiences of beauty, novelty, surprise, interestingness, curiosity, and creativity emerge from "compression progress" -- the improvement of the observer's internal compressor of its data.

**Core definition**: Interestingness is the *first derivative* of subjective beauty (compressibility). Data becomes temporarily interesting when an observer learns to compress it better, making it subjectively simpler. The steeper the improvement in compression rate, the stronger the intrinsic reward.

**Key distinction from Shannon surprise**: Traditional information-theoretic surprise (high entropy, low probability) is *not* the same as interestingness. Random noise has maximal Shannon entropy but zero interestingness because it permits no compression progress. Interestingness requires *learnable regularity* -- data that is initially complex but becomes simpler once the right pattern is recognized.

**Formal definition**: For an agent with compressor C at time t, the interestingness of datum d is approximately:

```
I(d, t) = C_t(d) - C_{t+1}(d)
```

where C_t(d) is the compressed length of d at time t. Positive values indicate the agent learned something from d.

**Implications for our metrics**: This provides a principled foundation for why "almost-valid" invalid formulas (high countermodel complexity) and "surprising" valid formulas (unexpected validity given their structure) are interesting. It also suggests that interestingness is context-dependent: a formula that teaches the system something new about the logic is more interesting than one that confirms what is already known.

---

## 3. Operational Systems for Automated Mathematical Discovery

### 3.1 Colton's HR System (1999-2007) -- Detailed Analysis

The HR system (named after Hardy and Ramanujan) performs automated theory formation in pure mathematics. Its interestingness framework is the most fully articulated of the classical systems.

**Concept Interestingness**: HR evaluates concepts using a weighted sum of normalized measures, each valued between 0 and 1:

```
I(concept) = w1*novelty + w2*applicability + w3*comprehensibility + w4*surprisingness + w5*plausibility
```

The specific measures:

1. **Novelty**: Fraction of entities with a *different* example classification than any previously seen concept. A concept that classifies entities in a genuinely new way scores high.

2. **Applicability**: Ratio of positive to total examples. A concept that applies broadly scores higher than one applying to a single example.

3. **Comprehensibility**: Inverse of the syntactic complexity (number of construction steps). Favors concepts that can be stated simply.

4. **Surprisingness**: Deviation between the concept's empirical behavior and what would be predicted based on related concepts. Specifically, if a conjecture relates concept A to concept B, the surprisingness is measured by how different the example sets of A and B are -- a conjecture linking apparently unrelated concepts is more surprising.

5. **Plausibility**: Based on empirical evidence -- primarily, the absence of counterexamples in the current database.

**Conjecture scoring**: A weighted sum of surprisingness and difficulty (proof length from the Otter theorem prover) assigns a value between 0 and 1 to each theorem. The average score for conjectures involving a concept then feeds back to order concepts themselves.

**Users set weights** depending on the type of theory they seek. For exploring a new domain, high novelty weights produce more diverse theories. For consolidating known results, high applicability and plausibility weights focus on well-supported generalizations.

### 3.2 Graffiti and TxGraffiti (1986-present)

Fajtlowicz's Graffiti is one of the earliest automated conjecturing systems and introduced the most influential filtering heuristic in the field.

**Architecture**: Graffiti operates on a finite database of mathematical objects (primarily graphs) and a library of numerical invariants. It generates candidate conjectures expressing relationships between invariants (typically inequalities like "independence number <= chromatic number * 2") and retains those that hold for all objects in the database.

**The Dalmatian Heuristic**: The breakthrough innovation that solves the "Sorcerer's Apprentice Problem" (being overwhelmed by true but trivial statements). A conjecture is retained only if it provides a *sharper bound for at least one object* than any existing conjecture. This operationalizes the idea that an interesting conjecture must add genuinely new information.

**TxGraffiti's Refinements** (Davila 2017-present): The modern successor implements a two-stage filtering pipeline:

1. **Truth screen**: Only candidates with no counterexample in the current database survive.

2. **Significance screen (Static-Dalmatian)**: A conjecture qualifies as significant if it "touches at least one previously untouched object" -- i.e., it provides an equality witness (bound achieved with equality) not explained by any previously accepted conjecture. The system maintains a running coverage set and accepts candidates that expand this set.

**Touch Number**: The primary ranking metric -- the count of objects where a bound holds with equality. Higher touch numbers indicate the bound is tight for more objects, making the conjecture more informative.

**Implications for our metrics**: The Dalmatian heuristic provides an excellent model for our Structural Novelty dimension. A theorem is interesting only if it provides *new information* not already captured by existing theorems in the corpus. This can be operationalized as: the theorem proves something about some formula or proof pattern that no existing theorem addresses.

### 3.3 MATHsAiD (McCasland, Bundy, Smith, 2003-2017)

MATHsAiD (Mathematics by Automated Reasoning, Heuristic Search, and Intelligent Discovery) automatically conjectures and proves theorems from user-supplied axioms and definitions.

**Key capabilities**: Unlike HR (which focuses on concept formation) or Graffiti (which focuses on numerical invariant relationships), MATHsAiD discovers theorems relating multiple mathematical theories -- a capability rare in automated theorem provers. MATHsAiD 2.0 proved a key theorem from one of the researchers' own papers, demonstrating it can discover results of publication-level quality.

**Relevance**: MATHsAiD's ability to discover cross-theory results maps directly to our interest in bimodal theorems that connect S5 modal reasoning with temporal logic reasoning -- precisely the theorems scoring highest on Operator Diversity and Axiom Layer Diversity.

### 3.4 IsaCoSy and Hipster (Johansson et al., 2009-2014)

**IsaCoSy's irreducibility criterion**: Only generates terms that cannot be simplified by existing equational reasoning. This is a negative filter: a conjecture is interesting only if it is NOT trivially reducible by known facts.

**Hipster's two-tier strategy**: Takes two reasoning strategies as parameters -- "routine reasoning" and "hard reasoning." Conjectures provable by routine reasoning alone are *discarded* as uninteresting. Only conjectures requiring hard reasoning (but still provable) are reported to the user. Furthermore, Hipster tries more general conjectures first, filtering out many specific routine results.

**Implications**: This two-tier approach directly informs our Proof Depth Ratio dimension. Theorems with proof height 0 (direct axiom match) are exactly the "routine reasoning" tier that Hipster would discard. Our scoring system should implement an analogous gate: height-0 proofs receive minimal interestingness regardless of other dimensions.

### 3.5 FERMAT (NeurIPS 2025 Spotlight) -- Detailed Analysis

FERMAT introduces an RL environment for concept discovery with an LLM-based evolutionary algorithm (EvoAbstract) for *learning* interestingness measures, rather than hand-coding them.

**Intrinsic reward function**: I(m, S) maps a mathematical entity m and the current theory state S to a real-valued score. The key insight is that interestingness is context-dependent -- the same entity may be interesting in one theory state and uninteresting in another.

**Baseline measures (reimplemented from HR)**:
1. **Novelty**: Fraction of entities with the same example classification (lower = more novel)
2. **Parsimony**: Inverse of syntactic size -- size(m)^{-1}
3. **Productivity**: How many subsequent environment steps use that entity (downstream utility)
4. **Applicability**: Ratio of positive to total examples (generality)
5. **Comprehensibility**: Inverse of construction steps (accessibility)

**EvoAbstract algorithm**: Three iterative phases:
1. **Evolution**: An LLM generates candidate scoring programs by mutating high-performing parents, across k=4 parallel populations
2. **Abstraction**: A second LLM analyzes elite programs to extract reusable subroutines, building dynamic libraries for compositional program synthesis
3. **Policy evaluation**: Candidate scoring functions guide theory formation across 16 episodic rollouts, generating reward signals for evolutionary selection

**Ground truth evaluation**: 180 concepts from elementary number theory textbooks (from reflexive properties to the Goldbach conjecture) and 67 domain-specific entities from finite field theory (F_27).

**Key result**: Learned interestingness measures outperform all hand-coded baselines, demonstrating that the "right" interestingness function is domain-specific and hard to hand-engineer.

**Implications**: For our project, FERMAT validates the approach of starting with hand-coded metrics (our 8-dimension taxonomy) while recognizing these should eventually be learned. The EvoAbstract paradigm could be applied to learn interestingness functions for bimodal logic specifically, using our named theorems as ground truth.

---

## 4. Modern RL Reward Signals for Theorem Proving

### 4.1 AlphaProof (Google DeepMind, 2024-2025)

AlphaProof is an AlphaZero-inspired agent that learns formal proofs through RL, achieving silver-medal performance at the 2024 IMO.

**Reward signal**: Binary -- 1 for a correct (Lean-verified) proof, 0 otherwise. The key advantage of theorem proving as an RL domain: "step-wise semantic verification with minimal ambiguity, enabling denser rewards and substantially easing long-horizon credit assignment."

**Training curriculum**: AlphaProof trains on millions of auto-formalized problems, suggesting that diversity of training problems (not just difficulty) is important for developing general proving capability.

**Implication**: The pure binary reward works for AlphaProof because it has enormous compute. For our project with more modest resources, augmenting binary correctness with interestingness-based shaping rewards could improve sample efficiency.

### 4.2 HyperTree Proof Search / HTPS (Lample et al., NeurIPS 2022)

HTPS learns from previous proof searches through online training. Its reward structure uses proof completion as the primary signal, but the search algorithm (inspired by AlphaZero's MCTS) incorporates a learned value function that estimates the probability of eventually closing a proof from the current state.

**Key insight**: The value function effectively learns a "proof progress" measure -- goals that are closer to being closed receive higher value estimates, creating a dense reward signal from sparse binary outcomes.

### 4.3 DeepSeek-Prover V1.5 (2024)

**Reward**: Binary correctness (1 if proof verified by Lean, 0 otherwise). Uses Group Relative Policy Optimization (GRPO) which eliminates the need for a separate critic model.

**RMaxTS**: A Monte-Carlo tree search variant with intrinsic-reward-driven exploration. The intrinsic reward comes from *new tree node expansion* in the proof search tree, serving as a proxy for extrinsic reward. This novelty-seeking behavior encourages diverse proof attempts.

**Implication**: The intrinsic reward from search tree expansion maps to our concept of Structural Novelty -- proofs that explore new regions of the proof space are more valuable for training.

### 4.4 Self-play Theorem Prover / STP (2025)

STP introduces a self-play paradigm where the system simultaneously plays two roles: **conjecturer** (generating theorems to prove) and **prover** (proving them). Each provides training signals to the other.

**Curriculum mechanism**: The conjecturer is trained iteratively on previously generated conjectures that are *barely provable* by the current prover. This creates a dynamic curriculum that automatically adjusts difficulty.

**Connection to interestingness**: "Barely provable" corresponds roughly to SPEED-RL's theoretical result that intermediate-difficulty prompts maximize the gradient signal-to-noise ratio. For our system, formulas that lie near the boundary of the prover's current capability are the most useful for training.

### 4.5 SPEED-RL (2025)

**Theoretical contribution**: For the RLOO estimator with N rollouts, the signal-to-noise ratio (SNR) has an upper bound of 4N * P_x(theta) * (1 - P_x(theta)), where P_x(theta) is the pass rate. This approaches zero as difficulty approaches 0 or 1, with the maximum at P_x = 0.5 (50% pass rate).

**Practical result**: Focusing RL training exclusively on moderately challenging prompts yields 2x to 6x faster training without degrading accuracy.

**Implications for our metrics**: This provides strong theoretical justification for a curriculum-based approach where interestingness scores are used to select training examples of intermediate difficulty. The "goldilocks zone" for training is theorems that the current model proves about half the time.

### 4.6 LeanProgress (2025)

LeanProgress predicts how many steps remain to complete a proof, achieving 75.8% prediction accuracy. This proof-progress signal provides a continuous reward for RL agents, rather than sparse binary completion.

**Relevance**: The remaining-steps prediction is closely related to our Proof Depth Ratio -- theorems requiring more steps are harder and (up to a point) more interesting. LeanProgress could potentially be adapted to predict an interestingness score directly.

### 4.7 LeanConjecturer (2025) and LeanNavigator (2025)

**LeanConjecturer**: A pipeline for generating mathematical conjectures in Lean 4 using LLMs. From 40 Mathlib seed files, produced 12,289 conjectures, with 3,776 syntactically valid and non-trivial (cannot be proven by `aesop`). The "cannot be proven by aesop" criterion is a concrete operationalization of non-triviality.

**LeanNavigator**: Constructs a state transition graph from existing proofs and explores alternative proof paths, generating 4.7 million theorems (1 billion tokens) from Mathlib4. The key insight: the graph structure reveals which theorems are "hubs" (connected to many proof paths) and which are "endpoints" -- hub theorems have higher Lemma Utility.

---

## 5. Quality-Diversity and Novelty Search Paradigms

### 5.1 MAP-Elites for Mathematical Discovery

MAP-Elites (Multi-dimensional Archive of Phenotypic Elites) maintains a grid of solutions, where each cell represents a unique behavior characterization and contains the highest-performing solution with that behavior. This produces a diverse collection of high-quality solutions.

**AlphaEvolve** (Google DeepMind, May 2025) uses MAP-Elites as its core search algorithm. It discovered novel algorithms across 50+ open mathematical problems, matching best-known results in ~75% of cases and *exceeding* them in ~20%. The breakthrough was a 4x4 complex matrix multiplication algorithm using 48 scalar multiplications, breaking Strassen's 56-year-old record of 49.

**Application to theorem discovery**: In our context, MAP-Elites dimensions could be:
- **Behavioral dimension 1**: Operator diversity profile (which operators appear)
- **Behavioral dimension 2**: Proof depth / complexity tier
- **Behavioral dimension 3**: Axiom layer usage pattern (propositional, modal, temporal, interaction)

Each cell would contain the "best" (highest interestingness) theorem with that particular behavioral profile. This ensures diversity: even a lower-complexity theorem is retained if it occupies a behavioral niche not covered by more complex theorems.

### 5.2 Novelty Search

Novelty search (Lehman and Stanley, 2011) abandons objective-based optimization entirely, rewarding only behavioral novelty -- how different an individual's behavior is from all previously seen behaviors. This has been shown to sometimes outperform objective-based search because it avoids deceptive local optima.

**Application to theorem discovery**: A novelty-only search would generate formulas maximally different from all known theorems in terms of their structural features. Combined with a validity filter, this could produce surprising valid formulas that fall in unexplored regions of formula space.

---

## 6. Modal and Temporal Logic-Specific Interestingness

### 6.1 Frame Correspondence as Interestingness Signal

The Sahlqvist correspondence theorem identifies a class of modal formulas that correspond to first-order conditions on Kripke frames. This provides a powerful domain-specific interestingness criterion:

**Correspondence-bearing theorems** are inherently more interesting because they connect the syntactic level (modal formulas) to the semantic level (frame properties). Key examples in the TM logic:
- `Box phi -> phi` (Modal T) corresponds to reflexivity of accessibility
- `Box phi -> Box (Box phi)` (Modal 4) corresponds to transitivity
- `phi -> Box (Diamond phi)` (Modal B) corresponds to symmetry
- `Diamond (Box phi) -> Box (Diamond phi)` (Church-Rosser) corresponds to confluence of accessibility

**Sahlqvist formulas for LTL** (Li and Belardinelli, 2022): This extension identifies LTL Sahlqvist formulas built using temporal operators F, G, X, and U, proving they correspond to first-order frame conditions. This is directly relevant to TM logic where both modal and temporal operators interact.

**Scoring implication**: Theorems that can be shown to correspond to frame properties should receive a significant bonus. The FrameConditions module already in the codebase (`Theories/Bimodal/FrameConditions/`) provides infrastructure for checking these correspondences.

### 6.2 S5-Specific Interestingness

S5 modal logic has a distinctive feature: iterated modalities collapse. In S5, any string of boxes and diamonds is equivalent to the last operator in the string. This creates a clear hierarchy of formula interestingness:

**Level 0 -- Trivially valid**: Formulas valid in *any* modal logic (propositional tautologies with vacuous modal operators), or valid by simple axiom schemas (ex_falso, identity).

**Level 1 -- S5-routine**: Formulas exploiting modal collapse (e.g., `Diamond (Box phi) -> Box phi` follows directly from S5 iteration collapse). These are interesting in weaker modal logics but routine in S5.

**Level 2 -- Genuinely S5**: Formulas that require the full strength of S5 (reflexivity + transitivity + symmetry) in their proofs but do not involve temporal operators. Examples: `Box phi -> Diamond phi` (requires T), the consistency theorem `not (Box (A and not A))`.

**Level 3 -- Cross-modal**: Formulas involving both modal and temporal operators where the interaction axiom (modal_future: `Box phi -> G(Box phi)`) plays an essential role. The perpetuity principles (P1-P5) are canonical examples, with P5 (`Diamond(Sometimes phi) -> Always(Diamond phi)`) at the apex of complexity.

**Interaction depth**: A useful S5+temporal metric is the number of times the proof must switch between modal reasoning and temporal reasoning. A proof that uses only modal axioms or only temporal axioms is less interesting than one that repeatedly alternates between both.

### 6.3 Temporal Logic Property Patterns (Dwyer et al.)

Dwyer et al. (1999) conducted a large-scale study of 500+ temporal specifications and found that over 90% fall into a small number of patterns: absence, existence, bounded existence, universality, precedence, and response. These patterns define what practitioners actually care about in temporal logic:

**Pattern-matching theorems**: Theorems that prove general facts about common specification patterns are inherently useful. For TM logic, theorems connecting these LTL patterns to modal properties would be highly interesting.

**Pattern hierarchy**: Simpler patterns (absence: `G(not phi)`, existence: `F phi`) are less interesting than composite patterns (response: `G(phi -> F psi)`, chain response: `G(phi -> F(psi -> F chi))`).

**Implications**: Our Operator Diversity metric partially captures this, but we should add explicit recognition of known temporal logic specification patterns. Theorems involving Until and Since in conjunction with modal operators are more interesting than those using only the derived operators G, F, H, P.

### 6.4 Bimodal Fusion and Interaction Axioms

When combining two modal logics (fusion), the resulting logic is the *least* system containing both components. The critical question is what **interaction axioms** (bridge principles) hold between the modalities.

**Conservativity**: The fusion of M and N is conservative over each component -- any theorem in the language of M alone that is provable in the fusion was already provable in M. This means: theorems in the fusion that involve *only one* modality type are routine (inherited from the component logic). Genuinely interesting fusion theorems *must* involve both modalities.

**TM's interaction axiom**: The modal_future axiom `Box phi -> G(Box phi)` ("what is necessary is always necessary") is the sole bridge principle in TM logic. Theorems whose proofs require this axiom are inherently interesting because they exploit the specific way modal and temporal reasoning interact in TM.

**Non-axiomatizable interactions**: Some bimodal combinations produce undecidable or non-finitely-axiomatizable logics. The fact that TM is decidable and finitely axiomatizable (via the BX system with modal_future) is itself an interesting metalogical result. Theorems that exercise the full power of the axiom system without requiring additional interaction axioms are especially interesting.

### 6.5 Admissible Rules and Structural Completeness

An inference rule is **admissible** in a logic if adding it does not increase the set of theorems -- every formula derivable with the new rule was already derivable without it. The rule is **derivable** if there is a proof of the rule's conclusion from its premises using existing axioms.

**Admissible but underivable rules** are inherently interesting: they reveal structural properties of the logic that are not explicit in the axiom system. For classical propositional logic, all admissible rules are derivable (structural completeness). But for many modal logics, this is not the case.

**Rybakov's contributions**: Showed that admissibility is decidable for S4 and many transitive modal logics, but that there is no finite basis of admissible rules for S4 or intuitionistic logic.

**S5 specifics**: S5 is structurally complete (all admissible rules are derivable). This means admissible rules are less interesting *within* S5, but the situation may differ for the TM fusion -- the temporal component could introduce admissible-but-underivable rules that exploit the interaction between modalities.

**Scoring implication**: While we cannot easily detect admissible rules computationally, theorems that reveal structural properties of the logic (conservation results, interpolation properties, definability results) should receive bonus interestingness.

### 6.6 Craig Interpolation

The Craig interpolation property states: if phi implies psi, there exists an interpolant beta in the common language of phi and psi such that phi implies beta and beta implies psi. This is a "deep harmony between syntax and semantics."

**Modal logic**: Many modal logics enjoy Craig interpolation, but not all. Notably, Priorean temporal logics (with both past and future modalities) over standard time flows do *not* have Craig interpolation. This is directly relevant to TM logic.

**Interestingness connection**: Theorems about which fragments of TM have interpolation, or explicit interpolants for known valid implications, are structurally significant. A theorem phi -> psi where no "simple" interpolant exists is more interesting than one where the interpolant is obvious.

### 6.7 The McKinsey Axiom and Church-Rosser Property

**McKinsey axiom** (`Box(Diamond phi) -> Diamond(Box phi)`): Notable because it has no first-order frame condition -- it cannot be expressed as a condition on individual accessibility relations. However, the conjunction of McKinsey with Modal 4 *does* have a first-order frame condition but is not equivalent to any Sahlqvist formula. This makes it a paradigmatic example of structural interest in modal logic.

**Church-Rosser property** (`Diamond(Box phi) -> Box(Diamond phi)`): Corresponds to confluence of the accessibility relation. In multimodal settings, Church-Rosser style properties capture diamond-like commutativity between modalities, which is precisely the kind of cross-modal interaction that makes bimodal theorems interesting.

**Barcan formula** (`forall x. Box phi(x) -> Box(forall x. phi(x))`): In quantified modal logic, this relates quantification scope and modality scope. Its frame condition involves domain inclusion across accessible worlds. While our propositional TM logic does not have quantifiers, the *spirit* of the Barcan formula -- scope interactions between operators -- applies to nested modalities and temporalities.

---

## 7. Information-Theoretic and Complexity-Theoretic Perspectives

### 7.1 Kolmogorov Complexity of Proofs

The Kolmogorov complexity K(x) of a string x is the length of the shortest program that outputs x. Applied to proofs:

**Proof complexity**: K(proof) measures how compressible a proof is. A highly compressible proof (low K relative to its length) has repetitive structure -- less interesting. An incompressible proof (K close to its length) is "maximally complex" -- but this could mean either genuinely deep or merely random/unstructured.

**The ratio K(proof) / K(theorem)**: The most interesting theorems have simple statements but complex proofs. This is the "compression ratio" of proof to theorem. Hardy's criteria of "unexpectedness" and "depth" map directly to this ratio being high.

**Practical approximation**: We cannot compute Kolmogorov complexity, but we can approximate it via:
- Proof length / formula complexity (our Proof Depth Ratio)
- Number of distinct axioms and rules used (our Proof Rule Diversity)
- Gzip compression ratio of the proof text (a practical Kolmogorov proxy)

### 7.2 Proof Complexity Theory (Razborov, Pudlak)

Proof complexity studies the minimum resources needed to prove a given tautology in a specific proof system. Key measures:

**Proof length** (total number of steps): The number of inference rule applications. Lower bounds on proof length indicate inherent difficulty.

**Proof depth** (longest path from root to leaves): Corresponds to the sequential complexity of the proof.

**Proof width** (maximum number of formulas in working memory): Corresponds to the space complexity of verification.

**Ben-Sasson and Wigderson's result**: For Resolution proofs, lower bounds on proof size reduce to lower bounds on proof width. The width-complexity tradeoff is fundamental -- proofs cannot be simultaneously short and narrow.

**Size-width tradeoffs**: The relationship between different proof complexity measures reveals structural properties of the proof. Theorems requiring proofs that are simultaneously deep AND wide (high in both dimensions) are the most genuinely complex.

**Application to TM**: Our proof traces record height (depth) and could be extended to record width (maximum context size during proof search). Theorems with high values in both dimensions would score higher on interestingness.

### 7.3 The "Matter of Interest" Study (2025)

A recent empirical study collected 822 interestingness judgments from 111 participants (high school to IMO level) on mathematical problems:

**Top human criteria for interestingness**:
1. "The problem statement is simple and elegant"
2. "The solution does not require sophisticated techniques/theorems"
3. "The solution is elegant"

**Critical finding**: Humans showed only moderate correlation (mean R-squared = 0.47) between interestingness and difficulty ratings, confirming these are distinct dimensions. Being hard is neither necessary nor sufficient for being interesting.

**LLM-human alignment**: Language models achieved R-squared values from 0.48 to 0.78 with human judgments on interestingness, with Mistral models performing strongest. But most LLMs failed to capture the *variability* in human responses -- they produced overly uniform interestingness ratings.

**Implications**: This empirical evidence supports our design choice to separate difficulty (Proof Depth Ratio) from interestingness (composite score). It also suggests that elegance/simplicity of the *statement* should be rewarded alongside proof complexity -- a theorem with a simple, clean statement but a deep proof is more interesting than one with an equally deep proof but an opaque, complex statement.

---

## 8. Synthesis: A Refined Scoring Architecture

Based on the deep literature survey, we refine the Round 1 taxonomy into a three-tier architecture with domain-specific enhancements.

### 8.1 Tier 1: Fast Syntactic Gate (O(n), no proof required)

These metrics can be computed on formula structure alone and serve as a fast pre-filter:

| Metric | Computation | Threshold |
|--------|-------------|-----------|
| **Semantic Non-Triviality (SNT)** | Pattern match against trivial templates | SNT=0 -> reject entirely |
| **Operator Diversity (OD)** | AST traversal counting operator types | OD >= 2 for "potentially interesting" |
| **Statement Simplicity (SS)** | Formula complexity / subformula count | Penalize excessively complex statements |
| **Modal-Temporal Interaction (MTI)** | Boolean: does formula use both modal AND temporal operators? | MTI=true gets bonus |

**New metric -- Statement Simplicity (SS)**: Motivated by the "Matter of Interest" study and Hardy's "economy." A clean, simple statement with a deep proof is more interesting than a verbose statement with an equally deep proof. Computed as the inverse of formula complexity normalized by the number of distinct atoms.

**Gate logic**: If SNT = 0, the formula is rejected regardless of other scores (multiplicative gating from Round 1, confirmed by all literature). If OD < 2, the formula enters a "low-interest" track where it can still score modestly on other dimensions but has a maximum composite score of 0.3.

### 8.2 Tier 2: Proof-Structural Score (O(proof_size), requires proof trace)

These metrics require a completed proof and capture the intrinsic interest of the proof itself:

| Metric | Computation | Weight |
|--------|-------------|--------|
| **Proof Depth Ratio (PDR)** | proof_height / formula_complexity | 0.20 |
| **Proof Rule Diversity (PRD)** | distinct_rule_types / total_rule_types | 0.15 |
| **Axiom Layer Diversity (ALD)** | distinct_axiom_layers / 4 | 0.20 |
| **Proof Incompressibility (PI)** | distinct_subgoals / total_steps (approximation) | 0.10 |

**New metric -- Axiom Layer Diversity (ALD)**: Separated from PRD based on the insight from bimodal/fusion logic literature that cross-layer reasoning is the hallmark of genuinely interesting bimodal theorems. The 4 layers are: propositional, S5 modal, BX temporal, modal-temporal interaction. A proof touching all 4 layers receives ALD = 1.0.

**New metric -- Proof Incompressibility (PI)**: Approximates the Kolmogorov complexity insight. A proof where every step introduces a genuinely new subgoal (no repeated patterns) has PI near 1.0. A proof that repeats the same pattern many times (e.g., iterated modus ponens on similar subformulas) has low PI.

### 8.3 Tier 3: Domain-Specific and Relational Metrics

These metrics capture modal/temporal logic-specific interestingness and relational novelty:

| Metric | Computation | Weight |
|--------|-------------|--------|
| **Frame Correspondence Bonus (FCB)** | Does the theorem correspond to a known frame property? | +0.15 bonus |
| **Interaction Axiom Dependency (IAD)** | Does the proof require modal_future? | +0.10 bonus |
| **Structural Novelty (SN)** | Minimum distance to nearest known theorem | 0.15 |
| **Lemma Utility (LU)** | Appearance frequency in other proofs | 0.10 |
| **Specification Pattern Match (SPM)** | Does the theorem match a Dwyer pattern? | +0.05 bonus |

**New metric -- Frame Correspondence Bonus (FCB)**: If we can determine that a theorem corresponds to a frame condition (using the FrameConditions infrastructure), it receives a significant bonus. This captures the Sahlqvist-correspondence insight.

**New metric -- Interaction Axiom Dependency (IAD)**: Checks whether modal_future (or its consequences) is required in the proof. This is the single interaction axiom in TM, and theorems that exercise it are inherently bimodal rather than merely the union of separate modal and temporal results.

### 8.4 Composite Score Formula

For valid formulas:

```
score(phi) = SNT_gate * (
    Tier2_score(phi) +
    Tier3_bonus(phi) +
    0.10 * statement_simplicity(phi)
)
```

where:
- `SNT_gate` is 0.0 if SNT=0 (trivially valid), 0.5 if SNT=1 (propositional tautology), 1.0 otherwise
- `Tier2_score = 0.20*PDR + 0.15*PRD + 0.20*ALD + 0.10*PI` (weighted sum, normalized to [0,1])
- `Tier3_bonus = 0.15*SN + 0.10*LU + FCB + IAD + SPM` (bonuses added when applicable)

For invalid formulas:
```
curiosity_score(phi) = countermodel_complexity * statement_simplicity(phi)
```
This captures "almost-valid" formulas as interesting negative examples.

### 8.5 Tier Classification (Revised)

| Score Range | Tier | Characterization | Example |
|-------------|------|-------------------|---------|
| 0.00 - 0.05 | trivial | Ex falso, identity, weakening | `bot -> Box phi` |
| 0.05 - 0.15 | routine | Propositional tautologies with modal dress | `Box phi -> Box phi` |
| 0.15 - 0.30 | basic | Direct axiom instances with modal content | `Box phi -> phi` |
| 0.30 - 0.50 | moderate | Single-rule derived results | `Box phi -> Diamond phi` |
| 0.50 - 0.70 | notable | Multi-step proofs, some operator diversity | `Diamond(Box phi) -> Box phi` |
| 0.70 - 0.85 | interesting | Cross-layer proofs, interaction axiom used | P1: `Box phi -> Always phi` |
| 0.85 - 1.00 | remarkable | Deep cross-modal proofs, high novelty | P5: `Diamond(Sometimes phi) -> Always(Diamond phi)` |

---

## 9. The Triviality-to-Depth Spectrum in TM Logic

### 9.1 Concrete Classification of Known Theorems

Using the refined scoring architecture, here is how existing theorems in the codebase would be classified:

**Trivial (0.00-0.05)**:
- `bot -> phi` (ex_falso): SNT=0, gate kills score
- `phi -> (psi -> phi)` (prop_s): SNT=0, gate kills score
- 1,754 of 1,959 valid training formulas fall here

**Routine (0.05-0.15)**:
- All remaining propositional tautologies with modal/temporal dressing
- 173 prop_s instances with non-trivial phi

**Basic (0.15-0.30)**:
- `Box phi -> phi` (modal_t instances): SNT=1, OD=1, PDR=0
- `Box phi -> Box(Box phi)` (modal_4 instances): SNT=1, OD=1, PDR=0
- `phi -> Box(Diamond phi)` (modal_b instances): SNT=1, OD=2

**Moderate (0.30-0.50)**:
- `Box phi -> Diamond phi` (t_box_to_diamond): Uses modal_t + contraposition
- `not(Box(A and not A))` (box_consistency): Multiple proof steps
- Combinators (identity, flip, composition) with height 4-10

**Notable (0.50-0.70)**:
- `Diamond(Box phi) -> Box phi` (S5 collapse): ~30 steps, uses S5 axioms
- `Box phi -> Diamond phi` via direct proof with necessitation + contraposition
- Temporal derived theorems (temp_k_dist, temp_4) proved from BX axioms

**Interesting (0.70-0.85)**:
- P1: `Box phi -> Always phi` (254 steps, 4 axioms, 3 rule types, crosses modal/temporal boundary via modal_future)
- P2: `Sometimes phi -> Diamond phi` (contrapositively related to P1)
- P3: `Box phi -> Box(Always phi)` (necessity of perpetuity)

**Remarkable (0.85-1.00)**:
- P5: `Diamond(Sometimes phi) -> Always(Diamond phi)` (327 steps, 8 axioms, 5 rule types, requires all 4 axiom layers, deeply exercises modal-temporal interaction)
- P4: `Diamond(Sometimes phi) -> Diamond phi` (persistence through time and possibility)
- Any theorem combining Until/Since with Box/Diamond in novel structural patterns

### 9.2 Why Perpetuity Principles Are the Gold Standard

The perpetuity principles P1-P5 provide a calibration anchor for our scoring system. They are interesting by every criterion surveyed:

- **Hardy**: High generality (connect modal and temporal domains), high depth (require 254-327 proof steps through 4 axiom layers), high unexpectedness (the connection between metaphysical necessity and temporal perpetuity is philosophically surprising)
- **Colton**: High novelty (unique operator combinations), high applicability (express fundamental philosophical principles), high surprisingness (connect apparently independent modalities)
- **Lakatos**: They are proof-generated -- the interaction between modalities reveals structural connections not obvious from the axioms alone
- **Schmidhuber**: High compression progress -- learning that "necessary implies always" compresses a large class of future reasoning
- **Frame correspondence**: P1 expresses a frame property (the interaction between accessibility and temporal ordering)
- **TxGraffiti's Dalmatian**: Each perpetuity principle provides a "sharper bound" on the relationship between modalities not captured by simpler theorems

---

## 10. Practical Reward Signal Design Recommendations

### 10.1 For RL-Based Theorem Discovery

Based on the convergence of SPEED-RL, STP, and AlphaProof:

```
reward(phi) =
  if not valid(phi):                    -0.1    (small penalty)
  elif SNT(phi) == 0:                    0.0    (zero for trivial)
  elif interestingness(phi) < 0.15:      0.01   (tiny reward for basic)
  elif interestingness(phi) < 0.50:      0.1 * interestingness(phi)
  elif interestingness(phi) < 0.85:      0.5 * interestingness(phi)
  else:                                  interestingness(phi)
```

The nonlinear scaling ensures that discovering remarkable theorems is heavily incentivized relative to producing routine ones.

### 10.2 For Curriculum Learning

Following SPEED-RL's theoretical insight, order formulas by predicted difficulty (approximated by interestingness tier) and train in bands:

1. **Phase 1 (Easy)**: Prove basic axiom instances (score 0.15-0.30) to learn fundamental proof patterns
2. **Phase 2 (Medium)**: Prove moderate derived results (score 0.30-0.50) to learn composition
3. **Phase 3 (Hard)**: Prove notable S5 results (score 0.50-0.70) to learn modal reasoning depth
4. **Phase 4 (Expert)**: Prove cross-modal theorems (score 0.70+) to learn interaction reasoning

At each phase, focus training on examples where the model succeeds ~50% of the time (SPEED-RL's optimal difficulty zone).

### 10.3 For Quality-Diversity Theorem Generation

Adopt a MAP-Elites approach with three behavioral dimensions:

| Dimension | Bins | Description |
|-----------|------|-------------|
| Operator profile | 8 bins | Which combination of {Box, Diamond, G, H, F, P, U, S} appears |
| Proof depth tier | 5 bins | [0], [1-5], [6-20], [21-100], [100+] |
| Axiom layer usage | 4 bins | Which of the 4 layers are used |

This creates up to 160 (8 * 5 * 4) behavioral niches. For each niche, retain the highest-scoring theorem. The archive then provides a diverse collection of maximally interesting theorems across the behavioral landscape.

---

## 11. Connections to the Automated Conjecturing Survey (2026)

A comprehensive survey published in 2026 in the Journal of Computer Science and Technology categorizes automated conjecturing methods into:

**Symbolic methods**: Top-down lemma discovery (given a goal, find auxiliary lemmas) and bottom-up theory exploration (generate conjectures from available operations). Our setting is primarily bottom-up -- generating formulas and assessing their interestingness.

**Data-driven methods**: Statistical analogy learning and neural methods. The survey notes that LLM-based approaches (STP, LeanConjecturer) are becoming dominant for producing synthetic training data.

**Evaluation of interestingness**: The survey discusses strategies and evaluation methods, noting that the field has not converged on a single standard. Our multi-dimensional approach with domain-specific bonuses aligns with the survey's recommendation for context-dependent, multi-criteria evaluation.

---

## 12. References

### Classical Systems and Philosophy

1. Hardy, G.H. *A Mathematician's Apology*. Cambridge University Press, 1940.
2. Lakatos, I. *Proofs and Refutations: The Logic of Mathematical Discovery*. Cambridge University Press, 1976.
3. Schmidhuber, J. "Driven by Compression Progress: A Simple Principle Explains Essential Aspects of Subjective Beauty, Novelty, Surprise, Interestingness." In *Anticipatory Behavior in Adaptive Learning Systems*, Springer, 2009. arXiv:0812.4360.
4. Colton, S. *Automated Theory Formation in Pure Mathematics*. PhD thesis, University of Edinburgh, 2001.
5. Colton, S., Bundy, A., Walsh, T. "On the Notion of Interestingness in Automated Mathematical Discovery." *International Journal of Human-Computer Studies*, 53(3):351-375, 2000.
6. Colton, S., Bundy, A. "Automatic Concept Formation in Pure Mathematics." IJCAI 1999.
7. Fajtlowicz, S. "On conjectures of Graffiti." *Discrete Mathematics*, 72:113-118, 1988.
8. Davila, R. "Automated Conjecturing with TxGraffiti." arXiv:2409.19379, 2024.
9. McCasland, R.L., Bundy, A., Smith, P.F. "MATHsAiD: Automated Mathematical Theory Exploration." *Applied Intelligence*, 47(3), 2017.
10. Johansson, M. "Hipster: Integrating Theory Exploration in a Proof Assistant." arXiv:1405.3426, 2014.
11. Ganesalingam, M., Gowers, T. "A Fully Automatic Problem Solver with Human-Style Output." arXiv:1309.4501, 2013.

### Modal and Temporal Logic

12. Sahlqvist, H. "Completeness and Correspondence in the First and Second Order Semantics for Modal Logic." *Proceedings of the Third Scandinavian Logic Symposium*, 1975.
13. Li, R., Belardinelli, F. "A Sahlqvist-style Correspondence Theorem for Linear-time Temporal Logic." arXiv:2206.05973, 2022.
14. Dwyer, M.B., Avrunin, G.S., Corbett, J.C. "Patterns in Property Specifications for Finite-State Verification." ICSE 1999.
15. Rybakov, V.V. *Admissibility of Logical Inference Rules*. Elsevier, 1997.
16. Kracht, M. "Properties of Independently Axiomatizable Bimodal Logics." University of Bielefeld, 1999.
17. Thomason, S.K. "Combinations of Tense and Modality." *Handbook of Philosophical Logic*, Vol. II, 1984.
18. Venema, Y. "Temporal Logic Survey." In *Mathematical Problems from Applied Logic II*, 2007.

### Modern ML for Theorem Proving

19. FERMAT Team. "Learning Interestingness in Automated Mathematical Theory Formation." NeurIPS 2025 Spotlight. arXiv:2511.14778.
20. Lample, G. et al. "HyperTree Proof Search for Neural Theorem Proving." NeurIPS 2022. arXiv:2205.11491.
21. AlphaProof Team. "Olympiad-level formal mathematical reasoning with reinforcement learning." *Nature*, 2025.
22. DeepSeek AI. "DeepSeek-Prover-V1.5: Harnessing Proof Assistant Feedback for Reinforcement Learning." ICLR 2025. arXiv:2408.08152.
23. STP Team. "Self-play LLM Theorem Provers with Iterative Conjecturing and Proving." arXiv:2502.00212, 2025.
24. LeanProgress Team. "LeanProgress: Guiding Search for Neural Theorem Proving via Proof Progress Prediction." arXiv:2502.17925, 2025.
25. LeanConjecturer Team. "LeanConjecturer: Automatic Generation of Mathematical Conjectures for Theorem Proving." arXiv:2506.22005, 2025.
26. LeanNavigator Team. "Generating Millions of Lean Theorems with Proofs by Exploring State Transition Graphs." arXiv:2503.04772, 2025.
27. Lean-STaR Team. "Lean-STaR: Learning to Interleave Thinking and Proving." ICLR 2025. arXiv:2407.10040.
28. SPEED-RL Team. "SPEED-RL: Faster Training of Reasoning Models via Online Curriculum Learning." ICML AI4Math Workshop, 2025. arXiv:2506.09016.

### Quality Diversity and Evolutionary Search

29. AlphaEvolve Team. "AlphaEvolve: A Gemini-powered coding agent for designing advanced algorithms." Google DeepMind, 2025.
30. Mouret, J.B., Clune, J. "Illuminating Search Spaces by Mapping Elites." arXiv:1504.04909, 2015.
31. Lehman, J., Stanley, K.O. "Abandoning Objectives: Evolution Through the Search for Novelty Alone." *Evolutionary Computation*, 19(2), 2011.

### Information Theory and Proof Complexity

32. Kolmogorov, A.N. "Three Approaches to the Quantitative Definition of Information." *Problems of Information Transmission*, 1(1):1-7, 1965.
33. Razborov, A.A. "Propositional Proof Complexity." In *Proceedings of the 8th European Congress of Mathematics*, 2012.
34. Ben-Sasson, E., Wigderson, A. "Short proofs are narrow -- resolution made simple." *Journal of the ACM*, 48(2):149-169, 2001.

### Empirical Studies

35. "A Matter of Interest: Understanding Interestingness of Math Problems in Humans and Language Models." arXiv:2511.08548, 2025.
36. "Value Judgments in Mathematics: G. H. Hardy and the (Non-)seriousness of Mathematical Theorems." PMC 10878122, 2024.

---

## 13. Recommendations for Implementation

### Immediate Priority

1. **Implement the SNT gate**: This alone would eliminate 89% (1,754/1,959) of valid formulas from training data as ex_falso instances. Pure pattern matching, O(n), no infrastructure changes needed.

2. **Implement Axiom Layer Diversity**: Track which of the 4 axiom layers (propositional, modal, temporal, interaction) each proof uses. This is the single most discriminating metric for bimodal interestingness. Can be computed from existing proof traces.

3. **Cross-reference proof_steps.jsonl theorems into training data**: The 310 named theorems with rich proofs are the calibration anchors for the scoring system. Their interestingness scores should span the full range and validate the metric weights.

### Short-Term

4. **Add Interaction Axiom Dependency**: Flag proofs that use modal_future. This binary feature alone separates genuinely bimodal theorems from "modal + temporal" theorems.

5. **Implement Statement Simplicity**: Reward clean, elegant theorem statements (low complexity relative to subformula count) -- supported by both Hardy and the "Matter of Interest" study.

### Medium-Term

6. **MAP-Elites behavioral archive**: Implement the quality-diversity approach with 3 behavioral dimensions to ensure diverse theorem generation.

7. **Curriculum-based training**: Use interestingness tiers to order training data, following SPEED-RL's theoretical optimal difficulty principle.

### Long-Term

8. **Learn interestingness**: Following FERMAT, use evolutionary or RL methods to discover domain-specific interestingness functions, validated against expert ratings of bimodal logic theorems.
