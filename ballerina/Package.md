## Overview

[HubSpot](https://www.hubspot.com) is an AI-powered customer relationship management (CRM) platform. 

The `ballerinax/hubspot.crm.pipelines` offers APIs to connect and interact with the [HubSpot Pipelines API](https://developers.hubspot.com/docs/guides/api/crm/pipelines) endpoints, specifically based on the [HubSpot REST API](https://developers.hubspot.com/docs/reference/api/overview).

## Setup guide

To use the `HubSpot CRM Pipelines` connector, you must have access to the HubSpot API through a HubSpot developer account and a HubSpot App under it. Therefore you need to register for a developer account at HubSpot if you don't have one already.

### Step 1: Create/Login to a HubSpot Developer Account

If you have an account already, go to the [HubSpot developer portal](https://app.hubspot.com/)

If you don't have a HubSpot Developer Account you can sign up to a free account [here](https://developers.hubspot.com/get-started)

### Step 2 (Optional): Create a Developer Test Account

Within app developer accounts, you can create a [developer test account](https://developers.hubspot.com/beta-docs/getting-started/account-types#developer-test-accounts) under your account to test apps and integrations without affecting any real HubSpot data.

> **Note:** These accounts are only for development and testing purposes. In production, you should not use Developer Test Accounts.

1. Go to the Test Account section from the left sidebar.

   ![Hubspot developer portal](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/test_acc_1.png)

2. Click Create developer test account.

   ![Hubspot developer testacc](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/test_acc_2.png)

3. In the dialogue box, give a name to your test account and click create.

   ![Hubspot developer testacc3](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/test_acc_3.png)

### Step 3: Create a HubSpot App under your account.

1. In your developer account, navigate to the "Apps" section. Click on "Create App"

   ![Hubspot app creation 1](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/create_app_1.png)

2. Provide the necessary details, including the app name and description.

### Step 4: Configure the Authentication Flow.

1. Move to the Auth Tab.

   ![Hubspot app creation 2](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/create_app_2.png)

2. In the Scopes section, click the "Add new scope" button to add the necessary scopes for your app.

   `crm.objects.orders.read`

   `crm.schemas.orders.write`
   
   ![scope](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/scope.png)
   
4. Add your Redirect URI in the relevant section. You can also use localhost addresses for local development purposes. Click Create App.

   ![Hubspot app creation final](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/create_app_final.png)

### Step 5: Get your Client ID and Client Secret

- Navigate to the Auth section of your app. Make sure to save the provided Client ID and Client Secret.

   ![Hubspot get credentials](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/main/docs/resources/get_credentials.png)

### Step 6: Setup Authentication Flow

Before proceeding with the Quickstart, ensure you have obtained the Access Token using the following steps:

1. Create an authorization URL using the following format:

   ```
   https://app.hubspot.com/oauth/authorize?client_id=<YOUR_CLIENT_ID>&scope=<YOUR_SCOPES>&redirect_uri=<YOUR_REDIRECT_URI>
   ```

   Replace the `<YOUR_CLIENT_ID>`, `<YOUR_REDIRECT_URI>` and `<YOUR_SCOPES>` with your specific value.

2. Paste it in the browser and select your developer test account to intall the app when prompted.

3. A code will be displayed in the browser. Copy the code.

4. Run the following curl command. Replace the `<YOUR_CLIENT_ID>`, `<YOUR_REDIRECT_URI`> and `<YOUR_CLIENT_SECRET>` with your specific value. Use the code you received in the above step 3 as the `<CODE>`.

   - Linux/macOS

     ```bash
     curl --request POST \
     --url https://api.hubapi.com/oauth/v1/token \
     --header 'content-type: application/x-www-form-urlencoded' \
     --data 'grant_type=authorization_code&code=<CODE>&redirect_uri=<YOUR_REDIRECT_URI>&client_id=<YOUR_CLIENT_ID>&client_secret=<YOUR_CLIENT_SECRET>'
     ```

   - Windows

     ```bash
     curl --request POST ^
     --url https://api.hubapi.com/oauth/v1/token ^
     --header 'content-type: application/x-www-form-urlencoded' ^
     --data 'grant_type=authorization_code&code=<CODE>&redirect_uri=<YOUR_REDIRECT_URI>&client_id=<YOUR_CLIENT_ID>&client_secret=<YOUR_CLIENT_SECRET>'
     ```

   This command will return the access token necessary for API calls.

   ```json
   {
     "token_type": "bearer",
     "refresh_token": "<Refresh Token>",
     "access_token": "<Access Token>",
     "expires_in": 1800
   }
   ```

5. Store the access token securely for use in your application.

## Quickstart


To use the HubSpot CRM Pipelines connector in your Ballerina application, follow these steps:

### Step 1: Import the module
```ballerina
import ballerinax/hubspot.crm.pipelines as hspipelines;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained credentials:
```toml
   clientId = "<Client Id>"
   clientSecret = "<Client Secret>"
   refreshToken = "<Refresh Token>"
```
2. Create a `hspipelines:ConnectionConfig` with the obtained access token and initialize the connector with it.

### Step 3: Use Connector Operations

Now, utilize the available connector operations.

## Examples

The `HubSpot CRM Pipelines` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/tree/9a23607e3c2bb8c638e2c41c47b3cdd04562a203/examples), covering the following use cases:

1. [Pipeline management](https://github.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/tree/9a23607e3c2bb8c638e2c41c47b3cdd04562a203/examples/Pipeline-management/main.bal)
2. [Support pipeline](https://github.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/tree/9a23607e3c2bb8c638e2c41c47b3cdd04562a203/examples/Support-pipeline/main.bal)
3. [Pipeline stage management](https://github.com/ballerina-platform/module-ballerinax-hubspot.crm.pipelines/tree/9a23607e3c2bb8c638e2c41c47b3cdd04562a203/examples/Pipeline-stage-management/main.bal)

