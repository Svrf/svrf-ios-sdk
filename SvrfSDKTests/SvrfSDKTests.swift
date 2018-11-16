//
//  SvrfSDKTests.swift
//  SvrfSDKTests
//
//  Created by Andrei Evstratenko on 05/11/2018.
//  Copyright © 2018 SVRF, Inc. All rights reserved.
//

import XCTest
import SVRFClientSwift
//@testable import SvrfSDK

fileprivate var token: String? = nil

class SvrfSDKTests: XCTestCase {
    
    private let correctApiKey = "f6de923045ee225bbaa237c973228e5a"
    private let incorrectApiKey = "incorrectApiKey"
    private let requestTimeOut: Double = 30
    private let singleSearchQuery = "S"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Supporting methods
    private func autorize(withApiKey apiKey: String, success: @escaping (_ response: AuthResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let body = Body(apiKey: apiKey)
        AuthenticateAPI.authenticate(body: body) { (response, error) in
            if (error != nil) {
                failure(error!)
            } else {
                success(response!)
            }
        }
    }
    
    private func searh(query: String, type: [MediaType]? = nil, stereoscopicType: String? = nil, category: String? = nil, size: Int? = nil, pageNum: Int? = nil, success: @escaping (_ response: SearchMediaResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        if (token != nil) {
            SVRFClientSwiftAPI.customHeaders = ["x-app-token": token!]
        }
        MediaAPI.search(q: query, type: type, stereoscopicType: stereoscopicType, category: category, size: size, pageNum: pageNum) { (searchMediaResponse, error) in
            if (error != nil) {
                failure(error!)
            } else {
                success(searchMediaResponse!)
            }
        }
    }
    
    private func getTrending(type: [MediaType]? = nil, stereoscopicType: String? = nil, category: String? = nil, size: Int? = nil, nextPageCursor: String? = nil, success: @escaping (_ response: TrendingResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        if (token != nil) {
            SVRFClientSwiftAPI.customHeaders = ["x-app-token": token!]
        }
        MediaAPI.getTrending(type: type, stereoscopicType: stereoscopicType, category: category, size: size, nextPageCursor: nextPageCursor) { (trendingResponse, error) in
            if (error != nil) {
                failure(error!)
            } else {
                success(trendingResponse!)
            }
        }
    }
    
    private func getById(id: String, success: @escaping (_ response: SingleMediaResponse) -> Void, failure: @escaping (_ error: Error) -> Void) {
        if (token != nil) {
            SVRFClientSwiftAPI.customHeaders = ["x-app-token": token!]
        }
        MediaAPI.getById(id: id) { (singleMediaResponse, error) in
            if (error != nil) {
                failure(error!)
            } else {
                success(singleMediaResponse!)
            }
        }
    }
    
    func testAuthenticationWithIncorrectApiKey() {
        let promise = expectation(description: "Authentication request with incorrect apiKey")
        autorize(withApiKey: incorrectApiKey, success: { (response) in
            XCTFail("Authentication method finished with success that despite what incorrect key was sent. Please check authentication method in client API library.")
            promise.fulfill()
        }) { (error) in
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    //MARK: - Authentication Tests
    func testAuthenticationWithCorrectApiKey() {
        let promise = expectation(description: "Authentication request with correct apiKey")
        autorize(withApiKey: correctApiKey, success: { (response) in
            if (response.success == nil) {
                XCTFail("Status(success field) in Authenticate response is nill.")
            }
            if (response.message == nil) {
                XCTFail("Message in Authenticate response is nill.")
            }
            if (response.expiresIn == nil) {
                XCTFail("ExpiresIn field in Authenticate response is nill.")
            }
            if (response.token == nil) {
                XCTFail("Token field in Authenticate response is nill.")
            }
            token = response.token
            promise.fulfill()
        }) { (error) in
            XCTFail("Authentication method finished with error. Please check authentication method in client API library. In this test was sent correct apiKey.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    // MARK: - Search Methods Tests
    func testSearchMethodWithEmptyQuery() {
        let promise = expectation(description: "Search request with emty query")
        searh(query: "", success: { (searchMediaResponse) in
            XCTFail("Response for search finished with success despite what empty q was sant. Please check search method in client API library.")
            promise.fulfill()
        }) { (error) in
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWithNotEmptyQuery() {
        let promise = expectation(description: "Search request with not empty query")
        searh(query: singleSearchQuery, success: { (searchMediaResponse) in
            if (searchMediaResponse.success == nil) {
                XCTFail("Status(success field) in Search method response is nill.")
            }
            if (searchMediaResponse.media == nil) {
                XCTFail("Media array in Search method response is nill.")
            }
            if (searchMediaResponse.totalNum == nil) {
                XCTFail("Total count of elements(totalNum field) in Search method response is nill.")
            }
            if (searchMediaResponse.tookMs == nil) {
                XCTFail("The number of milliseconds the request took in Search method response is nill.")
            }
            if (searchMediaResponse.pageNum == nil) {
                XCTFail("The current page number in Search method response is nill.")
            }
            if (searchMediaResponse.nextPageNum == nil) {
                XCTFail("The next page in Search method response is nill.")
            }
            promise.fulfill()
        }) { (error) in
            XCTFail("Search method finished with error. Please check search method in client API library. In this test was sent correct query.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWithMultipleParameters() {
        let promise = expectation(description: "Search request with multiple parameters")
        searh(query: singleSearchQuery, type: [MediaType.photo], stereoscopicType: nil, category: nil, size: 1, pageNum: nil, success: { (searchMediaResponse) in
            promise.fulfill()
        }) { (error) in
            XCTFail("Search method finished with error. Please check search method in client API library. In this test was sent multiple parameters.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWithPhotoType() {
        let promise = expectation(description: "Search request with photo type")
        searh(query: singleSearchQuery, type: [MediaType.photo], success: { (searchMediaResponse) in
            var isOnlySearchedType = true
            for mediaObject in searchMediaResponse.media! {
                if (mediaObject.type != MediaType.photo) {
                    isOnlySearchedType = false
                }
            }
            XCTAssertTrue(isOnlySearchedType, "Another Media Type was detected in search method with photo type. Please check search method in client API library. In this test was sent MediaType.Photo.")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with photo type. First of all check that previous test finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWithVideoType() {
        let promise = expectation(description: "Search request with video type")
        searh(query: singleSearchQuery, type: [MediaType.video], success: { (searchMediaResponse) in
            var isOnlySearchedType = true
            for mediaObject in searchMediaResponse.media! {
                if (mediaObject.type != MediaType.video) {
                    isOnlySearchedType = false
                }
            }
            XCTAssertTrue(isOnlySearchedType, "Another Media Type was detected in search method with video type. Please check search method in client API library. In this test was sent MediaType.Video.")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with video type. First of all check that previous test finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith3dType() {
        let promise = expectation(description: "Search request with 3d type")
        searh(query: singleSearchQuery, type: [MediaType._3d], success: { (searchMediaResponse) in
            var isOnlySearchedType = true
            for mediaObject in searchMediaResponse.media! {
                if (mediaObject.type != MediaType._3d) {
                    isOnlySearchedType = false
                }
            }
            XCTAssertTrue(isOnlySearchedType, "Another Media Type was detected in search method with 3d type. Please check search method in client API library. In this test was sent MediaType._3d.")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with 3d type. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWithMultipleTypes() {
        let promise = expectation(description: "Search request with multiple types")
        searh(query: singleSearchQuery,type: [MediaType.video, MediaType.photo], success: { (searchMediaResponse) in
            var isOnlySearchedTypes = true
            for mediaObject in searchMediaResponse.media! {
                if (mediaObject.type == MediaType._3d) {
                    isOnlySearchedTypes = false
                }
            }
            XCTAssertFalse(isOnlySearchedTypes, "Another Media Type was detected in search method with photo and video types. Please check search method in client API library. In this test was sent MediaType.video and MediaType.photo.")
            promise.fulfill()
        }) { (error) in
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith5Size() {
        let promise = expectation(description: "Search request with size = 5")
        searh(query: singleSearchQuery, size: 5, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 5, "Search method response contains wrong count of elements. Please check search method in client API with size = 5")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with size = 5. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith20Size() {
        let promise = expectation(description: "Search request with size = 20")
        searh(query: singleSearchQuery, size: 20, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 20, "Search method response contains wrong count of elements. Please check search method in client API with size = 20")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with size = 20. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith50Size() {
        let promise = expectation(description: "Search request with size = 50")
        searh(query: singleSearchQuery, size: 50, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 50, "Search method response contains wrong count of elements. Please check search method in client API with size = 50")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with size = 50. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith70Size() {
        let promise = expectation(description: "Search request with size = 70")
        searh(query: singleSearchQuery, size: 70, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 70, "Search method response contains wrong count of elements. Please check search method in client API with size = 70")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with size = 70. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith100Size() {
        let promise = expectation(description: "Search request with size = 100")
        searh(query: singleSearchQuery, size: 100, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 100, "Search method response contains wrong count of elements. Please check search method in client API with size = 100")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with size = 100. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith3Page() {
        let promise = expectation(description: "Search request with page = 3")
        searh(query: singleSearchQuery, pageNum: 3, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.pageNum == 3, "Search method response contain wrong count of elements. Please check search method in client API with page = 3")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with page = 3. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith15Page() {
        let promise = expectation(description: "Search request with page = 15")
        searh(query: singleSearchQuery, pageNum: 15, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.pageNum == 15, "Search method response contain wrong count of elements. Please check search method in client API with page = 15")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with page = 15. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testSearchMethodWith40Page() {
        let promise = expectation(description: "Search request with page = 15")
        searh(query: singleSearchQuery, pageNum: 40, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.pageNum == 40, "Search method response contain wrong count of elements. Please check search method in client API with page = 40")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in search method with page = 40. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    // MARK: - Trending Methods Tests
    func testGetTrendingWithoutParameters() {
        let promise = expectation(description: "Get trending method without parameters")
        getTrending(success: { (trendingResponse) in
            promise.fulfill()
        }) { (error) in
            XCTFail("Get trending method finished with error. Please check get trending method in client API library.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWithPhotoType() {
        let promise = expectation(description: "Get trendinng with photo type")
        getTrending(type: [MediaType.photo], success: { (trendingResponse) in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! {
                if (mediaObject.type != MediaType.photo) {
                    isOnlySearchedType = false
                }
            }
            XCTAssertTrue(isOnlySearchedType, "Another Media Type was detected in get trending method with photo type. Please check get trending method in client API library. In this test was sent MediaType.Photo.")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with photo type. First of all check that previous test finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWithVideoType() {
        let promise = expectation(description: "Get trending with video type")
        getTrending(type: [MediaType.video], success: { (trendingResponse) in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! {
                if (mediaObject.type != MediaType.video) {
                    isOnlySearchedType = false
                }
            }
            XCTAssertTrue(isOnlySearchedType, "Another Media Type was detected in get trending method with video type. Please check get trending method in client API library. In this test was sent MediaType.Video.")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with video type. First of all check that previous test finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWith3dType() {
        let promise = expectation(description: "Get trending with 3d type")
        getTrending(type: [MediaType._3d], success: { (trendingResponse) in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! {
                if (mediaObject.type != MediaType._3d) {
                    isOnlySearchedType = false
                }
            }
            XCTAssertTrue(isOnlySearchedType, "Another Media Type was detected in get trending method with 3d type. Please check get trending method in client API library. In this test was sent MediaType._3d.")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with 3d type. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWithMultipleTypes() {
        let promise = expectation(description: "Get trending request with multiple types")
        getTrending(type: [MediaType.video, MediaType.photo], success: { (trendingResponse) in
            var isOnlySearchedTypes = true
            for mediaObject in trendingResponse.media! {
                if (mediaObject.type == MediaType._3d) {
                    isOnlySearchedTypes = false
                }
            }
            XCTAssertFalse(isOnlySearchedTypes, "Another Media Type was detected in get trending method with photo and video types. Please check get trending method in client API library. In this test was sent MediaType.video and MediaType.photo.")
            promise.fulfill()
        }) { (error) in
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWith5Size() {
        let promise = expectation(description: "Get trending request with size = 5")
        getTrending(size: 5, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 5, "Get trending method response contains wrong count of elements. Please check get trending method in client API with size = 5")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with size = 5. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWith20Size() {
        let promise = expectation(description: "Get trending request with size = 20")
        getTrending(size: 20, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 20, "Get trending method response contains wrong count of elements. Please check get trending method in client API with size = 20")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with size = 20. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWith50Size() {
        let promise = expectation(description: "Get trending request with size = 50")
        getTrending(size: 50, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 50, "Get trending method response contains wrong count of elements. Please check get trending method in client API with size = 50")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with size = 50. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWith70Size() {
        let promise = expectation(description: "Get trending request with size = 70")
        getTrending(size: 70, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 70, "Get trending method response contains wrong count of elements. Please check get trending method in client API with size = 70")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with size = 70. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWith100Size() {
        let promise = expectation(description: "Get trending request with size = 100")
        getTrending(size: 100, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 100, "Get trending method response contains wrong count of elements. Please check get trending method in client API with size = 100")
            promise.fulfill()
        }) { (error) in
            XCTFail("Something went wrong in get trending method with size = 100. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    func testGetTrendingWithNextPageCursor() {
        let promise = expectation(description: "Get trending request with next page cursor")
        var cursor: String!
        getTrending(success: { [unowned self] (trendingResponse) in
            cursor = trendingResponse.nextPageCursor
            self.getTrending(nextPageCursor: cursor, success: { (trendingResponse) in
                promise.fulfill()
            }, failure: { (error) in
                XCTFail("Get trending method with next page cursor finished with error. Please check get trending method in client API with nextPageCursor = \(cursor)).")
                promise.fulfill()
            })
        }) { (error) in
            XCTFail("Something went wrong in get trending method. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
    // MARK: - Get media by id
    func testGetMediaById() {
        let promise = expectation(description: "Get media by id")
        var id: String!
        getTrending(success: { [unowned self] (trendingResponse) in
            id = trendingResponse.media![0].id!
            self.getById(id: id, success: { (singleMediaResponse) in
                promise.fulfill()
            }, failure: { (error) in
                XCTFail("Get media by id method finished with error. Please check get media by id method in client API with id = \(id)).")
            })
        }) { (error) in
            XCTFail("Something went wrong in get trending method. First of all check that previous tests finished with success.")
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
    
}
