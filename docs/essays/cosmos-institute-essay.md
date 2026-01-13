# Teaching Machines to Prove They're Right

When an AI recommends a medical treatment, drafts a legal argument, or creates a complex financial plan, can it prove its reasoning is correct? More than plausibility or statistically likelihood, what would it take to justify the inferences that an AI might draw? Without any answer or serious method by which to verify AI decision making, what is to become of human society when the volume of AI decisions outstrip human capacities for oversight.

This question haunts the frontier of artificial intelligence. The systems we're building are increasingly sophisticated at writing code, analyzing documents to report findings, and make consequential recommendations and decisions of all kinds. If we weren't delegating to AI systems autonomously, they would still be useful, but only up to the limits of what human attention has the capacity to check. Even assisted with further autonomously driven verification systems, it is always easier just to trust an advanced AI system with a good track record to get it right. As the pressure to compete motivates compromises in oversight for gains in autonomy, some part of humanity gambits security for advantage.

The question is if we can create a better alternative so that sacrificing oversight no longer secures any competitive edge. This project aims to provide the foundation for such an alternative, one in which auto-verification provides an economically advantageous alternative to blind faith. Rather than trying to get AI systems to show more of their work, this project provides the infrastructure for training AI systems to construct arguments and evidence that can be independently verified with mathematical certainty. Just as the critical mind guides the creative, formally verified reasoning in an interpreted language of thought can help assist generative AI in constructing reasoning that is machine-checkable to be valid.

## The Problem

Current AI systems learn to reason by imitation. They consume vast corpora of human text including billions of words of reasoning, argument, and explanation to learn to produce outputs that pattern-match against this training data. Since the body of human reasoning does not hang together as one, there is no single target for that imitation to mock. Even if there were consensus among humans how to reason, execution is inevitably flawed and of limited complexity. Even so, the results can appear impressive from a human perspective, making it difficult to tell when an AI is right and when it is just convincingly human.

The fundamental limitation is not human or artificial intelligence but verification. When a language model produces a chain of reasoning, there is no deterministic guarantee that the reasoning is valid. In addition to the enormous bottleneck of attempting to check everything that one might want to, it is not even clear what it would be to check whether some piece of reasoning is valid or not, or how one would go about doing so. Instead, language models reproduce what reasoning *looks like* from human data. Although far from consistent or accurate, this often suffices to convince human users. In place of what is true or valid, AI systems are trained on the appearance of truth and validity by simulating even our best human approximations.

Reasoning by simulation without verification matters because consequential decisions demands justification. A physician explaining a diagnosis or a lawyer constructing an argument must be able to account for their conclusions. This project provides a foundation for training AI systems that don't just imitate reasoning well enough to convince most humans but rather to reason in a way that is provably correct. But it requires thinking about what reasoning is and what it is good for.

## Philosophical Logic as Conceptual Engineering

Instead of thinking about logic as a simulation of how humans happen to reason, this project takes an engineering approach which understands logic as a discipline for building reasoning systems that are best fit to serve our aims.

Consider the materials science where raw sand is transformed into glass through controlled processes that remove impurities and create useful transparency. The result is not a description of sand but a refined material engineered that didn't exist before but has rather been created for specific purposes. Logic follows a similar course, engineering the conceptual world rather than the material.

Natural language provides the raw materials in the form of intuitions about how to use notions of conjunction, negation, identity, necessity, possibility, time, causation, belief, obligation, and many others. Such intuitions are immediate and useful but often remain ambiguous in edge cases, inconsistent across contexts, or otherwise resistant to systematic analysis. Formal logic refines these intuitions by stipulating operators with explicit axioms and inference rule in addition to semantic clauses. Although distinct, these methods can be used together to stipulate refined concepts for reasoning rather than describing the natural concepts with which we begin.

Rather than describing how the word "if" behaves in English (a descriptive project), formal logic stipulates how the material conditional, strict conditional, counterfactual conditional, and indicative conditional all *should* behave for systematic reasoning (a normative project). The resulting operators are close enough to natural language to remain intelligible, but precise enough to be verifiable. We can write down proof systems for how to reason with these concepts just as we can define the rules of the game of chess, and we can define the space of models which would show a sentence to be true or false by encoding the considerations to which it is sensitive.

Although writing axiomatic proofs and defining truth-conditions for formal expressions as a function of their constituents has carried us some ways over the past century and a half, doing so by hand is limited. Not only are humans liable to error, the work is slow and grueling, diminishing the pursuits to relative obscurity by limiting attempts to prove some properties or other for tiny fragment languages with few operators of interest working together.

