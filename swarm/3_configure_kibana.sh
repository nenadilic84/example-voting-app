#!/bin/bash

[ -z "$DEMO_NET" ] && DEMO_NET="voteapp"
[ -z "$ES_HOST" ] && ES_HOST="es"
[ -z "$KIBANA_HOST" ] && KIBANA_HOST="kibana"

# create container with curl app in voteapp network; use service
docker service ls --filter "name=curl" | grep "curl"
if [ $? -ne 0 ]; then
  docker service create --name curl --network voteapp --constraint "node.role == manager" alexeiled/alpine-plus:3.4 tail -f /dev/null
fi

curl_status=""
while [ "$curl_status" != "Running" ]; do
  curl_status=$(docker service ps -f "name=curl" curl | grep -w 'Running' | awk '{print $6}')
  sleep 2
done
CURL_CONTAINER=$(docker ps --filter "label=com.docker.swarm.service.name=curl" -q)
curl="docker exec -it ${CURL_CONTAINER} curl"

# Wait until ES is ready
$curl -XGET http://${ES_HOST}:9200/_cluster/health?pretty=true | grep "green\|yellow"
while [ $? -ne 0 ]; do
  sleep 2
  echo Waiting for Elasticsearch initialization
  $curl -XGET http://${ES_HOST}:9200/_cluster/health?pretty=true | grep "green\|yellow"
done

# Prepare default mapping for tugbot results
$curl -H "Content-Type: application/json" -XPOST -d '{
  "template":"tugbot_gaiadocker*",
    "mappings":{"_default_": {
      "dynamic_templates":
        [
          {"strings":{"match_mapping_type":"string","mapping":{"type":"string","index":"not_analyzed"}}}
        ]
      }
   }
}' http://${ES_HOST}:9200/_template/tugbot_template;

# Check that Kibana index is ready
$curl -XGET http://${ES_HOST}:9200/_cat/indices | grep kibana | grep "yellow\|green"
while [ $? -ne 0 ]; do
  sleep 2
  echo Waiting for Kibana index readiness
  $curl -XGET http://${ES_HOST}:9200/_cat/indices | grep "kibana" | grep "yellow\|green"
done

# Configure Kibana objects mapping
#curl -XPUT http://${ES_HOST}:9200/.kibana/_mapping/config -d '
#{"properties":{"buildNum":{"type":"long","index":"not_analyzed"},"defaultIndex":{"type":"string"}}}'

$curl -XPUT http://${ES_HOST}:9200/.kibana/_mapping/search -d '
  {
    "properties":{
      "columns":{"type":"string"},
      "description":{"type":"string"},
      "hits":{"type":"integer"},
      "kibanaSavedObjectMeta":{
        "properties":{"searchSourceJSON":{"type":"string"}}
      },
      "sort":{"type":"string"},
      "title":{"type":"string"},
      "version":{"type":"integer"}
    }
  }'

$curl -XPUT http://${ES_HOST}:9200/.kibana/_mapping/index-pattern -d '
{"properties":{"fieldFormatMap":{"type":"string"},"fields":{"type":"string"},"intervalName":{"type":"string"},"notExpandable":{"type":"boolean"},"timeFieldName":{"type":"string"},"title":{"type":"string"}}}'

$curl -XPUT http://${ES_HOST}:9200/.kibana/_mapping/dashboard -d '
{"properties":{"description":{"type":"string"},"hits":{"type":"integer"},"kibanaSavedObjectMeta":{"properties":{"searchSourceJSON":{"type":"string"}}},"optionsJSON":{"type":"string"},"panelsJSON":{"type":"string"},"timeFrom":{"type":"string"},"timeRestore":{"type":"boolean"},"timeTo":{"type":"string"},"title":{"type":"string"},"uiStateJSON":{"type":"string"},"version":{"type":"integer"}}}'

$curl -XPUT http://${ES_HOST}:9200/.kibana/_mapping/visualization -d '
{"properties":{"description":{"type":"string"},"kibanaSavedObjectMeta":{"properties":{"searchSourceJSON":{"type":"string"}}},"savedSearchId":{"type":"string"},"title":{"type":"string"},"uiStateJSON":{"type":"string"},"version":{"type":"integer"},"visState":{"type":"string"}}}'

# Create index pattern for tugbot_gaiadocker* in Kibana index
$curl -XPUT http://${ES_HOST}:9200/.kibana/index-pattern/tugbot_gaiadocker* -d '{"title" : "tugbot_gaiadocker*",  "timeFieldName": "TugbotData.StartedAt"}'

# Mark tugbot_gaiadocker* index pattern as default (NOTE Kibana version role is not clear - 4.5.1)
$curl -XPUT http://${ES_HOST}:9200/.kibana/config/4.5.1 -d '{"defaultIndex" : "tugbot_gaiadocker*"}'

