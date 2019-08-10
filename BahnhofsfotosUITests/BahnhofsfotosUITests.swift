//
//  BahnhofsfotosUITests.swift
//  BahnhofsfotosUITests
//
//  Created by Lennart Fischer on 10.08.19.
//  Copyright © 2019 Railway-Stations. All rights reserved.
//

import XCTest

class BahnhofsfotosUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTest() {
        
        
        
    }

}
