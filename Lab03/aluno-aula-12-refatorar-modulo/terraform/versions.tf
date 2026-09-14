# =============================================================================
# VEM PRONTO — não precisa mexer.
# Versao minima do Terraform e do provider AWS (travada).
#
# NOTA SOBRE O ESTADO: aqui ele comeca LOCAL, e assim deve ficar ate o Passo 6.
# O terraform.tfstate nasce nesta pasta, no seu laptop - a dor que o Exercicio
# 02 mandou sentir. A cura e o Passo 7 deste exercicio: backend "s3" com trava
# no DynamoDB, migrado com 'terraform init -migrate-state'.
#
# NAO adicione o bloco backend antes do plan limpo do Passo 6: o ponto do
# exercicio e provar que a modularizacao sozinha nao recriou nada, e so depois
# mexer no backend.
# =============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
