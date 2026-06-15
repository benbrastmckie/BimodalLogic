## 6 No gaps between equivalence classes

We know that the Prior axioms ensure that there will not be any definable gaps in a model. To show that our model can be made into a model over the reals we actually need a stronger result. We need to know that a certain type of definable equivalence relation also does not have its equivalence classes ending at gaps. First some definitions.

The *intervals* of a structure $M$ are just the convex subsets of $M$ and we will use the usual $(a, b]$, etc., notation for them.

If $S$ is a subset of the domain of a temporal structure $M$ (usually $S$ will be an interval here) then we write $M \mid S$ for the temporal structure with domain $S$, ordering as in $M$ and interpretation of atoms just the restrictions of the interpretations in $M$ to $S$. $M \mid S$ is called the *substructure* of $M$ with domain $S$.

Suppose that $\varepsilon(x, y)$ is a monadic formula with two free variables $x$ and $y$. We say that $\varepsilon$ defines a *contemporaneous equivalence relation* if and only if on any temporal structure $M$, if we define the binary relation $\sim_M$ by

$$a \sim_M b \quad \text{iff} \quad M \models \varepsilon(a, b),$$

then

- $\sim_M$ is an equivalence relation on the domain of $M$,
- $\sim_M$ partitions $M$ into intervals and
- $\varepsilon$ depends only on contemporary properties: i.e. for all $a, b \in M$,
$$M \models \varepsilon(a, b) \quad \text{iff} \quad M \mid [a, b] \models \varepsilon(a, b).$$

A binary relation $\sim$ on a structure $M$ is called a *contemporaneous equivalence relation* if and only if it is defined as $\sim_M$ by such an $\varepsilon$.

We prove that no so defined contemporaneous equivalence relation has equivalence classes ending at gaps in any Prior structures.

Given such an $\varepsilon$, define $\rho(x)$ as

$$\exists y > x\ \neg\varepsilon(x, y) \wedge \neg\exists z(x < z \wedge \varepsilon(x, z) \wedge \forall y(x < y < z \to \varepsilon(x, y)))$$

This says that $x$'s $\sim$-class ends in a gap on the right. Dually we can define $\lambda(x)$ about left ends. Note that the end of the whole structure is not a gap and that $\rho$ will not hold of points in the last $\sim_M$ class (if there is such a class).

Now by the expressive completeness of $U$ and $S$ there is temporal $R$ true in any Prior structure exactly where $\rho(x)$ is.

**Lemma 2.** *Suppose that $\varepsilon$ defines the contemporaneous equivalence relation $\sim_N$ on any structure $N$.*

*Then there is a $US$-formula $R$ which holds in any Prior structure $N$ exactly at those points whose $\sim_N$-class ends in a gap on the right.*

Dually $L$.

Now suppose that $M$ is a Prior structure and that $\sim = \sim_M$ is a contemporaneous equivalence relation defined by $\varepsilon$. Although we will only need to consider densely ordered $M$ for the real numbers proof, it will be seen that we prove the result for any Prior structure.

**Lemma 3.** *The maximal intervals in which $R$ holds are open intervals which, if bounded, have elements of $M$ as their (excluded) end points.*

**Proof.** Suppose that $R$ holds at $t \in M$. Clearly $\rho$ holding at $t$ implies that $R$ will hold for a while after $t$: up until a gap in fact. Thus $t$ is in a non-singleton interval of $R$. It is possible that $R$ holds for ever after $t$.

If $R$ does not hold for ever after $t$ then Prior-U applied to $R$ implies that $M$ contains a last point of this stretch of $R$ (plainly impossible given $\rho$) or a first point of $\neg R$. This is as claimed.

Now look to the left of $t$. Looking back from just after $t$ we can use Prior-S and see that either $R$ is true always before $t$, there is a last point of $\neg R$ just before this stretch of $R$ or there is no last point of $\neg R$, but instead a first point of $R$. We must rule out the third case. Note that in the case of $M$ not being dense there may be both a last point of $\neg R$ and a first point of $R$: this possibility, subsumed in the second case above, is acceptable in that it implies an excluded end point.

Suppose, for contradiction, that $s$ is this first point of $R$ so that $M \models (R \wedge K^-(\neg R))(s)$. The $\sim$-class containing $s$ can not stretch for ever into the future for then it does not end in a gap. Neither can it stretch to the end of the maximal interval of $R$ as it would again not end at a gap.

Thus there are other classes in this interval continuing on the other side of the gap which ends $s$'s. And for a while after the gap $R$ continues to be true: we have not reached the end of the interval yet. Thus $R \wedge K^-(\neg R)$ does not hold at the left hand end of any of these classes.

Let $B$ be the temporal formula saying that the $\sim$-class we are now in begins with a point satisfying $R \wedge K^-(\neg R)$. $B$ exists by expressive completeness. $B$ holds in $s$'s class up to the gap and is false arbitrarily soon after the gap. This contradicts Prior-U applied to $B$. $\blacksquare$

