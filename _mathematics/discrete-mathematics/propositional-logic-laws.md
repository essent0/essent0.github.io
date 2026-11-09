---
title: Laws of Propositional Logic
order: 2
---

**Commutativity**

$$
P \land Q \equiv Q \land P
$$
$$
P \lor Q \equiv Q \lor P
$$

**Associativity**

$$
(P \land Q) \land S \equiv P \land (Q \land S)
$$
$$
(P \lor Q) \lor S \equiv P \lor (Q \lor S)
$$

**Distributivity**

$$
P \land (Q \lor S) \equiv (P \land Q) \lor (P \land S)
$$

$$
P \lor (Q \land S) \equiv (P \lor Q) \land (P \lor S)
$$

**Complement**

$$
P \lor \neg P \equiv \top
$$

$$
P \land \neg P \equiv \bot
$$

**Identity**

$$
P \lor \bot \equiv P
$$
$$
P \land \top \equiv P
$$

**Domination**

$$
P \land \bot \equiv \bot
$$
$$
P \lor \top \equiv \top
$$

**Idempotent**

$$
P \lor P \equiv P
$$
$$
P \land P \equiv P
$$

**Absorption**

$$
P \lor (P \land Q) \equiv P
$$
$$
P \land (P \lor Q) \equiv P
$$

**Double Negation**

$$
P \equiv \neg\neg P
$$


**DeMorgan**

$$
\neg(P \land Q) \equiv (\neg P \lor \neg Q) 
$$
$$
\neg(P \lor Q) \equiv (\neg P \land \neg Q)
$$

**Quantifier Negation**

$$
\neg(\forall x \in A, \exists y \in B \text{ s.t. } C(x, y)) \equiv \exists x \in A, \forall y \in B \text{ s.t. } \neg C(x, y)
$$

**Conditional Equivalence**

$$
P \to Q \equiv \neg P \lor Q
$$

**Contrapositive Equivalence**

$$
\neg Q \to \neg P \equiv P \to Q
$$

**Biconditional Equivalence**

$$
P \leftrightarrow Q \equiv (P \land Q) \lor (\neg P \land \neg Q)
$$

**Exclusive Disjunction Equivalence**

$$
P \oplus Q \equiv \neg (P \leftrightarrow Q)
$$
