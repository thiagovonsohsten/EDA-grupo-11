# DECISOES.md — Exercício 02 (Aula 08)

Cinco decisões. Em cada uma digo o que escolhi, o que aceito perder e por quê.

**DECISÃO 01 — `valor` é `double`.** Quero que o Athena some e filtre sem `cast` em toda consulta. O SerDe converte o número sozinho. Aceito que os ~1,5% de eventos com vírgula (`"17,82"`) virem `null`: prefiro perder a linha a obrigar todo analista a lembrar `cast(replace(valor,',','.') as double)`. `string` não perde nada, mas cobra esse cast até o fim da vida da tabela. `decimal(10,2)` é o tipo “certo” de dinheiro, mas tem o mesmo destino dos 1,5% — só muda o nome do problema. O `null` eu consigo medir (`WHERE valor IS NULL`); o `cast` esquecido, não.

**DECISÃO 02 — `data_corrida` e `fim` são `string`.** Olhei o gerador: os campos saem como `"03:14:00"`, só hora, sem data. O tipo `timestamp` do Athena espera `AAAA-MM-DD HH:MM:SS`. Se eu declarar `timestamp`, todas as linhas viram `null` em silêncio — pior que `string`. Fico com `string` e filtro madrugada no `WHERE` com `substr(data_corrida,1,2)`. A escolha veio do formato real do dado, não de preferência de design.

**DECISÃO 03 — `ignore.malformed.json = true`.** Uma linha de JSON quebrada não pode derrubar o painel inteiro. Aceito perder linhas malformadas em silêncio para a consulta sempre responder. Quem paga: quem confia no número sem olhar o volume. Por isso deixo explícito aqui que a contagem pode estar sub-reportada; medir o quanto se perde fica para Data Quality. Com `false`, uma linha ruim quebra a query e o custo vira investigação manual — preço alto demais para um lake de evento.

**DECISÃO 04 — registro 8 partições (os 8 dias que subi), incluindo hoje.** O critério pede ≥3; registro os 8 que o `gerar-corridas.py` produziu para a consulta larga ter o que varrer e o teto ter o que barrar. As pastas `dt=` que eu **não** registrar são invisíveis para o Athena (ele só lê partição declarada). Um dado que chegar amanhã, dia 9, **não aparece** até alguém rodar `aws glue create-partition` ou `MSCK REPAIR`. Declaro isso como dívida operacional conhecida, não como bug.

**DECISÃO 05 — teto de `20971520` (20 MiB).** Medi pelo gerador: ~3,4 MB por dia; 8 dias ≈ 27 MB. O teto em 20 MiB **deixa passar** consulta de um dia (~3,4 MB) e **mata** a varredura completa da tabela (~27 MB), que é o erro caro que quero impedir. Não usei o piso (10 MiB): já barraria consultas de ~3–4 dias, úteis demais para cortar. Não usei o topo do intervalo (117 MiB): nunca tocaria o freio. O número saiu da medição do volume que subi, não de um valor copiado do lab.
