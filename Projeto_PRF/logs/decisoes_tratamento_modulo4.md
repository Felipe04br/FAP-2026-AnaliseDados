
# Decisões de tratamento — Módulo 4
Data: 2026-09-22 18:50

## Principais decisões
- Colunas: minúsculas, sem acentos, underline.
- Numéricas: pd.to_numeric(errors='coerce').
- Datas: pd.to_datetime(errors='coerce').
- Categorias ausentes: IGNORADO.
- Alvo: acidente_fatal=1 quando mortos>=1.
- Base modelável exclui variáveis
 derivadas do desfecho.

## Arquivos gerados
- C:\Users\Aluno\Documents\Felipe\FAP-2026-AnaliseDados\Projeto_PRF\dados_tratados\base_analitica_prf_2025.csv
- C:\Users\Aluno\Documents\Felipe\FAP-2026-AnaliseDados\Projeto_PRF\dados_tratados\base_modelavel_prf_2025.csv
- C:\Users\Aluno\Documents\Felipe\FAP-2026-AnaliseDados\Projeto_PRF\dados_tratados\dicionario_variaveis_modulo4.csv