The ProofChecker implements an axiomatic proof theory and recursive semantics for the Logos which provides a unified formal language with operators for reasoning about what must happen, what might happen, what would happen if, what will happen, what has happened, what is sufficient for what, what is necessary for what, what causes what, and so on, including all the conceptual vocabulary required for planning under uncertainty. And we've proven, mathematically, that the reasoning rules for this language are valid over its semantics.

## The Innovation

Our work has produced three main contributions, each addressing a different aspect of the verification problem.

### Machine-Verified Proofs

We have completed the first Lean 4 formalization of a bimodal logic for temporal-modal reasoning of the kind required when contemplating future contingency. The system combines operators for necessity and possibility (modal logic) with operators for past and future (temporal logic) into a unified framework with a novel semantics.

Every axiom in this system has been proven sound by a machine-checkable proof. This means the logical system cannot prove anything false. When the system derives a conclusion, that conclusion is guaranteed to follow from the premises. The proofs are not just human arguments that might contain errors but rather verified by Lean's type checker, providing mathematical certainty.

### A Language for Planning Under Uncertainty

The Logos is designed for a specific purpose: enabling AI systems to reason about plans with other agents under uncertainty. Plans are not certainties but proposed courses of action that, given available information, are likely to produce favorable outcomes compared to alternatives. To evaluate plans, it is imperative to be able to evaluate failure points for likelihood as well as outcomes by surveying the counterfactual futures that failures may induce.

This comparative evaluation requires specific conceptual resources. Temporal operators represent how situations evolve over time: "this will always be true," "this will eventually happen," "this was the case." Modal operators represent alternative possible histories: "this is possible," "this is necessay." Together, these operators enable representing and comparing alternative plans.

### Unlimited Verified Training Data

The third contribution addresses AI training directly. Current AI systems are trained on finite corpora of human-generated text, which is expensive to annotate, limited in scope, contains errors and inconsistencies, and is of limited complexity. This project offers an alternative: unlimited, mathematically verified training data.

The insight is that axiom systems generate infinite theorems. Each theorem comes with a *proof receipt* which is a machine-checkable demonstration that the inference is valid. Invalid inferences, meanwhile, can be refuted with *countermodels* which amount to explicit semantic scenarios showing exactly why the reasoning fails. This dual verification architecture produces training signals that are unbounded (infinite theorems are derivable), clean (there are no accidental errors), justified (proofs provide verification), and interpreted (semantic models explain meaning).

## Why It Matters

Ensuring AI systems do what we intend is fundamentally a problem of oversight. As AI systems become more capable, their reasoning becomes harder to verify. We cannot check every inference, examine every chain of reasoning, audit every recommendation. We need systems that can verify themselves.

Proof receipts enable exactly this kind of scalable oversight. When an AI system trained on our methodology produces a conclusion, it can provide a machine-checkable proof that the conclusion follows validly from the premises. You can verify the reasoning without understanding all the details since the proof itself serves as a certificate of correctness that can be trusted.

Explicit semantics provide interpretability. Each logical operator has precise truth conditions defined over formal models. When an AI system claims that something is "necessarily true" or "will eventually happen," these claims have exact mathematical meanings that can be inspected and understood. You can check not just whether the AI's reasoning *looks* right, but what it actually *means*.

The applications span any domain requiring verifiable reasoning under uncertainty. Medical planning: evaluating treatment strategies with counterfactual reasoning about what would happen under alternative interventions. Legal reasoning: tracking beliefs, motives, and obligations across time. Multi-agent coordination: modeling what others believe and prefer, planning accordingly.

## The Invitation

Philosophy without implementation is speculation. The work we describe here lives at the intersection, providing philosophical foundations for working infrastructure. The Logos has a layered architecture so that applications can import exactly the operators they need: temporal and counterfactual reasoning for planning, epistemic reasoning for uncertainty, normative reasoning for managing obligations and preferences. Each layer extends the previous without disrupting it.

The Logos provides conceptual infrastructure for building trustworthy AI. Where as the ProofChecker provides proofs that are verified in Lean 4, this project aligns with the ModelChecker which find countermodels generated by Z3. Together these packages provide training signals that are unlimited and mathematically guaranteed. We invite others to join this work. The tools are open. The methodology is documented. The goal is AI systems that can prove they're right rather than merely sounding convincing.

## Conclusion

We have built a formal language precise enough for mathematical verification yet expressive enough for real-world reasoning. We have proven its logical rules sound. We have demonstrated that it can generate unlimited verified training data. The result is not a finished product but a foundation: infrastructure for AI systems that reason with mathematical certainty rather than statistical approximation.

---

*This essay describes work supported by a grant from the Cosmos Institute. The Logos project is open source and available for collaboration.*
