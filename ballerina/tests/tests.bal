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

import ballerina/oauth2;
import ballerina/test;
import ballerina/time;

configurable boolean isLiveServer = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

configurable string serviceUrl = isLiveServer ? "https://api.hubapi.com/crm/v3/pipelines" : "http://localhost:9090/crm/v3/pipelines";

OAuth2RefreshTokenGrantConfig auth = {
    clientId: clientId,
    clientSecret: clientSecret,
    refreshToken: refreshToken,
    credentialBearer: oauth2:POST_BODY_BEARER // this line should be added in to when you are going to create auth object.
};

ConnectionConfig config = {auth: auth};
final Client hubspot = check new Client(config, serviceUrl);

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPostPipeline() returns error? {
    string objectType = "orders";
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;

    // Create pipeline
    Pipeline response = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "In Progress",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            },
            {
                "label": "Done",
                "metadata": {
                    "ticketState": "CLOSED"
                },
                "displayOrder": 1
            }
        ],
        "label": uniqueLabel
    });

    // Verify all fields of the created pipeline
    test:assertEquals(uniqueLabel, response.label, "Pipeline label should match the provided label");
    test:assertEquals(0, response.displayOrder, "Display order should be 0");
    test:assertEquals(2, response.stages.length(), "Pipeline should have two stages");

    // Cleanup - use the ID directly from the creation response
    _ = check hubspot->/["orders"]/[response.id].delete();
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelines() returns error? {
    string objectType = "orders";
    CollectionResponsePipelineNoPaging response = check hubspot->/[objectType].get();

    // Verify response has results
    test:assertTrue(response.results.length() > 0, "Response should contain at least one pipeline");

    // Verify first pipeline has stages
    test:assertTrue(response.results[0].stages.length() > 0, "Pipeline should have at least one stage");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelineById() returns error? {
    string pipelineId = "673651319";
    string objectType = "orders";
    Pipeline response = check hubspot->/[objectType]/[pipelineId].get();

    // Verify pipeline ID matches requested ID
    test:assertEquals(response.id, pipelineId, "Pipeline ID should match the requested ID");

    // Verify pipeline has at least one stage
    test:assertTrue(response.stages.length() > 0, "Pipeline should have at least one stage");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPutPipeline() returns error? {
    string objectType = "orders";
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;

    // Create pipeline
    Pipeline tempPipeline = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "In Progress",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            },
            {
                "label": "Done",
                "metadata": {
                    "ticketState": "CLOSED"
                },
                "displayOrder": 1
            }
        ],
        "label": uniqueLabel
    });

    string pipelineId = tempPipeline.id; // Store ID directly from creation response

    // Update pipeline
    Pipeline response = check hubspot->/[objectType]/[pipelineId].put(payload = {
        "displayOrder": 1,
        "stages": [
            {
                "label": "New Stage",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            }
        ],
        "label": "Updated Pipeline"
    });

    // Verify all updated fields
    test:assertEquals(response.label, "Updated Pipeline", "Pipeline label should be updated");
    test:assertEquals(response.stages.length(), 1, "Pipeline should have one stage");
    test:assertEquals(response.displayOrder, 1, "Display order should be updated");
    test:assertEquals(response.stages[0].label, "New Stage", "Stage label should be updated");

    // Cleanup
    _ = check hubspot->/[objectType]/[pipelineId].delete();
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPatchPipeline() returns error? {
    // Create a test pipeline first
    string objectType = "orders";
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;
    Pipeline tempPipeline = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "Stage 1",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            }
        ],
        "label": uniqueLabel
    });

    string pipelineId = tempPipeline.id;

    // Generate another unique name for the update
    string updatedLabel = string `Updated_Pipeline_${time:utcNow()[0]}`;

    // Perform the patch operation with unique name
    Pipeline response = check hubspot->/[objectType]/[pipelineId].patch(payload = {
        "label": updatedLabel
    });

    // Verify the patch
    test:assertEquals(updatedLabel, response.label, "Pipeline label should be updated");
    test:assertEquals(tempPipeline.stages.length(), response.stages.length(), "Stages should remain unchanged");
    test:assertEquals(tempPipeline.displayOrder, response.displayOrder, "Display order should remain unchanged");

    // Cleanup
    _ = check hubspot->/[objectType]/[pipelineId].delete();
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testDeletePipeline() returns error? {
    // Create a test pipeline first
    string objectType = "orders";
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;
    Pipeline response = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "In Progress",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            },
            {
                "label": "Done",
                "metadata": {
                    "ticketState": "CLOSED"
                },
                "displayOrder": 1
            }
        ],
        "label": uniqueLabel
    });

    string pipelineId = response.id;

    // Delete the pipeline
    _ = check hubspot->/[objectType]/[pipelineId].delete();

    // Verify deletion by attempting to get the pipeline
    CollectionResponsePipelineNoPaging pipelines = check hubspot->/orders.get();
    boolean pipelineExists = false;
    foreach Pipeline pipeline in pipelines.results {
        if pipeline.id == pipelineId {
            pipelineExists = true;
            break;
        }
    }

    test:assertFalse(pipelineExists, "Pipeline should be deleted");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelineAuditLog() returns error? {
    string pipelineId = "673651319";

    CollectionResponsePublicAuditInfoNoPaging|error response = hubspot->/["orders"]/[pipelineId]/audit.get();

    if response is CollectionResponsePublicAuditInfoNoPaging {
        test:assertTrue(response.results.length() > 0, "Pipeline audit should have at least one entry");
    } else {
        return response;
    }
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelineStageAuditLog() returns error? {
    string pipelineId = "673651319";
    string stageId = "987806513"; // Replace with actual stage ID
    string objectType = "orders";

    CollectionResponsePublicAuditInfoNoPaging|error response =
        check hubspot->/[objectType]/[pipelineId]/stages/[stageId]/audit.get();

    if response is CollectionResponsePublicAuditInfoNoPaging {
        test:assertTrue(response.results.length() > 0, "Pipeline stage audit should have at least one entry");
    } else {
        return response;
    }
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelineStageById() returns error? {
    string pipelineId = "673651319";
    string stageId = "987806513";
    string objectType = "orders";

    PipelineStage response = check hubspot->/[objectType]/[pipelineId]/stages/[stageId].get();
    // Verify basic properties
    test:assertNotEquals(response.id, "", "Stage ID should not be empty");
    test:assertNotEquals(response.label, "", "Stage label should not be empty");
    test:assertTrue(response.displayOrder >= 0, "Display order should be non-negative");

    // Verify timestamps are present
    test:assertNotEquals(response.createdAt, "", "Created timestamp should not be empty");
    test:assertNotEquals(response.updatedAt, "", "Updated timestamp should not be empty");

    // Verify specific fields match expected values
    test:assertEquals(response.archived, false, "Stage should not be archived by default");
    test:assertEquals(response.writePermissions, "CRM_PERMISSIONS_ENFORCEMENT",
            "Write permissions should match expected value");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetAllPipelineStages() returns error? {
    string pipelineId = "673651319";
    string objectType = "orders";

    CollectionResponsePipelineStageNoPaging|error response =
        check hubspot->/[objectType]/[pipelineId]/stages.get();

    if response is CollectionResponsePipelineStageNoPaging {
        // Verify we have at least one stage
        test:assertTrue(response.results.length() > 0, "Pipeline should have at least one stage");

        // Test the first stage in the results
        PipelineStage firstStage = response.results[0];

        // Verify required fields
        test:assertNotEquals(firstStage.id, "", "Stage ID should not be empty");
        test:assertNotEquals(firstStage.label, "", "Stage label should not be empty");
        test:assertTrue(firstStage.displayOrder >= 0, "Display order should be non-negative");

        // Verify timestamps
        test:assertNotEquals(firstStage.createdAt, "", "Created timestamp should not be empty");
        test:assertNotEquals(firstStage.updatedAt, "", "Updated timestamp should not be empty");

        // Verify standard fields
        test:assertEquals(firstStage.writePermissions, "CRM_PERMISSIONS_ENFORCEMENT",
                "Write permissions should match expected value");

        // Verify stages are ordered
        if response.results.length() > 1 {
            test:assertTrue(response.results[0].displayOrder <= response.results[1].displayOrder,
                    "Stages should be in order");
        }
    } else {
        return response;
    }
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testCreatePipelineStage() returns error? {
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;
    string objectType = "orders";
    Pipeline tempPipeline = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "Stage 1",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            }
        ],
        "label": uniqueLabel
    });

    string pipelineId = tempPipeline.id;

    // Prepare the request payload
    PipelineStageInput newStage = {
        metadata: {
            "ticketState": "CLOSED"
        },
        displayOrder: 2,
        label: "Done"
    };

    PipelineStage|error response =
        check hubspot->/[objectType]/[pipelineId]/stages.post(newStage);

    if response is PipelineStage {
        // Verify the stage was created with correct data
        test:assertNotEquals(response.id, "", "Stage ID should be generated");
        test:assertEquals(response.label, newStage.label, "Stage label should match input");
        test:assertEquals(response.displayOrder, newStage.displayOrder, "Display order should match input");

        // Verify metadata
        test:assertEquals(response.metadata["ticketState"], "CLOSED", "Ticket state should be CLOSED");

        // Verify timestamps and other auto-generated fields
        test:assertNotEquals(response.createdAt, "", "Created timestamp should be set");
        test:assertNotEquals(response.updatedAt, "", "Updated timestamp should be set");
        test:assertEquals(response.archived, false, "New stage should not be archived");
        //cleanup the created stage
        string stageId = response.id;
        _ = check hubspot->/[objectType]/[pipelineId]/stages/[stageId].delete();
        _ = check hubspot->/[objectType]/[pipelineId].delete();
    } else {
        return response;
    }
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testReplacePipelineStage() returns error? {
    //create a pipeline and a stage
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;
    string objectType = "orders";
    Pipeline tempPipeline = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "Stage 1",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            }
        ],
        "label": uniqueLabel
    });

    PipelineStageInput newStage = {
        metadata: {
            "ticketState": "CLOSED"
        },
        displayOrder: 2,
        label: "Done"
    };

    string pipelineId = tempPipeline.id;
    PipelineStage tempStage = check hubspot->/[objectType]/[pipelineId]/stages.post(newStage);

    string stageId = tempStage.id;

    // Prepare the replacement stage payload
    PipelineStageInput replacementStage = {
        metadata: {
            "ticketState": "CLOSED"
        },
        displayOrder: 1,
        label: "Done"
    };

    PipelineStage|error response =
        hubspot->/[objectType]/[pipelineId]/stages/[stageId].put(replacementStage);

    if response is PipelineStage {
        // Verify the stage was replaced with correct data
        test:assertEquals(response.id, stageId, "Stage ID should remain the same");
        test:assertEquals(response.label, replacementStage.label, "Stage label should match input");
        test:assertEquals(response.displayOrder, replacementStage.displayOrder, "Display order should match input");

        // Verify metadata
        test:assertEquals(response.metadata["ticketState"], "CLOSED", "Ticket state should be CLOSED");

        // Verify timestamps and other fields
        test:assertNotEquals(response.updatedAt, "", "Updated timestamp should be present");
        test:assertEquals(response.archived, false, "Stage should not be archived");

        // Verify the stage was actually updated by fetching it again
        PipelineStage|error verifyResponse =
            hubspot->/[objectType]/[pipelineId]/stages/[stageId].get();

        if verifyResponse is PipelineStage {
            test:assertEquals(verifyResponse.label, replacementStage.label,
                    "Verified stage label should match replacement");
            test:assertEquals(verifyResponse.displayOrder, replacementStage.displayOrder,
                    "Verified display order should match replacement");
        } else {
            return verifyResponse;
        }
        //cleanup the created pipeline
        _ = check hubspot->/[objectType]/[tempPipeline.id].delete();
    } else {
        return response;
    }
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPatchPipelineStage() returns error? {
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;
    string objectType = "orders";
    Pipeline tempPipeline = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "Stage 1",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            }
        ],
        "label": uniqueLabel
    });

    PipelineStageInput newStage = {
        metadata: {
            "ticketState": "CLOSED"
        },
        displayOrder: 2,
        label: "Done"
    };

    string pipelineId = tempPipeline.id;
    PipelineStage tempStage = check hubspot->/[objectType]/[pipelineId]/stages.post(newStage);

    string stageId = tempStage.id;

    PipelineStagePatchInput patch = {
        metadata: {
            "ticketState": "CLOSED"
        },
        displayOrder: 1,
        label: "Done"
    };

    PipelineStage response = check hubspot->/[objectType]/[pipelineId]/stages/[stageId].patch(patch);

    // Verify the stage was patched with correct data
    test:assertEquals(response.id, stageId, "Stage ID should remain the same");
    test:assertEquals(response.label, patch.label, "Stage label should match input");
    test:assertEquals(response.displayOrder, patch.displayOrder, "Display order should match input");

    // Verify metadata
    test:assertEquals(response.metadata["ticketState"], "CLOSED", "Ticket state should be CLOSED");

    // Verify timestamps and other fields
    test:assertNotEquals(response.updatedAt, "", "Updated timestamp should be present");
    test:assertEquals(response.archived, false, "Stage should not be archived");
    // Verify the stage was actually updated by fetching it again
    PipelineStage verifyResponse = check hubspot->/[objectType]/[pipelineId]/stages/[stageId].get();

    test:assertEquals(verifyResponse.label, patch.label,
            "Verified stage label should match patch");
    test:assertEquals(verifyResponse.displayOrder, patch.displayOrder,
            "Verified display order should match patch");
    //cleanup the created pipeline
    _ = check hubspot->/[objectType]/[tempPipeline.id].delete();
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testDeletePipelineStage() returns error? {
    //create a pipeline and a stage
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;
    string objectType = "orders";
    Pipeline tempPipeline = check hubspot->/[objectType].post(payload = {
        "displayOrder": 0,
        "stages": [
            {
                "label": "Stage 1",
                "metadata": {
                    "ticketState": "OPEN"
                },
                "displayOrder": 0
            }
        ],
        "label": uniqueLabel
    });
    string pipelineId = tempPipeline.id;

    // Prepare the request payload
    PipelineStageInput newStage = {
        metadata: {
            "ticketState": "CLOSED"
        },
        displayOrder: 2,
        label: "Done"
    };

    PipelineStage tempStage = check hubspot->/[objectType]/[pipelineId]/stages.post(newStage);

    // Delete the stage
    _ = check hubspot->/[objectType]/[pipelineId]/stages/[tempStage.id].delete();

    // Verify deletion by attempting to get the stage
    CollectionResponsePipelineStageNoPaging stages = check hubspot->/[objectType]/[pipelineId]/stages.get();
    boolean stageExists = false;
    foreach PipelineStage stage in stages.results {
        if stage.id == tempStage.id {
            stageExists = true;
            break;
        }
    }
    test:assertFalse(stageExists, "Stage should be deleted");

    //cleanup the created pipeline
    _ = check hubspot->/[objectType]/[pipelineId].delete();
}
