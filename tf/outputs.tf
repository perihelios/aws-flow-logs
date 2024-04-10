output "tgw-flow-log-fields" {
  value = join(" ", [
    for column in var.tgw-columns : "$${${replace(column, "_", "-")}}"
    if !local.tgw-column-definitions[column].synthetic
  ])
}

output "vpc-flow-log-fields" {
  value = join(" ", [
    for column in var.vpc-columns : "$${${replace(column, "_", "-")}}"
    if !local.vpc-column-definitions[column].synthetic
  ])
}
