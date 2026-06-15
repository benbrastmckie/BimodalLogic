### 8.4 Truth Lemma

Next we show that in the filtered canonical model all formulas contained in a state are also true in that state. Recall that $M^f$ is the model created when filtering $M^C$ through $\text{cl}(\varphi)$.

**Lemma 5 (CLC Truth Lemma [1, Theorem 1]).** For all $s \in S^C$ and $\psi \in \text{cl}(\varphi)$, we have $M^f, s^f \models \psi$ iff $\psi \in s^f$.

This proof is by induction on $\psi$. For space reasons we include only the proof for $C_G\psi$: $M^f, s^f \models C_G\psi$ iff $C_G\psi \in s^f$, and specifically the $\Leftarrow$ direction, as this was the most interesting to formalize. Given $C_G\psi \in s^f$, and some state $t^f$ such that $s^f \approx^f_G t^f$, we need to show $M^f, t^f \models \psi$. This proof is inductive on the common knowledge path from $s^f$ to $t^f$. Thus, the details of this proof depend on how exactly we defined the common knowledge path in Lean.

Let the length of a common knowledge path be the number of states in the path between our first state ($s^f$) and our last state ($t^f$). In this case we may describe a common knowledge path from $s^f$ to $t^f$ as $\langle s^f, \sim^f_{i_0}, u^f_1, \sim^f_{i_1}, u^f_2, \ldots, u^f_n, \sim^f_{i_n}, t^f \rangle$, such that $s^f \sim^f_{i_0} u^f_1$, $u^f_1 \sim^f_{i_1} u^f_2$, $\ldots$, $u^f_n \sim^f_{i_n} t^f$ and $\{i_0, i_1, \ldots, i_n\} \subseteq G$. We will perform induction on the length $n$ of this path.

For the **base case** of our inductive proof, let $n = 0$. Thus, we consider a path $\langle s^f, \sim^f_{i_0}, t^f \rangle$, matching the base case of our Lean implementation:

```lean
| done (hi : i ∈ G) (hst : t ∈ m.f.rel i s) : C_path G s t
```

Thus we need to prove that $M, t \models \psi$, given that $s^f \sim^f_{i_0} t^f$, for some $i_0 \in G$. This base case differs from a more traditional inductive proof on a common knowledge path, like the proof by Agotnes and Alechina [1], where the base case is simply the starting state, with the path being $\langle s^f \rangle$. Note that this is equivalent to our base case with the additional assumption that $s^f = t^f$, as we must by reflexivity have $s^f \sim^f_{i_0} s^f$.

Next our **inductive step** needs to match our recursive case in Lean:

```lean
| next (hi : i ∈ G) (hsu : u ∈ m.f.rel i s) (ih : C_path G u t) :
    C_path G s t
```

Here we build the path recursively from the front: so when looking at the path from $s^f$ to $t^f$, we consider first the individual knowledge relation from $s^f$ to the second state in the path. Then we recursively define the rest of the path from the second state to $t^f$. Our inductive step must match this format. Let the first state between $s^f$ and $t^f$ be $u^f$, where $s^f \sim^f_i u^f$ for some $i \in G$, and let the common knowledge path for group $G$ of length $n$ be $\langle u^f, \sim^f_{i_0}, u^f_1, \sim^f_{i_1}, u^f_2, \ldots, u^f_n, \sim^f_{i_n}, t^f \rangle$. The inductive hypothesis states that if $C_G\psi \in u^f$, then $M^f, t^f \models \psi$. Again, this approach to the inductive step is different from the more usual inductive proof on a common knowledge path by Agotnes and Alechina [1]. In their case the inductive step splits a path of length $n + 1$ into a path from the starting state ($s^f$) to the $n$th state in the path, and a single knowledge relation from the $n$th to the end state ($t^f$).

Note that for our inductive proof on the common knowledge path, both in the base case and in the inductive case we need to prove something (that $\psi$ holds in the base case, that it contains $C_G\psi$ for the inductive step) about a state ($t^f$ for the base case, $u^f$ for the inductive step) which is connected from $s^f$ by an individual knowledge relation for some agent in $G$. Thus we now show that for any state $w^f$, where there is a relation $s^f \sim^f_j w^f$ for some $j \in G$, we must have both $M^f, w^f \models \psi$ and $C_G\psi \in w^f$. From $C_G\psi \in s^f$ we must have $K_j(C_G\psi) \in s^f$ by definition of $\text{cl}(C_G\psi)$, propositional logic, and axioms (C), (K) and (RN). Thus by definition of $\sim^f_i$ we must also have $K_j(C_G\psi) \in w^f$. Then we must also have $C_G\psi \in w^f$ by axiom (T). Hereby we have proven $M^f, t^f \models \psi$ for the inductive step in our proof. Additionally, from $C_G\psi \in w^f$, we know $\psi \in w^f$, by axioms (T), (C), (K) and (RN). Note that by the inductive hypothesis for the truth lemma ($\forall s \in S^C,\; M^f, s^f \models \psi \leftrightarrow \psi \in s^f$), we must then also have $M^f, w^f \models \psi$. Therefore we have proven $M^f, t^f \models \psi$ for the base case in our proof.

