_Author_:  Thineth Gamage \
_Created_: 2025/01/06 \
_Updated_:  2025/01/06 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from HubSpot CRM Pipelines. 
The OpenAPI specification is obtained from (TODO: Add source link).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.


1. Change the `url` property of the servers object
- **Original**: 
```https://api.hubspot.com```

- **Updated**: 
```https://api.hubapi.com/marketing/v3/pipelines```

- **Reason**:  This change of adding the common prefix `marketing/v3/pipelines` to the base url makes it easier to access endpoints using the client.

2.Update the API Paths
- **Original**: Paths included common prefix above in each endpoint. (eg: ```/marketing/v3/pipelines```)

- **Updated**: Common prefix is now removed from the endpoints as it is included in the base URL.
  - **Original**: ```/marketing/v3/pipelines```
  - **Updated**: ```/```

- **Reason**:  This change simplifies the API paths, making them shorter and more readable.

3. Updated Data Type for `rawObject` in `PublicAuditInfo`

**Original:**

```json
"rawObject": {
  "type": "object",
  "properties": { }
}
```

**Updated:**

```json
"rawObject": {
  "type": "string"
}
```

**Reason:**  
This change ensures that the `rawObject` field is treated as a string instead of an object, aligning with the actual structure of the payload being processed. This prevents issues with incorrect data type handling during serialization and deserialization.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.json --mode client -o ballerina
```
Note: The license year is hardcoded to 2024, change if necessary.
