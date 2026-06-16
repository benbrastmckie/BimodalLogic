### 4.7. Equivalence results. There are two equivalence results which are useful for

relating some of the semantic approaches to CTL*. The proofs are straightforward. 

**Lemma 2.** *The following are equivalent:*

a) ⊨_B validity i.e. SC + FC path frame validity; 
b) bundled ω-tree validity; 
c) (N x W)-Ockhamist validity. 
The following equivalence result is of vital importance to the proof of soundness 
of our axiom system for ⊨_C. It follows from results in [Emerson and Sistla, 1984]. 

**Lemma 3.** *The following are equivalent:*

a) =c validity i.e. Kripke validity 
b) suffix,fusion and limit closedpath frame validity 
c) R-generable path frame validity 
d) complete ω-tree validity 
Note that the equivalence between a) and d) follows from a particularly close 
relationship between Kripke frames and ω-trees: a tree is just a Kripke frame with 
the accessibility relation defined in terms of immediate successors while a tree can 
be produced by unraveling the fullpaths on a given Kripke frame. 

### 4.8. An inequivalence result. We now show that ⊨_B and =c are distinct notions

of validity. 
Note that for complete ω-trees we have ⊨_C y where y = A G(p -* EX p) 
> 
(p -* E G p). 
However, this is not valid on bundled trees. To see this, in a slightly indirect way, 
consider the (N x W)-frame shown in figure 3 in which W = N and (n, u) -(m, v) if 
either (n,u) = (m, v) orn = m andbothn < u andn < v. Supposethatp E g(n, u) 
iffn < u. It is clear that we have (T, <,--, g), (0, 0) = A G(p -* E X p) A p A A F -p 
and so V=B Y. 
It is very interesting to also consider the bundled ω-tree corresponding to this 
Ockhamist structure. Take T = {(n,m) c N x NIn < m}. Put (a,b) < (c,d) 
iff(a = c and b < d) or a = b < c. Let D = {(n, n)In c N} E B(T, <) and define

-I 
-PI 
PI 
P I 
o 
0 
0 
_ 
_ 
-IP 
¬PI 
if 
__ 
o 
0 
0 
0 
__0_ 
--lpl-, 
IP 
1 
I 
__ 
P t I 
_ 
P t I 
_ 
o 
0 
_ 
_ 
0 
_ 
-PtI 
P_ 
P I 
P I 
o 
0 
__ 
0 
__ 
0 
__ 
0 
_ 
P tI 
_ _ 
P t 
___ 
P t 
___ 
P t 
___ 
P t 
___ 
o 
0 
0 
0 
0 
etc. 

*Figure 3. The Ockhamist Counter-example*

the bundle to be B = B(T, <) \ {D}. Finally define g so that (n, m) E g(p) iff 
n = m. See figure 4. Of course we have (T, <,B, g), (0,0) t 
-y as well. 
m 
P 
P 
P 
P 
P 
n 

*Figure 4. The Counter-example, tree-style*


### 4.9. Emergent branches. As well as establishing the inequivalence Of ⊨_B

and 
oc, this example also gives a good illustration of the idea of an emergent branch 
appearing from an Ockhamist construction. In particular note that the branch

D in the ω-tree does not correspond to any set up(n, w) in the Ockhamist frame. 
It is not in the bundle defined in the correspondence. In general converting an 
Ockhamist frame, even with a countable set W, to an ω-tree can produce a possibly 
uncountable number of such emergent branches. This fact will cause us a major 
difficulty in the completeness proof: we can make sure all the constructed branches 
satisfy a desired property at all finite stages of the construction of an Ockhamist 
frame but then discover a large number of extra branches emerge when we take the 
limit. We will need extra machinery to make sure that these emergent branches 
satisfy the desired property. 
In terms of Kripke structures the fact(problem) of emergent branches is seen here 
by viewing the ω-tree (T, <) as a Kripke structure (T, R, g) where (n, m)R(n, m + 1) 
and (n, n)R(n + 1, n + 1). This is just the Kripke structure we get by defining R in 
terms of immediate <-successors as we need to do in lemma 3. It is clear that we 
have a fullpath ((0, 0), (1, 1), (2, 2).... ) which is not in the bundle which is defined 
by the Ockhamist frame. The fullpath is emergent. 

## §5. The axiom system for bundled trees. Axioms for bundled validity will form

