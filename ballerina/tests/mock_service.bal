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
