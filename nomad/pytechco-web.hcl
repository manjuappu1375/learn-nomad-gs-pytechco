job "pytechco-web" {
  type = "service"

  group "ptc-web" {
    count = 2

    scaling {
      enabled = true
      min     = 2
      max     = 5

      policy {
        cooldown            = "2m"
        evaluation_interval = "30s"

        check "cpu_usage" {
          source = "nomad-apm"
          query  = "avg_cpu"

          strategy "target-value" {
            target = 35  
          }
        }

        check "memory_usage" {
          source = "nomad-apm"
          query  = "avg_memory"

          strategy "target-value" {
            target = 35  
          }
        }

        target "nomad-target" {
          job   = "pytechco-web"
          group = "ptc-web"
        }
      }
    }

    network {
      port "web" {
        to = 5000
      }
    }

    service {
      name     = "ptc-web-svc"
      port     = "web"
      provider = "nomad"
    }

    task "ptc-web-task" {
      driver = "docker"

      resources {
        cpu    = 256
        memory = 256
      }

      template {
        data        = <<EOH
{{ range nomadService "redis-svc" }}
REDIS_HOST={{ .Address }}
REDIS_PORT={{ .Port }}
FLASK_HOST=0.0.0.0
REFRESH_INTERVAL=500
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }

      config {
        image = "manjuappu1375/pytechco-web:latest"
        ports = ["web"]
      }
    }
  }
}
