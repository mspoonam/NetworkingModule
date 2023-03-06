# NetworkingModule
Setting up the base for Networking Module

At NM, 

##Handling Errors + Stubbing vs. Spying + Eliminating Invalid Paths 5:33 at 1x


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


## A Classicist TDD Approach (No Mocking) to Mapping JSON with Decodable + Domain-Specific Models
###. Data object is being created from FeedItem model and not from RemoteFeedItem model by HTTPClientSpy complete withStatusCode method.

Is it right ? Apparently the mapper is mapping from FeedItem data and not from RemoteFeedItem data.

Ans
The RemoteFeedItem is an internal Data Transfer Object (DTO). It's just an implementation detail of mapping the API model (what we receive from the backend API) into App Models (FeedItem). 

No other module will use the RemoteFeedItem directly - it's an implementation detail coupled with specific API details such as the JSON schema.

In the app, we use App Models, which are decoupled from API details and can be created from any source (not just the API). That's why the loader returns app models and not API-specific models.

This way, we can easily and quickly change the API source without breaking other modules. 
 

###. But in this specific test, we are creating a Data object that the FeedItemMapper will process.
So I still think is rare to create a Data object with a type different that the mapper is expecting.

And FeedItemMapper is expecting RemoteFeedItem, isnt't it ?

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}

Ans 
No, the FeedItemsMapper is expecting JSON data, not RemoteFeedItem.

Moreover, we're not testing the FeedItemsMapper directly. As I said previously, the FeedItemsMapper and the RemoteFeedItem are implementation details the test doesn't need to know about.

The behavior we're testing is the transformation from JSON data to FeedItem. It just happens that the implementation has an intermediary step that converts it into RemoteFeedItem first. But that's an implementation detail the tests don't need to know about. So we can refactor the code later to use JSONSerialization, for example, without breaking the tests.

Tests should be decoupled from internal/private implementation details. Otherwise, the tests are too coupled with the production structure, and it'll be hard to refactor later.

The tests should check the behavior only, not the structure of the code or implementation details. So we can change the structure/implementation without breaking the tests.

As long as the behavior/output is correct, it doesn't matter the implementation 

###. During the lesson, we added inside that map method of the FeedItemsMapper the logics to check the response status code and mapping the data received into instances of our model. Isn't this a violation of the single responsibility principle? 
What I mean is that we are managing two unrelated actions on the same method and a change in the successful status code (for example we want to consider also 201 as a success) or a change in the model used for parsing the data would require us to change the code. 

Moreover if we have to perform some specific actions for specific values of the response status code (I am thinking of a reauthentication process in the case we get a 401), with the current implementation, we would have to add this case specific logics inside the map function.

Ans
No, it's not a violation of the Single Responsibility Principle. The responsibility is "mapping the response" based on the backend API contract, which includes the status code. If the status code rule changes, it's a breaking change in the backend API contract and we need to update our component to reflect the changes.

Moreover, we don't need to do any reauthentication logic inside the mapper. The mapper will simply reject the 401 response, and another component will be responsible for dealing with reauthentication.

###. I like the approach to separate API Items and Feed Items into separate models.
In the video lesson, you use 'map' function to convert API Items to FeedItems of an array that has O(n) complexity. 
It means if we got, for example, 10000 items in API response then 10000 conversions will be done.
The example in the lesson uses a simple JSON object with 4 fields but in real life, it can be a much more complex object with more fields, nested objects etc. Also, several calls to different API endpoints can be performed at the same moment of time.
I understand that API should paginate data, return them in portions etc but the life isn’t ideal and sometimes happens that quite many items are returned in a single response resolution.

So the questions are: Do we pay with the performance for good app architecture in this case? Is it a trade-off for good architecture?

Ans  
10000 items are still a small sample. This solution works with small or large data sets. It's important to measure before optimizing.

When optimization is needed, there are clean solutions without changing this component or the architecture at all. For example, you can paginate the resource instead of loading thousands of items at once 

