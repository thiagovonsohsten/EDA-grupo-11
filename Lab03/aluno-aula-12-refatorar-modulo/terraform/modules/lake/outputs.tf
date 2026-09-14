# =============================================================================
# A interface do modulo. A raiz nao alcanca recurso de dentro do modulo: so
# chega ao que for exportado aqui. E o que sustenta os cinco outputs de
# contrato la fora (criterio 4).
# =============================================================================

output "bucket_name" {
  description = "Nome do bucket de dados do lake."
  value       = aws_s3_bucket.lake.bucket
}

output "results_bucket_name" {
  description = "Nome do bucket de resultados do Athena."
  value       = aws_s3_bucket.results.bucket
}

output "database_name" {
  description = "Nome do database no Glue Data Catalog."
  value       = aws_glue_catalog_database.db.name
}

output "table_name" {
  description = "Nome da tabela de corridas."
  value       = aws_glue_catalog_table.corridas.name
}

output "workgroup_name" {
  description = "Nome do workgroup do Athena."
  value       = aws_athena_workgroup.wg.name
}
