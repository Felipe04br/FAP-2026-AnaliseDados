-- Danilo Farias
-- Comandos em SQL - Módulo 03 - Análise de Dados

-- Primeiro faça:
-- Abra o terminal na pasta do projeto com o duckDB
-- Execute o comando .\duckdb.exe prf2025.duckdb

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

select data_inversa, dia_semana, horario from acidentes_prf_2025;

select data_inversa, dia_semana, horario, uf, br, municipio,
    causa_acidente, tipo_acidente, classificacao_acidente, 
    fase_dia, condicao_metereologica, tipo_pista, tracado_via,
    uso_solo, mortos 
        from acidentes_prf_2025
        limit 20;

select data_inversa, uf, br, municipio, causa_acidente, mortos
    from acidentes_prf_2025
    order by mortos desc, data_inversa
    limit 20;

select data_inversa, uf, br, municipio, causa_acidente, mortos
    from acidentes_prf_2025
    where uf = 'PE'
    order by mortos desc, data_inversa
    limit 20;

select data_inversa, uf, br, municipio, causa_acidente, mortos
    from acidentes_prf_2025
    where uf = 'PE' and municipio = 'RECIFE'
    order by mortos desc, data_inversa
    limit 20;

select data_inversa, uf, br, municipio, causa_acidente, mortos
    from acidentes_prf_2025
    where uf = 'PE' and municipio in ('RECIFE', 'OLINDA', 'IGARASSU', 'JABOATAO DOS GUARARAPES', 'PAULISTA')
    order by mortos desc, data_inversa
    limit 20;

select data_inversa, uf, br, municipio, causa_acidente, mortos
    from acidentes_prf_2025
    where mortos >= 1
    order by mortos desc, data_inversa;

select municipio from acidentes_prf_2025
    where uf = 'PE' and mortos >= 1
    order by municipio;

select distinct municipio from acidentes_prf_2025
    where uf = 'PE' and mortos >= 1
    order by municipio;

select distinct fase_dia from acidentes_prf_2025
    order by fase_dia;

select distinct causa_acidente from acidentes_prf_2025
    order by causa_acidente;

select distinct upper(tipo_acidente) from acidentes_prf_2025
    order by tipo_acidente;

select uf as "Estados", count(id) as "Total de Acidentes"
    from acidentes_prf_2025
    group by uf
    order by uf;

select uf as "Estados", count(id) as "Total de Acidentes"
    from acidentes_prf_2025
    group by uf
    order by count(id) desc;

select uf as "Estados", count(id) as "Total de Acidentes Fatais"
    from acidentes_prf_2025
    where mortos >= 1
    group by uf
    order by count(id) desc;

select uf as "Estados", 
    count(id) as "Total de Acidentes",
    sum(mortos) as "Total de Mortos"
    from acidentes_prf_2025
    group by uf
    order by count(id) desc;

select uf as "Estados", 
    count(id) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos"
    from acidentes_prf_2025
    where mortos >= 1
    group by uf
    order by count(id) desc;

select uf as "Estados", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos"
    from acidentes_prf_2025
    group by uf
    order by count(id) desc;

select uf as "Estados", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) * 100.0, 2) 
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by uf
    order by count(id) desc;

select uf as "Estados", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by uf
    order by count(id) desc;

select uf as "Estados", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by uf
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;