### 8.5 Finalizing the Completeness Proof

It remains to prove the final theorem:

**Theorem 6 (Completeness of CLC [1, Corollary 1]).** $\forall \varphi,\; \models \varphi \Rightarrow\; \vdash \varphi$

We prove the contrapositive by showing that every formula not provable by CLC is not globally valid: $\nvdash \varphi \Rightarrow \not\models \varphi$. From $\neg\vdash\varphi$ we know that $\{\neg\varphi\}$ must be a consistent set. By Lindenbaum's lemma [24] the set can thus be extended into some maximally consistent set $\Sigma$ that is equal to some state $s \in S^C$. Note that when filtered through $\text{cl}(\varphi)$, we will still have $\neg\varphi \in s^f$. By Lemma 5 $\neg\varphi$ is true in that filtered state, and thus $\varphi$ is not. Thus $\varphi$ is not globally valid.

We have thus verified the proof theory and model theory of CLC relate to each other as expected by proving both soundness and completeness. All Lean lemmas and definitions about (filtered) canonical model construction can be reused to prove that CL and CLK are also sound and complete (see [21] for details). For CL, as mentioned previously, this is done by proving the truth lemma for the canonical coalition model for CL. For Coalition Logic with individual knowledge (CLK), the proofs are analogous to the proofs presented here, omitting any parts related to common knowledge.

## 9 Conclusion and Discussion

In this paper, we have described the successful implementation of soundness and completeness proofs for CLC in Lean. Our project consists of approximately 6,000 lines of code. Of these, approximately 300 lines are specific to Coalition Logic (CL), 700 are specific to Coalition Logic with Knowledge operators (CLK), and 1,100 to Coalition Logic with Common knowledge operators (CLC). The remaining almost 4,000 lines are shared between the three. In addition, we make extensive use of the Lean mathematical library Mathlib. We will not mention a De Bruijn factor for our development, as there is no direct comparison possible between the scope of our work and any of the relevant papers.

Much of the complexity of our formalization comes from the need to deal with finiteness in Lean. To access properties of finiteness in Lean, we needed to use specific data types. This is most notable in our formalization of $\varphi_X$, where we create three different definitions for when $X$ is a `Set`, a `Finset` (finite set) and a `List`. Of the three mentioned data types only the `List` is ordered in Lean (in our case, when converting from a (finite) set the order is arbitrary) and therefore allows us to iterate over elements. However when translating some (finite) set into a list we often need to keep track of relevant properties about the initial `Set`. For instance, we may need to remember that our resulting `List` contains no repeating elements. We are therefore often required to create separate lemmas for each data type, and manually pass such information forward. These translations consequently add a lot of work. However, each individual step was relatively simple with the existing Mathlib library [25]. Additionally, some of these challenges are likely exacerbated by our goal to keep our Lean proofs reasonably similar to their respective paper proofs. For instance, in our formalization we define finite conjunctions and disjunctions recursively. However to show a finite conjunction is provable or is contained in some state, we simply need to show that all conjuncts are provable or are contained within that state. Similarly for finite disjunctions we aim to show that one disjunct is provable or contained within the state. Thus a deeper embedding using Lean's native $\forall$ and $\exists$ quantifiers may have been more natural.

Another difficulty with formalization is that there are many trivial lemmas that need detailed proofs in Lean, which makes formalization cumbersome and time-consuming. This is especially notable with the lemmas about the finite closure ($\text{cl}$), for instance that it is closed under single negations. Despite being trivial by our definition of $\text{cl}$, the proof in Lean is long because of how many cases need to be considered. This highlights the need for continued work on increasing automation in Lean. Specifically, these long but trivial inductive proofs would be ideal candidates for better automation.

