#!/bin/bash

[ -z "$DEMO_NET" ] && DEMO_NET="voteapp"

# Wait until ES is ready
curl -XGET http://localhost:9200/_cluster/health?pretty=true | grep "green\|yellow"
while [ $? -ne 0 ]; do
  sleep 2
  echo Waiting for Elasticsearch initialization
  curl -XGET http://localhost:9200/_cluster/health?pretty=true | grep "green\|yellow"
done

# Prepare default mapping for tugbot results
curl -H "Content-Type: application/json" -XPOST -d '{
  "template":"tugbot_gaiadocker*",
    "mappings":{"_default_": {
      "dynamic_templates":
        [
          {"strings":{"match_mapping_type":"string","mapping":{"type":"string","index":"not_analyzed"}}}
        ]
      }
   }
}' http://localhost:9200/_template/tugbot_template;

# Create index for Kibana (if not existing)
curl -i -XHEAD http://localhost:9200/.kibana | grep 200
if [ $? -ne 0 ]; then
  curl -XPUT http://localhost:9200/.kibana/ -d '{"settings" : { "index": {}}}'
fi

# Check that Kibana index is ready
curl -XGET http://localhost:9200/_cat/indices | grep kibana | grep "yellow\|green"
while [ $? -ne 0 ]; do
  sleep 2
  echo Waiting for Kibana index readiness
  curl -XGET http://localhost:9200/_cat/indices | grep "kibana" | grep "yellow\|green"
done

# Create index pattern for tugbot_gaiadocker* in Kibana index
curl -XPUT http://localhost:9200/.kibana/index-pattern/tugbot_gaiadocker* -d '{"title" : "tugbot_gaiadocker*",  "timeFieldName": "tugbotData.startedAt"}'

# Mark tugbot_gaiadocker* index pattern as default (NOTE Kibana version role is not clear - 4.5.1)
curl -XPUT http://localhost:9200/.kibana/config/4.5.1 -d '{"defaultIndex" : "tugbot_gaiadocker*"}'

# Add visualization and dashboard objects
curl -XPUT http://localhost:9200/.kibana/visualization/Top-5-slowest-tests-percentile-95 -d '
  {
      "title": "Top 5 slowest tests (percentile 95)",
      "visState": "{\"title\":\"Top 5 slowest tests (percentile 95)\",\"type\":\"histogram\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"scale\":\"linear\",\"mode\":\"stacked\",\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"percentiles\",\"schema\":\"metric\",\"params\":{\"field\":\"time\",\"percents\":[95]}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"tugbotData.startedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"name\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1.95\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
  }'
curl -XPUT http://localhost:9200/.kibana/visualization/Passed-vs-Failed-overtime -d '
{
      "title": "Passed vs Failed overtime",
      "visState": "{\"title\":\"New Visualization\",\"type\":\"histogram\",\"params\":{\"addLegend\":true,\"addTimeMarker\":false,\"addTooltip\":true,\"defaultYExtents\":false,\"mode\":\"stacked\",\"scale\":\"linear\",\"setYExtents\":false,\"shareYAxis\":true,\"times\":[],\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Tests per container execution\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"tugbotData.startedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"status\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\",\"customLabel\":\"\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}},\"filter\":[]}"
      }
  }'
curl -XPUT http://localhost:9200/.kibana/visualization/AverageTotalDuration -d '
 {
      "title": "AverageTotalDuration",
      "visState": "{\"title\":\"New Visualization\",\"type\":\"line\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"showCircles\":true,\"smoothLines\":false,\"interpolate\":\"linear\",\"scale\":\"linear\",\"drawLinesBetweenPoints\":true,\"radiusRatio\":9,\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"avg\",\"schema\":\"metric\",\"params\":{\"field\":\"testSuite.time\",\"customLabel\":\"Avg. test container execution duration\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"tugbotData.startedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
    }
  }'
curl -XPUT http://localhost:9200/.kibana/visualization/Test-case-failures-per-container-execution-summary -d '
 {
      "title": "Test case failures per container execution (summary)",
      "visState": "{\"title\":\"New Visualization\",\"type\":\"pie\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"isDonut\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"testSuite.failed\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\",\"customLabel\":\"Failures per container execution\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
  }'
