#!/usr/bin/env bash

set -oe pipefail -u

generate_vmoptions() {
  local file='/etc/graphouse/graphouse.vmoptions'

  cat > "$file" <<EOL
-Xms${GH_XMS:=256m}
-Xmx${GH_XMX:=4g}
-Xss${GH_XSS:=2m}
-XX:StringTableSize=10000000
-XX:+UseG1GC
-XX:MaxGCPauseMillis=1000
EOL
  if (( $? != 0 )); then
    echo "error generate file: $file"
    exit 1
  fi
  echo "[DEBUG] Config: ${file}"
  echo "-----"
  cat "$file"
  echo "-----"
}

generate_properties() {
  local file='/etc/graphouse/graphouse.properties'
  cat > "$file" <<EOL
graphouse.allow-cold-run=${GH__ALLOW_COLD_RUN:=false}

#Clickhouse
graphouse.clickhouse.host=${GH__CLICKHOUSE__HOST:=localhost}
graphouse.clickhouse.port=${GH__CLICKHOUSE__PORT:=8123}
graphouse.clickhouse.db=${GH__CLICKHOUSE__DB:=graphite}
graphouse.clickhouse.user=${GH__CLICKHOUSE__USER:=}
graphouse.clickhouse.password=${GH__CLICKHOUSE__PASSWORD:=}

graphouse.clickhouse.data-table=${GH__CLICKHOUSE__DATA_TABLE:=data}
graphouse.clickhouse.metric-tree-table=${GH__CLICKHOUSE__METRIC_TREE_TABLE:=metrics}

graphouse.clickhouse.socket-timeout-seconds=${GH__CLICKHOUSE__SOCKET_TIMEOUT_SECONDS:=600}
graphouse.clickhouse.query-timeout-seconds=${GH__CLICKHOUSE__QUERY_TIMEOUT_SECONDS:=120}

graphouse.clickhouse.retention-config=${GH__CLICKHOUSE__RETENTION_CONFIG:=}

#metric server and cacher
graphouse.cacher.port=${GH__CACHER__PORT:=2003}
graphouse.cacher.threads=${GH__CACHER__THREADS:=100}
graphouse.cacher.socket-timeout-millis=${GH__CACHER__SOCKET_TIMEOUT_MILLIS:=42000}

graphouse.cacher.cache-size=${GH__CACHER__CACHE_SIZE:=2000000}
graphouse.cacher.batch-size=${GH__CACHER__BATCH_SIZE:=1000000}
graphouse.cacher.writers-count=${GH__CACHER__WRITERS_COUNT:=2}
graphouse.cacher.flush-interval-seconds=${GH__CACHER__FLUSH_INTERVAL_SECONDS:=5}

#Http server (metric search, ping, metricData)
graphouse.http.port=${GH__HTTP__PORT:=2005}
graphouse.http.threads=${GH__HTTP__THREADS:=25}

#Mretric search and tree
graphouse.search.refresh-seconds=${GH__SEARCH__REFRESH_SECONDS:=60}
graphouse.tree.in-memory-levels=${GH__TREE__IN_MOMORY_LEVELS:=3}
graphouse.tree.dir-content.cache-time-minutes=${GH__TREE__DIR_CONTENT__CACHE_TIME_MINUTES:=60}
graphouse.tree.dir-content.cache-concurrency-level=${GH__TREE__DIR_CONTENT__CACHE_CONCURRENCY_LEVELS:=6}
graphouse.tree.dir-content.batcher.max-parallel-requests=${GH__TREE__DIR_CONTENT__BATCHER__MAX_PARALLEL_REQUEST:=3}
graphouse.tree.dir-content.batcher.max-batch-size=${GH__TREE__DIR_CONTENT__BATCHER__MAX_BATCH_SIZE:=2000}
graphouse.tree.dir-content.batcher.aggregation-time-millis=${GH__TREE__DIR_CONTENT__BATCHER__AGGREGATION_TIME_MILLIS:=50}


#Host metrics redirect
graphouse.host-metric-redirect.enabled=${GH__HOST_METRICS_REDIRECT__ENABLE:=false}
graphouse.host-metric-redirect.dir=${GH__HOST_METRICS_REDIRECT__DIR:=}
graphouse.host-metric-redirect.postfixes=${GH__HOST_METRICS_REDIRECT__POSTFIXES:=}

#Autohide
graphouse.autohide.enabled=${GH__AUTOHIDE__ENABLED:=false}
graphouse.autohide.run-delay-minutes=${GH__AUTOHIDE__RUN_DELAY_MINUTES:=30}
graphouse.autohide.max-values-count=${GH__AUTOHIDE__MAX_VALUES_COUNT:=200}
graphouse.autohide.missing-days=${GH__AUTOHIDE__MISSING_DAYS:=7}
graphouse.autohide.step=${GH__AUTOHIDE__STEP:=10000}
graphouse.autohide.retry.count=${GH__AUTOHIDE__RETRY__COUNT:=10}
graphouse.autohide.retry.wait_seconds=${GH__AUTOHIDE__RETRY__WAIT_SECONDS:=10}
graphouse.autohide.clickhouse.query-timeout-seconds=${GH__AUTOHIDE__CLICKHOUSE__QUERY_TIMEOUT_SECONDS:=600}

#Metric validation
graphouse.metric-validation.min-length=${GH__METRIC_VALIDATION__MIN_LENGTH:=10}
graphouse.metric-validation.max-length=${GH__METRIC_VALIDATION__MAX_LENGTH:=200}
graphouse.metric-validation.min-levels=${GH__METRIC_VALIDATION__MIN_LEVELS:=2}
graphouse.metric-validation.max-levels=${GH__METRIC_VALIDATION__MAX_LEVELS:=15}
graphouse.metric-validation.regexp=${GH__METRIC_VALIDATION__REGEXP:=[-_0-9a-zA-Z\\\\.]*$}
EOL
  if (( $? != 0 )); then
    echo "error generate file: $file"
    exit 1
  fi
  echo "[DEBUG] Config: ${file}"
  echo "-----"
  cat "$file"
  echo "-----"
}

generate_vmoptions
generate_properties

echo "STARTING"

/opt/graphouse/bin/graphouse