
//  Created by Mamdouh El Nakeeb on 5/14/17.
import UIKit
import XCTest

class Bug {
    enum State {
        case open
        case closed
    }
    
    let state: State
    let timestamp: Date
    let comment: String
    
    init(state: State, timestamp: Date, comment: String) {
        // To be implemented
        self.state = state
        self.timestamp = timestamp
        self.comment = comment
    }
    
    init(jsonString: String) throws {
        // To be implemented
        
        do {
            // get JSON from String
            let data = jsonString.data(using: .utf8)
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
    
            // get State String and set Bug state
            let state = json.value(forKey: "state") as! String
            switch state {
            case "open":
                self.state = Bug.State.open
                break
            case "closed":
                self.state = Bug.State.closed
                break
            default:
                self.state = Bug.State.closed
                break
            }
            
            // get Timestamp Double and set Bug timeInterval
            let timestamp = json.value(forKey: "timestamp") as! Double
            self.timestamp = Date(timeIntervalSince1970: timestamp)
            
            // get Comment String and set Bug comment
            self.comment = json.value(forKey: "comment") as! String
            
        }
        
    }
    
}

enum TimeRange {
    case pastDay
    case pastWeek
    case pastMonth
}

class Application {
    var bugs: [Bug]
    
    init(bugs: [Bug]) {
        self.bugs = bugs
    }
    
    func findBugs(state: Bug.State?, timeRange: TimeRange) -> [Bug] {
        // To be implemented
        var bugArray:Array<Bug> = Array<Bug>()
        
        var timeRangeInterval: Double = 0
        let currentTime = NSDate().timeIntervalSince1970
        
        switch timeRange.hashValue {
        case 0:
            // Day timeInterval
            timeRangeInterval = 86400
            break
        case 1:
            // Week timeInterval
            timeRangeInterval = 604800
            break
        case 2:
            // Month timeInterval
            timeRangeInterval = 2678400
            break
        default:
            break
        }
        
        for bug in bugs{
        
            // get filtered bugs from Bugs array
            if (bug.state == state) && (currentTime - (bug.timestamp.timeIntervalSince1970) <= timeRangeInterval){
                bugArray.append(bug)
            }
        }
        
        return bugArray
    }
}

class UnitTests : XCTestCase {
    lazy var bugs: [Bug] = {
        var date26HoursAgo = Date()
        date26HoursAgo.addTimeInterval(-1 * (26 * 60 * 60))
        
        var date2WeeksAgo = Date()
        date2WeeksAgo.addTimeInterval(-1 * (14 * 24 * 60 * 60))
        
        let bug1 = Bug(state: .open, timestamp: Date(), comment: "Bug 1")
        let bug2 = Bug(state: .open, timestamp: date26HoursAgo, comment: "Bug 2")
        let bug3 = Bug(state: .closed, timestamp: date2WeeksAgo, comment: "Bug 3")

        return [bug1, bug2, bug3]
    }()
    
    lazy var application: Application = {
        let application = Application(bugs: self.bugs)
        return application
    }()

    func testFindOpenBugsInThePastDay() {
        let bugs = application.findBugs(state: .open, timeRange: .pastDay)
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
        XCTAssertEqual(bugs[0].comment, "Bug 1", "Invalid bug order")
    }
    
    func testFindClosedBugsInThePastMonth() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastMonth)
        
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
    }
    
    func testFindClosedBugsInThePastWeek() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastWeek)
        
        XCTAssertTrue(bugs.count == 0, "Invalid number of bugs")
    }
    
    func testInitializeBugWithJSON() {
        do {
            let json = "{\"state\": \"open\",\"timestamp\": 1493393946,\"comment\": \"Bug via JSON\"}"

            let bug = try Bug(jsonString: json)
            
            XCTAssertEqual(bug.comment, "Bug via JSON")
            XCTAssertEqual(bug.state, .open)
            XCTAssertEqual(bug.timestamp, Date(timeIntervalSince1970: 1493393946))
        } catch {
            print(error)
        }
    }
}

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(String(describing: testCase.name)), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

TestRunner().runTests(testClass: UnitTests.self)
