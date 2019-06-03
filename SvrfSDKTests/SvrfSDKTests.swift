//
//  SvrfSDKTests.swift
//  SvrfSDKTests
//
//  Created by Andrei Evstratenko on 05/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import XCTest

@testable import SvrfSDK

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
    private func authenticate(withApiKey apiKey: String,
                              success: @escaping (_ response: SvrfAuthenticationResponse) -> Void,
                              failure: @escaping (_ error: Error?) -> Void) {

        SvrfAPIManager.authenticate(with: apiKey, onSuccess: { authenticationResponse in
            success(authenticationResponse)
        }, onFailure: { error in
            failure(error)
        })
    }

    private func search(query: String,
                        options: SvrfOptions?,
                        success: @escaping (_ response: SvrfSearchResponse) -> Void,
                        failure: @escaping (_ error: Error?) -> Void) {

        _ = SvrfAPIManager.search(query: query, options: options, onSuccess: { searchResponse in
            success(searchResponse)
        }, onFailure: { error in
            failure(error)
        })
    }

    private func getTrending(options: SvrfOptions?,
                             success: @escaping (_ response: SvrfTrendingResponse) -> Void,
                             failure: @escaping (_ error: Error?) -> Void) {

        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            success(trendingResponse)
        }, onFailure: { error in
            failure(error)
        })
    }

    private func getById(id: String,
                         success: @escaping (_ response: SvrfMediaResponse) -> Void,
                         failure: @escaping (_ error: Error?) -> Void) {

        _ = SvrfAPIManager.getMedia(by: id, onSuccess: { mediaResponse in
            success(mediaResponse)
        }, onFailure: { error in
            failure(error)
        })
    }

    func testAuthenticationWithIncorrectApiKey() {

        let promise = expectation(description: "Authentication request with incorrect apiKey")
        authenticate(withApiKey: incorrectApiKey, success: { _ in
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
        authenticate(withApiKey: correctApiKey, success: { (response) in
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
        search(query: "", options: nil, success: { _ in
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
        search(query: singleSearchQuery, options: nil, success: { searchMediaResponse in
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

        let options = SvrfOptions(type: [.photo], size: 1)
        search(query: singleSearchQuery, options: options, success: { _ in
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

        let options = SvrfOptions(type: [.photo])
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            var isOnlySearchedType = true
            for mediaObject in searchResponse.media! where mediaObject.type != SvrfMediaType.photo {
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

        let options = SvrfOptions(type: [.video])
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            var isOnlySearchedType = true
            for mediaObject in searchResponse.media! where mediaObject.type != SvrfMediaType.photo {
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

        let options = SvrfOptions(type: [._3d])
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            var isOnlySearchedType = true
            for mediaObject in searchResponse.media! where mediaObject.type != SvrfMediaType._3d {
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

        let options = SvrfOptions(type: [.photo, .video])
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            var isOnlySearchedTypes = true
            for mediaObject in searchResponse.media! where mediaObject.type == SvrfMediaType._3d {
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

        let options = SvrfOptions(size: 5)
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            XCTAssertTrue(searchResponse.media!.count == 5,
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

        let options = SvrfOptions(size: 20)
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            XCTAssertTrue(searchResponse.media!.count == 20,
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

        let options = SvrfOptions(size: 50)
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            XCTAssertTrue(searchResponse.media!.count == 50,
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

        let options = SvrfOptions(size: 70)
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            XCTAssertTrue(searchResponse.media!.count == 70,
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

        let options = SvrfOptions(size: 100)
        search(query: singleSearchQuery, options: options, success: { searchResponse in
            XCTAssertTrue(searchResponse.media!.count == 100,
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

        let options = SvrfOptions(pageNum: 3)
        _ = SvrfAPIManager.search(query: singleSearchQuery, options: options, onSuccess: { searchResponse in
            XCTAssertTrue(searchResponse.pageNum == 3,
                          """
                          Search method response contain wrong count of elements. \
                          Please check search method in client API with page = 3
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        let options = SvrfOptions(pageNum: 15)
        _ = SvrfAPIManager.search(query: singleSearchQuery, options: options, onSuccess: { searchResponse in
            XCTAssertTrue(searchResponse.pageNum == 15,
                          """
                          Search method response contain wrong count of elements. \
                          Please check search method in client API with page = 15
                          """)
            promise.fulfill()
        }, onFailure: { _ in
            XCTFail("""
                    Something went wrong in search method with page = 15. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })

        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testSearchMethodWith40Page() {

        let promise = expectation(description: "Search request with page = 40")

        let options = SvrfOptions(pageNum: 40)
        _ = SvrfAPIManager.search(query: singleSearchQuery, options: options, onSuccess: { searchResponse in
            XCTAssertTrue(searchResponse.pageNum == 3,
                          """
                          Search method response contain wrong count of elements. \
                          Please check search method in client API with page = 40
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        _ = SvrfAPIManager.getTrending(options: nil, onSuccess: { _ in
            promise.fulfill()
        }, onFailure: { _ in
            XCTFail("Get trending method finished with error. Please check get trending method in client API library.")
            promise.fulfill()
        })

        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWithPhotoType() {

        let promise = expectation(description: "Get trendinng with photo type")

        let options = SvrfOptions(type: [.photo])
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! where mediaObject.type != SvrfMediaType.photo {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in get trending method with photo type.\
                          Please check get trending method in client API library.
                          In this test was sent MediaType.Photo.
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        let options = SvrfOptions(type: [.video])
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! where mediaObject.type != SvrfMediaType.video {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in get trending method with video type. \
                          Please check get trending method in client API library. In this test was sent MediaType.Video.
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        let options = SvrfOptions(type: [.video])
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            var isOnlySearchedType = true
            for mediaObject in trendingResponse.media! where mediaObject.type != SvrfMediaType._3d {
                isOnlySearchedType = false
            }
            XCTAssertTrue(isOnlySearchedType,
                          """
                          Another Media Type was detected in get trending method with 3d type.
                          Please check get trending method in client API library. In this test was sent MediaType._3d.
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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
        let options = SvrfOptions(type: [.video, .photo])
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            var isOnlySearchedTypes = true
            for mediaObject in trendingResponse.media! where mediaObject.type == SvrfMediaType._3d {
                isOnlySearchedTypes = false
            }
            XCTAssertFalse(isOnlySearchedTypes,
                           """
                           Another Media Type was detected in get trending method with photo and video types. \
                           Please check get trending method in client API library. \
                           In this test was sent MediaType.video and MediaType.photo.
                           """)
            promise.fulfill()
        }, onFailure: { _ in
            promise.fulfill()
        })

        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWith5Size() {

        let promise = expectation(description: "Get trending request with size = 5")

        let options = SvrfOptions(size: 5)
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            XCTAssertTrue(trendingResponse.media!.count == 5,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 5
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        let options = SvrfOptions(size: 20)
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            XCTAssertTrue(trendingResponse.media!.count == 20,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 20
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        let options = SvrfOptions(size: 50)
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            XCTAssertTrue(trendingResponse.media!.count == 50,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 50
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        let options = SvrfOptions(size: 70)
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            XCTAssertTrue(trendingResponse.media!.count == 70,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 70
                          """)
            promise.fulfill()
        }, onFailure: { _ in
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

        let options = SvrfOptions(size: 100)
        _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
            XCTAssertTrue(trendingResponse.media!.count == 100,
                          """
                          Get trending method response contains wrong count of elements. \
                          Please check get trending method in client API with size = 100
                          """)
            promise.fulfill()
        }, onFailure: { _ in
            XCTFail("""
                    Something went wrong in get trending method with size = 100. \
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })

        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }

    func testGetTrendingWithPageNum() {
        let promise = expectation(description: "Get trending request with next page cursor")

        _ = SvrfAPIManager.getTrending(options: nil, onSuccess: { trendingResponse in

            let options = SvrfOptions(pageNum: trendingResponse.pageNum)
            _ = SvrfAPIManager.getTrending(options: options, onSuccess: { _ in
                promise.fulfill()
            }, onFailure: { _ in
                XCTFail("""
                        Get trending method with next page cursor finished with error.
                        Please check get trending method in client API with nextPageNum.
                        """)
            })
        }, onFailure: { _ in
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

        _ = SvrfAPIManager.getTrending(options: nil, onSuccess: { trendingResponse in
            let id = trendingResponse.media?.first?.id!
            _ = SvrfAPIManager.getMedia(by: id!, onSuccess: { _ in
                promise.fulfill()
            }, onFailure: { _ in
                XCTFail("""
                    Get media by id method finished with error.
                    Please check get media by id method in client API with id = \(id!).
                    """)
            })
        }, onFailure: { _ in
            XCTFail("""
                    Something went wrong in get trending method.
                    First of all check that previous tests finished with success.
                    """)
            promise.fulfill()
        })

        waitForExpectations(timeout: requestTimeOut, handler: nil)
    }
}
