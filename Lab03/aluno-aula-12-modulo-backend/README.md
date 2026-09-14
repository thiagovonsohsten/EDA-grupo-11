# Lab03 — Exercício 03 (Aula 12) · refatorar em módulo, com plan limpo

Único exercício do semestre que **não constrói nada novo**. A stack plana do
pacote canônico vira **módulo + backend remoto + workspace**, com a regra dura de
que o `terraform plan` final diga **`No changes`**.

> **Zero recurso recriado.** Um plan que quer mudar qualquer coisa é falha no
> critério 1 (30%, o maior peso). Refatorar que recria não é refatorar.

## Estado da entrega

| Critério | Peso | Situação |
| --- | --- | --- |
| 0 — módulo + `modules/` + `backend "s3"` + workspace | elimina | ✅ no código |
| 1 — `plan` limpo | 30% | ⏳ exige AWS |
| 2 — estado no backend remoto | 15% | ⏳ exige AWS (`backend.tf` pronto) |
| 3 — workspace nomeado ou código workspace-aware | 10% | ✅ `locals.tf` usa `terraform.workspace` |
| 4 — os cinco outputs de contrato | 10% | ✅ `outputs.tf` |
| 5 — `destroy` limpo | 15% | ⏳ exige AWS |
| 6 — `DECISOES.md` | 20% | ✅ as cinco escritas |

Falta só o que precisa de credencial: rodar a sequência e colar a saída do
`verifica.sh` em `evidencia-verifica.txt`.

## O histórico do git É o exercício

Os commits desta branch são os estados do enunciado, e **cada um roda**:

| Commit | Estado do código | Passos |
| --- | --- | --- |
| `troca a base pelo pacote canônico` | 6 `resource` na raiz, estado local | **2** — `apply` daqui |
| `corrige HCL inválido` | idem, mas compilando | pré-requisito do Passo 2 |
| `extrai modules/lake` | raiz é só `module "lake"`, estado ainda local | **3–6** — `plan`, `state mv`, `plan` limpo |
| `backend remoto + workspace` | `backend.tf` com S3 + trava DynamoDB | **7–9** — `init -migrate-state` |

O estado da AWS **não** volta junto com o `git checkout` — é esse descompasso que
o exercício ensina a consertar com `terraform state mv`.

## ⚠️ O pacote do professor não compila

`terraform init` para antes de tudo:

```
Error: Invalid single-argument block definition
  on main.tf line 50, in resource "aws_glue_catalog_table" "corridas":
  50:     columns { name = "corrida_id" type = "string" }
```

Bloco de uma linha em HCL aceita **um** argumento; as três linhas de `columns` têm
dois. Corrigido no commit `corrige HCL inválido`, expandindo para multilinha — o
schema declarado é idêntico, a mudança é só sintática.

## Como executar

```bash
export AWS_REGION=us-east-1
export SUFIXO=grupo11
cd terraform
cp backend.hcl.example backend.hcl     # e troque CONTA pelo bucket da disciplina
```

**Passo 2 — suba a stack plana**, a partir do commit onde o código ainda é plano:

```bash
git checkout <sha-do-corrige-HCL> -- .
terraform init && terraform apply -var="sufixo=$SUFIXO"     # 6 added
```

**Passos 3–4 — traga o código refatorado e veja o problema:**

```bash
git checkout Lab03-pacote-oficial -- .
terraform plan -var="sufixo=$SUFIXO"    # Plan: 6 to add, 0 to change, 6 to destroy
```

⚠️ **Não aplique.** O código fala de `module.lake.aws_s3_bucket.lake`, o estado
ainda guarda `aws_s3_bucket.lake` — para o Terraform um sumiu e outro nasceu.

**Passo 5 — mova o estado (seis comandos):**

```bash
terraform state mv aws_s3_bucket.lake                     module.lake.aws_s3_bucket.lake
terraform state mv aws_s3_bucket_public_access_block.lake module.lake.aws_s3_bucket_public_access_block.lake
terraform state mv aws_s3_bucket.results                  module.lake.aws_s3_bucket.results
terraform state mv aws_glue_catalog_database.db           module.lake.aws_glue_catalog_database.db
terraform state mv aws_glue_catalog_table.corridas        module.lake.aws_glue_catalog_table.corridas
terraform state mv aws_athena_workgroup.wg                module.lake.aws_athena_workgroup.wg
```

**Passo 6 — prove:** `terraform plan -var="sufixo=$SUFIXO"` → `No changes.`

**Passos 7–8 — backend remoto:**

```bash
terraform init -migrate-state -backend-config=backend.hcl   # responda yes
terraform plan -var="sufixo=$SUFIXO"                        # No changes. de novo
```

**Passo 9 — workspace:**

```bash
terraform workspace new dev
terraform workspace select default     # a stack migrada vive aqui (DECISÃO 03)
```

**Passos 10–12:**

```bash
cd ../verificacao && ./verifica.sh
cd ../terraform && terraform destroy -var="sufixo=$SUFIXO"
cd ../verificacao && ./verifica.sh --pos-destroy
```

Cole as duas saídas em `evidencia-verifica.txt` e no PR.

## Não renomeie nada

Os nomes são `eda-a12-grupo11-lake`, `-results`, `-wg` e o database
`eda_a12_grupo11`. O argumento `bucket` é *ForceNew*: mudar o nome destrói e
recria, e o plan nunca fica limpo. É também o que o `verifica.sh` procura no
critério 5 — ele monta os nomes a partir do `sufixo` do `terraform.tfvars`.

## A pasta

| Arquivo | Papel |
| --- | --- |
| `terraform/main.tf` | raiz — só o bloco `module "lake"` |
| `terraform/locals.tf` | `sufixo_efetivo`, workspace-aware (no-op no `default`) |
| `terraform/modules/lake/` | os 6 recursos, movidos sem renomear |
| `terraform/backend.tf` | backend S3 parcial + `workspace_key_prefix` |
| `terraform/backend.hcl.example` | modelo do `-backend-config` (o `.hcl` é ignorado) |
| `terraform/outputs.tf` | **contrato** — os cinco nomes que o `verifica.sh` lê |
| `verificacao/verifica.sh` | aceite oficial, do pacote do professor |
| `rubrica.md` | rubrica oficial, do pacote |
| `DECISOES.md` | as cinco decisões da refatoração |

## Nunca comitar

`terraform.tfstate`, `.terraform/`, `backend.hcl` (tem o nome da conta).
Todos já estão nos `.gitignore`.