Despite these challenges, one of the main advantages of formalizing this proof is that it required us to be precise about exactly when we were using hypotheses and assumptions. In our case, this led to us easily showing that the completeness proof for CLC described by Agotnes and Alechina [1] also holds if we extend the syntax to also allow formulas of the form $C_\emptyset\varphi$. Programmatic formalization lends itself well to these tests of generalization: it automates the work of re-checking an entire proof every time a hypothesis is slightly changed or removed [4, 10].

Aside from dealing with the nature of formalization itself, one of the goals of our research was to allow for reuse of lemmas and definitions across different logics. To this end we introduced Lean classes for each logic's syntax and axiomatic system. Importantly, we were able to define the canonical model $M^C$ for these classes, such that the model can be built for CL and any of its extensions. Additionally we provided a large number of lemmas defined using our classes for propositional logic, CL, CLK and CLC. We hope that an increasing library of these kinds of proofs can aid future research into formalizing modal logics, especially work on formalizing the other types of Epistemic Coalition Logic described by Agotnes and Alechina [1].

We note, however, that we did not add semantics to our class definitions. This choice was made as the semantics are only used in inductive proofs. We could not use classes for inductive proofs, as they act as minimum requirements for the syntax and proof system of the logic. However, each individual case in an inductive proof could be separated into its own lemma if the semantics was added to the generic classes. Future work could thus look into expanding our classes and creating such generic proofs. Even more interesting would be to define the logics in such a way that we can use generic data structures for inductive proofs.

## References

