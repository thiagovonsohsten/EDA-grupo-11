# =============================================================================
# CONTRATO — não mexa nos nomes. O verifica.sh lê exatamente estes cinco outputs.
#
# Os nomes e os valores sao os mesmos de antes da refatoracao; so a origem
# mudou: agora vem de module.lake.*, porque a raiz nao enxerga recurso de
# dentro do modulo. Output nao existe no estado da AWS - trocar a origem nao
# recria nada, e por isso o plan continua limpo.
# =============================================================================

output "bucket_name" {
  description = "Nome do bucket de dados do lake."
  value       = module.lake.bucket_name
}

output "database_name" {
  description = "Nome do database no Glue Data Catalog."
  value       = module.lake.database_name
}

output "table_name" {
  description = "Nome da tabela de corridas."
  value       = module.lake.table_name
}

output "workgroup_name" {
  description = "Nome do workgroup do Athena."
  value       = module.lake.workgroup_name
}

output "teto_bytes" {
  description = "Teto de bytes por consulta aplicado."
  value       = var.teto_bytes
}

# Conveniencia (nao entra na nota): URL do editor do Athena.
output "console_url_athena" {
  description = "Abrir o editor do Athena no console."
  value       = "https://${var.regiao}.console.aws.amazon.com/athena/home?region=${var.regiao}#/query-editor"
}
