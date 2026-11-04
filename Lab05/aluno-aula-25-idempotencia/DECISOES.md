# DECISOES.md — Exercício 05 · grupo: 11 (`grupo11`)

Uma frase por decisão, com o número que medimos em 2026-11-04 (relatório `relatorios/corridas.json`,
`verifica.sh` e Athena; hoje = 2026-11-04, madrugada atrasada = 2026-11-01, reenvio = 2026-10-30).

## DECISÃO 01 — modo de escrita (`modo_escrita`)
Escolhemos `sobrescrever` (overwrite dinâmico de partição): cada execução troca só as pastas
`dt=` que escreve, então rodar o job duas vezes deixou a tabela em **518.400 → 518.400** linhas
(com `append` a segunda execução teria levado a 1.036.800). O que aceitamos perder: uma partição
reescrita fica só com o que a raw tem hoje — se o cru de um dia sumir, o próximo run apaga esse dia da trusted.

## DECISÃO 02 — a chave da linha (`chave_dedup`)
Escolhemos `corrida_id`, mantendo a primeira chegada: o reenvio de 5 dias atrás trouxe
**17.280** duplicatas (`duplicatas_removidas`), e a tabela ficou com **518.400 linhas para 518.400
corridas distintas** (sem chave seriam 535.680 linhas). O que aceitamos perder: se o produtor
reenviar uma corrida *corrigida*, fica a versão antiga, a da primeira chegada.

## DECISÃO 03 — janela de atraso (`janela_atraso_dias`)
Escolhemos **3** dias, o menor valor que ainda aceita a madrugada que chegou com 3 dias de atraso:
a madrugada dos últimos 7 dias (dt >= 2026-10-29) deu **11.137** corridas, com `fora_da_janela = 0` —
as **1.591** corridas da madrugada de 2026-11-01, que chegaram só em 2026-11-04, entraram. Cada execução
diária aceita, para cada dia do evento, **4** dias de chegada (o próprio dia + 3). O que aceitamos
perder: uma corrida que chegue com 4 dias ou mais de atraso fica fora da carga diária (entra em
`fora_da_janela`) e só volta pelo backfill (DECISÃO 04). Com janela 2, a madrugada atrasada cairia
e o 11.137 não fecharia.

## DECISÃO 04 — o backfill
Se uma corrida chegar com mais atraso do que a janela, o comando que conserta é
`./rodar-job.sh DIAS=<AAAA-MM-DD do evento>` — medimos com `./rodar-job.sh DIAS=2026-11-01`, o dia da
madrugada atrasada; ele reescreve **1** pasta (`dt=2026-11-01`, `dias_gravados_neste_run = 1`, 17.280 linhas gravadas) e a tabela
continua com **518.400** linhas. Não duplica porque o modo `sobrescrever` troca só aquela partição
inteira (em vez de acrescentar) e a chave `corrida_id` deixa uma linha por corrida mesmo juntando
todas as chegadas daquele dia.
