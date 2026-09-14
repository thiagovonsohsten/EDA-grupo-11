# =============================================================================
# A fronteira do modulo (DECISAO 01).
#
# Entra so o que o modulo precisa para NOMEAR e DIMENSIONAR os recursos.
# 'regiao' ficou de fora de proposito: e configuracao de PROVIDER, e provider
# quem configura e a raiz. Modulo que declara o proprio provider nao pode ser
# instanciado duas vezes na mesma stack - e e isso que a Parte 1 do projeto
# (AV1) vai precisar fazer.
# =============================================================================

variable "sufixo" {
  type        = string
  description = "Sufixo unico dos nomes dos recursos. So minusculas e numeros."

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.sufixo))
    error_message = "Use apenas letras minusculas e numeros (sem hifen, por causa do Glue)."
  }
}

variable "teto_bytes" {
  type        = number
  description = "BytesScannedCutoffPerQuery do workgroup do Athena."
}
