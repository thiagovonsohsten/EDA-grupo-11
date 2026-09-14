# =============================================================================
# PONTO DE PARTIDA — Exercicio 03 (Aula 12).
# Preencha os valores em terraform.tfvars (copie de terraform.tfvars.example)
# ou passe via -var, como o enunciado faz: -var="sufixo=$SUFIXO".
#
# Na refatoracao, estas variaveis passam a ser repassadas ao modulo:
#   module "lake" { source = "./modules/lake"  sufixo = var.sufixo  teto_bytes = var.teto_bytes }
# =============================================================================

variable "regiao" {
  type        = string
  default     = "us-east-1"
  description = "Regiao da AWS. Nao mude."
}

variable "turma" {
  type        = string
  default     = "2026-2"
  description = "Identificador da turma; entra nas tags."
}

variable "sufixo" {
  type        = string
  description = "Sufixo unico dos nomes (ex.: seu login). So minusculas, numeros e hifen."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.sufixo))
    error_message = "Use apenas letras minusculas, numeros e hifen."
  }
}

# Teto de bytes por consulta (Athena), herdado do Exercicio 02.
# Aqui ele NAO e uma decisao: e um valor que precisa ficar PARADO. Mudar o teto
# altera o workgroup, e o plan do Passo 6 deixa de ser "No changes".
variable "teto_bytes" {
  type        = number
  description = "BytesScannedCutoffPerQuery do workgroup, herdado do Exercicio 02."

  validation {
    condition     = var.teto_bytes >= 10485760 && var.teto_bytes <= 117455962
    error_message = "O teto deve ficar entre 10485760 (10 MB) e 117455962."
  }
}
