//
/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

@testable import CareKitStore
import XCTest

final class TestOutcomesSynchronization: XCTestCase {

    func testOutcomesSynchronization() throws {

        // 1. Setup the a server with two sync'd stores
        let remoteA = SimulatedRemote(name: "A")
        let storeA = OCKStore(name: "A", type: .inMemory, remote: remoteA)
        try storeA.syncAndWait()

        XCTAssert(try! storeA.fetchTasksAndWait().count == 1)
        XCTAssert(try! storeA.fetchOutcomesAndWait().count == 5)
        
        let nausea = try! storeA.fetchTasksAndWait(query: .init(id: "nausea")).first!
        let march15 = Calendar.current.date(from: .init(year: 2021, month:3, day: 15))!
        
        let nauseaEvents = try storeA.fetchEventsAndWait(taskID: nausea.id, query: .init(for: march15))
        XCTAssert(nauseaEvents.count == 1)

        let nauseaOutcome = nauseaEvents.first!.outcome
        XCTAssert(nauseaOutcome != nil)
        XCTAssert(nauseaOutcome!.values.count == 5)
        
    }
}

private final class SimulatedRemote: OCKRemoteSynchronizable {

    let name: String

    weak var delegate: OCKRemoteSynchronizationDelegate?

    var automaticallySynchronizes: Bool = false

    init(name: String) {
        self.name = name
    }

    func pullRevisions(
        since knowledgeVector: OCKRevisionRecord.KnowledgeVector,
        mergeRevision: @escaping (OCKRevisionRecord) -> Void,
        completion: @escaping (Error?) -> Void) {

        do {
            let decoder = JSONDecoder()
            let revision = try decoder.decode(OCKRevisionRecord.self, from: jsonString.data(using: .utf8)!)
            mergeRevision(revision)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func pushRevisions(
        deviceRevision: OCKRevisionRecord,
        completion: @escaping (Error?) -> Void) {
            completion(nil)
    }

    func chooseConflictResolution(
        conflicts: [OCKEntity], completion: @escaping OCKResultClosure<OCKEntity>) {

        let keep = conflicts.max(by: { $0.value.createdDate! > $1.value.createdDate! })!
        completion(.success(keep))
    }

    private let jsonString = "{\"knowledgeVector\":{\"processes\":[{\"id\":\"4CE82DE2-F41F-490E-9F50-D9450BB0EF64\",\"clock\":12},{\"id\":\"65797806-E94D-4FDC-AE8A-74B81CD92900\",\"clock\":4},{\"id\":\"C0226289-7F38-4625-977A-C53A663F6E8E\",\"clock\":4}]},\"entities\":[{\"type\":\"task\",\"object\":{\"id\":\"nausea\",\"uuid\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"nextVersionUUIDs\":[],\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"createdDate\":637569158.4899869,\"tags\":[],\"updatedDate\":637569158.49000001,\"title\":\"Track your nausea\",\"notes\":[],\"previousVersionUUIDs\":[],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"instructions\":\"Tap the button below anytime you experience nausea.\",\"impactsAdherence\":false,\"effectiveDate\":637142400,\"schedule\":{\"elements\":[{\"text\":\"Anytime throughout the day\",\"duration\":{\"isAllDay\":true},\"interval\":{\"minute\":0,\"hour\":0,\"second\":0,\"day\":1,\"month\":0,\"year\":0,\"weekOfYear\":0},\"targetValues\":[],\"start\":637142400}]}}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"59B7CE13-C381-4300-A9B7-A8FB51325FF4\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569161.63076901,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"A06AC993-2A91-444A-8D36-2303BF7879AD\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569162.96640611,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"59B7CE13-C381-4300-A9B7-A8FB51325FF4\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"E7B89B33-499C-4650-B4AE-CA647BD03602\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569164.12518001,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569164.122509,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"A06AC993-2A91-444A-8D36-2303BF7879AD\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"5830D963-B790-431C-AF76-78A90D5CC793\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569165.34137106,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569165.3385601,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569164.122509,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"E7B89B33-499C-4650-B4AE-CA647BD03602\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"E772CCD1-994F-440E-BDE2-F1103D1CD622\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569169.32398391,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569164.122509,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569169.32103109,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569165.3385601,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"5830D963-B790-431C-AF76-78A90D5CC793\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}}]}"


}
