//

import Foundation
import CareKitStore

public final class SimulatedServer {

    private(set) var revisions = [(stamp: OCKRevisionRecord.KnowledgeVector, data: Data)]()
    private var knowledge = OCKRevisionRecord.KnowledgeVector()

    init() {
        let decoder = JSONDecoder()
        let revision = try! decoder.decode(OCKRevisionRecord.self, from: jsonString.data(using: .utf8)!)
        self.revisions.append((stamp: revision.knowledgeVector, data: try! JSONEncoder().encode(revision.entities)))
        self.knowledge = revision.knowledgeVector
    }
    
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
    
    private var jsonString: String = {
        return "{\"knowledgeVector\":{\"processes\":[{\"id\":\"4CE82DE2-F41F-490E-9F50-D9450BB0EF64\",\"clock\":12},{\"id\":\"65797806-E94D-4FDC-AE8A-74B81CD92900\",\"clock\":4},{\"id\":\"C0226289-7F38-4625-977A-C53A663F6E8E\",\"clock\":4}]},\"entities\":[{\"type\":\"task\",\"object\":{\"id\":\"nausea\",\"uuid\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"nextVersionUUIDs\":[],\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"createdDate\":637569158.4899869,\"tags\":[],\"updatedDate\":637569158.49000001,\"title\":\"Track your nausea\",\"notes\":[],\"previousVersionUUIDs\":[],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"instructions\":\"Tap the button below anytime you experience nausea.\",\"impactsAdherence\":false,\"effectiveDate\":637142400,\"schedule\":{\"elements\":[{\"text\":\"Anytime throughout the day\",\"duration\":{\"isAllDay\":true},\"interval\":{\"minute\":0,\"hour\":0,\"second\":0,\"day\":1,\"month\":0,\"year\":0,\"weekOfYear\":0},\"targetValues\":[],\"start\":637142400}]}}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"59B7CE13-C381-4300-A9B7-A8FB51325FF4\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569161.63076901,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"A06AC993-2A91-444A-8D36-2303BF7879AD\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569162.96640611,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"59B7CE13-C381-4300-A9B7-A8FB51325FF4\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"E7B89B33-499C-4650-B4AE-CA647BD03602\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569164.12518001,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569164.122509,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"A06AC993-2A91-444A-8D36-2303BF7879AD\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"5830D963-B790-431C-AF76-78A90D5CC793\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569165.34137106,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569165.3385601,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569164.122509,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"E7B89B33-499C-4650-B4AE-CA647BD03602\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}},{\"type\":\"outcome\",\"object\":{\"schemaVersion\":{\"majorVersion\":2,\"minorVersion\":1,\"patchNumber\":0},\"nextVersionUUIDs\":[],\"uuid\":\"E772CCD1-994F-440E-BDE2-F1103D1CD622\",\"createdDate\":637569161.6307621,\"tags\":[],\"updatedDate\":637569169.32398391,\"taskOccurrenceIndex\":4,\"values\":[{\"type\":\"boolean\",\"createdDate\":637569161.627213,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569164.122509,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569169.32103109,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569162.96377802,\"value\":true},{\"type\":\"boolean\",\"createdDate\":637569165.3385601,\"value\":true}],\"notes\":[],\"taskUUID\":\"0838965B-FCAB-44A8-A6D8-418E9F02BC4C\",\"previousVersionUUIDs\":[\"5830D963-B790-431C-AF76-78A90D5CC793\"],\"timezone\":{\"identifier\":\"America\\/Los_Angeles\"},\"effectiveDate\":637569161.62754393}}]}"
    }()
}

public final class SimulatedRemote: OCKRemoteSynchronizable {

    let name: String

    let server: SimulatedServer

    public weak var delegate: OCKRemoteSynchronizationDelegate?

    public var automaticallySynchronizes: Bool = false

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

//        let keep = conflicts.max(by: { $0.value.createdDate! > $1.value.createdDate! })!
        completion(.success(conflicts.first!))
    }
}
