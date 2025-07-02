# --- Load config based on stage (e.g., dev.json, prod.json) ---
locals {
  config_file = "${var.stage}.json"
  config      = jsondecode(file(local.config_file))
}