1. Thomas Agotnes and Natasha Alechina. Coalition logic with individual, distributed and common knowledge. *Journal of Logic and Computation*, 29(7):1041--1069, 2019. doi:[10.1093/logcom/exv085](https://doi.org/10.1093/logcom/exv085).

2. Mussab Alaa, Aos Alaa Zaidan, Bilal Bahaa Zaidan, Mohammed Talal, and Miss Laiha Mat Kiah. A review of smart home applications based on internet of things. *Journal of Network and Computer Applications*, 97:48--65, 2017. doi:[10.1016/j.jnca.2017.08.017](https://doi.org/10.1016/j.jnca.2017.08.017).

3. Jeremy Avigad, Leonardo de Moura, Soonho Kong, and Sebastian Ullrich. Theorem proving in Lean 4. Accessed 2024-01-18. URL: [https://lean-lang.org/theorem_proving_in_lean4/](https://lean-lang.org/theorem_proving_in_lean4/).

4. Anne Baanen, Alexander Bentkamp, Jasmin Blanchette, Johannes Holzl, and Jannis Limperg. *The Hitchhiker's Guide to Logical Verification*. Vrije Universiteit Amsterdam, 2021 edition, 2021.

5. Colm Baston and Venanzio Capretta. Game forms for coalition effectivity functions. In *TYPES 2019*, pages 26--27, 2019. URL: [https://nottingham-repository.worktribe.com/output/2681068](https://nottingham-repository.worktribe.com/output/2681068).

6. Bruno Bentzen. A Henkin-style completeness proof for the modal logic S5. In *Lecture Notes in Computer Science*, pages 459--467. Springer International Publishing, 2021. doi:[10.1007/978-3-030-89391-0_25](https://doi.org/10.1007/978-3-030-89391-0_25).

7. Lubor Budaj. Formalization of modal logic S5 in the Coq proof assistant, 2022. Bachelor's Thesis, University of Groningen. URL: [https://fse.studenttheses.ub.rug.nl/28482/1/BSc_Thesis_final.pdf](https://fse.studenttheses.ub.rug.nl/28482/1/BSc_Thesis_final.pdf).

8. Leonardo de Moura, Soonho Kong, Jeremy Avigad, Floris van Doorn, and Jakob von Raumer. The Lean Theorem Prover (System Description). In *Lecture Notes in Computer Science*, volume 9195, pages 378--388. Springer, 2015. doi:[10.1007/978-3-319-21401-6_26](https://doi.org/10.1007/978-3-319-21401-6_26).

9. Asta Halkjaer From. Formalized soundness and completeness of epistemic logic. In *Logic, Language, Information, and Computation*, pages 1--15, Cham, 2021. Springer International Publishing.

10. Herman Geuvers. Proof assistants: History, ideas and future. *Sadhana*, 34:3--25, 2009.

11. Balaji Parasumanna Gokulan and Dipti Srinivasan. An introduction to multi-agent systems. In *Innovations in Multi-Agent Systems and Applications*, pages 1--27. Springer, Berlin, Heidelberg, 2010. doi:[10.1007/978-3-642-14435-6_1](https://doi.org/10.1007/978-3-642-14435-6_1).

12. Valentin Goranko, Wojciech Jamroga, and Paolo Turrini. Strategic games and truly playable effectivity functions. *Autonomous Agents and Multi-Agent Systems*, 26(2):288--314, March 2013. doi:[10.1007/s10458-012-9192-y](https://doi.org/10.1007/s10458-012-9192-y).

13. Frans C. A. Groen, Matthijs T. J. Spaan, Jelle R. Kok, and Gregor Pavlin. Real world multi-agent systems: Information sharing, coordination and planning. In *TbiLLC '05*, volume 4363 of LNCS, pages 154--165, Cham, 2007. Springer. doi:[10.1007/978-3-540-75144-1_12](https://doi.org/10.1007/978-3-540-75144-1_12).

14. Joni Helin. Combining deep and shallow embeddings. *Electronic Notes in Theoretical Computer Science*, 164(2):61--79, 2006. doi:[10.1016/j.entcs.2006.10.005](https://doi.org/10.1016/j.entcs.2006.10.005).

15. Thierry Lecomte, Thierry Servat, and Guilhem Pouzancre. Formal methods in safety-critical railway systems. In *10th Brazilian Symposium on Formal Methods*, pages 29--31, August 2007.

16. Pierre Lescanne and Jerome Puissegur. Dynamic logic of common knowledge in a proof assistant. (preprint), 2007. doi:[10.48550/arXiv.0712.3146](https://doi.org/10.48550/arXiv.0712.3146).

17. Jiatu Li. Formalization of PAL-S5 in proof assistant. (preprint), 2020. doi:[10.48550/arXiv.2012.09388](https://doi.org/10.48550/arXiv.2012.09388).

18. Claudia Nalon, Lan Zhang, Clare Dixon, and Ullrich Hustadt. A resolution prover for coalition logic. In *Proceedings 2nd International Workshop on Strategic Reasoning, SR 2014*, volume 146 of EPTCS, pages 65--73, 2014. doi:[10.4204/EPTCS.146.9](https://doi.org/10.4204/EPTCS.146.9).

19. Paula Neeley. A formalization of dynamic epistemic logic. Master's thesis, Carnegie Mellon University, 2021.

20. Kai Obendrauf. CL-Lean Formalization. Software, swhId: swh:1:dir:5679444e6dc3b26cd7f1c54786bff9be89541c19 (visited on 2024-07-08). URL: [https://github.com/kaiobendrauf/cl-lean](https://github.com/kaiobendrauf/cl-lean).

21. Kai Obendrauf. Formalizing completeness proofs for coalition logic with and without common knowledge in Lean. Master's thesis, Vrije Universiteit Amsterdam, 2023. doi:[10.5281/zenodo.12582708](https://doi.org/10.5281/zenodo.12582708).

22. Marc Pauly. A modal logic for coalitional power in games. *Journal of Logic and Computation*, 12(1):149--166, 2002. doi:[10.1093/logcom/12.1.149](https://doi.org/10.1093/logcom/12.1.149).

23. Daniel Selsam, Sebastian Ullrich, and Leonardo de Moura. Tabled typeclass resolution. *CoRR*, abs/2001.04301, 2020. arXiv:[2001.04301](https://arxiv.org/abs/2001.04301).

24. Alfred Tarski. Uber einige fundamentale Begriffe der Metamathematik. *Sprawozdania z Posiedzen Towarzystwa Naukowego Warszawskiego. Wydzial III*, 23:22--29, 1930.

25. The mathlib Community. The Lean mathematical library. In *CPP 2020*, pages 367--381, New York, NY, USA, 2020. ACM. doi:[10.1145/3372885.3373824](https://doi.org/10.1145/3372885.3373824).

26. Johan Van Benthem. Games in dynamic-epistemic logic. *Bulletin of Economic Research*, 53(4):219--248, 2001. doi:[10.1111/1467-8586.00133](https://doi.org/10.1111/1467-8586.00133).

27. Wiebe van der Hoek and Michael J. Wooldridge. Logics for multiagent systems. *AI Mag.*, 33(3):92--105, 2012. doi:[10.1609/aimag.v33i3.2427](https://doi.org/10.1609/aimag.v33i3.2427).

28. Philip Wadler and Stephen Blott. How to make ad-hoc polymorphism less ad hoc. In *POPL '89, Principles of Programming Languages*, pages 60--76. ACM, 1989. doi:[10.1145/75277.75283](https://doi.org/10.1145/75277.75283).
