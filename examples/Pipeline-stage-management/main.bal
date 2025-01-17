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
import ballerinax/hubspot.crm.pipelines as hspipelines;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string objectType = "tickets";

final hspipelines:OAuth2RefreshTokenGrantConfig auth = {
    clientId,
    clientSecret,
    refreshToken,
    credentialBearer: oauth2:POST_BODY_BEARER
};

final hspipelines:Client hubSpotPipelines = check new ({auth});

public function main() returns error? {

    hspipelines:Pipeline pipeline = check createSupportPipeline(hubSpotPipelines, objectType);
    io:println("Created pipeline: ", pipeline.label);

    hspipelines:PipelineStage newStage = check addPipelineStage(hubSpotPipelines, objectType, pipeline.id);
    io:println("Added new stage: ", newStage.label);

    hspipelines:PipelineStage[] stages = check getPipelineStages(hubSpotPipelines, objectType, pipeline.id);
    io:println("Current pipeline stages:");
    foreach hspipelines:PipelineStage stage in stages {
        io:println(string `- ${stage.label} (${stage.id})`);
    }

    hspipelines:PipelineStage updatedStage = check updateStageDetails(hubSpotPipelines, objectType, pipeline.id, newStage.id);
    io:println("Updated stage: ", updatedStage.label);

    _ = check hubSpotPipelines->/[objectType]/[pipeline.id]/stages/[newStage.id].delete();
    _ = check hubSpotPipelines->/[objectType]/[pipeline.id].delete();
    io:println("Cleanup completed");
}

function createSupportPipeline(hspipelines:Client hubspot, string objectType) returns hspipelines:Pipeline|error {
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

function addPipelineStage(hspipelines:Client hubspot, string objectType, string pipelineId) returns hspipelines:PipelineStage|error {
    return hubspot->/[objectType]/[pipelineId]/stages.post({
        label: "Under Investigation",
        displayOrder: 1,
        metadata: {
            "ticketStatus": "IN_PROGRESS",
            "priority": "HIGH"
        }
    });
}

function getPipelineStages(hspipelines:Client hubspot, string objectType, string pipelineId) returns hspipelines:PipelineStage[]|error {
    hspipelines:CollectionResponsePipelineStageNoPaging response = check hubspot->/[objectType]/[pipelineId]/stages.get();
    return response.results;
}

function updateStageDetails(hspipelines:Client hubspot, string objectType, string pipelineId, string stageId) returns hspipelines:PipelineStage|error {
    return hubspot->/[objectType]/[pipelineId]/stages/[stageId].patch({
        label: "Investigation Complete",
        metadata: {
            "ticketStatus": "PENDING_REVIEW",
            "priority": "MEDIUM"
        }
    });
}