**Lemma 4.** *There is no last class and no first class in any maximal interval of $R$.*

**Proof.** The last class in a maximal interval of $R$ wouldn't end in a gap.

By expressive completeness, the formula

$$\rho(x) \wedge \forall y < x\ (y < z < x \wedge \varepsilon(y, z))$$

has a temporal equivalent which is true only in the first classes of maximal intervals of $R$. If there is a first class then no immediately subsequent classes satisfy this and so we have this formula holding up to a gap and false arbitrarily soon afterwards. This contradicts Prior-U. $\blacksquare$

**Lemma 5.** *If a temporal formula holds somewhere in one $\sim$-class in a maximal interval of $R$, then it holds somewhere in each $\sim$-class in the interval.*

*Furthermore, each pair of the $\sim$-classes in a maximal interval of $R$ are elementarily equivalent (taken as substructures of $M$).*

**Proof.** For a contradiction to the first statement, suppose that $A$ holds in one class but not anywhere in some other class in the same maximal interval of $R$.

Using expressive completeness and $\varepsilon$, find $B$ which is true at points only if $A$ occurs somewhere in their $\sim$-class. By using $\neg B$ instead if necessary we may suppose that we have $B$ holding throughout one $\sim$-class in our maximal interval of $R$ and false throughout a later class. Choose a point $t$ in this former class in which $B$ holds. $B$ holds in the whole of a class if it is true anywhere at all in the class so it continues for a while after $t$. By Prior-U there is either a last point where $B$ holds after $t$ (not possible as $B$ must continue for a while) or a first point $s > t$ where $\neg B \wedge K^-(B)$ holds.

So $s$ must be the left hand end point of its $\sim$-class. Look at the gap at the right hand end of this class. We can not have $B$ arbitrarily soon after the gap because of Prior-U. Thus for a while after this class $B$ stays false.

Let $C$ be the temporal formula saying that we are now in a class whose left hand end point is also in the class and at that point $K^-(B)$ holds. Now $C$ is true in $s$'s class but false afterwards contradicting Prior-U.

Now consider the second statement in the lemma. Given a monadic sentence $\phi$, we relativise it by restricting quantifiers to where $\varepsilon(x, -)$ holds. We get a formula $\phi'$ of one free variable. By expressive completeness this is equivalent to a temporal formula. This is true exactly throughout $\sim$-classes which model $\phi$. Then, by the first part of the lemma, it can't be true somewhere and false elsewhere in the interval. $\blacksquare$

We define a *bad point* to be where $R \vee L$ holds. We define a *bad interval* as a non-empty and maximal one in which $R \vee L$ holds throughout.

**Lemma 6.** *Bad points only occur in non-singleton bad intervals.*

*In any bad interval both $R$ and $L$ hold throughout. Any bad interval, if bounded, has excluded end points in $M$ (neither $R$ nor $L$ holds at these end points).*

**Proof.** We first show that $L$ holds wherever $R$ does. Suppose for contradiction that we have a maximal interval of $R$ in which $L$ fails to hold somewhere. So $\neg L$ holds throughout at least one $\sim$-class. By the definition of $L$, there are two cases. Either this particular $\sim$-class is one which includes its left hand end point or it is one which begins just after some point of $M$. The class can not be unbounded below for then it would be first in this bad interval.

In fact we can not have a class beginning just after a point $r$ of $M$. Since the class can not be first in the bad interval $r$ itself must be in a $\sim$-class in the bad interval. But $r$'s class can not end in a gap on the right when $r$ must be its right hand end point.

Thus we have a class in the bad interval which includes its left hand end point. It's not hard to use the previous result to show that throughout the bad interval all classes include their left hand end points.

Let $B$ be a temporal formula true at times which are not left hand end points of their $\sim$-classes. $B$ is then true continuously in any class from just after the left hand end point up until the gap at the right hand end point. $B$ must be false arbitrarily soon after the gap contradicting Prior-U.

Using mirror images of the above and previous results we get our proof. $\blacksquare$

**Lemma 7.** *If a formula $B$ is true for a while at the start of a $\sim$-class in a bad interval then it holds throughout the bad interval. Similarly at the end.*

*If a formula is true anywhere in a bad interval it is true arbitrarily close to each end of each class in the interval.*

**Proof.** Suppose that $\gamma < \delta$ are gaps and that $(\gamma, \delta)$ is a $\sim$-class within a bad interval.

Suppose that $B$ holds for a while after $\gamma$ but that $\neg B$ holds somewhere in the bad interval. By lemma 5, $\neg B$ also holds somewhere in $(\gamma, \delta)$.

Using $\varepsilon$ and expressive completeness we can find a temporal formula $C$ which is true only at points within a $\sim$-class after some $\neg B$ in that class. $C$ will be false for a while at the beginning of each class and then true for a while at the end.

