# Entrega do Exercicio 03 (Aula 12) — grupo 11.
# O verifica.sh le o sufixo daqui (grep '^\s*sufixo') para montar os nomes que
# procura no criterio 5. Sem hifen: o Glue nao aceita hifen em nome de database.

sufixo = "grupo11"

# teto_bytes tem default 20971520 no variables.tf. Nao sobrescrevemos: mudar o
# teto altera o workgroup, e o plan do fim deixaria de ser "No changes".