# Add visualization and dashboard objects to Kibana
$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/dashboard/Tugbot?op_type=create -d '{"title":"Tugbot","hits":0,"description":"","panelsJSON":"[{\"col\":1,\"id\":\"Summary-Metrics\",\"panelIndex\":1,\"row\":1,\"size_x\":5,\"size_y\":2,\"type\":\"visualization\"},{\"col\":6,\"id\":\"Top-5-failing-tests\",\"panelIndex\":2,\"row\":1,\"size_x\":4,\"size_y\":2,\"type\":\"visualization\"},{\"col\":10,\"id\":\"Test-Case-Failures-per-Container-Execution-summary\",\"panelIndex\":3,\"row\":1,\"size_x\":3,\"size_y\":2,\"type\":\"visualization\"},{\"col\":2,\"id\":\"Test-Container-Duration-overtime\",\"panelIndex\":4,\"row\":3,\"size_x\":10,\"size_y\":3,\"type\":\"visualization\"},{\"col\":2,\"id\":\"Total-Test-Cases-Duration-overtime\",\"panelIndex\":5,\"row\":6,\"size_x\":10,\"size_y\":3,\"type\":\"visualization\"},{\"col\":2,\"id\":\"Top-5-slowest-tests-percentile-95\",\"panelIndex\":6,\"row\":12,\"size_x\":10,\"size_y\":3,\"type\":\"visualization\"},{\"col\":2,\"id\":\"Passed-vs-Failed-overtime\",\"panelIndex\":7,\"row\":15,\"size_x\":10,\"size_y\":3,\"type\":\"visualization\"},{\"col\":1,\"id\":\"Top-3-frequent-failures\",\"panelIndex\":8,\"row\":18,\"size_x\":5,\"size_y\":3,\"type\":\"visualization\"},{\"col\":6,\"id\":\"Top-5-Failing-Test-Cases-overtime\",\"panelIndex\":9,\"row\":18,\"size_x\":7,\"size_y\":3,\"type\":\"visualization\"},{\"col\":1,\"columns\":[\"Test.Name\",\"Test.Status\",\"Test.Time\",\"TugbotData.HostName\"],\"id\":\"Tugbot-Raw-Data\",\"panelIndex\":10,\"row\":21,\"size_x\":12,\"size_y\":5,\"sort\":[\"TugbotData.StartedAt\",\"desc\"],\"type\":\"search\"},{\"id\":\"Median-Test-Cases-Duration-overtime\",\"type\":\"visualization\",\"panelIndex\":11,\"size_x\":10,\"size_y\":3,\"col\":2,\"row\":9}]","optionsJSON":"{\"darkTheme\":true}","uiStateJSON":"{}","version":1,"timeRestore":false,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"filter\":[{\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}}}]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/search/Tugbot-Raw-Data -d '{"title":"Tugbot Raw Data","description":"","hits":0,"columns":["Test.Name","Test.Status","Test.Time","TugbotData.HostName"],"sort":["TugbotData.StartedAt","desc"],"version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}},\"filter\":[],\"highlight\":{\"pre_tags\":[\"@kibana-highlighted-field@\"],\"post_tags\":[\"@/kibana-highlighted-field@\"],\"fields\":{\"*\":{}},\"require_field_match\":false,\"fragment_size\":2147483647}}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Top-5-failing-tests?op_type=create -d '{"title":"Top 5 failing tests","visState":"{\"title\":\"Top 5 failing tests\",\"type\":\"pie\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"isDonut\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"Test.Name\",\"size\":5,\"orderAgg\":{\"id\":\"2-orderAgg\",\"type\":\"sum\",\"schema\":{\"group\":\"none\",\"name\":\"orderAgg\",\"title\":\"Order Agg\",\"aggFilter\":[\"!percentiles\",\"!median\",\"!std_dev\"],\"min\":0,\"max\":null,\"editor\":false,\"params\":[]},\"params\":{\"field\":\"Test.NumericStatus\"}},\"order\":\"desc\",\"orderBy\":\"custom\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"Test.Status\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Top-5-slowest-tests-percentile-95?op_type=create -d '{"title":"Top 5 slowest tests - percentile 95","visState":"{\"title\":\"Top 5 slowest tests - percentile 95\",\"type\":\"histogram\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"scale\":\"linear\",\"mode\":\"stacked\",\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"percentiles\",\"schema\":\"metric\",\"params\":{\"field\":\"Test.Time\",\"percents\":[95]}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"TugbotData.StartedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"Test.Name\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1.95\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Summary-Metrics?op_type=create -d '{"title":"Summary Metrics","visState":"{\"title\":\"Summary Metrics\",\"type\":\"metric\",\"params\":{\"handleNoResults\":true,\"fontSize\":60},\"aggs\":[{\"id\":\"1\",\"type\":\"cardinality\",\"schema\":\"metric\",\"params\":{\"field\":\"TugbotData.ImageName\",\"customLabel\":\"Test Images\"}},{\"id\":\"2\",\"type\":\"cardinality\",\"schema\":\"metric\",\"params\":{\"field\":\"TugbotData.StartedAt\",\"customLabel\":\"Test Container Invocations\"}},{\"id\":\"3\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Test Cases Runs\"}},{\"id\":\"4\",\"type\":\"sum\",\"schema\":\"metric\",\"params\":{\"field\":\"Test.NumericStatus\",\"customLabel\":\"Test Case Failures\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1"  http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Test-Case-Failures-per-Container-Execution-summary?op_type=create -d '{"title":"Test Case Failures per Container Execution summary","visState":"{\"title\":\"Test Case Failures per Container Execution summary\",\"type\":\"pie\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"isDonut\":false},\"aggs\":[{\"id\":\"1\",\"params\":{\"field\":\"TugbotData.StartedAt\"},\"schema\":\"metric\",\"type\":\"cardinality\"},{\"id\":\"2\",\"params\":{\"customLabel\":\"Failures per container execution\",\"field\":\"Test.TestSet.Failures\",\"order\":\"desc\",\"orderBy\":\"1\",\"size\":5},\"schema\":\"segment\",\"type\":\"terms\"}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Median-Test-Cases-Duration-overtime?op_type=create -d '{"title":"Median Test Cases Duration overtime","visState":"{\"title\":\"Median Test Cases Duration overtime\",\"type\":\"line\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"showCircles\":true,\"smoothLines\":false,\"interpolate\":\"linear\",\"scale\":\"linear\",\"drawLinesBetweenPoints\":true,\"radiusRatio\":9,\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"median\",\"schema\":\"metric\",\"params\":{\"field\":\"Test.Time\",\"percents\":[50],\"customLabel\":\"Median of Test Case Duration\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"TugbotData.StartedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"Test.Name\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1.50\",\"customLabel\":\"Test Case Name\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Top-5-Failing-Test-Cases-overtime?op_type=create -d '{"title":"Top 5 Failing Test Cases overtime","visState":"{\"title\":\"Top 5 Failing Test Cases overtime\",\"type\":\"histogram\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"scale\":\"linear\",\"mode\":\"stacked\",\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Failed Test Cases Count\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"TugbotData.StartedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"Test.Name\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\",\"customLabel\":\"by name\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"Test.Status:\\\"Failed\\\"\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Test-Container-Duration-overtime?op_type=create -d '{"title":"Test Container Duration overtime","visState":"{\"title\":\"Test Container Duration overtime\",\"type\":\"line\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"showCircles\":true,\"smoothLines\":false,\"interpolate\":\"linear\",\"scale\":\"linear\",\"drawLinesBetweenPoints\":true,\"radiusRatio\":9,\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"avg\",\"schema\":\"metric\",\"params\":{\"field\":\"Test.TestSet.Time\",\"customLabel\":\"Avg. test container execution duration\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"TugbotData.StartedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Top-3-frequent-failures?op_type=create -d '{"title":"Top 3 frequent failures","visState":"{\"title\":\"Top 3 frequent failures\",\"type\":\"pie\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"isDonut\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Failed test cases\"}},{\"id\":\"2\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"Test.Failure\",\"size\":3,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"Test.Status:\\\"Failed\\\"\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Passed-vs-Failed-overtime?op_type=create -d '{"title":"Passed vs Failed overtime","visState":"{\"title\":\"Passed vs Failed overtime\",\"type\":\"histogram\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"scale\":\"linear\",\"mode\":\"stacked\",\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Tests per container execution\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"TugbotData.StartedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"Test.Status\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'

$curl -XPOST -H "Content-Type: application/json;charset=UTF-8" -H "kbn-version: 4.5.1" http://${KIBANA_HOST}:5601/elasticsearch/.kibana/visualization/Total-Test-Cases-Duration-overtime?op_type=create -d '{"title":"Total Test Cases Duration overtime","visState":"{\"title\":\"Total Test Cases Duration overtime\",\"type\":\"line\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"showCircles\":true,\"smoothLines\":false,\"interpolate\":\"linear\",\"scale\":\"linear\",\"drawLinesBetweenPoints\":true,\"radiusRatio\":9,\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"sum\",\"schema\":\"metric\",\"params\":{\"field\":\"Test.Time\",\"customLabel\":\"Total test duration\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"TugbotData.StartedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}}],\"listeners\":{}}","uiStateJSON":"{}","description":"","version":1,"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"}}'
