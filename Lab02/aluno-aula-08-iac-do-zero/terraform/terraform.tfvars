# Preenchido para a entrega do Exercício 02 (Aula 08).
# Datas = os 8 dias que o gerar-corridas.py produz (terminando em hoje).

sufixo = "grupo11"

# DECISÃO 05 — teto medido (20 MiB).
# 1 partição ≈ 3,4 MB; 8 partições ≈ 27 MB.
# 20 MiB barra a varredura completa e deixa passar consulta de 1 dia.
teto_bytes = 20971520

# DECISÃO 04 — registro os 8 dias gerados, incluindo hoje (2026-09-04).
dias_particao = [
  "2026-08-28",
  "2026-08-29",
  "2026-08-30",
  "2026-08-31",
  "2026-09-01",
  "2026-09-02",
  "2026-09-03",
  "2026-09-04"
]
