#!/bin/sh 

docker ps --format "table {{.ID}}\t{{.Names}}\t{{.State}}\t{{.CreatedAt}}"