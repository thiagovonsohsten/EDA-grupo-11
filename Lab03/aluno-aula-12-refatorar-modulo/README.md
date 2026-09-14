# Lab03 — Exercício 03 (Aula 12) · refatorar em módulo, com plan limpo

Único exercício do semestre que **não constrói nada novo**. A stack é a mesma do
Exercício 02; o que muda é o código: **módulo + backend remoto + workspace**, com
a regra dura de que o `terraform plan` final diga **`No changes`**.

> **Zero recurso recriado.** Se o plan quer mudar qualquer coisa, a refatoração
> não é refatoração — e o critério 1 (30%) cai junto.

## Estado desta pasta

Esta é a **stack plana do ponto de partida**: os sete recursos vivem na raiz de
`terraform/`, o estado é local e não existe módulo nenhum. É cópia fiel da stack
entregue no Exercício 02, com o que era exclusivo daquele exercício removido
(gerador de dados, partições do Glue, evidência e `verifica.sh` da Aula 08).

| Arquivo | Situação |
| --- | --- |
| `terraform/main.tf` | 7 `resource` na raiz — é o que vai virar `modules/lake/` |
| `terraform/variables.tf` | `regiao`, `turma`, `sufixo`, `teto_bytes` |
| `terraform/outputs.tf` | **contrato** — os cinco nomes que o `verifica.sh` lê |
| `terraform/terraform.tfvars` | `sufixo` e `teto_bytes` herdados do Ex. 02 |
| `terraform/backend.hcl.example` | modelo do Passo 7 (o `backend.hcl` é ignorado) |
| `verificacao/` | vazia — o `verifica.sh` da Aula 12 vem no pacote do professor |
| `DECISOES.md` | esqueleto das cinco decisões, a preencher |

## Os sete `state mv` (Passo 5)

⚠️ O enunciado lista **seis**, porque o pacote canônico do professor não traz o
`public_access_block` do bucket de resultados. Esta stack traz — então são
**sete**. Esquecer um deixa recurso órfão no plan e derruba o critério 1.

```bash
terraform state mv aws_s3_bucket.lake                        module.lake.aws_s3_bucket.lake
terraform state mv aws_s3_bucket_public_access_block.lake    module.lake.aws_s3_bucket_public_access_block.lake
terraform state mv aws_s3_bucket.results                     module.lake.aws_s3_bucket.results
terraform state mv aws_s3_bucket_public_access_block.results module.lake.aws_s3_bucket_public_access_block.results
terraform state mv aws_glue_catalog_database.db              module.lake.aws_glue_catalog_database.db
terraform state mv aws_glue_catalog_table.corridas           module.lake.aws_glue_catalog_table.corridas
terraform state mv aws_athena_workgroup.wg                   module.lake.aws_athena_workgroup.wg
```

O `apply` do Passo 2 vai dizer `7 added`, não `6 added`, e o plan do Passo 4 vai
dizer `7 to add, 0 to change, 7 to destroy`. É esperado.

> Se o pacote canônico do professor chegar, **use ele** como ponto de partida no
> lugar desta pasta, e aí a lista de seis do enunciado vale como está.

## Não renomeie nada

Os nomes continuam `eda-a08-*` (`eda-a08-lake-grupo11`, `eda-a08-results-grupo11`,
`eda-a08-wg-grupo11`, `eda_a08_lake_grupo11`). Trocar o `a08` por `a12` muda o
argumento `bucket`, que é *ForceNew*: o Terraform destrói e recria, e o plan
nunca fica limpo. O prefixo fica com o número da aula "errado" de propósito — o
exercício é código novo sobre a **mesma** infraestrutura.

## Ordem dos passos (a ordem é a lição)

1. `terraform init && terraform apply -var="sufixo=$SUFIXO"` → `7 added`, estado local
2. Extrair `modules/lake/` — mover os blocos **sem renomear**
3. `terraform plan` → vê os `7 to destroy`. **Não aplique.**
4. Os sete `terraform state mv`
5. `terraform plan` → `No changes.` ← metade do exercício, feita
6. `backend.hcl` + bloco `backend "s3"` + `terraform init -migrate-state -backend-config=backend.hcl`
7. `terraform plan` → `No changes.` de novo, agora com estado no S3
8. `terraform workspace new dev && terraform workspace select default`
9. `verifica.sh`, `DECISOES.md`, `terraform destroy`, `verifica.sh --pos-destroy`, PR

## Nunca comitar

`terraform.tfstate`, `.terraform/`, `backend.hcl` (tem o nome da conta).
Todos já estão nos `.gitignore` desta pasta.
