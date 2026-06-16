### 8.2 Filtering the Canonical Model

Given some $\varphi$, we filter $S^C$ into a finite set of states $S^f$. We will prove the properties of $S^C$ transfer to $S^f$ and show it enjoys some additional properties essential to constructing a playable model. We achieve this by creating a finite closure $\text{cl}(\varphi)$, defined as the smallest set satisfying the following:

1. For any $\psi \in \text{cl}(\varphi)$, all subformulas of $\psi$ are also contained in $\text{cl}(\varphi)$.
2. For any $\psi \in \text{cl}(\varphi)$, if $\psi$ is not of the form $\neg\chi$, then $\neg\psi \in \text{cl}(\varphi)$. ($\text{cl}(\varphi)$ is thus closed under single negations.)
3. If $C_G\varphi \in \text{cl}(\varphi)$, then for all $i \in G$, $K_iC_G\varphi \in \text{cl}(\varphi)$.
4. If $[G]\varphi \in \text{cl}(\varphi)$, then $C_G[G]\varphi \in \text{cl}(\varphi)$.

This definition is adjusted slightly compared to the work by Agotnes and Alechina [1], as we allow the formula $C_\emptyset\psi$, and thus do not need to consider the case $G = \emptyset$ separately. Additionally, we change the first requirement such that all subformulas of any $\psi \in \text{cl}(\varphi)$ are contained in the closure, rather than just subformulas of $\varphi$. This change is needed to prove the truth lemma, where we will perform induction on an arbitrary $\psi \in \text{cl}(\varphi)$. For Agotnes and Alechina [1] this adjusted requirement is already met when $\text{cl}(\varphi)$ contains all subformulas of $\varphi$, because their syntax is defined from different base operators. The closure definition thus illustrates that small implementation choices early in the formalization process can have unintended effects later in the proof that may not be immediately obvious. Luckily, the interactive environment of a theorem prover made the consequences of this change clear, and made the necessary changes easy to implement and test.

The set $\text{cl}(\varphi)$ can be built recursively on the structure of $\varphi$, and this is also how we define it in Lean. For instance, for the case $\text{cl}(C_G\psi)$, the closure must include $\text{cl}(\psi) \cup \{C_G\psi, \neg(C_G\psi)\} \cup \{K_iC_G\psi : i \in G\} \cup \{\neg(K_iC_G\psi) : i \in G\}$. Note that the sets $\{K_iC_G\psi : i \in G\}$ and $\{\neg(K_iC_G\psi) : i \in G\}$ are finite, because $G$ is finite. In Lean we define the union of these two sets as follows:

```lean
noncomputable def cl_C {agents : Type} [Fintype agents] (G : Set agents)
    (φ : formCLC agents) : Finset (formCLC agents) :=
  Finset.image (fun i => K i (C G φ)) (toFinset G) ∪
  Finset.image (fun i => (¬ K i (C G φ))) (toFinset G)
```

In addition to defining a set, the above definition also guarantees that the set is finite, using the `Finset` datatype. We create this resulting `Finset` by first mapping the set of agents $G$ from a `Set` to a `Finset`. Lean can infer this is possible, because $N$ is finite, as indicated by the hypothesis `[Fintype agents]`. Then we can take the image of $G$ as desired.

In Lean, we then need to prove that our closure $\text{cl}(\varphi)$, defined recursively on the structure of the formula $\varphi$, indeed meets the four requirements described above. To do so, we first define a subformula as an inductive proposition with cases for each operator. For instance we define two cases for the $\wedge$-operator: `and_left {φ ψ} : subformula φ (φ '∧ ψ)` and `and_right {φ ψ} : subformula ψ (φ '∧ ψ)`. Additionally, we add two cases for the requirements that our sub-formula definition must be reflexive and transitive. Given this definition, we tackle the four proofs about the closure. Although in a paper proof all four requirements are trivially met by definition of the closure, in Lean this is only the case for the last two. The first two requirements both need inductive proofs on $\varphi$ where for every case we iteratively consider all possible $\psi \in \text{cl}(\varphi)$. For instance if $\varphi = \chi_l \wedge \chi_r$, we consider the cases where $\psi = \chi_l \wedge \chi_r$, $\psi = \neg(\chi_l \wedge \chi_r)$, $\psi \in \text{cl}(\chi_l)$ and $\psi \in \text{cl}(\chi_r)$. These proofs are not difficult, but considering each case creates long and tedious proofs.

Now that we have defined the closure, given some $\varphi$, we can filter $M^C$ through $\text{cl}(\varphi)$, to construct a finite model $M^f := (F^f, V^f)$, where $F^f := (S^f, E^f, \{\sim^f_i : i \in N\})$. We construct $M^f$ as follows:

