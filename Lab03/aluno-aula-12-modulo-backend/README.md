# Lab03 — Exercício 03 (Aula 12) · refatorar em módulo, com plan limpo

Único exercício do semestre que **não constrói nada novo**. A stack é a mesma do
Exercício 02; o que muda é o código: **módulo + backend remoto + workspace**, com
a regra dura de que o `terraform plan` final diga **`No changes`**.

> **Zero recurso recriado.** Se o plan quer mudar qualquer coisa, a refatoração
> não é refatoração — e o critério 1 (30%) cai junto.

## O histórico do git É o exercício

Os três commits desta branch são os três estados do enunciado. Cada um roda:

| Commit | Estado do código | Onde entra no enunciado |
| --- | --- | --- |
| `Lab03: ponto de partida` | 7 `resource` na raiz, estado local, sem módulo | **Passo 2** — `apply` daqui |
| `Lab03: extrai modules/lake` | raiz é só `module "lake"`, estado ainda local | **Passos 3–6** — `plan`, `state mv`, `plan` limpo |
| `Lab03: backend remoto + workspace` | `backend.tf` com S3 + trava DynamoDB | **Passos 7–9** — `init -migrate-state` |

O estado da AWS **não** volta junto com o `git checkout` — é esse descompasso
que o exercício ensina a consertar com `terraform state mv`.

## Como executar

```bash
export AWS_REGION=us-east-1
export SUFIXO=grupo11
cd terraform
cp terraform.tfvars.example terraform.tfvars    # já vem preenchido nesta entrega
cp backend.hcl.example backend.hcl              # e troque SEU_LOGIN pelo sufixo
```

**Passo 2 — suba a stack plana.** Volte ao primeiro commit, onde o código ainda
é plano, e aplique:

```bash
git checkout <sha-do-ponto-de-partida> -- .
terraform init && terraform apply -var="sufixo=$SUFIXO"     # 7 added
```

**Passos 3–4 — traga o código refatorado e veja o problema:**

```bash
git checkout Lab03 -- .
terraform plan -var="sufixo=$SUFIXO"      # Plan: 7 to add, 0 to change, 7 to destroy
```

⚠️ **Não aplique.** O código fala de `module.lake.aws_s3_bucket.lake`, o estado
ainda guarda `aws_s3_bucket.lake` — para o Terraform um sumiu e outro nasceu.

**Passo 5 — mova o estado.** São **sete**, não seis: o enunciado lista 6 porque
o pacote canônico do professor não traz o `public_access_block` do bucket de
resultados. Esta stack traz. Esquecer um deixa órfão no plan e derruba o
critério 1.

```bash
terraform state mv aws_s3_bucket.lake                        module.lake.aws_s3_bucket.lake
terraform state mv aws_s3_bucket_public_access_block.lake    module.lake.aws_s3_bucket_public_access_block.lake
terraform state mv aws_s3_bucket.results                     module.lake.aws_s3_bucket.results
terraform state mv aws_s3_bucket_public_access_block.results module.lake.aws_s3_bucket_public_access_block.results
terraform state mv aws_glue_catalog_database.db              module.lake.aws_glue_catalog_database.db
terraform state mv aws_glue_catalog_table.corridas           module.lake.aws_glue_catalog_table.corridas
terraform state mv aws_athena_workgroup.wg                   module.lake.aws_athena_workgroup.wg
```

**Passo 6 — prove:** `terraform plan -var="sufixo=$SUFIXO"` → `No changes.`

**Passos 7–8 — backend remoto:**

```bash
terraform init -migrate-state -backend-config=backend.hcl    # responda yes
terraform plan -var="sufixo=$SUFIXO"                         # No changes. de novo
```

**Passo 9 — workspace:**

```bash
terraform workspace new dev
terraform workspace select default
```

**Passos 10–12:** `verifica.sh`, preencher o `DECISOES.md`, `terraform destroy`,
`verifica.sh --pos-destroy`, colar as saídas em `evidencia-verifica.txt`.

## Não renomeie nada

Os nomes continuam `eda-a08-*` (`eda-a08-lake-grupo11`, `eda-a08-results-grupo11`,
`eda-a08-wg-grupo11`, `eda_a08_lake_grupo11`). Trocar o `a08` por `a12` muda o
argumento `bucket`, que é *ForceNew*: destrói e recria, e o plan nunca fica
limpo. O prefixo fica com o número da aula "errado" de propósito — o exercício é
código novo sobre a **mesma** infraestrutura.

## A pasta

| Arquivo | Papel |
| --- | --- |
| `terraform/main.tf` | raiz — só o bloco `module "lake"` |
| `terraform/modules/lake/` | os 7 recursos, movidos sem renomear |
| `terraform/backend.tf` | backend S3 parcial + `workspace_key_prefix` |
| `terraform/backend.hcl.example` | modelo do `-backend-config` (o `.hcl` é ignorado) |
| `terraform/outputs.tf` | **contrato** — os cinco nomes que o `verifica.sh` lê |
| `verificacao/` | vazia — o `verifica.sh` da Aula 12 vem no pacote do professor |
| `DECISOES.md` | as cinco decisões da refatoração |

## Nunca comitar

`terraform.tfstate`, `.terraform/`, `backend.hcl` (tem o nome da conta).
Todos já estão nos `.gitignore`.
