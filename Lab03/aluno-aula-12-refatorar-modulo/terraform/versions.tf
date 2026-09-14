# =============================================================================
# VEM PRONTO — não precisa mexer.
# Versao minima do Terraform e do provider AWS (travada).
#
# NOTA SOBRE O ESTADO: ele nasce LOCAL e vira REMOTO no Passo 7. A declaracao
# do backend "s3" mora em backend.tf, nao aqui - este arquivo so trava versoes.
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
