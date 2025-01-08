import ballerina/http;
import ballerina/io;
import ballerina/oauth2;
import ballerinax/hubspot.crm.pipelines as pipelines;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string pipelineLabel = "Support Pipeline";
configurable string objectType = "tickets";

public function main() returns error? {
    pipelines:OAuth2RefreshTokenGrantConfig auth = {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshToken: refreshToken,
        credentialBearer: oauth2:POST_BODY_BEARER
    };
    pipelines:ConnectionConfig config = {auth: auth};
    pipelines:Client hubspot = check new (config);

    // Create pipeline
    pipelines:Pipeline createdPipeline = check createPipeline(hubspot, objectType, pipelineLabel);
    io:println("Created pipeline: ", createdPipeline.label);

    // Fetch and log all pipelines
    pipelines:Pipeline[] pipelineList = check getPipelines(hubspot, objectType);
    io:println("\nAll pipelines:");
    foreach var pipeline in pipelineList {
        io:println("- ", pipeline.label);
    }

    // Clean up (delete created pipeline)
    _ = check deletePipeline(hubspot, objectType, createdPipeline.id);
    io:println("Pipeline deleted: ", createdPipeline.label);
}

function createPipeline(pipelines:Client hubspot, string objectType, string label) returns pipelines:Pipeline|error {
    return hubspot->/[objectType].post({
        displayOrder: 0,
        label: label,
        stages: [
            {label: "Submitted", displayOrder: 0, metadata: {"ticketState": "OPEN"}},
            {label: "Initial Review", displayOrder: 1, metadata: {"ticketState": "OPEN"}},
            {label: "Solution Delivered", displayOrder: 2, metadata: {"ticketState": "CLOSED"}}
        ]
    });
}

function getPipelines(pipelines:Client hubspot, string objectType) returns pipelines:Pipeline[]|error {
    pipelines:CollectionResponsePipelineNoPaging response = check hubspot->/[objectType].get();
    return response.results;
}

function deletePipeline(pipelines:Client hubspot, string objectType, string pipelineId) returns http:Response|error {
    return hubspot->/[objectType]/[pipelineId].delete();
}
