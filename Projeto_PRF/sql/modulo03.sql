-- Danilo Farias
-- Comandos em SQL - Módulo 03 - Análise de Dados

-- Exibe a versão do DuckDB
select version();

-- Exibe os dados do arquivo CSV de acidentes de trânsito 2025
-- O arquivo CSV está localizado no diretório 'dados_brutos' e utiliza o delimitador ';'
-- Lembra de inserir a o parâmetro 'encoding' para lidar com caracteres especiais, como acentos e cedilha
select * from read_csv_auto(
    'dados_brutos/acidentes2025.csv',
    delim = ';',
    header = true,
    encoding = 'latin-1',
    sample_size = -1
)
LIMIT 10;

create or replace table acidentes_prf_2025 as
select * from read_csv_auto(
    'dados_brutos/acidentes2025.csv',
    delim = ';',
    header = true,
    encoding = 'latin-1',
    sample_size = -1
);

-- Testando a tabela criada
select * from acidentes_prf_2025;

-- Exibe a estrutura da tabela 'acidentes_prf_2025'
describe acidentes_prf_2025;

select data_inversa, dia_semana, horario, uf, br, municipio,
    causa_acidente, tipo_acidente, classificacao_acidente, 
    fase_dia, condicao_metereologica, tipo_pista, tracado_via,
    uso_solo, mortos from acidentes_prf_2025
        limit 20;
