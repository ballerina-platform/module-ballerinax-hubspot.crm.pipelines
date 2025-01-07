# Examples

The `ballerinax/hubspot.crm.pipelines` connector provides practical examples illustrating usage in various scenarios.

[//]: # (TODO: Add examples)
1. [Pipeline management](Pipeline-management/main.bal)
2. [Support pipeline](Support-pipeline/main.bal)

## Prerequisites

[//]: # (TODO: Add prerequisites)
1. Create a huspot application to authenticate the connecter as described in the [Setup guide](../ballerina/Package.md)
2. For each example, create a `Config.toml` file the related configuration. Here's an example of how your `Config.toml` file should look:

    ```toml
    clientId = "<Client Id>"
    clientSecret = "<Client Secret>"
    refreshToken = "<Refresh Token>"
    ```


## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
