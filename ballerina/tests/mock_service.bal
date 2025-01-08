import ballerina/http;

# Mock service for the HubSpot Pipeline API
service /crm/v3/pipelines on new http:Listener(9090) {

    resource function post [string objectType](@http:Payload PipelineInput payload) returns Pipeline|http:Response {
        Pipeline pipeline = {
            createdAt: "2024-06-17T12:00:00Z",
            archivedAt: (),
            archived: false,
            displayOrder: payload.displayOrder,
            stages: [
                {
                    id: "stage-001",
                    label: "Qualification",
                    displayOrder: 1,
                    createdAt: "2024-06-17T12:01:00Z",
                    updatedAt: "2024-06-17T12:10:00Z",
                    archived: false
                },
                {
                    id: "stage-002",
                    label: "Negotiation",
                    displayOrder: 2,
                    createdAt: "2024-06-17T12:05:00Z",
                    updatedAt: "2024-06-17T12:15:00Z",
                    archived: false
                }
            ],
            label: payload.label,
            id: "pipeline-123",
            updatedAt: "2024-06-18T15:45:00Z"
        };
        return pipeline;
    }

    resource function get [string objectType]/[string pipelineId]/audit() returns CollectionResponsePublicAuditInfoNoPaging|http:Response {
        CollectionResponsePublicAuditInfoNoPaging auditInfo = {
            results: [
                {
                    identifier: "audit-001",
                    rawObject: "raw-data-1",
                    fromUserId: 12345,
                    portalId: 67890,
                    action: "CREATE",
                    message: "Pipeline created",
                    timestamp: "2024-06-17T12:00:00Z"
                },
                {
                    identifier: "audit-002",
                    rawObject: "raw-data-2",
                    fromUserId: 12345,
                    portalId: 67890,
                    action: "UPDATE",
                    message: "Pipeline updated",
                    timestamp: "2024-06-18T15:45:00Z"
                }
            ]
        };
        return auditInfo;
    }

    resource function put [string objectType]/[string pipelineId](@http:Payload PipelinePatchInput payload) returns Pipeline|http:Response {
        Pipeline pipeline = {
            createdAt: "2024-06-17T12:00:00Z",
            archivedAt: (),
            archived: payload.archived ?: false,
            displayOrder: payload.displayOrder ?: 1,
            stages: [
                {
                    id: "stage-001",
                    label: "Qualification",
                    displayOrder: 1,
                    createdAt: "2024-06-17T12:01:00Z",
                    updatedAt: "2024-06-17T12:10:00Z",
                    archived: false
                },
                {
                    id: "stage-002",
                    label: "Negotiation",
                    displayOrder: 2,
                    createdAt: "2024-06-17T12:05:00Z",
                    updatedAt: "2024-06-17T12:15:00Z",
                    archived: false
                }
            ],
            label: payload.label ?: "Updated Pipeline",
            id: pipelineId,
            updatedAt: "2024-06-18T15:45:00Z"
        };
        return pipeline;
    }

    resource function delete [string objectType]/[string pipelineId]() returns http:Response {
        http:Response response = new ();
        response.setPayload({message: "Pipeline deleted successfully"});
        return response;
    }

    resource function get [string objectType]/[string pipelineId]() returns Pipeline|http:Response {
        Pipeline pipeline = {
            createdAt: "2024-06-17T12:00:00Z",
            archivedAt: (),
            archived: false,
            displayOrder: 1,
            stages: [
                {
                    id: "stage-001",
                    label: "Qualification",
                    displayOrder: 1,
                    createdAt: "2024-06-17T12:01:00Z",
                    updatedAt: "2024-06-17T12:10:00Z",
                    archived: false
                },
                {
                    id: "stage-002",
                    label: "Negotiation",
                    displayOrder: 2,
                    createdAt: "2024-06-17T12:05:00Z",
                    updatedAt: "2024-06-17T12:15:00Z",
                    archived: false
                }
            ],
            label: "Sample Pipeline",
            id: pipelineId,
            updatedAt: "2024-06-18T15:45:00Z"
        };
        return pipeline;
    }
}
