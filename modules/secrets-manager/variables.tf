# TODO maybe need more stuff idk

variable "secrets" {
  type = list(object({
    name        = string
    description = optional(string)
    keys        = list(string)
  }))
  default = []
}
