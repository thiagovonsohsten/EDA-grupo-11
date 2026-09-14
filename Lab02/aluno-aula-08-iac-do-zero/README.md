# Lab02 — Exercício 02 (Aula 08) · entrega

Data Lake mínimo **só em Terraform**, com schema declarado (sem Crawler),
≥3 partições e teto medido no Athena.

## O que já está pronto nesta pasta

| Arquivo | Função |
| --- | --- |
| `terraform/` | Stack completa (bucket, Glue, partições, workgroup) |
| `terraform/terraform.tfvars` | `sufixo`, 8 dias (inclui hoje) e teto `20971520` |
| `DECISOES.md` | Justificativas 01–05 |
| `dados/saida/` | JSON gerado (~3,4 MB × 8 dias) |
| `verificacao/verifica.sh` | Aceite automático |

## Pré-requisitos

1. [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) autenticada (`aws sts get-caller-identity`)
2. [Terraform ≥ 1.5](https://developer.hashicorp.com/terraform/install)
3. Git Bash ou WSL (para rodar `verifica.sh`)
4. `AWS_REGION=us-east-1`

## Se for rodar em outro dia

As datas em `terraform.tfvars` precisam ser os dias reais do gerador **e incluir hoje**.

```powershell
cd dados
python gerar-corridas.py --dias 8
# anote as datas dt=... e atualize dias_particao no terraform.tfvars
```

## Subir a stack

No PowerShell, a partir de `aluno-aula-08-iac-do-zero`:

```powershell
$env:AWS_REGION = "us-east-1"
cd terraform
terraform init
terraform apply -auto-approve

$bucket = terraform output -raw bucket_name
aws s3 cp ../dados/saida/ "s3://$bucket/raw/corridas/" --recursive
```

## Verificar (cole a saída no PR)

No Git Bash / WSL:

```bash
export AWS_REGION=us-east-1
cd verificacao
./verifica.sh
```

## Destroy limpo (critério 5)

```powershell
cd terraform
terraform destroy -auto-approve
```

```bash
cd verificacao
./verifica.sh --pos-destroy
```

Cole as duas saídas do `verifica.sh` em `evidencia-verifica.txt`.

## Decisões (resumo)

1. `valor` → `double`
2. tempos → `string`
3. `ignore.malformed.json` → `true`
4. 8 partições (incluindo hoje)
5. teto → 20 MiB (`20971520`)
