# =============================================================================
# ESTADO REMOTO — Passo 7 (Exercicio 03, Aula 12).
#
# O bloco fica PARCIAL de proposito: bucket, key, region e dynamodb_table nao
# entram aqui. Eles carregam o nome da conta e vao em backend.hcl, que NAO e
# versionado (ver .gitignore). Modelo: backend.hcl.example.
#
#   cp backend.hcl.example backend.hcl        # e preencha a conta
#   terraform init -migrate-state -backend-config=backend.hcl
#
# O -migrate-state pergunta se copia o estado local para o S3: responda yes.
# Migrar backend nao toca em recurso nenhum - o plan do Passo 8 continua
# dizendo "No changes".
#
# workspace_key_prefix separa o estado por workspace dentro do bucket, em
# eda-a12/<workspace>/aula12/terraform.tfstate. O workspace 'default' e a
# excecao: grava direto na 'key', sem prefixo. E la que a stack migrada fica
# (DECISAO 03).
#
# A trava: o DynamoDB eda-tflock impede dois applies simultaneos no mesmo
# estado. Era o que faltava no Exercicio 02, com o tfstate no laptop.
# O backend e o COMPARTILHADO da disciplina - nao e deste exercicio e
# sobrevive ao destroy.
# =============================================================================

terraform {
  backend "s3" {
    workspace_key_prefix = "eda-a12"
  }
}
