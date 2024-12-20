## Overview

[//]: # "TODO: Add overview mentioning the purpose of the module, supported REST API versions, and other high-level details."

[HubSpot](https://www.hubspot.com/our-story) is an customer platform with all the software, integrations, and resources users need to connect thier marketing, sales, and customer service.

The `ballerinax/hubspot.crm.pipelines` package offers APIs to connect and interact with [HubSpot API for CRM Pipelines](https://developers.hubspot.com/docs/reference/api/crm/pipelines#pipelines) endpoints, specifically based on [HubSpot CRM Pipelines API v3 OpenAPI spec](https://github.com/HubSpot/HubSpot-public-api-spec-collection/blob/main/PublicApiSpecs/CRM/Pipelines/Rollouts/145896/v3/pipelines.json).

Using this API, users can create and manage deal and ticket pipelines. Pipelines enable users to track the status or progress of deals and tickets, such as closing deals and opening support tickets.

## Setup guide

[//]: # "TODO: Add detailed steps to obtain credentials and configure the module."

To use the `HubSpot CRM Pipelines` connector, you must have access to the HubSpot API through a HubSpot developer account and a HubSpot App under it. Therefore you need to register for a developer account at HubSpot if you don't have one already.

### Step 1: Create/Login to a HubSpot Developer Account

If you have an account already, go to the [HubSpot developer portal](https://app.hubspot.com/)

If you don't have a HubSpot Developer Account you can sign up to a free account [here](https://developers.hubspot.com/get-started)

### Step 2 (Optional): Create a [Developer Test Account](https://developers.hubspot.com/beta-docs/getting-started/account-types#developer-test-accounts) under your account

Within app developer accounts, you can create developer test accounts to test apps and integrations without affecting any real HubSpot data.

**_These accounts are only for development and testing purposes. In production you should not use Developer Test Accounts._**

1. Go to Test Account section from the left sidebar.

   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/test_acc_1.png" alt="Hubspot developer portal" style="width: 70%;">

2. Click Create developer test account.

   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/test_acc_2.png" alt="Hubspot developer testacc" style="width: 70%;">

3. In the dialogue box, give a name to your test account and click create.

   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/test_acc_3.png" alt="Hubspot developer testacc3" style="width: 70%;">

### Step 3: Create a HubSpot App under your account.

1. In your developer account, navigate to the "Apps" section. Click on "Create App"

   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/create_app_1.png" alt="Hubspot app creation 1 testacc3" style="width: 70%;">

2. Provide the necessary details, including the app name and description.

### Step 4: Configure the Authentication Flow.

1. Move to the Auth Tab.


   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/create_app_2.png" alt="Hubspot app creation 2 testacc3" style="width: 70%;">

2. In the Scopes section, add the nessessory scopes for your app using the "Add new scope" button.

   `crm.objects.orders.read`

   `crm.schemas.orders.write`
   
   <img src="https://github.com/user-attachments/assets/ffe2744b-2320-4e42-966a-93f35fa5c4b9" alt="scope" style="width: 70%;">

4. Add your Redirect URI in the relevant section. You can also use localhost addresses for local development purposes. Click Create App.

   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/create_app_final.png" alt="Hubspot app creation 1 testacc3" style="width: 70%;">

### Step 5: Get your Client ID and Client Secret

- Navigate to the Auth section of your app. Make sure to save the provided Client ID and Client Secret.

   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/get_credentials.png" alt="Hubspot app creation 1 testacc3" style="width: 70%;">

### Step 6: Setup Authentication Flow

Before proceeding with the Quickstart, ensure you have obtained the Access Token using the following steps:

1. Create an authorization URL using the following format:

   ```
   https://app.hubspot.com/oauth/authorize?client_id=<YOUR_CLIENT_ID>&scope=<YOUR_SCOPES>&redirect_uri=<YOUR_REDIRECT_URI>
   ```

   Replace the `<YOUR_CLIENT_ID>`, `<YOUR_REDIRECT_URI>` and `<YOUR_SCOPES>` with your specific value.

2. Paste it in the browser and select your developer test account to intall the app when prompted.

   <img src="https://github.com/3nethz/module-ballerinax-hubspot.crm.pipelines/blob/main/docs/resources/install_app.png" alt="Hubspot app creation 1 testacc3" style="width: 70%;">

3. A code will be displayed in the browser. Copy the code.

   ```
   Received code: na1-129d-860c-xxxx-xxxx-xxxxxxxxxxxx
   ```

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

[//]: # "TODO: Add a quickstart guide to demonstrate basic pipeline operations"

To use the HubSpot CRM Pipelines connector in your Ballerina application, follow these steps:

### Step 1: Import the module
```ballerina
import ballerinax/hubspot.crm.pipelines as hspipelines;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained credentials:
```toml
token = "<Access Token>"
```
2. Create a `hspipelines:ConnectionConfig` with the obtained access token and initialize the connector with it.

### Step 3: Use Connector Operations

Now, utilize the available connector operations.

## Examples

The `HubSpot CRM Pipelines` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-hubspot.crm.pipelines/tree/main/examples/), covering the following use cases:

[//]: # (TODO: Add examples)