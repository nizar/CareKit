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

import Foundation
import CareKitStore

public final class SimulatedServer {

    private(set) var revisions = [(stamp: OCKRevisionRecord.KnowledgeVector, data: Data)]()

    private var knowledge = OCKRevisionRecord.KnowledgeVector()

    func upload(
        data: Data?,
        deviceKnowledge: OCKRevisionRecord.KnowledgeVector,
        from remote: SimulatedRemote) throws {

        if let latest = revisions.last?.stamp, latest >= deviceKnowledge {
            let problem = "New knowledge on server. Pull first then try again"
            throw OCKStoreError.remoteSynchronizationFailed(reason: problem)
        }

        knowledge.merge(with: deviceKnowledge)

        if let data = data {
            revisions.append((stamp: deviceKnowledge, data: data))
        }
    }

    func updates(
        for deviceKnowledge: OCKRevisionRecord.KnowledgeVector,
        from remote: SimulatedRemote) -> (stamp: OCKRevisionRecord.KnowledgeVector, data: [Data]) {

        let newToRemote = revisions.filter { $0.stamp >= deviceKnowledge }
        let newData = newToRemote.map(\.data)

        return (stamp: knowledge, newData)
    }
}

public final class SimulatedRemote: OCKRemoteSynchronizable {

    let name: String

    let server: SimulatedServer

    public weak var delegate: OCKRemoteSynchronizationDelegate?

    public var automaticallySynchronizes: Bool = true

    init(name: String, server: SimulatedServer) {
        self.name = name
        self.server = server
    }

    public func pullRevisions(
        since knowledgeVector: OCKRevisionRecord.KnowledgeVector,
        mergeRevision: @escaping (OCKRevisionRecord) -> Void,
        completion: @escaping (Error?) -> Void) {

        do {
            let response = server.updates(for: knowledgeVector, from: self)
            let decoder = JSONDecoder()
            let entities = try response.data.flatMap { try decoder.decode([OCKEntity].self, from: $0) }
            let revision = OCKRevisionRecord(entities: entities, knowledgeVector: response.stamp)
            mergeRevision(revision)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func pushRevisions(
        deviceRevision: OCKRevisionRecord,
        completion: @escaping (Error?) -> Void) {

        do {
            let data = deviceRevision.entities.isEmpty ?
                nil : try! JSONEncoder().encode(deviceRevision.entities)

            let knowledge = deviceRevision.knowledgeVector

            try server.upload(data: data, deviceKnowledge: knowledge, from: self)

            completion(nil)

        } catch {
            completion(error)
        }
    }

    public func chooseConflictResolution(
        conflicts: [OCKEntity], completion: @escaping OCKResultClosure<OCKEntity>) {

        let keep = conflicts.first!
//        let keep = conflicts.max(by: { $0.value.createdDate! > $1.value.createdDate! })!
        completion(.success(keep))
    }
}