###. Json file with test data 
1. The way we created sample JSON was a learning to me. What we do usually is to have separate json files having mock responses and decode it via a JSONParser class. The question is, is this still the recommended way (creating a helper method to create JSON data manually?) when we have way too big json responses?

2. You've mentioned that you wont be creating instance of `FeedItemsMapper`? Why does it should have a static map method. We can always do `FeedItemsMapper().map()` right? what's hinting you to take decisions about creating a static vs instance methods? 

Ans
I recommend you define the JSON with helper methods as shown in the lectures. 

Otherwise, it's hard to understand the test and solve test issues/failures since the JSON will live in another file (you have to jump back and forth between two files - and JSON is not meant to be human-readable). The test can also be slow and have more failure points since it needs to read from the file system.

That's why I recommend helper methods in the test scope. And you don't need a big JSON file for that. You can use the minimum amount of details to validate the serialization/deserialization, as shown in the lecture.

---

2. The `FeedItemsMapper.map` helper doesn't require any instance properties or methods, so it can but doesn't need to be an instance method. It can be a static method or just a free function. 

The idea is to choose simple solutions that solve the problem well.

In this case, the static method seemed the simplest and clearest solution since it's a pure function with no side-effects and no need for instance properties/method or `self`.

Moreover, the `FeedItemsMapper` is an `internal` type. So clients don't have access to it. This means you can refactor it later into an instance method or a free function if needed.

###. why we are not using JSONEncoder to convert the swift dictionary to json instead of JSONSerializer ?

Ans We used JSONSerialization to show that the test doesn't need to follow the same production implementation. And in this case, it's the simplest solution for creating valid JSON on the test side.

###.I'm wondering if one API TDD have to take this step, what about testing every other API that needed, let's says in App need 35 API with different return type and object, should we do all the same step with every API ?
## Ans - In future lectures 
No, you don't need to repeat this process over and over. You'll learn how to create generic solutions that can cover any API request as you progress in the lectures.

### "If this changes in the API, we might break other modules that have nothing to do with the API"

