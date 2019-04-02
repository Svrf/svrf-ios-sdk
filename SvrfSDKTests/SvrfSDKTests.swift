//
//  SvrfSDKTests.swift
//  SvrfSDKTests
//
//  Created by Andrei Evstratenko on 05/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import XCTest
import SVRFClient
//@testable import SvrfSDK

private var token: String?

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
    private func authorize(withApiKey apiKey: String,
                           success: @escaping (_ response: AuthResponse) -> Void,
                           failure: @escaping (_ error: Error) -> Void) {
        let body = Body(apiKey: apiKey)
        AuthenticateAPI.authenticate(body: body) { (response, error) in
            if error != nil {
                failure(error!)
            } else {
                success(response!)
            }
        }
    }

    private func search(query: String,
                        type: [MediaType]? = nil,
                        stereoscopicType: MediaAPI.StereoscopicType_search? = nil,
                        category: MediaAPI.Category_search? = nil,
                        size: Int? = nil,
                        pageNum: Int? = nil,
                        success: @escaping (_ response: SearchMediaResponse) -> Void,
                        failure: @escaping (_ error: Error) -> Void) {
        if token != nil {
            SVRFClientAPI.customHeaders = ["x-app-token": token!]
        }
        MediaAPI.search(q: query,
                        type: type,
                        stereoscopicType: stereoscopicType,
                        category: category,
                        size: size,
                        pageNum: pageNum) { (searchMediaResponse, error) in
            if error != nil {
                failure(error!)
            } else {
                success(searchMediaResponse!)
            }
        }
    }

    private func getTrending(type: [MediaType]? = nil,
                             stereoscopicType: MediaAPI.StereoscopicType_getTrending? = nil,
                             category: MediaAPI.Category_getTrending? = nil,
                             size: Int? = nil,
                             pageNum: Int? = nil,
                             success: @escaping (_ response: TrendingResponse) -> Void,
                             failure: @escaping (_ error: Error) -> Void) {
        if token != nil {
            SVRFClientAPI.customHeaders = ["x-app-token": token!]
        }
        MediaAPI.getTrending(type: type,
                             stereoscopicType: stereoscopicType,
                             category: category,
                             size: size,
                             pageNum: pageNum) { (trendingResponse, error) in
            if error != nil {
                failure(error!)
            } else {
                success(trendingResponse!)
            }
        }
    }

    private func getById(identifier: String,
                         success: @escaping (_ response: SingleMediaResponse) -> Void,
                         failure: @escaping (_ error: Error) -> Void) {
        if token != nil {
            SVRFClientAPI.customHeaders = ["x-app-token": token!]
        }
        MediaAPI.getById(id: identifier) { (singleMediaResponse, error) in
            if error != nil {
                failure(error!)
            } else {
                success(singleMediaResponse!)
            }
        }
    }

    func testAuthenticationWithIncorrectApiKey() {
        let promise = expectation(description: "Authentication request with incorrect apiKey")
        authorize(withApiKey: incorrectApiKey, success: { _ in
            XCTFail("""
                    Authentication method finished with success that despite what incorrect key was sent. \
                    Please check authentication method in client API library.
                    """)
            promise.fulfill()
        }, failure: { _ in
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    // MARK: - Authentication Tests
    func testAuthenticationWithCorrectApiKey() {
        let promise = expectation(description: "Authentication request with correct apiKey")
        authorize(withApiKey: correctApiKey, success: { (response) in
            if response.success == nil {
                XCTFail("Status(success field) in Authenticate response is nill.")
            }
            if response.message == nil {
                XCTFail("Message in Authenticate response is nill.")
            }
            if response.expiresIn == nil {
                XCTFail("ExpiresIn field in Authenticate response is nill.")
            }
            if response.token == nil {
                XCTFail("Token field in Authenticate response is nill.")
            }
            token = response.token
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Authentication method finished with error. \
                    Please check authentication method in client API library. In this test was sent correct apiKey.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    // MARK: - Search Methods Tests
    func testSearchMethodWithEmptyQuery() {
        let promise = expectation(description: "Search request with emty query")
        search(query: "", success: { _ in
            XCTFail("""
                    Response for search finished with success despite what empty q was sant. \
                    Please check search method in client API library.
                    """)
            promise.fulfill()
        }, failure: { _ in
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWithNotEmptyQuery() {
        let promise = expectation(description: "Search request with not empty query")
        search(query: singleSearchQuery, success: { (searchMediaResponse) in
            if searchMediaResponse.success == nil {
                XCTFail("Status(success field) in Search method response is nill.")
            }
            if searchMediaResponse.media == nil {
                XCTFail("Media array in Search method response is nill.")
            }
            if searchMediaResponse.totalNum == nil {
                XCTFail("Total count of elements(totalNum field) in Search method response is nill.")
            }
            if searchMediaResponse.tookMs == nil {
                XCTFail("The number of milliseconds the request took in Search method response is nill.")
            }
            if searchMediaResponse.pageNum == nil {
                XCTFail("The current page number in Search method response is nill.")
            }
            if searchMediaResponse.nextPageNum == nil {
                XCTFail("The next page in Search method response is nill.")
            }
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Search method finished with error. Please check search method in client API library.
                    In this test was sent correct query.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWithMultipleParameters() {
        let promise = expectation(description: "Search request with multiple parameters")
        search(query: singleSearchQuery,
              type: [MediaType.photo],
              stereoscopicType: nil,
              category: nil,
              size: 1,
              pageNum: nil,
              success: { _ in
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Search method finished with error. Please check search method in client API library. \
                    In this test was sent multiple parameters.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWithPhotoType() {
        let promise = expectation(description: "Search request with photo type")
        search(query: singleSearchQuery, type: [MediaType.photo], success: { (searchMediaResponse) in
            var isOnlySearchedType = true
            for mediaObject in searchMediaResponse.media! where mediaObject.type != MediaType.photo {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in search method with photo type. \
                          Please check search method in client API library. In this test was sent MediaType.Photo.
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with photo type. \
                    First of all check that previous test finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWithVideoType() {
        let promise = expectation(description: "Search request with video type")
        search(query: singleSearchQuery, type: [MediaType.video], success: { (searchMediaResponse) in
            var isOnlySearchedType = true
            for mediaObject in searchMediaResponse.media! where mediaObject.type != MediaType.video {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in search method with video type. \
                          Please check search method in client API library. \
                          In this test was sent MediaType.Video.
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with video type. \
                    First of all check that previous test finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith3dType() {
        let promise = expectation(description: "Search request with 3d type")
        search(query: singleSearchQuery, type: [MediaType._3d], success: { (searchMediaResponse) in
            var isOnlySearchedType = true
            for mediaObject in searchMediaResponse.media! where mediaObject.type != MediaType._3d {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType, """
                                              Another Media Type was detected in search method with 3d type. \
                                              Please check search method in client API library. \
                                              In this test was sent MediaType._3d.
                                              """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with 3d type. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWithMultipleTypes() {
        let promise = expectation(description: "Search request with multiple types")
        search(query: singleSearchQuery, type: [MediaType.video, MediaType.photo], success: { (searchMediaResponse) in
            var isOnlySearchedTypes = true
            for mediaObject in searchMediaResponse.media! where mediaObject.type == MediaType._3d {
                isOnlySearchedTypes = false
            }
            XCTAssertFalse(isOnlySearchedTypes,
                           """
                           Another Media Type was detected in search method with photo and video types. \
                           Please check search method in client API library. \
                           In this test was sent MediaType.video and MediaType.photo.
                           """)
            promise.fulfill()
        }, failure: { _ in
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith5Size() {
        let promise = expectation(description: "Search request with size = 5")
        search(query: singleSearchQuery, size: 5, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 5,
                          """
                          Search method response contains wrong count of elements. \
                          Please check search method in client API with size = 5
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with size = 5. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith20Size() {
        let promise = expectation(description: "Search request with size = 20")
        search(query: singleSearchQuery, size: 20, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 20,
                          """
                          Search method response contains wrong count of elements. \
                          Please check search method in client API with size = 20
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with size = 20. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith50Size() {
        let promise = expectation(description: "Search request with size = 50")
        search(query: singleSearchQuery, size: 50, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 50,
                          """
                          Search method response contains wrong count of elements. \
                          Please check search method in client API with size = 50
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with size = 50. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith70Size() {
        let promise = expectation(description: "Search request with size = 70")
        search(query: singleSearchQuery, size: 70, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 70,
                          """
                             Search method response contains wrong count of elements. \
                             Please check search method in client API with size = 70
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with size = 70. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith100Size() {
        let promise = expectation(description: "Search request with size = 100")
        search(query: singleSearchQuery, size: 100, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.media!.count == 100,
                          """
                          Search method response contains wrong count of elements. \
                          Please check search method in client API with size = 100
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with size = 100. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith3Page() {
        let promise = expectation(description: "Search request with page = 3")
        search(query: singleSearchQuery, pageNum: 3, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.pageNum == 3,
                          """
                          Search method response contain wrong count of elements. \
                          Please check search method in client API with page = 3
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with page = 3. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith15Page() {
        let promise = expectation(description: "Search request with page = 15")
        search(query: singleSearchQuery, pageNum: 15, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.pageNum == 15,
                          """
                          Search method response contain wrong count of elements. \
                          Please check search method in client API with page = 15
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with page = 15. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith40Page() {
        let promise = expectation(description: "Search request with page = 15")
        search(query: singleSearchQuery, pageNum: 40, success: { (searchMediaResponse) in
            XCTAssertTrue(searchMediaResponse.pageNum == 40,
                          """
                          Search method response contain wrong count of elements. \
                          Please check search method in client API with page = 40
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in search method with page = 40. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    // MARK: - Trending Methods Tests
    func testGetTrendingWithoutParameters() {
        let promise = expectation(description: "Get trending method without parameters")
        getTrending(success: { _ in
            promise.fulfill()
        }, failure: { _ in
            XCTFail("Get trending method finished with error. Please check get trending method in client API library.")
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWithPhotoType() {
        let promise = expectation(description: "Get trendinng with photo type")
        getTrending(type: [MediaType.photo], success: { (trendingResponse) in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! where mediaObject.type != MediaType.photo {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in get trending method with photo type.\
                          Please check get trending method in client API library.
                          In this test was sent MediaType.Photo.
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with photo type. \
                    First of all check that previous test finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWithVideoType() {
        let promise = expectation(description: "Get trending with video type")
        getTrending(type: [MediaType.video], success: { (trendingResponse) in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! where mediaObject.type != MediaType.video {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in get trending method with video type. \
                          Please check get trending method in client API library. In this test was sent MediaType.Video.
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with video type. \
                    First of all check that previous test finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWith3dType() {
        let promise = expectation(description: "Get trending with 3d type")
        getTrending(type: [MediaType._3d], success: { (trendingResponse) in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! where mediaObject.type != MediaType._3d {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in get trending method with 3d type.
                          Please check get trending method in client API library. In this test was sent MediaType._3d.
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with 3d type. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWithMultipleTypes() {
        let promise = expectation(description: "Get trending request with multiple types")
        getTrending(type: [MediaType.video, MediaType.photo], success: { (trendingResponse) in
            var isOnlySearchedTypes = true
            for mediaObject in trendingResponse.media! where mediaObject.type == MediaType._3d {
                isOnlySearchedTypes = false
            }
            XCTAssertFalse(isOnlySearchedTypes,
                           """
                           Another Media Type was detected in get trending method with photo and video types. \
                           Please check get trending method in client API library. \
                           In this test was sent MediaType.video and MediaType.photo.
                           """)
            promise.fulfill()
        }, failure: { _ in
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWith5Size() {
        let promise = expectation(description: "Get trending request with size = 5")
        getTrending(size: 5, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 5,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 5
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with size = 5. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWith20Size() {
        let promise = expectation(description: "Get trending request with size = 20")
        getTrending(size: 20, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 20,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 20
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with size = 20. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWith50Size() {
        let promise = expectation(description: "Get trending request with size = 50")
        getTrending(size: 50, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 50,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 50
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with size = 50. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWith70Size() {
        let promise = expectation(description: "Get trending request with size = 70")
        getTrending(size: 70, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 70,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 70
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with size = 70. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWith100Size() {
        let promise = expectation(description: "Get trending request with size = 100")
        getTrending(size: 100, success: { (trendingResponse) in
            XCTAssertTrue(trendingResponse.media!.count == 100,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 100
                          """)
            promise.fulfill()
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with size = 100.
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWithNextPageCursor() {
        let promise = expectation(description: "Get trending request with next page cursor")
        getTrending(success: { [unowned self] (trendingResponse) in
            self.getTrending(pageNum: trendingResponse.nextPageNum, success: { _ in
                promise.fulfill()
            }, failure: { _ in
                XCTFail("""
                        Get trending method with next page cursor finished with error.
                        Please check get trending method in client API with nextPageNum.
                        """)
                promise.fulfill()
            })
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method.
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    // MARK: - Get media by id
    func testGetMediaById() {
        let promise = expectation(description: "Get media by id")
        var identifier: String!
        getTrending(success: { [unowned self] (trendingResponse) in
            identifier = trendingResponse.media![0].id!
            self.getById(identifier: identifier, success: { _ in
                promise.fulfill()
            }, failure: { _ in
                XCTFail("""
                        Get media by id method finished with error.
                        Please check get media by id method in client API with id = \(identifier ?? "").
                        """)
            })
        }, failure: { _ in
            XCTFail("""
                    Something went wrong in get trending method.
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })
        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
}
