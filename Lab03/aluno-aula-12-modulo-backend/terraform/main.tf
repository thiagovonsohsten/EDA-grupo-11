# =============================================================================
# RAIZ — depois da refatoracao (Exercicio 03, Aula 12).
#
# Os seis "resource" que viviam aqui foram para ./modules/lake, sem renomear
# nada. A raiz virou o que uma raiz deve ser: composicao, e nada mais.
#
# ATENCAO: mudar o CODIGO nao move o ESTADO. Antes de qualquer 'apply', rode os
# seis 'terraform state mv' (a lista esta no README desta pasta). Sem eles o
# Terraform entende que os seis recursos antigos sumiram e seis novos
# apareceram, e destroi e recria tudo:
#
#   Plan: 6 to add, 0 to change, 6 to destroy.
#
# Depois dos state mv o mesmo plan diz "No changes." - e esse e o exercicio.
# =============================================================================

module "lake" {
  source = "./modules/lake"

  # local.sufixo_efetivo == var.sufixo no workspace default (ver locals.tf)
  sufixo     = local.sufixo_efetivo
  teto_bytes = var.teto_bytes
}
