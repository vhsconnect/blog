---
tags: typescript 
title:  X could be instantiated with a different subtype of constraint 'object'.
author: vhs
---

I ran into this error the other day - and felt like this great stack overflow answer by [Flavio Vilante](https://stackoverflow.com/questions/56505560/how-to-fix-ts2322-could-be-instantiated-with-a-different-subtype-of-constraint) needed to be archived.

### The Question

Type X is not assignable to type 'Y'.
'X' is assignable to the constraint of type 'Y', but 'Y' could be instantiated with a different subtype of constraint 'object'.

### The Short Answer

TLDR; There are two common causes for this kind of error message. You are doing the first one (see below). Along with the text, I explain in rich detail what this error message wants to convey.

CAUSE 1: In typescript, a concrete instance is not allowed to be assigned to a type parameter. Following you can see an example of the 'problem' and the 'problem solved', so you can compare the difference and see what changes:

PROBLEM

```ts
const func1 = <A extends string>(a: A = "foo") => `hello!`; // Error!

const func2 = <A extends string>(a: A) => {
    //stuff
    a = `foo`; // Error!
    //stuff
};
```

SOLUTION

```ts
const func1 = <A extends string>(a: A) => `hello!`; // ok

const func2 = <A extends string>(a: A) => {
    //ok
    //stuff
    //stuff
};
```

CAUSE 2: Although you are not doing the below error in your code. It is also a normal circumstance where this kind of error message pops up. You should avoid doing this:

Repeat (by mistaken) the Type Parameter in a class, type, or interface.

Don't let the complexity of the below code confuse you, the only thing I want you to concentrate on is how the removing of the letter 'A' solves the problem:

PROBLEM:

```ts
type Foo<A> = {
    //look the above 'A' is conflicting with the below 'A'
    map: <A, B>(f: (_: A) => B) => Foo<B>;
};

const makeFoo = <A>(a: A): Foo<A> => ({
    map: (f) => makeFoo(f(a)), //error!
});

SOLUTION: type Foo<A> = {
    // conflict removed
    map: <B>(f: (_: A) => B) => Foo<B>;
};

const makeFoo = <A>(a: A): Foo<A> => ({
    map: (f) => makeFoo(f(a)), //ok
});
```

### The Long Answer

Following I'll decompose each element of the error message below:

Type '{}' is not assignable to type 'P'.
'{}' is assignable to the constraint of type 'P', but 'P' could be
instantiated with a different subtype of constraint'object'

WHAT IS TYPE {}

It's a type that you can assign anything except null or undefined. For example:

```ts
type A = {};
const a0: A = undefined; // error
const a1: A = null; // error
const a2: A = 2; // ok
const a3: A = "hello world"; //ok
const a4: A = { foo: "bar" }; //ok
// and so on...
```

WHAT IS is not assignable

To assign is to make a variable of a particular type correspond to a particular instance. If you mismatch the type of the instance you get an error. For example:

// type string is not assignable to type number
const a: number = 'hello world' //error

// type number is assinable to type number
const b: number = 2 // ok

WHAT IS A different subtype

Two types are equals: if they do not add or remove details in relation to each other.

Two types are different: if they are not equal.

Type A is a subtype of type S: if A adds detail without removing already existent detail from S.

type A and type B are different subtypes of type S: If A and B are subtypes of S, but A and B are different types. Said in other words: A and B adds detail to the type S, but they do not add the same detail.

Example: In the code below, all the following statements are true:

```
    A and D are equal types
    B is subtype of A
    E is not subtype of A
    B and C are different subtype of A

```

```ts
type A = { readonly 0: "0" };
type B = { readonly 0: "0"; readonly foo: "foo" };
type C = { readonly 0: "0"; readonly bar: "bar" };
type D = { readonly 0: "0" };
type E = { readonly 1: "1"; readonly bar: "bar" };

type A = number;
type B = 2;
type C = 7;
type D = number;
type E = `hello world`;

type A = boolean;
type B = true;
type C = false;
type D = boolean;
type E = number;
```

NOTE: Structural Type

When you see in TS the use of type keyword, for instance in type A = { foo: 'Bar' } you should read: Type alias A is pointing to type structure { foo: 'Bar' }.
The general syntax is: type [type_alias_name] = [type_structure].
Typescript type system just checks against [type_structure] and not against the [type_alias_name]. That means that in TS there's no difference in terms of type checking between following: type A = { foo: 'bar } and type B = { foo: 'bar' }. For more see: Official Doc.

