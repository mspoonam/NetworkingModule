# NetworkingModule
Setting up the base for Networking Module

At NM, Handling Errors + Stubbing vs. Spying + Eliminating Invalid Paths 5:33 at 1x


### NetworkingModule - Stubs and Spies

We first tested the connectivity error completion of the RemoteFeedLoader by stubbing the error on HTTPClientSpy by setting an error value.

After seeing this and the next video I felt very confused, there was something I was missing ... stub, spy, I did not understand the right concepts.
After reading Martin Fowler's article (linked in the next video lesson) I went back to review the lesson and now everything makes more sense to me.
So, if I understand correctly, the Spy object you use is a Stub object with some behavioural methods (almost like the functionalities of Mock objects) using a "classic" TDD approach.
I am new to TDD techniques, Martin's article has clarified me more concepts. I recommend everyone to read it.

That's it: Stubs and Spies are test-doubles.

1. A Stub is used to set predefined behaviors or responses during tests. For example, you can create a Stub to provide "canned" HTTP responses (e.g., predefined JSON data or error).

2. A Spy collects or "records" usage information such as method invocation count and values received. So you can use/verify them later in the test.

A Spy is often also a Stub, as you can choose to set predefined actions/responses into it.

### 1. Why have you replaced the stubbing with capturing values?

Firstly, because we wanted to show different ways to test asynchronous behavior with completion closures.

Secondly, because capturing the completion closure gives us more control over *when* the async completion closure will be invoked during tests.

In this case, it also helped us remove the `if-logic` from the Spy class. Ideally, test-doubles such as Spies and Stubs should be as simple as possible and contain little to no logic.


### 2. Why you can't create a Stub for HTTPClient and use it for tests instead of using the captured values?

You can create and use Stubs for tests, as shown in the lecture.

We usually prefer Spies for the reasons given in the video, article, and in answer #1 above.


