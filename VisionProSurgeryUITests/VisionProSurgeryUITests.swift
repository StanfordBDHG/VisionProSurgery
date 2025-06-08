//
// This source file is part of the StanfordBDHG VisionProSurgery project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


class VisionProSurgeryUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testOnboardingFlow() throws {
        XCTAssertTrue(app.staticTexts["Spezi VP Surgery"].exists)
        XCTAssertTrue(app.staticTexts["Vision pro enabled streaming system"].exists)
        
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
        getStartedButton.tap()
    }
    
    func testConnectionSetup() throws {
        app.buttons["Get Started"].tap()
        
        XCTAssertTrue(app.textFields["Enter IP address"].exists)
        XCTAssertTrue(app.staticTexts["Enter Port Pin"].exists)
        
        let ipTextField = app.textFields["Enter IP address"]
        ipTextField.tap()
        ipTextField.typeText("invalid.ip")
        
        let connectButton = app.buttons["Establish Connection"]
        XCTAssertTrue(connectButton.exists)
        connectButton.tap()
        
        let alert = app.alerts["Connection Failed"]
        XCTAssertTrue(alert.exists)
        alert.buttons["Ok"].tap()
        
        let portTextFields = app.textFields.allElementsBoundByIndex
        XCTAssertEqual(portTextFields.count, 5)
        
        let portDigits = ["8", "0", "8", "0"]
        for (index, digit) in portDigits.enumerated() {
            let textField = portTextFields[index + 1]
            textField.tap()
            textField.typeText(digit)
        }
    }
}
