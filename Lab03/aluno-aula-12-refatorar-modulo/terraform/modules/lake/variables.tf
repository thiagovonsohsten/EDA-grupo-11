# =============================================================================
# A fronteira do modulo (DECISAO 01).
#
# Entra so o que o modulo precisa para nomear e dimensionar os recursos.
# Fora ficam 'regiao' e 'turma': sao configuracao de PROVIDER (default_tags),
# e provider quem configura e a raiz - um modulo que declara o proprio provider
# nao pode ser reusado duas vezes na mesma stack.
# =============================================================================

variable "sufixo" {
  type        = string
  description = "Sufixo unico dos nomes dos recursos (ex.: seu login)."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.sufixo))
    error_message = "Use apenas letras minusculas, numeros e hifen."
  }
}

variable "teto_bytes" {
  type        = number
  description = "BytesScannedCutoffPerQuery do workgroup do Athena."

  validation {
    condition     = var.teto_bytes >= 10485760 && var.teto_bytes <= 117455962
    error_message = "O teto deve ficar entre 10485760 (10 MB) e 117455962."
  }
}
