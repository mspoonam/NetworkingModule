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


That's it, the HTTPClient's job is to get a response from the server regardless if it is 200, 400, etc. So the HTTPClient shouldn't have to validate the response.

It's up to another component to validate the received response according to the API contract. In this case, the data would be deemed "invalid" if it doesn't follow the payload contract the app expects (this could be a programmer error in the app or the server implementation).

### 3. What is  mean of @escaping and @nonescaping closers and also auto closer in technical  term 
https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/

### 4. More understanding of Spies and Stubs :- 
 Spying lets us capture values, then assert on them later. 
* This helps us to simulate asynchronous behaviour of real time API calls. Stubbing is also good, but since we have 
  predefined sets of values in stubbing (eg: connectivity error was predefined in this video), we get immediate results which 
  do not match with real world asynchronous behavior. 
* Thats why Spying over stubbing is better option.

* HttpClient should be used only as an interface to provide the functionality to connect with internet. 
* It doesn't matters, what kind of framework (Alamofire/ Combine/ etc) is used by the Class/Struct that wants to do 
   networking.  
* Hence, HttpClient is only responsible for a Network Call successfull/ failure result types. 
* These return types from the get method of HTTPClient if handled with Enum gives us better option to test them with ease.
* We are not interested as of now in knowing other details of mapping the data or decoding the data.

• Spying and Stubbing are both important techniques - the choice depends on the case.

• And the HTTPClient is an abstraction to hide implementation details about making network requests.

### 5. What if we have more than one function that receives messages, will we have multiple message arrays in the spy in this case?
You can create multiple message arrays, but I recommend a single array with an enum type wrapping each message if you need to check the order of the received messages.

###6. error array tests. 199, 201, 300, 400, 500 why do we for looping all the code if the expected result is the same as invalid data? if the error is not 400, what if 300 or else etc, but nor in the SUT and Client, it's not capturing specific 400 case so isn't it enough we know the test with one non 200 code is result of invalid data?

It's important to test different values to increase coverage. In this case, the cost of adding more examples is low. So there's no harm in being thorough in the samples.

When testing values, it's important to check the boundaries to avoid off-by-one mistakes. So if we're testing for the value 200, it's important to add at least 199, 200, and 201. The extra samples can help increase coverage at a low cost and serve as documentation for the next developer (there's a clear sample of possible expected values from this API).

###. for now HTTPClientResult only succeeds when a response is received from the service, even if it is a 400. But this can be a bit confusing if what I receive as a success is invalid data.

That's it, the HTTPClient's job is to get a response from the server regardless if it is 200, 400, etc. So the HTTPClient shouldn't have to validate the response.

It's up to another component to validate the received response according to the API contract. In this case, the data would be deemed "invalid" if it doesn't follow the payload contract the app expects (this could be a programmer error in the app or the server implementation)

###. In a personal project, I had defined an interface like this:

```
public protocol HTTPClient {
    func perform(_ request: Request, decoder: JSONDecoder) -> AnyPublisher, Error>
}

public enum HTTPClientError: Error {
    case invalidHTTPResponse
    case invalidStatusCode
    case modelMapping
}
```

And basically, I provided an URLSessionHTTPClient implementation, which basically returns decoded models and perform status code validation as defined by my custom Request's validation optional property (which is an enum with cases like successCodes, successAndRedirectCodes, custom ~ similar to what Moya offers). This functionality was implemented following TDD.

So, let's say this is a kind of higher level interface (i.e over URLSession which returns Data & HTTPURLResponse), in this case if the consumer using the HTTPClient doesn't have to perform any status code validation, it can just pass choose a validation range. Is this okay or can cause any issue in the long term?

Ans: 
In this solution, the `HTTPClient` abstraction defines too many responsibilities. 

That's because implementations must be responsible for fetching the data, validating the response, decoding the data, and generating responses. Plus, it couples clients with the Combine framework and forces clients to know which decoder to use.

Too many responsibilities lead to complex implementations that are rigid and hard to test and reuse. For example, every implementation must duplicate validation and decoding logic. And what if one endpoint returns XML or HTML instead of JSON? Then, you wouldn't be able to use this HTTPClient to fetch data. 

So this abstraction doesn't present a pure HTTPClient. It's a very specific abstraction for loading JSON only. But an HTTPClient component should ideally be only responsible for performing HTTP requests, regardless of the response body type.

If you separate the responsibilities as we recommend in the program, you can then compose the HTTPClient with any decoder, any validation logic, any framework, and so on. You can also test it in isolation and reuse it in any other context. That's why we recommend the HTTPClient protocol should only define a simple interface for loading HTTP requests without validating or decoding the response
 
### . What is a stub? 

The word `stub` has a different meaning in the two contexts you mentioned.

1) The compiler message you get related to protocol stubs refers to adding an empty implementation of the protocol methods, just to satisfy the compiler. A *stub* in this context is simply a placeholder implementation of the protocol methods (the empty implementations).

2) In the context of this lecture, *stub* refers to a type of component used for facilitating tests. *Stub* in the context of testing is a technique.

In testing, a *Stub* is a kind of test-double, just like *mocks*, *spies*, *fakes*, and other types of test-doubles used for facilitating tests.

A Stub is used to set predefined values and behavior during tests. So, you can simulate conditions like the ones that happen in production (the real world!).

---

###. Am I right to assume that SPY class only making us easier to test?

Yes, exactly. A *Spy* is a test-double used for facilitating tests. 

A *Spy* is used to capture events, operations, and values that occur during tests. So, you can *later* assert on the captured values or simulate conditions like the ones that happen in production (the real world!).

---

In short:

• A Stub is used to set predefined actions or responses. For example, you can create a Stub to provide "canned" HTTP responses (e.g., predefined JSON data or error). 

• A Spy collects or "records" usage information such as method invocation count, and values received so you can use them later on in the test.

P.S. A Spy is often also a Stub, as you can choose to set predefined actions/responses into it.

###. you use an array of samples to test behaviour with HTTP status other than 200… wouldn’t have been better to use random values, so the test is “different” every time we execute it? Something like this:

```
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let json = makeItemsJSON([])
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: Int.random(in: 1...199), data: json, at: 0)
        })
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: Int.random(in: 201...999), data: json, at: 1)
        })
    }
```

Or creating an array of random samples.

I sometimes use this technique to create default values for parameters in `makeSUT` factory methods, just to be more confident that my production code is not doing weird things on some edge cases.

What’s your take on this? Do you think it is going too far?

Ans 
Yes, using random values can improve your test coverage, but it doesn't automatically guarantee you covered edge cases.

When using random values, you'd have to run the tests *many* times to ensure it works for any input within the given bounds (assuming the random samples will be well distributed to cover every case).

That's why there are libraries and frameworks for randomizing tests more reliably. For example, property-based testing is a great solution to this.

But beware that running the tests many times can make your test suite slower.

Now, when testing code with basic XCTest assertions, I recommend you cover edge cases explicitly. 

For instance, we want to make sure only `200` status code is accepted as described in the contract with the backend.

So, we covered:

- Exactly 200
- Less than 200 (199)
- More than 200 (201)
- And a couple of extra cases to ensure the production code is not using hardcoded values to check the status code.

Without a proper mechanism like property-based testing, you cannot guarantee that you checked for the adjacent values of the 200 status code (199 and 201). Meaning you could have "off-by-one errors" in production.

https://en.wikipedia.org/wiki/Off-by-one_error

So, using random values is good advice when you have a reliable mechanism for distributing random samples. 

###. 

###. 
