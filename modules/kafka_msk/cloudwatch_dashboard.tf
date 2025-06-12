
# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "msk" {
  dashboard_name = "msk-${var.name}"
  dashboard_body = jsonencode({
    widgets = concat([
      # Row 1: Cluster Health Overview
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "ActiveControllerCount", { stat = "Average", label = "Active Controllers" }],
            [".", "OfflinePartitionsCount", { stat = "Maximum", label = "Offline Partitions" }],
            [".", "UnderReplicatedPartitions", { stat = "Maximum", label = "Under-Replicated Partitions" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Cluster Health"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "CpuUser", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Average" }],
            [".", "CpuSystem", ".", ".", { stat = "Average" }],
            [".", "CpuIdle", ".", ".", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "CPU Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "MemoryUsed", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Average" }],
            [".", "MemoryFree", ".", ".", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Memory Usage"
          period  = 300
        }
      },
      # Row 2: Storage and Network
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "KafkaBrokerStorageUtilization", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Average", label = "Avg Storage %" }],
            ["...", { stat = "Maximum", label = "Max Storage %" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Storage Utilization %"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "Warning Threshold"
                value = 75
              },
              {
                label = "Critical Threshold"
                value = 85
                fill  = "above"
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 6
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "NetworkRxPackets", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Sum" }],
            [".", "NetworkTxPackets", ".", ".", { stat = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Network Packets"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 6
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "NetworkRxBytes", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Sum" }],
            [".", "NetworkTxBytes", ".", ".", { stat = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Network Throughput (Bytes)"
          period  = 300
        }
      },
      # Row 3: Request Metrics and Connections
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "RequestCount", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Sum" }],
            [".", "RequestErrorCount", ".", ".", { stat = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Request Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 12
        width  = 8
        height = 6
        properties = {
          metrics = [
            [{ expression = "(m2/m1)*100", label = "Error Rate %", id = "e1" }],
            ["AWS/Kafka", "RequestCount", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Sum", id = "m1", visible = false }],
            [".", "RequestErrorCount", ".", ".", { stat = "Sum", id = "m2", visible = false }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Request Error Rate %"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
          annotations = {
            horizontal = [{
              label = "Error Threshold"
              value = 5
              fill  = "above"
            }]
          }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 12
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "ConnectionCount", "Cluster Name", aws_msk_cluster.main.cluster_name, { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Connection Count"
          period  = 300
          annotations = {
            horizontal = [{
              label = "High Connection Warning"
              value = 1000
            }]
          }
        }
      },
      # Row 4: Per-Broker Metrics (if enhanced monitoring enabled)
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "BytesInPerSec", "Cluster Name", aws_msk_cluster.main.cluster_name, "Broker ID", "1", { stat = "Average" }],
            ["...", "2", { stat = "Average" }],
            ["...", "3", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Bytes In Per Broker"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Kafka", "BytesOutPerSec", "Cluster Name", aws_msk_cluster.main.cluster_name, "Broker ID", "1", { stat = "Average" }],
            ["...", "2", { stat = "Average" }],
            ["...", "3", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "Bytes Out Per Broker"
          period  = 300
        }
      }
      ], var.dev_mode ? [] : [
      # Row 5: Alarm Status Widget (only shown in non-dev mode)
      {
        type   = "alarm"
        x      = 0
        y      = 24
        width  = 24
        height = 3
        properties = {
          title = "MSK Cluster Alarms"
          alarms = [
            aws_cloudwatch_metric_alarm.cpu_high.arn,
            aws_cloudwatch_metric_alarm.disk_usage_critical.arn,
            aws_cloudwatch_metric_alarm.offline_partitions.arn,
            aws_cloudwatch_metric_alarm.under_replicated_partitions.arn,
            aws_cloudwatch_metric_alarm.active_controller.arn,
          ]
        }
      }
    ])
  })
}
