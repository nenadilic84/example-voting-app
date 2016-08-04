#!/bin/bash

subnet=$(docker network inspect --format='{{(index (index .IPAM.Config) 0).Subnet}}' examplevotingapp_voteapp)

[ $http_proxy ] && tb_proxy=$http_proxy || tb_proxy=$HTTP_PROXY
tb_no_proxy=$(echo redis,db,voting-app,result,es),$(seq -s ',' -f $(echo $subnet | cut -d '.' -f1-3).%g 0 255)
[ $no_proxy ] && tb_no_proxy=$tb_no_proxy,$no_proxy,127.0.0.1,localhost || tb_no_proxy=$tb_no_proxy,$NO_PROXY,127.0.0.1,localhost

# echo tb_proxy=$tb_proxy
# echo tb_no_proxy=$tb_no_proxy
export tb_proxy=$tb_proxy
export tb_no_proxy=$tb_no_proxy,result

