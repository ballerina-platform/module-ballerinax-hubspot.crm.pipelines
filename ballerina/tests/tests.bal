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
