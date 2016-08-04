#!/bin/bash

subnet=$(docker network inspect --format='{{(index (index .IPAM.Config) 0).Subnet}}' examplevotingapp_voteapp)
[ $http_proxy ] && tb_proxy=$http_proxy || tb_proxy=$HTTP_PROXY
[ $no_proxy ] && tb_no_proxy=$no_proxy,result,es,$(seq -s ',' -f $(echo $subnet | cut -d '.' -f1-3).%g 0 255) || tb_no_proxy=$(seq -s ',' -f $(echo $subnet | cut -d '.' -f1-3).%g 0 255)

# echo tb_proxy=$tb_proxy
# echo tb_no_proxy=$tb_no_proxy
export tb_proxy=$tb_proxy
export tb_no_proxy=$tb_no_proxy,result

