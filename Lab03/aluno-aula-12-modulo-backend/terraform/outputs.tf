# =============================================================================
# CONTRATO — o verifica.sh le estes nomes. Preservados na refatoracao.
#
# Os nomes e os valores sao os mesmos de antes; so a ORIGEM mudou: agora vem de
# module.lake.*, porque a raiz nao enxerga recurso de dentro do modulo. Output
# nao existe no estado da AWS - trocar a origem nao recria nada, e por isso o
# plan continua limpo.
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

# Nao entra no contrato: diz de qual workspace este estado fala. Output nao
# existe na AWS, entao nao afeta o plan.
output "workspace" {
  description = "Workspace cujo estado descreve esta stack."
  value       = terraform.workspace
}