part of our final axiom system. Consider a system for bundled validity. The 
inference rules are modus ponens and temporal and path generalization: 
a, a-fi 
a 
a 
fi 
Ga 
A a' 
The axiom schemes include the usual ones for PLTL (as seen earlier): plus axioms 
ensuring that the path modality A behaves as in the modal logic S5 
C9 A(a- *fi) --(Aa 
--Af) 
CIO Aa--*AAa 
Cli 
A a- +a 
C12 a - 
AEa 
C13 A -a <--, Ea 
plus propositional atoms only depend on states 
C14 
p -* A p, for each atomic proposition p 
plus some interaction between modalities 
C15 A Xa- *XA a 
We define derivability ⊢_B using this system in the usual way. 
Note that we do not use a substitution rule as it is not valid for ⊨_B. 
For example 
tB 
(E p -* p) is valid for each atomic proposition p (and can be derived easily) 
but FrB (E a -- a ) is not generally valid. 
We could show that 

**Lemma 4** ([Stirling, 1992])**.** *⊢_B is sound and (weakly) complete for ⊨_B-*

Soundness is the usual straightforward induction on the lengths of proofs. Com- 
pleteness (for an equivalent but slightly different set of axioms) is shown in [Stir- 
ling, 1992] by building a SC+FC path structure. In what is actually quite a similar 
technique, despite appearances, one could also use a step by step method via Ock- 
hamist frames to produce a bundled ω-tree structure. This style of proof is seen in 
proofs by Burgess, Zanardo and von Kutschera for logics of historical necessity. In 
fact, this method forms the basis for our ⊨_C completeness proof later in the paper.

