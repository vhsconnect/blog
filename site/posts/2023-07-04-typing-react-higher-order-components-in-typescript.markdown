---
tags: typescript, react
title: Typing React higher order components in Typescript
author: vhs
---

This post is not about React components, it is about React Higher Order Components or HOCs - but to understand HOC, we have a to understand what a React component is. A React component is an abstraction, a function, an encapsulation of view and state - all these things - React will take your component tree and build a virtual dom that it will then append to the document. It's easy seeing the forest for the tree, in this case, it's the tree that is more fuzzy to see. Let's look at what the React docs have to say.

```ts
const Greeter = ({ name }: Props) => <div>hello {name}!</div>;
```

The React docs shows a simple Greeter functional component and goes on to say that **This function is a valid React component because it accepts a single “props” (which stands for properties) object argument with data and returns a React element)**. Ok so then what is a React element. A quick look at the type of `React.ElementType<P>` shows an overload of 173 types - matching a variety of HTML tags but also including React components which themselves can return more React elements. So a reasonable way to think of React components is to think of them as functions that accept `props` and return more React nodes, that can themselves include more React components but don't _need_ to. The evaluation will keep recursively evaluating more nodes until they all resolve to basic hypertext elements. For our purposes what is important to note here is that the return value of the component is not a function in the typical sense. Actually JSX elements are transpiled to functions by React - So for the purposes of this article functions that return JSX are react components, but what about functions that return higher order function that return JSX?

### What are Higher Order Components

HOCs get their name from higher order functions. Common known higher order functions include `map`, `filter`, `reduce`, `fold`, `zip` and many more. But the general idea is that these function take a function and return another function.

```js
const increment = map((x) => x + 1);
```

Increment could operate on any type or data structure. It would actually be determined by our `map` function. If a React component was a data structure then essentially it could have its own map, and it would be an algebraic data structure, a functor. But it's not - it's just a function that returns some markup. What's possible however is for us to affect the return type of a React component - we can do in may ways.

-   Wrap our React node and enhance functionality by passing down props
-   Wrap our React node and enhance functionality by transforming props
-   Wrap our React node and enhance functionality by setting up listeners
-   Wrap our React node and enhance functionality with hooks

You get the picture right? All the tools available to you in React Components are also available to you in higher order components. You just do what you want to do and wrap the target component.

### Composition

Just like higher order functions, HOCs really shine when you compose them together. Your components can stay light weight and you can encapsulate all the redundant logic separately. The result end up looking to something like this.

```js
const myEnhancedComponent = compose(
    withRedux(mapperFunction),
    mapProps(mapperFunction),
    withErrorBoundary,
    RenderOnlyIf(predicateFunction)
)(myComponent);
```

### RenderOnlyIf.tsx, an example

```ts
// just a way to get rid of IntrinsicAttributes type error -
type ReactProps = Omit<React.PropsWithChildren, "children">;

const RenderOnlyIf =
    <P extends ReactProps>(predicate: (arg0: P) => boolean) =>
    (Child: React.ComponentType<P>) =>
    (ownProps: P) =>
        predicate(ownProps) ? <Child {...(ownProps as P)} /> : <></>;
```

This hoc takes a predicate function and will only render the child if the predicate passes. This component is pretty simple to visualize as the `Child` and the wrapped form of `Child` will consume the same shape of props `P`. But what about a component that will not pass down its props unmodified - a common pattern.

### PassDownProps.tsx, another example

Here is a more complex HOC. It will pass down some variables as props to a child component.

```ts
const PassDownProps =
    <S, P extends S>(props: S) =>
    <O extends Omit<P, keyof S>>(
        Child: React.ComponentType<P>
    ): React.ComponentType<O> =>
    (ownProps: O) => <Child {...{ ...(props as P), ...(ownProps as O) }} />;
```

The terms I use - I've heard others refer to child as the wrapped child but this is the language that makes sense to me.

-   Child: The component we want to wrap.
-   Wrapped Child: the component wrapped, the third function in PassDownProps.

Let's break it down. The outer-most function accepts the props that you want to pass down `S`. It will return a higher order component. The higher order component takes a component, the `Child` - a component with props of the shape `P` - and will return another component - or a wrapped form of that `Child`. In this example, this wrapped component combines its own props of type `S` with the rest of the props that we expect of type `O`, the one that return the HOC. Together a union of both `O & S` will result in the type `P` - the type of props `Child` expects.

#### Breaking down the type


In the example above we defined three generics `S`(some) and `P`(props) and `O`(omit) - representing the shape of our props before, during and after the wrapping is done. the type casting happening in the last line is necessary because of some typescript limitation - the type of Child ends up being lost and not tracked anymore by the ts compiler - I lost the link to the exact issue, and I didn't understand it when I read it - but this will probably be fixed down the line - Just remember to always force assert the props with their defined type. The `Child` has props of type `P` - when using this pattern always start with the type of the child, that is where the type information will be conveyed to the next HOC in your composition and it's often the simplest one to reason about. It is good to be explicit about the return type here. Finally the wrapped Child's type should match the return of the second function - they refer to the same component and are therefore equivalent.

I think where the visualization gets a little more tricky is when we are composing multiple HOCs. 

#### Visualizing an HOC composition

```ts
type FullName = {
    first: string;
    last: string;
};
const Wrapper = compose(
    PassDownProps({ first: "John" }),
    PassDownProps({ last: "Doe" }),
    RenderOnlyIf(() => true)<FullName>
);
const Wrapped = Wrapper(Image);
```

_a note_

I've found that the only reliable way of keeping type information passing reliably though most components is to narrow the generic's type in the composition itself - in this case we are narrowing `RenderOnlyIf`'s  generic type `X` to `FullName`. I don't know why it's not infering the type from the return type of its ancestor.

_the gist_

when reading a composition, read it top to bottom and visualize the top HOC as the parent of the next and etcetera. Keep in mind however that it is the last HOC that will execute first and it will be the closest and first to wrap the `Child`

_the stack_

I've come to visualize component composition or any composition as a stack. I think it's especially useful here with React components. 

Think of what code is running first, in this case, the first inner function of `PassDownProps` is first to being evaluated by the interpreter. it expected a child but the child is not available yet, for it to be available the first inner function of the second `PassDownProps` needs to resolve/get called, same as the one before, it expects a child. It won't be until `RenderOnlyIf` processes the `Image` component, that it will have its component and return one anew for the first `PassDownProps` to process (Hence the stack analogy. The stack of functions keep building up until the last hoc resolves the target component and the stack colpases backwards. The last HOC is the first one to be successfully called but it's the first HOC that is the parent of the bunch. It took me quite a while to realize that polarity and it was confusing me for the longest time.

### Conclusion haiku

```
typescript so good,
hoc also good,
a marriage outside heaven
```