_WHAT IS constraint of type 'X'_

The Type Constraint is simply what you put on the right side of the 'extends' keyword. In the below example, the Type Constraint is 'B'.

```ts
const func = <A extends B>(a: A) => `hello!`;
```

Reads: Type Constraint 'B' is the constraint of type 'A'
WHY THE ERROR HAPPENS

To illustrate I'll show you three cases. The only thing that will vary in each case is the Type Constraint, nothing else will change.

What I want you to notice is that the restriction that Type Constraint imposes to Type Parameter does not include different subtypes. Let's see it:

Given:

type Foo = { readonly 0: '0'}
type SubType = { readonly 0: '0', readonly a: 'a'}
type DiffSubType = { readonly 0: '0', readonly b: 'b'}

const foo: Foo = { 0: '0'}
const foo_SubType: SubType = { 0: '0', a: 'a' }
const foo_DiffSubType: DiffSubType = { 0: '0', b: 'b' }

CASE 1: NO RESTRICTION

```ts
const func = <A>(a: A) => `hello!`;

// call examples
const c0 = func(undefined); // ok
const c1 = func(null); // ok
const c2 = func(() => undefined); // ok
const c3 = func(10); // ok
const c4 = func(`hi`); // ok
const c5 = func({}); //ok
const c6 = func(foo); // ok
const c7 = func(foo_SubType); //ok
const c8 = func(foo_DiffSubType); //ok
```

CASE 2: SOME RESTRICTION

Note below that restriction does not affect subtypes.

VERY IMPORTANT: In Typescript the Type Constraint does not restrict different subtypes

```ts
const func = <A extends Foo>(a: A) => `hello!`;
// call examples
const c0 = func(undefined); // error
const c1 = func(null); // error
const c2 = func(() => undefined); // error
const c3 = func(10); // error
const c4 = func(`hi`); // error
const c5 = func({}); // error
const c6 = func(foo); // ok
const c7 = func(foo_SubType); // ok <-- Allowed
const c8 = func(foo_DiffSubType); // ok <-- Allowed
```

CASE 3: MORE CONSTRAINED

```ts
const func = <A extends SubType>(a: A) => `hello!`;

// call examples
const c0 = func(undefined); // error
const c1 = func(null); // error
const c2 = func(() => undefined); // error
const c3 = func(10); // error
const c4 = func(`hi`); // error
const c5 = func({}); // error
const c6 = func(foo); // error <-- Restricted now
const c7 = func(foo_SubType); // ok <-- Still allowed
const c8 = func(foo_DiffSubType); // error <-- NO MORE ALLOWED !
```

CONCLUSION

The function below:

```ts
const func = <A extends Foo>(a: A = foo_SubType) => `hello!`; //error!
```

Yields this error message:

Type 'SubType' is not assignable to type 'A'.
'SubType' is assignable to the constraint of type 'A', but 'A'
could be instantiated with a different subtype of constraint
'Foo'.ts(2322)

Because Typescript infers A from the function call, but there's no restriction in the language limiting you to call the function with different subtypes of 'Foo'. For instance, all function's call below are considered valid:

```ts
const c0 = func(foo); // ok! type 'Foo' will be infered and assigned to 'A'
const c1 = func(foo_SubType); // ok! type 'SubType' will be infered
const c2 = func(foo_DiffSubType); // ok! type 'DiffSubType' will be infered
```

Therefore assigning a concrete type to a generic Type Parameter is incorrect because in TS the Type Parameter can always be instantiated to some arbitrary different subtype.

Solution:

Never assign a concrete type to a generic type parameter, consider it as read-only! Instead, do this:

```ts
const func = <A extends Foo>(a: A) => `hello!`; //ok!
```
