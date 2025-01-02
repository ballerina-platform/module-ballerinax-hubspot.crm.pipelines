import ballerina/io;
import ballerina/oauth2;
import ballerina/test;
import ballerina/time;

configurable boolean isLiveServer = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

configurable string serviceUrl = "https://api.hubapi.com";

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
    string uniqueLabel = string `Pipeline_${time:utcNow()[0]}`;
    Pipeline response = check hubspot->/crm/v3/pipelines/["orders"].post(payload = {
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
    test:assertTrue(response.label == uniqueLabel, "Pipeline label should match the provided label");
    test:assertTrue(response.displayOrder == 0, "Display order should be 0");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelines() returns error? {
    CollectionResponsePipelineNoPaging response = check hubspot->/crm/v3/pipelines/["orders"].get();

    // Verify the response contains pipelines
    // Verify response has results
    test:assertTrue(response.results.length() > 0, "Response should contain at least one pipeline");

    // Verify first pipeline has stages
    test:assertTrue(response.results[0].stages.length() > 0, "Pipeline should have at least one stage");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelineById() returns error? {
    string pipelineId = "668663365";
    Pipeline response = check hubspot->/crm/v3/pipelines/["orders"]/[pipelineId].get();

    // Verify pipeline ID matches requested ID
    test:assertTrue(response.id == pipelineId, "Pipeline ID should match the requested ID");

    // Verify pipeline has at least one stage
    test:assertTrue(response.stages.length() > 0, "Pipeline should have at least one stage");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPutPipeline() returns error? {
    string pipelineId = "668663365";

    Pipeline response = check hubspot->/crm/v3/pipelines/["orders"]/[pipelineId].put(payload = {
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

    // Verify pipeline was updated
    test:assertTrue(response.label == "Updated Pipeline", "Pipeline label should be updated");
    test:assertTrue(response.stages.length() == 1, "Pipeline should have one stage");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPatchPipeline() returns error? {
    string pipelineId = "668663365";

    Pipeline response = check hubspot->/crm/v3/pipelines/["orders"]/[pipelineId].patch(payload = {
        "label": "Updated Pipeline Name"
    });

    // Verify only the label was updated
    test:assertTrue(response.label == "Updated Pipeline Name", "Pipeline label should be updated");
}

// @test:Config {
//     groups: ["live_tests", "mock_tests"]
// }
// isolated function testDeletePipeline() returns error? {
//     string pipelineId = "668662952"; // Replace with the pipeline ID to delete

//     // Perform the DELETE request
//     http:Response|error result = hubspot->/crm/v3/pipelines/["orders"]/[pipelineId].delete();

//     // Assert the DELETE operation succeeded
//     // If the result is a response, check the status code
//     if result is http:Response {
//         test:assertTrue(result.statusCode == 204, "Pipeline deletion should return HTTP 204 No Content");
//     }
// }

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelineAuditLog() returns error? {
    string pipelineId = "667509129";

    CollectionResponsePublicAuditInfoNoPaging|error response =  hubspot->/crm/v3/pipelines/["orders"]/[pipelineId]/audit.get();

    if response is CollectionResponsePublicAuditInfoNoPaging {
        //test:assertTrue(response.results.length() > 0, "Pipeline audit should have at least one entry");
        io:println(response);
    } else {
        io:println(response);
        return response;
    }
}


@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testGetPipelineStageAuditLog() returns error? {
    string pipelineId = "667509129";
    string stageId = "979597671"; // Replace with actual stage ID
    string objectType = "orders";
    
    CollectionResponsePublicAuditInfoNoPaging|error response = 
        check hubspot->/crm/v3/pipelines/[objectType]/[pipelineId]/stages/[stageId]/audit.get();
    
    if response is CollectionResponsePublicAuditInfoNoPaging {
        test:assertTrue(response.results.length() > 0, "Pipeline stage audit should have at least one entry");
        
        // Additional validations for the first audit entry
        //test:assertNotEquals(response.results[0].identifier, "", "Identifier should not be empty");
        //test:assertNotEquals(response.results[0].timestamp, "", "Timestamp should not be empty");
        //test:assertTrue(response.results[0].portalId > 0, "Portal ID should be positive");
        
        io:println(response);
    } else {
        return response;
    }
}

// @test:Config {
//     groups: ["live_tests", "mock_tests"]
// }
// isolated function testGetPipelineStageById() returns error? {
//     string pipelineId = "668663365";
//     string stageId = "980764740";
//     string objectType = "orders";
    
//     PipelineStage|error response = 
//         check hubspot->/crm/v3/pipelines/[objectType]/[pipelineId]/stages/[stageId].get();
    
//     if response is PipelineStage {
//         // Verify basic properties
//         test:assertNotEquals(response.id, "", "Stage ID should not be empty");
//         test:assertNotEquals(response.label, "", "Stage label should not be empty");
//         test:assertTrue(response.displayOrder >= 0, "Display order should be non-negative");
        
//         // Verify timestamps are present
//         test:assertNotEquals(response.createdAt, "", "Created timestamp should not be empty");
//         test:assertNotEquals(response.updatedAt, "", "Updated timestamp should not be empty");
        
//         // Verify specific fields match expected values
//         test:assertEquals(response.archived, false, "Stage should not be archived by default");
//         test:assertEquals(response.writePermissions, "CRM_PERMISSIONS_ENFORCEMENT", 
//             "Write permissions should match expected value");
        
//         //io:println(response);
//     } else {
//         return response;
//     }
// }

// @test:Config {
//     groups: ["live_tests", "mock_tests"]
// }
// isolated function testGetAllPipelineStages() returns error? {
//     string pipelineId = "668663365";
//     string objectType = "orders";
    
//     CollectionResponsePipelineStageNoPaging|error response = 
//         check hubspot->/crm/v3/pipelines/[objectType]/[pipelineId]/stages.get();
    
//     if response is CollectionResponsePipelineStageNoPaging {
//         // Verify we have at least one stage
//         test:assertTrue(response.results.length() > 0, "Pipeline should have at least one stage");
        
//         // Test the first stage in the results
//         PipelineStage firstStage = response.results[0];
        
//         // Verify required fields
//         test:assertNotEquals(firstStage.id, "", "Stage ID should not be empty");
//         test:assertNotEquals(firstStage.label, "", "Stage label should not be empty");
//         test:assertTrue(firstStage.displayOrder >= 0, "Display order should be non-negative");
        
//         // Verify timestamps
//         test:assertNotEquals(firstStage.createdAt, "", "Created timestamp should not be empty");
//         test:assertNotEquals(firstStage.updatedAt, "", "Updated timestamp should not be empty");
        
//         // Verify standard fields
//         test:assertEquals(firstStage.writePermissions, "CRM_PERMISSIONS_ENFORCEMENT", 
//             "Write permissions should match expected value");
        
//         // Verify stages are ordered
//         if response.results.length() > 1 {
//             test:assertTrue(response.results[0].displayOrder <= response.results[1].displayOrder, 
//                 "Stages should be in order");
//         }
        
//         //io:println(response);
//     } else {
//         return response;
//     }
// }

// @test:Config {
//     groups: ["live_tests", "mock_tests"]
// }
// isolated function testCreatePipelineStage() returns error? {
//     string pipelineId = "668663365";
//     string objectType = "orders";
    
//     // Prepare the request payload
//     PipelineStageInput newStage = {
//         metadata: {
//             "ticketState": "CLOSED"
//         },
//         displayOrder: 2,
//         label: "Done"
//     };
    
//     PipelineStage|error response = 
//         check hubspot->/crm/v3/pipelines/[objectType]/[pipelineId]/stages.post(newStage);
    
//     if response is PipelineStage {
//         // Verify the stage was created with correct data
//         test:assertNotEquals(response.id, "", "Stage ID should be generated");
//         test:assertEquals(response.label, newStage.label, "Stage label should match input");
//         test:assertEquals(response.displayOrder, newStage.displayOrder, "Display order should match input");
        
//         // Verify metadata
//         test:assertEquals(response.metadata["ticketState"], "CLOSED", "Ticket state should be CLOSED");
        
//         // Verify timestamps and other auto-generated fields
//         test:assertNotEquals(response.createdAt, "", "Created timestamp should be set");
//         test:assertNotEquals(response.updatedAt, "", "Updated timestamp should be set");
//         test:assertEquals(response.archived, false, "New stage should not be archived");
//         test:assertEquals(response.writePermissions, "CRM_PERMISSIONS_ENFORCEMENT", 
//             "Write permissions should be set correctly");
        
//         //io:println(response);
//     } else {
//         return response;
//     }
// }

// @test:Config {
//     groups: ["live_tests", "mock_tests"]
// }
// isolated function testReplacePipelineStage() returns error? {
//     string pipelineId = "668663365";
//     string stageId = "980764740";
//     string objectType = "orders";
    
//     // Prepare the replacement stage payload
//     PipelineStageInput replacementStage = {
//         metadata: {
//             "ticketState": "CLOSED"
//         },
//         displayOrder: 1,
//         label: "Done"
//     };
    
//     PipelineStage|error response = 
//         hubspot->/crm/v3/pipelines/[objectType]/[pipelineId]/stages/[stageId].put(replacementStage);
    
//     if response is PipelineStage {
//         // Verify the stage was replaced with correct data
//         test:assertEquals(response.id, stageId, "Stage ID should remain the same");
//         test:assertEquals(response.label, replacementStage.label, "Stage label should match input");
//         test:assertEquals(response.displayOrder, replacementStage.displayOrder, "Display order should match input");
        
//         // Verify metadata
//         test:assertEquals(response.metadata["ticketState"], "CLOSED", "Ticket state should be CLOSED");
        
//         // Verify timestamps and other fields
//         test:assertNotEquals(response.createdAt, "", "Created timestamp should be present");
//         test:assertNotEquals(response.updatedAt, "", "Updated timestamp should be present");
//         test:assertEquals(response.archived, false, "Stage should not be archived");
//         test:assertEquals(response.writePermissions, "CRM_PERMISSIONS_ENFORCEMENT", 
//             "Write permissions should be correct");
        
//         // Verify the stage was actually updated by fetching it again
//         PipelineStage|error verifyResponse = 
//             hubspot->/crm/v3/pipelines/[objectType]/[pipelineId]/stages/[stageId].get();
            
//         if verifyResponse is PipelineStage {
//             test:assertEquals(verifyResponse.label, replacementStage.label, 
//                 "Verified stage label should match replacement");
//             test:assertEquals(verifyResponse.displayOrder, replacementStage.displayOrder, 
//                 "Verified display order should match replacement");
//             // test:assertEquals(verifyResponse.metadata["ticketState"], "CLOSED", 
//             //     "Verified ticket state should be CLOSED");
//         } else {
//             return verifyResponse;
//         }
        
//         //io:println(response);
//     } else {
//         return response;
//     }
// }