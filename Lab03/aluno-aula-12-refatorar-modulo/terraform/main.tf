# =============================================================================
# RAIZ — depois da refatoracao (Exercicio 03, Aula 12).
#
# Os sete "resource" que viviam aqui foram para ./modules/lake, sem renomear
# nada. A raiz virou o que uma raiz deve ser: composicao e nada mais.
#
# ATENCAO: mudar o codigo NAO move o estado. Antes de qualquer 'apply', rode os
# sete 'terraform state mv' (estao no README desta pasta) - senao o Terraform
# entende que os sete recursos antigos sumiram e sete novos apareceram, e
# destroi e recria tudo. O plan do Passo 4 mostra exatamente isso:
#
#   Plan: 7 to add, 0 to change, 7 to destroy.
#
# Depois dos state mv, o mesmo plan diz "No changes." - e esse e o exercicio.
# =============================================================================

module "lake" {
  source = "./modules/lake"

  sufixo     = var.sufixo
  teto_bytes = var.teto_bytes
}
