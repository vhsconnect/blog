---
tags: typescript, react
title: Typing React higher order components in Typescript
author: vhs
---

This post is not about React components, it is about React Higher Order Components or HOCs - but to understand HOC, we have a to understand what a React component is. A React component is an abstraction, a function, an encapsulation of view and state - all these things - React will take your component tree and build a virtual dom that it will then append to the document. It's easy seeing the forrest for the tree, in this case, it's the tree that is more fuzzy to see. Let's look at what the React docs have to say.

```ts
const Greeter = ({ name }: Props) => <div>hello {name}!</div>;
```

The React docs shows a simple Greeter functional component and goes on to say that **This function is a valid React component because it accepts a single “props” (which stands for properties) object argument with data and returns a React element)**. Ok so then what is a React element. A quick look at the type of `React.ElementType<P>` shows an overload of 173 types - matching a variety of HTML tags but also including React components which themselves can return more React elements. So a reasonable way to think of React components is to think of them as functions that accept `props` and return more React nodes, that can themselves include more React components but don't _need_ to. Each render, the React node is evaluated and eventually becomes HTML. For our purposes what is important to note here is that the return value of the component is not a function. If it were a function, and specifically a function that accepted `props` and returned another React Node than it would be a React Higher Order Component.

### What are Higher Order Components

HOCs get their name from higher order functions. Common known higher order functions include `map`, `filter`, `reduce`, `fold`, `zip` and many more. But the general idea is that these function take a function and return another function.

```js
const increment = map((x) => x + 1);
```

increment could operate on any type or data structure. It would actually be determined by our `map` function. If a React component was a data structure then essentially it could have its own map, and it would be a functor. But its not - it's just a function. What's possible however is for us to affect the return type of a React component - we can do in may ways.

-   Wrap our React node and enhance functionality by passing down props
-   Wrap our React node and enhance functionality by transforming props
-   Wrap our React node and enhance functionality by setting up listeners
-   Wrap our React node and enhance functionality with hooks

You get the picture right? All the tools available to you in React Components are also available to you in higher order components. You just do what you want to do and wrap the target component.

### Composition

Just like higher order functions, HOCs really shine when you compose them together. Your components can stay light weight and you can encapsulate all the redundant logic seperately. The result end up looking to something like this.

```js
const myEnhancedComponent = compose(
    withRedux(mapperFunction),
    mapProps(mapperFunction),
    withErrorBoundary,
    renderOnlyIf(predicateFunction)
)(myComponent);
```

### PassPropsThrough.tsx, an example

Here is a simple HOC that will passdown some variables as props to a child component.

```ts
const PassPropsThrough =
    <P, T>(props: P) =>
    (Child: ComponentType<any>) =>
    (ownProps: T) =>
        <Child {...{ ...(props as P), ...(ownProps as T) }} />;
```

Let's break it down. The first function accepts the props that you want to pass down. It will return a higher order component. That's it. The higher order component takes a component, the `Child` and will return another component - or a wrapped form of that `Child`. In this example, this wrapped component combines its own props of type `T` with the props that we from our original function of type `P`, the one that return the HOC.

We can use this same pattern to _enhance_ any component. It's a common pattern in react development, especially before hooks were a thing. The community is typically split, albeit unequally, between 2 camps in regards to what abstraction is best - but that's a post for another day.

You can see much more example of higher order components in the now archived [recompose library](https://github.com/acdlite/recompose).

#### Breaking down the type

In the example above we defined two generics `P` and `T`. One for the shape of props that we are passing through and the other for the shape of props of its own return type (more on that below). We will destructure both sets of props into the returned `Child`. the type casting is happening in the last line is necessary because of some typescript limitation - the type of Child ends up being lost and not tracked anymore by the ts compiler - I lost the link to the exact issue - but this will probably be fixed down the line. The `Child` has props of type `any` because we don't know what shape it will be - we can accept anything - perhaps `unknown` would be more accurate but it won't help us doing what we want here.

I think where the visualization gets kind of tricky is when we are composing multiple HOCs. PassPropsThrough is called like this. Let's go through the call stack and see if that can bring clarity to our types.

```js
const Wrapper = compose(FirstHoc, PassPropsThrough({ size: "big" }), LastHoc);
const Wrapped = Wrapper(Image);
```

FirstHoc will be the first HOC to be run not called. Assuming we're wrapping a simple img tag component here. It will need to wait until all other HOC have been run and called, before it can finally be called with the resulting component. The stack will be 3 deep when we start resolving it - LastHoc will be the first to be called and will return a React component - which is a wrapped img tag component + the functionality of whatever LastHoc does, that will get passed to PassPropsThrough, which will return another React component (the react component from before + a parent component around it), and etcetera all the way up. Now back to types.

Let's consider type `T` in our PassPropsThrough. The best way to visualize it is as the props of the return type of the HOC- i.e in this case `PassPropsThrough({ size: "big" })(LastHoc(Image))` - i.e the type of props FirstHoc expects. And that's why we can get away with `React.ComponentType<any>`, because each parent HOC is type checking its child. We need not know what the type of the child will be - this recursive structure with type generics does the trick.