$$S^f := \{s^f \mid s \in S^C\}, \quad \text{where } s^f := s \cap \text{cl}(\varphi)$$

$$X \in E^f(s)(N) \quad \text{iff} \quad \exists t \in S^C,\; s^f = t^f \text{ and } \widetilde{\varphi_X} \in E^C(t)(N)$$

$$X \in E^f(s)(G \subset N) \quad \text{iff} \quad \forall t \in S^C,\; s^f = t^f \Rightarrow \widetilde{\varphi_X} \in E^C(t)(G)$$

$$s^f \sim^f_i t^f \quad \text{iff} \quad \{\varphi \mid K_i\varphi \in s^f\} = \{\varphi \mid K_i\varphi \in t^f\}$$

$$s \in V^f(p) \quad \text{iff} \quad p \in s$$

where $\varphi_X := \bigvee_{s^f \in X} \varphi_{s^f}$ is the disjunction of a set of filtered states, $\varphi_{s^f} := \bigwedge_{\psi \in s^f} \psi$ is the conjunction of the formulas in a filtered state, and $\widetilde{\psi} := \{t \in S^C \mid \psi \in t\}$. Note that $S^f$ is finite because $\text{cl}(\varphi)$ is, and that $\sim^f_i$ is an equivalence relation by definition. For this model we will use the notation $s^f \approx^f_G t^f := (s^f, t^f) \in (\bigcup_{i \in G} {\sim^f_i})^*$ for the common knowledge path.

These definitions can be translated quite directly into Lean, although it might not look so direct, due to again having to distinguish between sets and finite sets in Lean. Thus, to define $S^f$ in Lean, we start with $\text{cl}(\varphi)$, as this is a `Finset`. We take the powerset of $\text{cl}(\varphi)$, which Lean knows must also be finite. This finite powerset is filtered with `Finset.filter` to include only those elements $s^f$ for which there exists some $s \in S^C$ such that $s^f = s \cap \text{cl}(\varphi)$. In order to check $s^f = s \cap \text{cl}(\varphi)$, we need both to be of the same data type and therefore convert both to sets. Finally, we pair each state $s^f$ with a proof that it is produced by the filter, using `Finset.attach`.

```lean
def S_f {agents form : Type} (m : modelCL agents) [SetLike m.f.states form]
    (cl : form → Finset (form)) (φ : form) : Type :=
  Finset.attach (Finset.filter
    (λ sf => ∃ s : m.f.states, {x | x ∈ cl φ ∧ x ∈ s} = {x | x ∈ sf})
    (Finset.powerset (cl φ)))
```

Note that we do not impose strong requirements on the model in the definition of $S^f$, so long as the states contain a set of formulas, as enforced by the hypothesis `[SetLike m.f.states form]`. Doing so allows us to keep our definition simpler and more generic, by removing the need for hypotheses needed to create our canonical model (for instance that $N$ is nonempty).

Next we define the subformulas $\varphi_X$ and $\varphi_{s^f}$ which are needed to define $E^f$:

```lean
variable {agents form : Type} [Pformula form]
  {m : modelCL agents} [SetLike m.f.states form]
  {cl : form → Finset (form)} {φ : form}

noncomputable def phi_s_f (sf : S_f m cl φ) : form :=
  finite_conjunction (Finset.toList (sf.1))

noncomputable def phi_X_list : List (S_f m cl φ) → List form
  | List.nil      => List.nil
  | (sf :: ss)     => ((phi_s_f sf) :: phi_X_list ss)

noncomputable def phi_X_finset (X : Finset (S_f m cl φ)) : form :=
  finite_disjunction (phi_X_list (Finset.toList X))

noncomputable def phi_X_set (X : Set (S_f m cl φ)) : form :=
  phi_X_finset (Finite.toFinset (Set.toFinite X))
```

Here the `variable` statement adds the hypotheses to each subsequent declaration. Defining $\varphi_{s^f}$ in Lean (`phi_s_f`) is as simple as converting our finite set to a list (putting the elements in an arbitrary order) and then creating a conjunction from that list. We then define $\varphi_X$ in several steps. First we define a function `phi_X_list` to map $X$ to $\{\varphi_{s^f} : s^f \in X\}$. Next, we define $\varphi_X$ for finite sets, as we can convert that finite set to a list, map it to formulas with `phi_X_list`, and then return the disjunction of that mapped list. Lastly, for the `Set` datatype, we define $\varphi_X$ by converting to a `Finset`, which we can do because $X \subseteq S^f$ is a set of a finite type.

