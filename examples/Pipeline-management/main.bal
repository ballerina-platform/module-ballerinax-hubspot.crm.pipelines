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

import ballerina/http;
import ballerina/io;
import ballerina/oauth2;
import ballerinax/hubspot.crm.pipelines as pipelines;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string pipelineLabel = "Orders Pipeline";
configurable string objectType = "orders";

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

    // Update pipeline
    pipelines:Pipeline updatedPipeline = check updatePipeline(hubspot, objectType, createdPipeline.id, "Updated Orders Pipeline");
    io:println("Updated pipeline name to: ", updatedPipeline.label);

    // Fetch and log all pipelines
    pipelines:Pipeline[] pipelineList = check getPipelines(hubspot, objectType);
    io:println("\nAll pipelines:");
    foreach var pipeline in pipelineList {
        io:println("- ", pipeline.label);
    }

    // Clean up (delete created pipeline)
    _ = check deletePipeline(hubspot, objectType, createdPipeline.id);
    io:println("Pipeline deleted: ", updatedPipeline.label);
}

function createPipeline(pipelines:Client hubspot, string objectType, string label) returns pipelines:Pipeline|error {
    return hubspot->/[objectType].post({
        "displayOrder": 0,
        "label": label,
        "stages": [
            {
                "label": "Order Received",
                "displayOrder": 0,
                "metadata": {
                    "probability": "0.2",
                    "orderStatus": "RECEIVED"
                }
            },
            {
                "label": "Processing",
                "displayOrder": 1,
                "metadata": {
                    "probability": "0.4",
                    "orderStatus": "PROCESSING"
                }
            },
            {
                "label": "Ready for Shipment",
                "displayOrder": 2,
                "metadata": {
                    "probability": "0.6",
                    "orderStatus": "READY_TO_SHIP"
                }
            },
            {
                "label": "Shipped",
                "displayOrder": 3,
                "metadata": {
                    "probability": "0.8",
                    "orderStatus": "SHIPPED"
                }
            },
            {
                "label": "Delivered",
                "displayOrder": 4,
                "metadata": {
                    "probability": "1.0",
                    "orderStatus": "DELIVERED"
                }
            }
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

function updatePipeline(pipelines:Client hubspot, string objectType, string pipelineId, string newLabel) returns pipelines:Pipeline|error {
    return hubspot->/[objectType]/[pipelineId].patch({
        displayOrder: 1,
        label: newLabel
    });
}
