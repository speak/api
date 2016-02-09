#!/bin/bash
echo "******CREATING DOCKER DATABASE******"
gosu postgres postgres --single <<- EOSQL
  CREATE DATABASE development;
  CREATE DATABASE test;
  GRANT ALL PRIVILEGES ON DATABASE development to postgres;
  GRANT ALL PRIVILEGES ON DATABASE test to postgres;
EOSQL
echo "******DOCKER DATABASE CREATED******"