Although it would suffice logically to work with a `List` of filtered states, we provide the definition `phi_X_set` in higher generality for two reasons. Firstly, this approach more closely matches the definitions in the paper proof. Secondly, the definition should intuitively not depend on a choice of order on the states, so we make this independence explicit in the datatypes. Splitting this definition up into three parts may seem to add complexity. However, it allows us to define lemmas about each data type, thereby breaking proofs down into smaller steps. We can prove lemmas more easily for a list, which is ordered, finite, and allows induction. Then, it is easy to show that if some lemma holds for a list, it must work for a list created from a (finite) set. Keeping track of the converted datatypes and how they relate to one another within a single lemma is non-trivial (and not always possible) in Lean. Thus in Lean we often prove some result about $\varphi_X$ across three lemmas, one for each datatype: `Set`, `Finset` and `List`.

Given our definition(s) for $\varphi_X$, it is straightforward to define $E^f$, and then our whole model $M^f$. We thus omit these Lean translations.

### 8.3 Playability of the Filtered Canonical Model

We prove that $M^f$ meets the requirements for being a CLC model. We have to show that for an arbitrary state $s^f$ in the filtered model, $E^f(s^f)$ is truly playable [1, Proposition 1]. This proof relies on the fact that $E^f$ is defined from $E^C$. We are therefore able to exploit the fact that the first five true playability conditions hold in $E^C$ to prove that they must also hold in $E^f$. In Lean we really benefit from our generic typeclasses here, as our proofs that $E^C$ meets those playability conditions are written to hold for any logic that extends CL. Recall that the final true playability condition must hold in $E^f$ because $M^f$ is finite [12].

To formalize this proof, we first expand the proof by Agotnes and Alechina, into a proof with similar levels of detail to a Lean formalization. We aim for a level of detail such that each step in our extended paper proof translates roughly into one step in Lean, possibly with some reshaping. To illustrate this procedure and the level of detail required we present our extended paper proof for Condition 3 of true playability (Definition 1), which was the most interesting to formalize in Lean.

**$E^f(s^f)$ is $N$-maximal** (for every $X \subseteq S^f$, if $(S^f \setminus X) \notin E^f(s^f)(\emptyset)$, then $X \in E^f(s^f)(N)$) is shown by the following sequence of proof steps:

1. Pick some $X \subseteq S^f$ such that $X^c = (S^f \setminus X) \notin E^f(s^f)(\emptyset)$.
2. $\neg(X^c \in E^f(s^f)(\emptyset))$, from Step 1.
3. $\neg\big(\forall t \in S^C : s^f = t^f \Rightarrow \widetilde{\varphi_{X^c}} \in E^C(t)(\emptyset)\big)$, from Step 2 and by definition of $E^f$.
4. $\exists t \in S^C : s^f = t^f$ and $\widetilde{\varphi_{X^c}} \notin E^C(t)(\emptyset)$, from Step 3.
5. $\vdash \varphi_{X^c} \leftrightarrow \neg\varphi_X$, because $\vdash \varphi_{S^f}$ and $\forall s, t \in S^{C\prime},\; s^f \neq t^f \Rightarrow \vdash \varphi_{s^f} \to \neg\varphi_{t^f}$.
6. $\exists t \in S^C,\; s^f = t^f$ and $\widetilde{\neg\varphi_X} \notin E^C(t)(\emptyset)$, from Step 4 and 5.
7. $\exists t \in S^C,\; s^f = t^f$ and $(\widetilde{\varphi_X})^c \notin E^C(t)(\emptyset)$, from Step 6, because all $s \in S^C$ are maximally consistent.
8. $\exists t \in S^C,\; s^f = t^f$, and $\widetilde{\varphi_X} \in E^C(t)(N)$, provided $s = t$, from Step 7, because $E^C(t)$ is $N$-maximal: $(\widetilde{\varphi_X})^c \notin E^C(t)(\emptyset) \Rightarrow \widetilde{\varphi_X} \in E^C(t)(N)$
9. $X \in E^f(s^f)(N)$, from Step 8, by definition of $E^f$.

In this expanded proof the only step that is not straightforward to formalize in Lean is Step 5. We elaborate on the process of formalizing this step as it is a good illustration of working with our Lean definition(s) of $\varphi_X$. For space we do not expand on the proofs that $\vdash \varphi_{S^f}$ and $\forall s, t \in S^{C\prime},\; s^f \neq t^f \Rightarrow \vdash \varphi_{s^f} \to \neg\varphi_{t^f}$. In Lean these proofs are given in the lemmas `univ_disjunct_provability` and `unique_s_f` respectively. To show $\vdash \varphi_{X^c} \leftrightarrow \neg\varphi_X$, in the $\Leftarrow$ direction we first use a lemma defined elsewhere called `phi_X_set_disjunct_of_disjuncts`, which proves that $\vdash(\neg\varphi_X \to \varphi_Y) \Leftrightarrow \vdash(\varphi_{X \cup Y})$, to change the goal to $\vdash \varphi_{X \cup X^c}$. This lemma is trivial on paper by definition of $\varphi_X$, but requires unfolding the definitions and their respective datatype in Lean. Next we change the goal to $\vdash \varphi_{S^f}$, with the lemma `union_compl_self`, because the union of a set and its complement is the universe. Lastly, we can use `univ_disjunct_provability` to prove this goal:

