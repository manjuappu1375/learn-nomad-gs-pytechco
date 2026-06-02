job "autoscaler" {
  type = "service"

  group "autoscaler" {
    count = 1

    task "autoscaler" {
      driver = "docker"

      config {
        image   = "hashicorp/nomad-autoscaler:0.5"
        command = "nomad-autoscaler"
        args    = ["agent", "-config", "${NOMAD_TASK_DIR}/config.hcl"]
      }

      template {
        data = <<EOF
nomad {
  address = "http://{{ env "attr.unique.network.ip-address" }}:4646"
}

apm "nomad-apm" {
  driver = "nomad-apm"
  config = {
    address = "http://{{ env "attr.unique.network.ip-address" }}:4646"
  }
}

strategy "target-value" {
  driver = "target-value"
}
EOF
        destination = "${NOMAD_TASK_DIR}/config.hcl"
      }

      resources {
        cpu    = 50
        memory = 128
      }
    }
  }
}
