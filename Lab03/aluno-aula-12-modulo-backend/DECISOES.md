# DECISOES.md — Exercício 03 (Aula 12)

Cinco decisões sobre a **refatoração**, não sobre o lake. Uma frase por decisão,
dizendo o que escolhemos, o que aceitamos perder e por quê.

## DECISÃO 01 — a fronteira do módulo

<!-- O que entrou em modules/lake/, o que ficou na raiz, e por quê. -->

## DECISÃO 02 — mover o estado

<!-- Como movemos sem recriar: `terraform state mv` × bloco `moved {}`.
     O que aprendemos ao ver o plan do Passo 4 querendo destruir tudo. -->

## DECISÃO 03 — workspace × pasta

<!-- Por que workspace, e por que a stack migrada ficou no `default`
     (renomeá-la para `dev` mudaria os nomes dos recursos e recriaria tudo). -->

## DECISÃO 04 — o plan limpo

<!-- O que ele prova — e o que ele NÃO prova: drift continua existindo,
     o plan só compara o estado com o código. -->

## DECISÃO 05 — a ordem

<!-- O que quebraria se tivéssemos dado `apply` antes do `state mv`. -->
