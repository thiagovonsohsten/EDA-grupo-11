# DECISOES.md — Exercício 03 (Aula 12)

Cinco decisões sobre a **refatoração**, não sobre o lake. Em cada uma dizemos o
que escolhemos, o que aceitamos perder e por quê.

## DECISÃO 01 — a fronteira do módulo

**Entraram em `modules/lake/` os seis recursos; ficaram na raiz o provider, as
variáveis e os outputs.** O critério foi um só: o módulo recebe o que *cria
coisa*, a raiz guarda o que *configura a sessão*. Por isso `regiao` não virou
variável do módulo, embora fosse tentador — `regiao` alimenta o `provider "aws"`,
e módulo que declara o próprio provider não pode ser instanciado duas vezes na
mesma stack. Como a Parte 1 do projeto (AV1) vai justamente reusar este módulo,
travar isso agora custaria caro depois. A conta que aceitamos pagar: o módulo não
é autossuficiente — quem o usar precisa configurar o provider por fora. É o
contrato normal de um módulo reusável, e preferimos ele à conveniência de um
módulo que só funciona uma vez.

Também deixamos os outputs na raiz lendo de `module.lake.*` em vez de expor os
recursos diretamente. O módulo publica uma interface (`modules/lake/outputs.tf`);
quem está de fora não alcança `aws_s3_bucket.lake`. Isso é limitação de
propósito: se amanhã trocarmos o bucket por outro recurso, a raiz não percebe.

## DECISÃO 02 — mover o estado com `state mv`, não com `moved {}`

**Usamos os seis `terraform state mv`.** Os dois valem pela rubrica, e o `moved {}`
é objetivamente melhor para uma equipe: fica versionado, todo mundo que der
`apply` reexecuta a mesma movimentação, e ninguém precisa rodar comando à mão.
Escolhemos o `state mv` mesmo assim porque o exercício é *aprender o que o estado
é* — e `state mv` obriga a olhar o mapa endereço por endereço, seis vezes, e a
entender que `aws_s3_bucket.lake` e `module.lake.aws_s3_bucket.lake` são o mesmo
recurso com dois nomes. O `moved {}` faz isso acontecer sem que você veja.

O que aceitamos perder: a movimentação não ficou no código. Quem clonar o repo e
der `apply` com um estado antigo vai ter que repetir os seis comandos na mão —
eles estão no `README.md` por isso. Num repositório de time de verdade,
usaríamos `moved {}`.

## DECISÃO 03 — workspace, e a stack migrada fica no `default`

**Criamos o workspace `dev` e deixamos a stack migrada no `default`.** Não é
preguiça: renomear o workspace da stack existente mudaria `local.sufixo_efetivo`,
que mudaria o nome dos buckets, e `bucket` é *ForceNew* — o Terraform destruiria e
recriaria tudo, que é exatamente o que o critério 1 proíbe. Workspace novo serve
para ambiente novo, não para rebatizar ambiente velho.

O `locals.tf` deixa isso explícito: no `default` o sufixo é `grupo11` e nada muda;
em qualquer outro workspace ele vira `grupo11<workspace>`, para que `dev` e `prod`
não disputem nome de bucket — o namespace do S3 é global. Combinado com o
`workspace_key_prefix = "eda-a12"` no backend, cada ambiente ganha estado
separado no mesmo bucket.

Workspace **em vez de pasta por ambiente**, e sabemos o que isso custa: workspace
compartilha o mesmo código, então não dá para `dev` ter um recurso a mais que
`prod` sem encher o HCL de condicional. Para ambientes que divergem de verdade, a
pasta por ambiente é melhor. Aqui eles são idênticos e só mudam de nome — que é o
caso em que workspace ganha.

## DECISÃO 04 — o que o `plan` limpo prova, e o que não prova

**Prova exatamente uma coisa: que o código refatorado e o estado descrevem a mesma
infraestrutura.** Ou seja, que a modularização e a migração de backend foram
operações sobre o *mapa*, não sobre o território. É o que o exercício pede, e não
é pouco: um `plan` sujo aqui significaria seis recursos destruídos e recriados.

O que ele **não** prova:

- **Não prova que a AWS está como o estado diz.** `plan` compara *código* com
  *estado*, e o estado é a nossa crença sobre a AWS, não a AWS. Se alguém apagar
  um bucket pelo console, o `plan` continua limpo até rodarmos `terraform refresh`
  (ou `plan` com refresh, que o `-refresh=false` desliga). Drift existe e é
  invisível aqui.
- **Não prova que a infraestrutura funciona.** Os buckets podem existir, estarem
  corretos no estado, e o Athena ainda devolver zero linha.
- **Não prova que o módulo é bom.** Provaria o mesmo se tivéssemos jogado os seis
  recursos num módulo chamado `coisas`.

## DECISÃO 05 — a ordem: `state mv` antes de qualquer `apply`

**Se tivéssemos dado `apply` no Passo 4, o Terraform teria destruído os seis
recursos e criado seis novos** — porque para ele os endereços antigos sumiram e
seis endereços novos apareceram. O plan avisa isso em letras claras
(`6 to add, 0 to change, 6 to destroy`), e é fácil de ignorar quando se está
apertando `yes` no automático.

O estrago não seria simétrico. O S3 não deixa recriar um bucket com o mesmo nome
imediatamente — o nome fica reservado por um tempo depois do delete. Então o
`apply` destruiria os buckets e falharia no meio ao tentar recriá-los, deixando a
stack pela metade: parte destruída, parte não, e um estado que não descreve nem o
antes nem o depois. Sair desse buraco é reconstruir o estado na mão, recurso por
recurso, com `terraform import`.

É por isso que os três commits desta branch estão separados, e por isso o
`backend.tf` só aparece no último: cada estado do código é executável na ordem do
enunciado, e nenhum deles convida a aplicar cedo demais.