```lean
apply (phi_X_set_disjunct_of_disjuncts _ _).mpr
rw [union_compl_self X]
apply univ_disjunct_provability
```

For the $\Rightarrow$ direction, we cannot so immediately apply the relevant lemma `unique_s_f`, as this lemma refers to single elements (filtered states) in our sets $X$ and $X^c$. We will eventually use an inductive proof to consider a single element in $X$. In Lean we will therefore need to work with a list datatype and will need to unfold our definitions of $\varphi_X$ accordingly. We create a lemma per data type: `phi_X_set_unique`, `phi_X_finset_unique` and `phi_X_list_unique`, which show the slightly generalized result that $\vdash \varphi_X \to \neg\varphi_Y$ holds for any disjoint sets $X, Y \subseteq S^f$. Our actual proof simply applies this first lemma:

```lean
apply phi_X_set_unique hcl (compl_inter_self X)
```

where `compl_inter_self` is a lemma proving that a set and its complement are disjoint, and `hcl` is a proof that our closure is closed under single negations. The need to pass this condition of our closure forward highlights how verification makes explicit exactly when and for which purpose specific hypotheses are used. In this case we will eventually pass this hypothesis to the lemma `unique_s_f`.

The interesting work is within `phi_X_list_unique`. We have converted $X$ into `sfs : List (S_f M cl φ)`, where `S_f M cl φ` corresponds to $S^f$ for the canonical model $M$ and $Y$ into `tfs : List (S_f M cl φ)`. The proof is first inductive on $X$. The case when $X$ is empty is trivial because $\varphi_{[]}$ is defined as $\bot$ in Lean. Thus we unfold the definitions `phi_X_list` and `finite_disjunction`, and then use `explosion`, which represents the propositional lemma $\forall\psi,\; \vdash \bot \to \psi$.

```lean
induction' sfs with sf sfs ihsfs generalizing tfs
· -- sfs = []
  simp only [phi_X_list, finite_disjunction, explosion]
```

So let `sfs` contain at least one element `sf` at the head of the list, and call the rest of the list `sfs'`. Then we can split $\vdash (\varphi_{s^f} \vee \varphi_{X'}) \to \neg\varphi_Y$ into two cases, where the latter follows from the induction hypothesis `ihsfs`. Note that the `sorry` keyword in the snippet below indicates a proof omitted from the paper for presentation purposes; the omitted proof is included below and in the full formalization source code.

```lean
· -- sfs = sf :: sfs'
  simp only [phi_X_list, finite_disjunction]
  apply or_cases
  -- ⊢ phi sf → ¬ phi tfs
  · sorry -- Proof included below
  -- ⊢ phi sfs' → ¬ phi tfs
  · apply ihsfs
    apply List.disjoint_of_disjoint_cons_left hdis
```

Here the lemma `List.disjoint_of_disjoint_cons_left` shows that `sfs'` and `tfs` must be disjoint when `sfs` and `tfs` are disjoint (represented by `hdis` in Lean).

For the case $\vdash \varphi_{s^f} \to \neg\varphi_Y$, we perform induction on $Y$ (`tfs`). Again here the base case of an empty list holds by propositional logic, so assume `tfs` contains at least one element `tf` at the head of the list, and call the rest of the list `tfs'`. We now look at the contrapositive of our goal: $\vdash (\varphi_{t^f} \vee \bigvee_{u^f \in tfs'} \varphi_{u^f}) \to \neg\varphi_{s^f}$. Again we have two cases. For the former we can apply lemma `unique_s_f` where we prove $s^f \neq t^f$ by contradiction, based on the disjointness of both lists. The latter case is solved with the (new) induction hypothesis (`ihtfs`).

```lean
· induction' tfs with tf tfs ihtfs
  · simp only [phi_X_list, finite_disjunction]
    exact mp _ _ (p1 _ _) iden -- applying propositional lemmas
  · simp [finite_disjunction] at *
    -- contrapositive
    refine contrapos.mp (cut dne (or_cases ?_ ?_))
    -- ⊢ phi tf → ¬ phi sf
    · apply unique_s_f hcl
      by_contra h
      simp only [h] at hdis
    -- ⊢ phi tfs' → ¬ phi sf (proved with ihtfs and propositional lemmas)
    · rw [← contrapos]
      exact cut dne (ihtfs hdis.2.1 hdis.2.2)
```
