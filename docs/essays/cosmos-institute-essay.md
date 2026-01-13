# Teaching Machines to Prove They're Right

When an AI recommends a medical treatment, drafts a legal argument, or plans a complex operation, can it prove its reasoning is correct? Not just plausible-sounding or statistically likely, but *correct*.

This question haunts the frontier of artificial intelligence. The systems we're building are increasingly sophisticated at writing code, analyzing documents, and make consequential recommendations. They can even show some of their work. What they cannot provide is what any competent human professional must provide: justification.

## The Problem

Current AI systems learn to reason by imitation. They consume vast corpora of human text including billions of words of reasoning, argument, and explanation to learn to produce outputs that pattern-match against this training data. The results can be impressive, making it increasingly difficult to tell when they are confidently wrong.

The fundamental limitation is not intelligence but verification. When a language model produces a chain of reasoning, there is no mathematical guarantee that the reasoning is valid. The model has learned what reasoning *looks like*, not what makes reasoning *work*. It approximates patterns statistically rather than deriving conclusions logically.

This matters because consequential decisions demand verifiable reasoning. A physician explaining a diagnosis, a lawyer constructing an argument, a planner evaluating alternatives—each must be able to justify their conclusions. Their reasoning must be not merely plausible but sound. And increasingly, AI systems are being asked to assist with exactly these tasks.

The question becomes: Can we build AI systems that don't just imitate reasoning but actually *do* it—and prove they've done it correctly?

We believe the answer is yes. But it requires rethinking what logic is for.

## Philosophy as Engineering

The answer requires thinking about logic differently—not as a description of how humans reason, but as an engineering discipline for building reasoning systems.

Consider how materials science works. Raw sand is transformed into glass through controlled processes that remove impurities and create useful transparency. The result is not a description of sand but a refined material engineered for specific purposes. Logic, properly understood, does something similar with concepts.

Natural language provides the raw materials: intuitive notions of necessity, possibility, time, causation, belief, obligation. These concepts are powerful but imprecise—ambiguous in edge cases, inconsistent across contexts, resistant to systematic analysis. Formal logic refines these intuitions into operators with explicit truth conditions: precise semantic clauses that specify exactly what each operator means.

This is conceptual engineering. Rather than describing how the word "if" behaves in English (a descriptive project), we stipulate how the logical conditional *should* behave for systematic reasoning (a normative project). The resulting operators are close enough to natural language to remain intelligible, but precise enough to be verifiable.

The Logos project takes this engineering approach seriously. We've built a formal language equipped with operators for reasoning about what must happen, what might happen, what would happen if, what will happen, and what has happened—the conceptual vocabulary required for planning under uncertainty. And we've proven, mathematically, that the reasoning rules for this language are sound.

## The Innovation

Our work has produced three main contributions, each addressing a different aspect of the verification problem.

### Machine-Verified Proofs

We have completed the first Lean 4 formalization of a bimodal logic for temporal-modal reasoning—the kind of reasoning required when contemplating future contingency. The system combines operators for necessity and possibility (modal logic) with operators for past and future (temporal logic) into a unified framework.

Every axiom in this system has been proven sound by a machine-checkable proof. This means the logical system cannot prove anything false. When the system derives a conclusion, that conclusion is guaranteed to follow from the premises. The proofs are not just human arguments that might contain errors—they are verified by Lean's type checker, providing mathematical certainty.

### A Language for Planning Under Uncertainty

The Logos is designed for a specific purpose: enabling AI systems to reason about plans. Plans are not certainties but *high expected value futures*—proposed courses of action that, given available information, are likely to produce favorable outcomes compared to alternatives.

This comparative evaluation requires specific conceptual resources. Temporal operators represent how situations evolve over time: "this will always be true," "this will eventually happen," "this was the case." Modal operators represent alternative possibilities: "this must happen," "this might happen." Together, these operators enable representing and comparing alternative plans—asking not just what *will* happen but what *would* happen under different choices.

### Unlimited Verified Training Data

The third contribution addresses AI training directly. Current AI systems are trained on finite corpora of human-generated text, which is expensive to annotate, limited in scope, and contains errors and inconsistencies. We offer an alternative: unlimited, mathematically verified training data.

The insight is that axiom systems generate infinite theorems. Each theorem comes with a *proof receipt*—a machine-checkable demonstration that the inference is valid. Invalid inferences, meanwhile, can be refuted with *countermodels*—explicit semantic scenarios showing exactly why the reasoning fails. This dual verification architecture produces training signals that are unbounded (infinite theorems derivable), clean (soundness guarantees correctness), justified (proofs provide verification), and interpreted (semantic models explain meaning).

## Why It Matters

The alignment problem—ensuring AI systems do what we intend—is fundamentally a problem of oversight. As AI systems become more capable, their reasoning becomes harder to verify. We cannot check every inference, examine every chain of reasoning, audit every recommendation. We need systems that can verify themselves.

Proof receipts enable exactly this kind of scalable oversight. When an AI system trained on our methodology produces a conclusion, it can provide a machine-checkable proof that the conclusion follows validly from the premises. You can verify the reasoning without understanding all the details—the proof itself serves as a certificate of correctness.

Explicit semantics provide interpretability. Each logical operator has precise truth conditions defined over formal models. When an AI system claims that something is "necessarily true" or "will eventually happen," these claims have exact mathematical meanings that can be inspected and understood. You can check not just whether the AI's reasoning *looks* right, but what it actually *means*.

The applications span any domain requiring verifiable reasoning under uncertainty. Medical planning: evaluating treatment strategies with counterfactual reasoning about what would happen under alternative interventions. Legal reasoning: tracking beliefs, motives, and obligations across time. Multi-agent coordination: modeling what others believe and prefer, planning accordingly.

## The Invitation

Philosophy without implementation is speculation. Implementation without philosophy is blindness. The work we describe here lives at the intersection—philosophical foundations translated into working infrastructure.

The Logos project demonstrates that formal verification can be practical, not merely theoretical. The layered architecture means applications can import exactly the operators they need: temporal reasoning for planning, modal reasoning for possibility, epistemic reasoning for uncertainty, normative reasoning for obligations. Each layer extends the previous without disrupting it.

This is infrastructure for building trustworthy AI. The proofs are verified in Lean 4. The countermodels are generated by Z3. The training signals are unlimited and mathematically guaranteed. What remains is to build on this foundation—to train systems that don't just imitate reasoning but actually do it, with proof receipts to show their work.

We invite others to join this work. The tools are open. The methodology is documented. The goal is AI systems that can prove they're right—not just sound right.

## Conclusion

The question we began with—can an AI prove its reasoning is correct?—now has a concrete answer. Yes, if we engineer the right foundations.

We have built a formal language precise enough for mathematical verification yet expressive enough for real-world reasoning. We have proven its logical rules sound. We have demonstrated that it can generate unlimited verified training data. The result is not a finished product but a foundation: infrastructure for AI systems that reason with mathematical certainty rather than statistical approximation.

The path from pattern matching to verified inference is now open. Building on it is the work ahead.

---

*This essay describes work supported by a grant from the Cosmos Institute. The Logos project is open source and available for collaboration.*
