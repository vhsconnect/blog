---
tags: javascript, jest,
title: Testing promise rejections with jest
author: vhs
---

Often we need to timeout network requests after a certain amount of time. One way to do that in javascript is to use Promise.race() to guard against a network request taking to long to resolve by feeding it a Promise that resolves with a `setTimeout` along with your wrapped network request promise.

```js
Promise.race(myNetworkRequest, new Promise(res) => setTimeout(res, SOME_AMOUNT_OF_TIME)})
```

The other day I wanted to write a quick test to assert that my resolver would not hang forever to test something similar to what you see above. It took longer then I would have liked. I found that Jest's way of testing for promise rejections is not straight forward


```js
const functionUnderTestReturnsAPromise = someFunction

describe('When ...', () => {
  it('Then ...', () => {
    jest.useFakeTimers();
    const promise = functionUnderTestReturnsAPromise();
    jest.runAllTimers();
    return expect(promise).rejects.toEqual(
      'rejection message/string'
    );
  });
});
```

We use `useFakeTimers` and `runAllTimers` to make jest mock the setTimeout functions and manipulate the global environment timers.

The subtlety here is that we are returning the expect call and that way we can evaluate this 'rejects' property and run our assertions on what kind of promise rejection occured under our test's conditions.
