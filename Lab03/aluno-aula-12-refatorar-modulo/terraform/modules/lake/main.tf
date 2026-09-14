# =============================================================================
# modules/lake — os SETE recursos, movidos da raiz SEM UMA LINHA DE MUDANCA.
#
# Refatorar e reorganizar, nao rebatizar: cada "resource" mantem o mesmo tipo e
# o mesmo nome local que tinha na raiz. E isso que faz o 'terraform state mv'
# casar endereco por endereco e o plan final dizer "No changes".
#
#   aws_s3_bucket.lake  ->  module.lake.aws_s3_bucket.lake
#
# Os nomes AWS continuam eda-a08-* de proposito: 'bucket' e ForceNew, trocar
# para a12 destruiria e recriaria os buckets - exatamente o que o criterio 1
# proibe. O numero da aula fica "errado"; a infraestrutura fica intacta.
# =============================================================================

# ---- Bucket de dados do lake --------------------------------------------------
resource "aws_s3_bucket" "lake" {
  bucket        = "eda-a08-lake-${var.sufixo}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "lake" {
  bucket                  = aws_s3_bucket.lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---- Bucket de resultados do Athena ------------------------------------------
resource "aws_s3_bucket" "results" {
  bucket        = "eda-a08-results-${var.sufixo}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "results" {
  bucket                  = aws_s3_bucket.results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---- Catalogo: database ------------------------------------------------------
resource "aws_glue_catalog_database" "db" {
  name = "eda_a08_lake_${var.sufixo}"
}

# ---- Catalogo: tabela com SCHEMA DECLARADO -----------------------------------
# Sem Crawler: as colunas sao escritas a mao. Tres campos exigem decisao.
resource "aws_glue_catalog_table" "corridas" {
  name          = "corridas"
  database_name = aws_glue_catalog_database.db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "json"
    # DECISAO 03 — barulho ou silencio.
    # "true" ignora linhas de JSON malformado; "false" quebra a consulta.
    # Justifique quem paga o que voce escolheu. (default abaixo: ajuste se decidir outro)
    "ignore.malformed.json" = "true" # DECISAO 03 <- true ou false
  }

  partition_keys {
    name = "dt"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.lake.bucket}/raw/corridas/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "corrida_id"
      type = "string"
    }
    columns {
      name = "motorista_id"
      type = "string"
    }
    columns {
      name = "passageiro_id"
      type = "string"
    }
    columns {
      name = "bairro"
      type = "string"
    }

    # DECISAO 02 — colunas de tempo.
    # "string" ou "timestamp"? Decida pelo que o SELECT devolveu quando voce testou,
    # nao pelo que voce supos. (default abaixo: string)
    columns {
      name = "data_corrida"
      type = "string"
    } # DECISAO 02
    columns {
      name = "fim"
      type = "string"
    } # DECISAO 02

    columns {
      name = "distancia_km"
      type = "double"
    }
    columns {
      name = "duracao_min"
      type = "int"
    }

    # DECISAO 01 — o tipo de "valor".
    # double converte sozinho, mas os 1,5% de eventos com "17,82" (virgula) viram null.
    # string nao perde nada e cobra um cast de toda consulta futura.
    # decimal(10,2) e o tipo do dinheiro. Diga o que voce ACEITA PERDER. (default: double)
    columns {
      name = "valor"
      type = "double"
    } # DECISAO 01 <- double, string ou decimal(10,2)
  }
}

# ---- Consulta: workgroup do Athena com o teto de bytes -----------------------
# DECISAO 05 — o teto (var.teto_bytes, no tfvars), que voce MEDIU.
resource "aws_athena_workgroup" "wg" {
  name          = "eda-a08-wg-${var.sufixo}"
  state         = "ENABLED"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false
    bytes_scanned_cutoff_per_query     = var.teto_bytes

    result_configuration {
      output_location = "s3://${aws_s3_bucket.results.bucket}/athena-results/"
    }
  }
}