Ans 
The FeedItem represents the app model and is referenced by other modules. So every time we change it, we need to also recompile all other modules that depend on it. And if there is a breaking change, such as changing a public interface, an initializer signature, or a property name, we may break clients (they need to manually update their modules to reflect this change; otherwise, the code won't compile!).

This can be expensive because it may require extra work from developers and also slow down builds. That's why we want to minimize modular dependencies and protect our modules from external changes, such as the backend API contract.

If we keep the API details such as JSON keys in the FeedItem app model, there's an external source (the backend API) that may force us to update the module and potentially break clients. For example, if the backend API changes a key in the JSON contract, we need to change the FeedItem and recompile all other modules. Even though those modules have nothing to do with the API, and don't even know about it!

That's why we recommend defining an API-specific model to deal with the mapping. This way, the main FeedItem model won't be influenced by changes in the API contract. So we also protect other modules from breaking changes in the backend API.

You can get away with coupling the app model with backend API details in a small project with a couple of developers because the cost of updating all modules can be low. But preventing this problem becomes mandatory in larger projects with many developers.

You'll learn it in detail, with many examples, as you progress in the lectures.

###. Any reason to use computed variable instead of constant, like "static let OK_200 = 200" and as we confirm 'Equitable' protocol for 'FeedItem' and 'Enum' but we didn't implement the '==' method.

Ans 
1. Since we're representing a value type (Int), a class constant and a computed var are equivalent in this context. It's a matter of personal preference.

2. Since 'FeedItem' is a struct and every property conforms to 'Equatable', the compiler can automatically synthesize the 'Equatable' implementation for us. So you don't need to implement it. You can learn more here: https://developer.apple.com/documentation/swift/equatable


### Would you mind elaborating on what you mean by:

"Since we're representing a value type (Int), a class constant and a computed var are equivalent in this context. It's a matter of personal preference."

What do you mean by a class constant and computed var being equivalent?

Ans 
What I meant is that both represent an immutable value type with a hardcoded value (200) in this case. 

So with compiler optimizations, the generated machine code will be very similar (or the same). So they're pretty much equivalent at runtime:

```
class MyClass {
    static let OK_200 = 200
}
```

```
class MyClass {
    static var OK_200: Int { 200 }
}
```

Thus, it's a matter of personal preference in this case.

### What is your opinion about using 404 for empty data and not 200 from the backend perspective ?

Ans 
Empty successful responses are usually represented with the 204 status code.

But it depends on what you're trying to achieve. I recommend you follow the standard HTTP response code semantics in your apps.

For example:

- 404 is for "Not Found" errors - if that's what you're to represent, use 404.

- 200 is for "OK" responses (success returning content).

- 204 is for "No Content" (successful responses not returning any content).

Learn more in the following links & below question 

https://en.wikipedia.org/wiki/List_of_HTTP_status_codes

###. Do you check the status code in real practice or is it here to represent a requirement (for the example)? Should be enough to check if we're able to decode our model?

Let me put one case on the table, currently i have a project that is on development (server is still on development), so some decisions taken (although initially some contract was defined, later is refined or change a little bit). Initially on the server when something was created (POST) server return 204 response (No Response Body). On the Android project was checking those status code and app start failing on all places. In the case of iOS with Alamofire, i was only validating that this is a valid status code in the range 200..<300 (by the library itself), so not changes required on my side.

Ans 
It depends on your use cases and API contract. 

Some use cases require a specific status code. Anything else would be an invalid response. Thus, we would check for the correct status code, e.g.:

`guard response.statusCode == 201`

If your use case allows a range of valid status codes, you must also reflect it in your implementation, e.g.:

`guard (200..<300).contains(response.statusCode)`

Similarly, if you don't have specific rules about status codes in your requirements, it's probably better to allow any 2xx response. This way, you avoid situations where API changes break the clients like the one you described.

In your case, a permissive status code rule saved your app from API breaking changes. But beware that by allowing any 2xx status code, you can also introduce issues.

For example, once I was working on an e-commerce app that would return a 200 response when payment was taken successfully. 

Later on, the backend had to add a fraud check system, so payment would not always be synchronous anymore. In some cases, the payment attempt would be flagged as potential fraud, and in that case, it'd require further checks.

When that happened, the backend would return a 202 HTTP status code (Accepted). Which meant the server accepted the request, but the processing was not complete yet.

In a usual 200 response, everything was as expected with the JSON response payload. In a 202 response, there was no response body.

Some clients didn't implement this logic correctly, where they would just check the response for the range 200...299 and try to deserialize the JSON. 

Since it couldn't deserialize the empty 202 response, the app would show an error. However, the payment would potentially go through after the fraud checks. So, some customers would be billed unexpectedly. Not a great customer experience.

That's why it's important to map specific status codes with particular payloads depending on the use case.

###. What did you do then to complete with Result.successful without returning a concrete type for the response 202? Did you include that case in YourClass.Error?

202 was not an error, but a response representing a "Processing" state.

So we implemented the proper 202 handling, where it would generate a successful result representing the "Processing" state and we'd show a "Payment is processing, we'll let you know when it's done" message to the user.

###. Could you provide more detail about it? What I'm interred in knowing is:
In our example the load returns a result either successful(object) or error. However for the code 202 returning this result is not correct. Did you add a new state / case like ".accepted / processing" in the load method?

Something like:
Result {
case .successful(object)
case .error(Error)
case .processing
}

What about the HTTPClient, in our example when success, it returns type Data. Did you have to adjust it in the HTTPClient and also in your YourClassLoader?

Ans 
It was Obj-C, so we didn't have rich enums and Result types at the time 🙂. But in Swift, it could be something like what you mentioned:

```
enum PaymentStatus {
  case processing
  case processed(PaymentDetails)
}
```

And the result type: 

```
Result<PaymentStatus, Error>

```

###. what about the HTTPClient? In our example we return successful(Data), but that wouldn't make sense for code 202, right? 

so, did you have to adjust your HTTPClient and also your Loader?

Ans 

The logic is *not* in the HTTPClient. 

The HTTPClient returns (Data, HTTPURLResponse) - it shouldn't contain logic at all. 

The HTTPURLResponse holds the status code. So it's up to consumers to decide what to do with the data depending on the status code.

Moreover, you can create an empty `Data` instance holding 0 bytes. That's a valid `Data` instance and "empty" response representation!


 ###. 
 this validation if statusCode == 202, would it be done in the Mapper, or in the inside the RemoteLoader.load?

The same applies if I would like to have specific requirements for statusCode 400, 401, xxx?
Ans 
It can be done in both the loader or the mapper, as shown in the lectures. You'll learn how to decide as you progress in the lectures.

###. I have not yet watched the next video, but why don't we declare `sut` and `client` on the setup() function? If you did in the next videos, please ignore this comment? Otherwise, please let me know your thoughts

Ans : 
 You can find in detail the reasons we choose not to create the `sut` and its collaborators in the `setUp` method in the following article: 
https://www.essentialdeveloper.com/articles/xctest-swift-setup-teardown-vs-factory-methods

###. you say that in this episode we followed a Classicist approach to TDD, that we are not mocking anything.
But what is a Classicist approach? And how it would be if we mocked things?
And what is test things in integrations? And why when it fails it might be harder to find where the issue is precisely?

What are the differences and trade-offs between mocking vs. testing collaborators in integration?

####  Ans 
1. That's it. We followed a Classicist TDD approach in this episode, where we decided not to mock the Mapper implementation.

What is a Classicist TDD approach? 

Classicist TDD refers to the original ideas when the TDD movement started. At the time, the testing strategies relied much less on mocking behavior during tests.

---

2. How it would be if we mocked things?

An example would be to create a `Mapper` protocol as pass it as a dependency in the `RemoteFeedLoader` class. Like we did with the `HTTPClient` dependency.

Something like:

```
protocol FeedItemsMapper {
    func map(_: Data, ...) -> [FeedItem]
}

class RemoteFeedLoader {
    let client: HTTPClient
    let mapper: FeedItemsMapper
    ...
}
```

Then, during tests, you could use a test double that implements the protocol (e.g., a mock, stub, or spy). 

```
let mapperSpy = FeedItemsMapperSpy()
let sut = RemoteFeedLoader(mapper: mapperSpy, ...)
```

Then you'd check that the test double received the expected messages, rather than testing the actual mapping of the response directly as we did.

```
XCTAssertEqual(mapperSpy.receivedMessages, [.map(expectedData)])
```

And you'd test the production `FeedItemsMapper` protocol implementation in another test class and compose the objects in the Composition Root.

The Classicist approach is to avoid mocking as much as possible. We also recommend it. Thus, reserve mocking for slow and flaky functionality such as disk lookups, networking, and UI interactions.

---

3. What is testing things in integration? 

When you test more than one component at a time. 

For example, in this episode, we're testing the RemoteFeedLoader, FeedItemsMapper, and the Decodable setup all in one go (in Integration).

If you were to use the mockist strategy with a mapper test doubles instead, you'd be testing the RemoteFeedLoader in isolation (without any other real collaborator).

---

4. Why when an Integration Test fails it might be harder to find where the issue is precisely?

Because when you test many classes at the same time, it's hard to tell which one is generating the issues. You'd have to spend time debugging to find out.

For example, as we're testing the RemoteFeedLoader, FeedItemsMapper, and the Decodable setup all in one go, when a test fails it can be hard to tell if the problem is in the RemoteFeedLoader, in the FeedItemsMapper, or in the Decodable setup.

That's a simple case, so you probably could find the problem quickly.

But you can imagine that the more objects in integration, the harder it becomes to find the issue when a test fails.

On the other hand, a good unit/isolated test would tell you precisely where the problem is. No need to spend time debugging.

So, we recommend you rely more on unit/isolated tests. And test only a few objects in collaboration at a time when you decide to write integration tests.

---

5. What are the differences and trade-offs between mocking vs. testing collaborators in integration?

You'll learn their differences and trade-offs in detail as you progress in the course.

