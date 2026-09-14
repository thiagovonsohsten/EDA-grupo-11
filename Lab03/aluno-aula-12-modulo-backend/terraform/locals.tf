# =============================================================================
# Codigo WORKSPACE-AWARE (DECISAO 03).
#
# No workspace 'default' o sufixo fica intacto - e por isso a stack migrada
# continua se chamando eda-a12-grupo11-* e o plan do Passo 8 fica limpo.
# Em qualquer outro workspace ele ganha o nome do ambiente, para que dev e
# prod nao disputem o mesmo nome de bucket (S3 e namespace global).
#
#   default  ->  grupo11        ->  eda-a12-grupo11-lake
#   dev      ->  grupo11dev     ->  eda-a12-grupo11dev-lake
#
# E o que permite 'workspace new dev' criar um ambiente inteiro sem tocar no
# que ja existe. Renomear a stack migrada para 'dev' faria o oposto: mudaria
# os nomes dos recursos que ja existem e recriaria tudo.
# =============================================================================

locals {
  sufixo_efetivo = terraform.workspace == "default" ? var.sufixo : "${var.sufixo}${terraform.workspace}"
}
