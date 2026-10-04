# EDA — Grupo 11

Repositório do grupo 11 da disciplina **Engenharia de Dados** (CESAR School).

## Integrantes

- Thiago von Sohsten
- Felipe Sérgio
- Sérgio Gouveia
- Thiago Menezes
- Matheus Lucena
- Lui Manso
- Rodrigo Souza

## Laboratórios

| Pasta | Descrição |
| --- | --- |
| [`parte-1`](./parte-1) | Projeto · Parte 1 (AV1) — Data Lake em Terraform |
| [`Lab01`](./Lab01) | Exercício 01 — schema declarado no Glue (sem Crawler) |
| [`Lab02/aluno-aula-08-iac-do-zero`](./Lab02/aluno-aula-08-iac-do-zero) | Exercício 02 — Data Lake do zero em Terraform |
| [`Lab03/aluno-aula-12-modulo-backend`](./Lab03/aluno-aula-12-modulo-backend) | Exercício 03 — refatorar em módulo, com plan limpo |

### Parte 1 — AV1

Entrega oficial da primeira unidade, baseada no cenário de corridas urbanas.

- `parte-1/terraform/` — Terraform modular, backend remoto S3 e workspace `av1`
- `parte-1/dados/gerar-corridas.py` — gerador dos eventos JSON Lines
- `parte-1/consultas/pergunta-negocio.sql` — consulta Athena da pergunta de negócio
- `DECISOES.md` — decisões de engenharia da AV1
- `verificacao/verifica.sh` — aceite automático da AV1
- `apresentacao-parte-1-g11.md` e `apresentacao-parte-1-g11.pdf` — apresentação da AV1

Região obrigatória: `us-east-1` (N. Virginia).

### Lab01 — entrega

- `infra/template.yaml` — stack CloudFormation
- `infra/parameters.json` — parâmetros preenchidos
- `DECISOES.md` — justificativas das cinco decisões
- `evidencia-verifica.txt` — saída do `verifica.sh` e do `--pos-destroy`

### Lab02 — entrega

- `Lab02/aluno-aula-08-iac-do-zero/terraform/` — stack Terraform (schema declarado, partições, teto)
- `Lab02/aluno-aula-08-iac-do-zero/terraform/terraform.tfvars` — sufixo, dias e teto medido
- `Lab02/aluno-aula-08-iac-do-zero/DECISOES.md` — justificativas 01–05
- `Lab02/aluno-aula-08-iac-do-zero/evidencia-verifica.txt` — saída do `verifica.sh`

### Lab03 — entrega

Parte da stack do Exercício 02 e a refatora: **módulo + backend remoto + workspace**,
sem recriar recurso nenhum (`terraform plan` final = `No changes`).

- `Lab03/aluno-aula-12-modulo-backend/terraform/` — pacote canônico → `modules/lake/`
- `Lab03/aluno-aula-12-modulo-backend/terraform/backend.tf` — backend S3 + `workspace_key_prefix`
- `Lab03/aluno-aula-12-modulo-backend/DECISOES.md` — justificativas 01–05 (refatoração)
- `Lab03/aluno-aula-12-modulo-backend/evidencia-verifica.txt` — saída do `verifica.sh`
