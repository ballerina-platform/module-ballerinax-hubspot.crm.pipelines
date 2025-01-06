// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
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
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/io;
import ballerina/oauth2;
import ballerinax/hubspot.crm.pipelines as pipelines;

// Configuration for HubSpot authentication
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string serviceUrl = "https://api.hubapi.com/crm/v3/pipelines";

// Initialize authentication configuration
pipelines:OAuth2RefreshTokenGrantConfig auth = {
    clientId: clientId,
    clientSecret: clientSecret,
    refreshToken: refreshToken,
    credentialBearer: oauth2:POST_BODY_BEARER
};

pipelines:ConnectionConfig config = {
    auth: auth
};

public function main() returns error? {
    final pipelines:Client hubspot = check new (config, serviceUrl);
    
    // Create a new orders pipeline
    string objectType = "orders"; 
    
    // Define pipeline stages for order processing
    pipelines:Pipeline newPipeline = check hubspot->/[objectType].post({
        "displayOrder": 1,
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
        ],
        "label": "pipelineName"
    });
    
    io:println("Created new pipeline: ", newPipeline.label);
    
    // Get all pipelines to verify creation
    pipelines:CollectionResponsePipelineNoPaging searchResult = check hubspot->/[objectType].get();
    pipelines:Pipeline[] pipelineList = <pipelines:Pipeline[]>searchResult.results;
    
    io:println("\nAll active pipelines:");
    foreach pipelines:Pipeline pipeline in pipelineList {
        io:println("Pipeline Name: ", pipeline.label);
        pipelines:PipelineStage[] stages = <pipelines:PipelineStage[]>pipeline.stages;
        io:println("Stages:");
        foreach pipelines:PipelineStage stage in stages {
            io:println("\t- ", stage.label);
        }
    }
    
    // Update a specific pipeline stage if needed
    string pipelineId = newPipeline.id;
    pipelines:Pipeline updatedPipeline = check hubspot->/[objectType]/[pipelineId].patch({
        displayOrder: 1,
        label: "Updated Pipeline Name"
    });
    
    io:println("\nUpdated pipeline stages for: ", updatedPipeline.label);
    
    // Cleanup
    _ = check hubspot->/[objectType]/[pipelineId].delete();
}