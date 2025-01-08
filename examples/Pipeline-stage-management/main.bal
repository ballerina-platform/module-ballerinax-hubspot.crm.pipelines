// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/oauth2;
import ballerinax/hubspot.crm.pipelines as pipelines;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
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

    pipelines:Pipeline pipeline = check createSupportPipeline(hubspot, objectType);
    io:println("Created pipeline: ", pipeline.label);

    pipelines:PipelineStage newStage = check addPipelineStage(hubspot, objectType, pipeline.id);
    io:println("Added new stage: ", newStage.label);

    pipelines:PipelineStage[] stages = check getPipelineStages(hubspot, objectType, pipeline.id);
    io:println("Current pipeline stages:");
    foreach pipelines:PipelineStage stage in stages {
        io:println(string `- ${stage.label} (${stage.id})`);
    }

    pipelines:PipelineStage updatedStage = check updateStageDetails(hubspot, objectType, pipeline.id, newStage.id);
    io:println("Updated stage: ", updatedStage.label);

    _ = check hubspot->/[objectType]/[pipeline.id]/stages/[newStage.id].delete();
    _ = check hubspot->/[objectType]/[pipeline.id].delete();
    io:println("Cleanup completed");
}

function createSupportPipeline(pipelines:Client hubspot, string objectType) returns pipelines:Pipeline|error {
    return hubspot->/[objectType].post({
        label: "Customer Support Pipeline",
        displayOrder: 0,
        stages: [
            {
                label: "New Ticket",
                displayOrder: 0,
                metadata: {
                    "ticketStatus": "NEW",
                    "priority": "MEDIUM"
                }
            }
        ]
    });
}

function addPipelineStage(pipelines:Client hubspot, string objectType, string pipelineId) returns pipelines:PipelineStage|error {
    return hubspot->/[objectType]/[pipelineId]/stages.post({
        label: "Under Investigation",
        displayOrder: 1,
        metadata: {
            "ticketStatus": "IN_PROGRESS",
            "priority": "HIGH"
        }
    });
}

function getPipelineStages(pipelines:Client hubspot, string objectType, string pipelineId) returns pipelines:PipelineStage[]|error {
    pipelines:CollectionResponsePipelineStageNoPaging response = check hubspot->/[objectType]/[pipelineId]/stages.get();
    return response.results;
}

function updateStageDetails(pipelines:Client hubspot, string objectType, string pipelineId, string stageId) returns pipelines:PipelineStage|error {
    return hubspot->/[objectType]/[pipelineId]/stages/[stageId].patch({
        label: "Investigation Complete",
        metadata: {
            "ticketStatus": "PENDING_REVIEW",
            "priority": "MEDIUM"
        }
    });
}
