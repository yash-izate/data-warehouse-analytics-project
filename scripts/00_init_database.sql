/*
    DataWarehouse database bootstrap
    --------------------------------
    Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

    Resets the local DataWarehouse database, then creates the bronze, silver,
    and gold schemas as separate namespaces for the warehouse layers.

    WARNING: Rerunning this script permanently deletes the existing database
    and all data in it. Run only when a reset is intended.
*/
USE [master];


GO
-- Switch to master before resetting the target database so it is not the
-- database currently in use by this connection.
IF DB_ID(N'DataWarehouse') IS NOT NULL
    BEGIN
        ALTER DATABASE [DataWarehouse]
            SET SINGLE_USER 
            WITH ROLLBACK IMMEDIATE;
        DROP DATABASE [DataWarehouse];
    END


GO
-- CREATE DATABASE must be in its own batch.
CREATE DATABASE [DataWarehouse];


GO
USE [DataWarehouse];


GO
-- Keep each warehouse layer in its own schema for clearer organization
-- and to support layer-specific permissions as the project grows.
CREATE SCHEMA [bronze];


GO
CREATE SCHEMA [silver];


GO
CREATE SCHEMA [gold];


GO