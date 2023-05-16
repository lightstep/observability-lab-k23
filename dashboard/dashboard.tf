resource "lightstep_dashboard" "demo_dashboard" {
  dashboard_name = "OpenTelemetry Demo App Dashboard"
  project_name   = var.LIGHTSTEP_PROJECT

  group {
    rank            = 0
    title           = ""
    visibility_type = "implicit"
  }
  group {
    rank            = 1
    title           = "Key Service Level Objectives"
    visibility_type = "explicit"

    chart {
      name   = "Frontend gRPC Client Latency"
      type   = "timeseries"
      rank   = 0
      x_pos  = 0
      y_pos  = 0
      width  = 16
      height = 8

      query {
        query_name   = "a"
        display      = "line"
        hidden       = false
        query_string = "spans latency | delta | filter (((service == \"frontend\") && (operation != \"dns.lookup\")) && (span.kind == \"client\")) | group_by [\"operation\"], sum | point percentile(value, 50.0), percentile(value, 95.0), percentile(value, 99.0), percentile(value, 99.9)"
      }
    }
    chart {
      name   = "Mean Basket Size/hour"
      type   = "timeseries"
      rank   = 1
      x_pos  = 16
      y_pos  = 0
      width  = 16
      height = 8

      query {
        query_name   = "a"
        display      = "line"
        hidden       = false
        query_string = "metric app.businessmetrics.products | delta 2m, 2m | group_by [], mean | reduce 1h, mean"
      }
    }
    chart {
      name   = "Fraud Detection Error Rate"
      type   = "timeseries"
      rank   = 2
      x_pos  = 32
      y_pos  = 0
      width  = 16
      height = 8

      query {
        query_name   = "a"
        display      = "line"
        hidden       = false
        query_string = "with\n  errors = spans count | delta | filter ((service == \"frauddetectionservice\") && (error == true)) | group_by [], sum;\n  total = spans count | delta | filter (service == \"frauddetectionservice\") | group_by [], sum;\njoin (errors / total), errors=0, total=0"
      }
    }
  }
  group {
    rank            = 2
    title           = "Key Service Health"
    visibility_type = "explicit"

    chart {
      name   = "Recommendation Service Server Latency"
      type   = "timeseries"
      rank   = 0
      x_pos  = 0
      y_pos  = 0
      width  = 16
      height = 8

      query {
        query_name   = "a"
        display      = "line"
        hidden       = false
        query_string = "spans latency | delta | filter ((service == \"recommendationservice\") && (span.kind == \"server\")) | group_by [], sum | point percentile(value, 50.0), percentile(value, 95.0), percentile(value, 99.0), percentile(value, 99.9)"
      }
    }
    chart {
      name   = "Ad Service Server Latency"
      type   = "timeseries"
      rank   = 1
      x_pos  = 16
      y_pos  = 0
      width  = 16
      height = 8

      query {
        query_name   = "a"
        display      = "line"
        hidden       = false
        query_string = "spans latency | delta 2m | filter ((service == \"adservice\") && (span.kind == \"server\")) | group_by [], sum | point percentile(value, 50.0), percentile(value, 95.0), percentile(value, 99.0), percentile(value, 99.9)"
      }
    }
    chart {
      name   = "Checkout Service Server Latency"
      type   = "timeseries"
      rank   = 2
      x_pos  = 32
      y_pos  = 0
      width  = 16
      height = 8

      query {
        query_name   = "a"
        display      = "line"
        hidden       = false
        query_string = "spans latency | delta | filter ((service == \"checkoutservice\") && (span.kind == \"server\")) | group_by [\"operation\"], sum | point percentile(value, 50.0), percentile(value, 95.0), percentile(value, 99.0), percentile(value, 99.9)"
      }
    }
    chart {
      name   = "Product Catalog Server Latency"
      type   = "timeseries"
      rank   = 3
      x_pos  = 0
      y_pos  = 8
      width  = 16
      height = 8

      query {
        query_name   = "a"
        display      = "line"
        hidden       = false
        query_string = "spans latency | delta 2m | filter ((service == \"productcatalogservice\") && (span.kind == \"server\")) | group_by [], sum | point percentile(value, 50.0), percentile(value, 95.0), percentile(value, 99.0), percentile(value, 99.9)"
      }
    }
    chart {
      name   = "Product Catalog Upstream Dependency Map"
      type   = "timeseries"
      rank   = 4
      x_pos  = 16
      y_pos  = 8
      width  = 32
      height = 8

      query {
        query_name   = "a"
        display      = "dependency_map"
        hidden       = false
        query_string = "spans_sample ((service == \"productcatalogservice\") && (span.kind == \"server\")) | assemble"
      }
    }
  }
}