curl -XPUT http://localhost:9200/.kibana/visualization/Top-5-failing-tests -d '
 {
      "title": "Top 5 failing tests",
      "visState": "{\"title\":\"New Visualization\",\"type\":\"pie\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"isDonut\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"name\",\"size\":5,\"orderAgg\":{\"id\":\"3-orderAgg\",\"type\":\"sum\",\"schema\":\"orderAgg\",\"params\":{\"field\":\"numericStatus\"}},\"order\":\"desc\",\"orderBy\":\"custom\"}},{\"id\":\"4\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"status\",\"size\":2,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
  }'
curl -XPUT http://localhost:9200/.kibana/visualization/SummaryMetrics -d '
 {
      "title": "SummaryMetrics",
      "visState": "{\"title\":\"SummaryMetrics\",\"type\":\"metric\",\"params\":{\"handleNoResults\":true,\"fontSize\":60},\"aggs\":[{\"id\":\"2\",\"type\":\"cardinality\",\"schema\":\"metric\",\"params\":{\"field\":\"tugbotData.ImageName\",\"customLabel\":\"Test Images\"}},{\"id\":\"3\",\"type\":\"cardinality\",\"schema\":\"metric\",\"params\":{\"field\":\"tugbotData.startedAt\",\"customLabel\":\"Test Container Invocations\"}},{\"id\":\"4\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Test Cases Runs\"}},{\"id\":\"5\",\"type\":\"sum\",\"schema\":\"metric\",\"params\":{\"field\":\"numericStatus\",\"customLabel\":\"Test Case Failures\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}},\"filter\":[]}"
      }
  }'
curl -XPUT http://localhost:9200/.kibana/visualization/Top-3-frequent-failures -d '
  {
      "title": "Top 3 frequent failures",
      "visState": "{\"title\":\"New Visualization\",\"type\":\"pie\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"isDonut\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Failed test cases\"}},{\"id\":\"2\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"failure\",\"size\":3,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"status:\\\"Failed\\\"\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
  }'
curl -XPUT http://localhost:9200/.kibana/visualization/Top-5-failing-test-cases-overtime -d '
{
      "title": "Top 5 failing test cases overtime",
      "visState": "{\"title\":\"New Visualization\",\"type\":\"histogram\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"scale\":\"linear\",\"mode\":\"stacked\",\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{\"customLabel\":\"Failed Test Cases Count\"}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"tugbotData.startedAt\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{},\"customLabel\":\"Time\"}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"name\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{}}",
      "uiStateJSON": "{}",
      "description": "",
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"tugbot_gaiadocker*\",\"query\":{\"query_string\":{\"query\":\"status:\\\"Failed\\\"\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
  }'
curl -XPUT http://localhost:9200/.kibana/dashboard/Tugbot-Demo -d '
  {
      "title": "Tugbot-Demo",
      "hits": 0,
      "description": "",
      "panelsJSON": "[{\"col\":1,\"id\":\"SummaryMetrics\",\"panelIndex\":1,\"row\":1,\"size_x\":5,\"size_y\":3,\"type\":\"visualization\"},{\"col\":6,\"id\":\"Top-5-failing-tests\",\"panelIndex\":2,\"row\":1,\"size_x\":4,\"size_y\":3,\"type\":\"visualization\"},{\"col\":2,\"id\":\"AverageTotalDuration\",\"panelIndex\":3,\"row\":4,\"size_x\":9,\"size_y\":3,\"type\":\"visualization\"},{\"col\":2,\"id\":\"Top-5-slowest-tests-percentile-95\",\"panelIndex\":4,\"row\":7,\"size_x\":9,\"size_y\":3,\"type\":\"visualization\"},{\"col\":10,\"id\":\"Test-case-failures-per-container-execution-summary\",\"panelIndex\":5,\"row\":1,\"size_x\":3,\"size_y\":3,\"type\":\"visualization\"},{\"col\":2,\"id\":\"Passed-vs-Failed-overtime\",\"panelIndex\":6,\"row\":10,\"size_x\":9,\"size_y\":3,\"type\":\"visualization\"},{\"col\":1,\"id\":\"Top-3-frequent-failures\",\"panelIndex\":7,\"row\":13,\"size_x\":3,\"size_y\":3,\"type\":\"visualization\"},{\"col\":4,\"id\":\"Top-5-failing-test-cases-overtime\",\"panelIndex\":8,\"row\":13,\"size_x\":9,\"size_y\":3,\"type\":\"visualization\"}]",
      "optionsJSON": "{\"darkTheme\":true}",
      "uiStateJSON": "{}",
      "version": 1,
      "timeRestore": false,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"filter\":[{\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}}}]}"
      }
  }'

