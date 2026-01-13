variable "project_name" {
  description = "專案名稱，用於資源命名前綴"
  type        = string
  default     = "vue-todo-app"
}

variable "aws_region" {
  description = "AWS 區域"
  type        = string
  default     = "ap-northeast-1"
}

variable "allowed_countries" {
  description = "允許存取的國家代碼清單（ISO 3166-1 alpha-2）"
  type        = list(string)
  default     = ["TW", "JP"]
}

variable "environment" {
  description = "部署環境"
  type        = string
  default     = "production"
}
