# Decisões do Exercício 01

## DECISÃO 01 — tipo de `valor`

Usei `double`: o JsonSerDe converte sozinho os 98,5% numéricos e o Athena agrega sem `cast`. Aceito perder os 1,5% com vírgula (`"17,82"`) — viram `null` — porque preferir `string` transfere o `cast` para toda consulta daqui em diante, e alguém vai esquecer; preferir `decimal(10,2)` não salva a vírgula e ainda aperta a precisão.

## DECISÃO 02 — tipo das colunas de tempo

Usei `string` em `data_corrida` e `fim`. O `SELECT fim FROM corridas WHERE dt = '2026-08-17' LIMIT 5` devolveu `2026-08-17T00:53:13Z`, `2026-08-17T01:01:51Z` e as outras três no mesmo formato, com `T` e `Z`. Com `timestamp` essas linhas viram `null` — o JsonSerDe não parseia esse texto. Aceito converter com `from_iso8601_timestamp` só na consulta que precisar de data.

## DECISÃO 03 — `ignore.malformed.json`

Deixei `true`: prefiro silêncio. Uma linha JSON quebrada vira `null` e a consulta responde. Quem paga sou eu (e o painel): perdemos a linha sem alarme. `false` faria um único evento ruim derrubar o `sum(valor)` inteiro com `HIVE_BAD_DATA`, e aí quem paga é todo analista até alguém achar a linha.

## DECISÃO 04 — quantas das 30 partições

Declarei só 3 (anteontem, ontem e hoje — o `deploy.sh` calcula na hora). As outras 27 existem no S3 e estão pagas, mas para o Athena não existem: `WHERE dt` nelas devolve zero linha. No dia 31 a pasta nova cai no bucket e ninguém a registra — sem um novo `deploy` (ou orquestração, Aula 21), o dia corrente some do catálogo.

## DECISÃO 05 — teto de bytes por consulta

O gerador (`--dias 30 --taxa 12 --seed 42`) mediu 3.921.495 bytes na partição de hoje e 11.765.273 nas três que o catálogo enxerga — as outras 27 não entram no scan. O teto é 11.000.000: deixa passar um dia e mata o `SELECT count(*)` sem `WHERE`. Não usei 10.485.760 porque é o mínimo da AWS, não o tamanho do meu dado; não usei 117.655.605 porque, com só 3 partições declaradas, esse número nunca seria varrido e o freio não tocaria.