By removing most of the machinery associated with the automaton and the banning 
procedure, we would be left with a completeness proof for [-B. 
Note that the example y from the previous section shows that the system for H-B 
is incomplete for ⊨_C. 
Of course, this system is sound for ⊨_C. 
In the next two 
sections we introduce a new axiom and new rules of inference to allow us to derive 
the extra validities. 

## §6. The limit closure axiom. Intuitively, the new limit closure (LC) axiom schema

captures a particular form of limit closure. Suppose that some state formula E a, 
say, is always (at all points on all branches) at the start of a finite path of E fi states 
leading up to a new E a state. Also suppose that E a holds at some node. Then it 
is clear that from that node extends a branch on which (E f) U(E a) always holds. 
LC: 
A G(E a - 
EX((E/3) 
U(E a))) 
-* 
(Ea 
-* E G((Efi) U(Ea))) 

**Lemma 5.** *The LC axiom schema is soundfor ⊨_C.*

PROOF. Suppose that (T, <, V) is a (complete) ω-tree structure with a node to c T 
and 
(T, <, V), to t A G(E a - 
E X((E /) 
U(E a))) A E a. 
We are to show that (T, <, V), to # E G((E/3) U(Ea)). 
We will find a sequence of nodes to < t1 < ... from T such that 
* (T,<, V),tk -E a and 
* for each s such that tk < 
< tk+1, we have (T, <, V), s t Ei. 
We already have to chosen. Suppose for the induction we have chosen an appro- 
priate tk with (T, <, V), tk t Ea. By assumption 
(T, <, V), tk t EX((E P) U(E a)). 
This gives us some tk+1 > tk along some branch starting at tk, with (7T, <, V), tk+1 # 
Ea and (T, <, V), s t E/ for each s such that tk <s < tk+l. 
Let 7r be the branch of (T, <) which starts at to and includes to < t1 < .... 
By construction we have 
(T. <, V), 7r t- G((E P) U(E a)): 
for all n < co, either 7n = to when we put k = 0 or there is some k > 0 such 
that tkl I < mC < tic and so we have (T7 <, V), tk t Ea and at any s with Cn < 
s < tk we have (T, <, V), s t E/. 
It follows immediately that (T. <, V), to t 
E G((E P) U(E a)). 
So the LC axiom is valid on ω-tree structures. By lemma 3, it is valid for ⊨_C. 

∎


## §7. The auxiliary atoms rule. The Auxiliary Atoms (AA) rule allows the use of

a certain arrangement of fresh atoms in a proof. Suppose that L and Q are disjoint 
sets of atoms. Suppose that A, which only uses atoms from L, is the formula which 
we are interested in deriving. The rule will involve another formula 0, using atoms 
from L U Q. The formula 0 describes the arrangement of the fresh atoms, ie those in 
Q, in terms of those in L. The AA rule will allow F t to be derived from F- (0 A 
) 
under certain side-conditions.

As we will see in example derivations below in section 16, the AA rule can be 
used in conjunction with the LC schema to derive a formula stating the existence of 
a fullpath satisfying a certain desired property The LC schema allows us to deduce 
the existence of the infinite fullpath from the existence of a finite cycle of states. The 
fresh atoms can be used as markers placed along the cycle for various reasons. For 
example they can be used to record that various states are visited in the cycle. They 
can also be used to distinguish several visits to one state within the cycle, indicating 
that at one visit a certain successor state should be chosen and on another visit a 
different successor state should be chosen. For the purposes of theorem-proving, 
deriving V say, the AA rule will be used as follows. First show that V is true when 
the fresh atoms are arranged according to 0, i.e. show F- (0 A) 
and then use the 
AA rule to immediate effect. 
Of course, the rule is also "used" in our completeness proof. We use the fresh 
atoms to record the states of a certain linear time automaton as it trundles along the 
branches of a tree. We eventually want to check whether the branches are accepted 
or not to see whether they satisfy a certain temporal formula. In the completeness 
proof, we will have assumed that a formula -AV, say, is consistent and we will be 
wanting to build a model of ¬A. Using the AA rule (in a contrapositive way) we 
will immediately know that 0 A -V is also consistent. The specific formula 0 which 
we will use here will describe an arrangement of the atoms to record the running 
of our automaton. So ¬V being consistent implies a description of a model of - 
with the automaton's state recorded in fresh atoms is also consistent. 
Note that there is no necessary connection between the AA rule and automata. 
(In fact, the acceptance criteria of automata has no counterpart in the AA rule, and 
so we should really only be discussing finite state machines here). The AA rule is 
just a rule which allows fresh atoms to be introduced into a proof in accordance with 
a fairly prescriptive arrangement. However, in our completeness proof we are going 
to use the rule to allow our construction to make use of an automaton. Further, as 
we will see in some example derivations later, uses of the AA rule in theorem-proving 
may well be motivated by consideration of certain automata. Finally, we will see 
that an understanding of automata will help with an intuitive understanding of the 
rule. 
Obviously the AA rule must have a substantial side-condition: it can not always 
be sound to derive F- V from F- (0 - 
V). In terms of consistency/satisfiability, we 
must state sufficient conditions on 0 under which 0 can be added as a conjunct to 
any formula ¬V with satisfiability preserved. 
In fact, a very general class of such formulas 0 exists. It is easy to see that we 
just need to require that, given any ω-tree structure in the language of L, and any 
point, we can choose the valuations of the atoms in Q so that the state formula 
0 holds at that point of the expanded structure. We might call such formulas 
L + Q-expandable. However, this is a semantic condition on 0 and we instead find 
a syntactic condition which is sufficient to ensure that 0 is in this class. 
The actual syntactic side-condition we uSe for our purposes is slightly compli- 
cated. It says that 0 is a formula which prescribes exactly which atom from Q to 
make true at each point in any w-tree structure in the language of L by working up 
from the root along each branch. We require that 0 makes use of a finite pairwise- 
inconsistent set { al, . . . }, 
an 
of state formulas in the language of L and a function

p to determine which atom to make true at the next point along a branch. We will 
say that such formula 0 is functionally L + Q-expandable. 

**Definition 4.** Say that {a I,

., 
} is a set of formulas using atoms only from 
L such that 
* each ai is a state formula, i.e. a boolean combination of atoms and formulas 
of the form Ef,, 
* for each i #4 j, (ai A aj) 
-* false is a substitution instance of a classical 
tautology and 
* V 
a ai is a substitution instance of a classical tautology 
Suppose that Q is finite (and enumerated in some way), there is bo C Q and a 
function p: (Q x {1, . . ., 
* Q such that 
n 
0 bo A A GAA((b A ai)- 
A Xp(b, i))AA 
A -A(b A b'). 
bcQ i=1 
blb'CQ 
Then we say that 0 is functionally L + Q-expandable. 
We state the AA rule using this concept as follows: 
AA: 
provided there are disjoint sets L and Q of atoms such that: 
* V only uses atoms from L 
* 0 is functionally L + Q-expandable. 

**Lemma 6.** *The AA rule is soundfor ⊨_C.*

PROOF. We prove this by contraposition: suppose that ¬V is satisfiable, i.e. has a 
complete ω-tree model in the language of L. Say that - 
is true of the branch 2. 
But now a simple recursion on the length of finite prefixes of branches starting at 
no, defines an interpretation of the Q atoms to make 0 true of 2. 
We have a complete ω-tree model of 0 A ¬T and so, via lemma 3, have our 
result. 

∎


## §8. The theorem. Now we have all the axioms and rules of our proof system for

standard CTL* validity. 

**Definition 5.** Let ⊢_C be derivability in the system which results from adding

the limit closure axiom schema and the auxiliary atoms rule to the system ⊢_B for 
bundled trees. 

**Theorem 3.** *⊢_C is sound and (weakly) complete for standard CTL* validity, c.*

PROOF. Soundness follows from the usual induction on the lengths of proofs. We 
can show validity of the axioms including LC in lemma 5 and, from lemma 6, we 
know that the rules preserve validity. Most of the rest of the paper contains the 
completeness proof. We will show that any given consistent formula has a Kripke 
model.

Note that, as with PLTL and =B, the logic is not compact and we can thus only 
manage a weak completeness result. 

∎

