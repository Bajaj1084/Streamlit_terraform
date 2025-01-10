terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.17"
    }
  }

  backend "remote" {
    organization = "my-organization-name"
    role = "ACCOUNTADMIN"
    account ="axivxno-bwb79529"
    username = "sftraining"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}


resource "snowflake_role" "role" {
  name     = "TF_DEMO_SVC_ROLE"
}

resource "snowflake_database" "db" {
  name = "TF_DEMO"
}

resource "snowflake_schema" "schema" {
  database   = snowflake_database.db.name
  name       = "TF_DEMO_SCHEMA"
}

resource "snowflake_warehouse" "warehouse" {
  name           = "TF_DEMO"
  warehouse_size = "small"
  auto_suspend   = 60
}


resource "snowflake_grant_privileges_to_account_role" "database_grant" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_role.role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.db.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "warehouse_grant" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_role.role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse.name
  }
}

output "warehouse_name" {
  value = snowflake_warehouse.warehouse.name
}

output "database_name" {
  value = snowflake_database.db.name
}
