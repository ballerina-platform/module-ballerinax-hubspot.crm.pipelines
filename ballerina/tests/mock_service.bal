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
    
    http:Response response = new();

    if objectType is "object" {
        return pipeline;
    } else {
        return  response;
    }
}
};