In fact $C$ is true for a while up to the gap at the end and false arbitrarily soon after the gap. This contradicts Prior-U.

Applying the above to the negation of a formula gives us the second part. $\blacksquare$

Let us see what happens if we interfere with $M$ by replacing a whole bad interval by one of its $\sim$-classes.

Let $Q^-$ be the subset of the domain of $M$ being all that precedes the bad interval. Let $Q^+$ be all that follows. Either or both of these may be empty. Let $Q_0$ be the bad interval itself and $I$ be any one of its $\sim$-classes.

We look at $N$, the substructure of $M$ whose domain is just $Q^- \cup I \cup Q^+$.

**Lemma 8.** *For all temporal formulas $A$, for all $t \in N$,*

$$M \models A(t) \quad \text{iff} \quad N \models A(t)$$

**Proof.** We proceed by induction on the construction of $A$. The cases of atomic and boolean $A$ are immediate. Now consider $U(A, B)$: $S(A, B)$ is similar.

$(\Rightarrow)$: Consider then when $M \models U(A, B)(t)$ with $t \in N$. Say that $s \in M$, that $t < s$, that $M \models A(s)$ and for all $u \in M$, if $t < u < s$ then $M \models B(u)$.

There are several cases.

1. $t < s \in Q^-$: Apply the induction hypothesis to $A$ and $B$ at $s$ and at all points in between.

2. $t \in Q^-$ and $s \in Q_0$: $A$ holds somewhere in $Q_0$ so somewhere in $I$ (by lemma 7). So holds there in $I$ in $N$. $B$ holds for a while into $Q_0$ so, by lemma 7, holds everywhere in $Q_0$. By the induction hypothesis, $B$ holds everywhere in $I$ in $N$. Hence result.

3. $t \in Q^-$ and $s \in Q^+$: We can deduce that $B$ holds throughout $I$ in both $M$ and $N$ and get the result.

4. $t < s \in I$: Straightforward use of inductive hypothesis.

5. $t \in I$ and $s$ later in $Q_0$: Again by lemma 7 we have $B$ true throughout $I$ in $M$ and so in $N$. Since $A$ is true somewhere in $Q_0$ in $M$, lemma 7 tells us that $A$ is true arbitrarily close to the end of $I$ in $M$ and so in $N$. This gives us our result.

6. $t \in I$ and $s \in Q^+$: $B$ is true throughout $I$ and we have our result.

7. $t < s \in Q^+$: Apply induction hypothesis to $A$ and $B$ at $s$ and at all points in between.

$(\Leftarrow)$: Consider then when $N \models U(A, B)(t)$. Say that $t < s$, that $N \models A(s)$ and for all $u \in N$, if $t < u < s$ then $N \models B(u)$.

Again there are several cases:

1. $t < s \in Q^-$: Apply induction hypothesis to $A$ and $B$ at $s$ and at all points in between.

2. $t \in Q^-$ and $s \in I$: $B$ holds from $t$ up until the end of $Q^-$ in both $M$ and $N$. $B$ holds at the beginning of $I$ in $N$ and so in $M$. By lemma 7 $B$ holds throughout $Q_0$. $A$ holds in $I$ in $N$ and so in $M$ and we have our result.

3. $t \in Q^-$ and $s \in Q^+$: $B$ holds throughout $I$ in $N$ and so in $M$. Lemma 7 tells us $B$ holds throughout $Q_0$ in $M$.

4. $t < s \in I$: Straightforward use of inductive hypothesis.

5. $t \in I$ and $s \in Q^+$: $B$ is true throughout $I$ and we have our result.

6. $t < s \in Q^+$: Apply induction hypothesis to $A$ and $B$ at $s$ and at all points in between. $\blacksquare$

**Lemma 9.** *In fact there can't have been any bad points anyway.*

**Proof.** By lemma 8, $R$ holds in $I$ in $N$.

But by lemma 2, $R$ holds at a point in any Prior structure (not just $M$) if and only if the $\sim$-class of the point ends in a gap (where $\sim$ is the appropriate equivalence relation for the structure). And $N$ is a Prior structure: we still have all the instances of Prior-U/S continuing to hold as any counterexample point in $N$ is also one in $M$.

By the contemporaneity of $\varepsilon$, $I$ as a subset of $N$, like $I$ as a subset of $M$, is all in one $\sim_N$-class. Could the class be bigger now?

$R$ is true of this class so that it is bounded above amongst other things. Thus $Q^+$ is non-empty and by lemma 6 begins with a point $q$ say. Also by lemma 6 $\neg R$ holds at $q$ in $M$ and so in $N$. Clearly $q$ is not in the class of $I$ in $N$. Thus the class ends just before $q$.

$R$ can not have been true in this class after all. $\blacksquare$

Thus we have proven...

**Theorem 4.** *Suppose that $\sim$ is a contemporaneous equivalence relation on a Prior structure $M$.*

*Then the $\sim$-classes do not end at gaps.*
