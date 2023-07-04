Higher Order Components.

This post is not about React components, it is about React Higher Order Components or HOCs - but to understand HOC, we have a to understand what a React component is.

```tsx
const Greeter = ({ name }: Props) => <div>hello {name}!</div>;
```

The React docs shows a simple Greeter functional component and goes on to say that **This function is a valid React component because it accepts a single “props” (which stands for properties) object argument with data and returns a React element)**. Ok so then what is a React element. A quick look at the type of `React.ElementType<P>` shows an overload of 173 types - matching a variety of HTML tags but also including React components which themselves can return more React elements. So a reasonable way to think of React components is to think of them as functions that accept `props` and return more React nodes, that can themselves include more React components but don't _need_ to. Each render, the React node is evaluated and eventually becomes HTML. For our purposes what is important to note here is that return value of the component is not a function. If it were a function, and specifically a function that accepted `props` and returned another React Node than it would be a React Higher Order Component.

### What are Higher Order Components

HOCs get their name from higher order functions. Common known higher order functions include `map`, `filter`, `reduce`, `fold`, `zip` and many more. But the general idea is that these function take a function and return another function.
```js
const increment = map(x => x + 1)
```
increment could operate on any type or data structure. It would actually be determined by our `map` function. If a React component was data structure then essentially it could have its own map, and it would be a functor. But its not - it's just a function. What's possible however is for us to affect the return type of a React component - we can do in may ways.

- Wrap our React node and enhance functionality by passing down props
- Wrap our React node and enhance functionality by transforming props 
- Wrap our React node and enhance functionality by setting up listeners
- Wrap our React node and enhance functionality with hooks

You get the picture right? All the tools available to you in React Components are also available to you in higher order components. You just do what you want to do and wrap the target component.

### PassPropsThrough.tsx, an example

Here is a simple HOC that will passdown some variables as props to a child component. 
 
```tsx
const PassPropsThrough =
  <P, T>(props: P) =>
  (Child: ComponentType<any>) =>
  (ownProps: T) =>
    <Child {...{ ...(props as P), ...(ownProps as T) }} />;
```

Let's break it down. The first function accepts the props that you want to pass down. It will return a higher order component. That's it. The higher order component accepts another component, the `Child` and return another component, a final component, that in turn will combine its own props of type `T` with the props that we from our original function of type `P`, the one that return the HOC.



te be continued


