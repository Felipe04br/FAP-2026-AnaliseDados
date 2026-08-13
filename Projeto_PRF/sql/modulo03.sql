-- Danilo Farias
-- Comandos em SQL - Módulo 03 - Análise de Dados

-- Consulta: taxa de fatalidade por tipo de acidente
-- Fonte: Dados Abertos PRF 2025 acidentes agrupados por ocorrência
-- Critério: categorias com pelo menos 100 ocorrências
-- Objetivo: gerar insumo para análise bivariada do Módulo 5

-- Primeiro faça:
-- Abra o terminal na pasta do projeto com o duckDB
-- Execute o comando .\duckdb.exe prf2025.duckdb

-- Exibe a versão do DuckDB
select version();

-- Exibe os dados do arquivo CSV de acidentes de trânsito 2025
-- O arquivo CSV está localizado no diretório 'dados_brutos' e utiliza o delimitador ';'
-- Lembra de inserir a o parâmetro 'encoding' para lidar com caracteres especiais, como acentos e cedilha
select * from read_csv_auto(
    'C:\Users\danso\OneDrive\Documentos\GitHub\FAP-2026-AnaliseDados\Projeto_PRF\dados_brutos\acidentes2025.csv',
    delim = ';',
    header = true,
    encoding = 'latin-1',
    sample_size = -1
);

create or replace table acidentes_prf_2025 as
select * from read_csv_auto(
    'C:\Users\danso\OneDrive\Documentos\GitHub\FAP-2026-AnaliseDados\Projeto_PRF\dados_brutos\acidentes2025.csv',
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

select causa_acidente as "Causa dos Acidentes", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by causa_acidente
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select data_inversa as "Data", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by data_inversa
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select month(data_inversa) as "Mês"
    from acidentes_prf_2025;

select month(data_inversa)  as "Mês", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by month(data_inversa)
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select case month(data_inversa)  
    when 1 then 'Janeiro'
    when 2 then 'Fevereiro'
    when 3 then 'Março'
    when 4 then 'Abril'
    when 5 then 'Maio'
    when 6 then 'Junho'
    when 7 then 'Julho'
    when 8 then 'Agosto'
    when 9 then 'Setembro'
    when 10 then 'Outubro'
    when 11 then 'Novembro'
    when 12 then 'Dezembro'
    end as "Mês", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by month(data_inversa)
    order by month(data_inversa);

create or replace view  vw_acidentes_por_mes as
select case month(data_inversa)  
    when 1 then 'Janeiro'
    when 2 then 'Fevereiro'
    when 3 then 'Março'
    when 4 then 'Abril'
    when 5 then 'Maio'
    when 6 then 'Junho'
    when 7 then 'Julho'
    when 8 then 'Agosto'
    when 9 then 'Setembro'
    when 10 then 'Outubro'
    when 11 then 'Novembro'
    when 12 then 'Dezembro'
    end as "Mês", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by month(data_inversa)
    order by month(data_inversa);

select * from vw_acidentes_por_mes;

create or replace view vw_acidentes_por_uf as
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

select * from vw_acidentes_por_uf;

create or replace view vw_acidentes_por_causa as
select causa_acidente as "Causa dos Acidentes", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by causa_acidente
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select * from vw_acidentes_por_causa;

create or replace view vw_acidentes_por_br as
select br as "BR", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by br
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select * from vw_acidentes_por_br;

create or replace view vw_acidentes_por_tipo as
select tipo_acidente as "Tipo de Acidente", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by tipo_acidente
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select * from vw_acidentes_por_tipo;

create or replace view vw_acidentes_por_tipoPista as
select tipo_pista as "Tipo de Pista", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by tipo_pista
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select * from vw_acidentes_por_tipoPista;

create or replace view vw_acidentes_por_condicao_metereologica as
select condicao_metereologica as "Condição Meteorológica", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by condicao_metereologica
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select * from vw_acidentes_por_condicao_metereologica;

create or replace view vw_acidentes_por_classificacao_acidente as
select classificacao_acidente as "Classificação do Acidente", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by classificacao_acidente
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select * from vw_acidentes_por_classificacao_acidente;

select * from acidentes_prf_2025
    where classificacao_acidente = 'NA';

UPDATE acidentes_prf_2025
SET classificacao_acidente = 'Com Vítimas Fatais'
WHERE classificacao_acidente = 'NA' AND mortos >= 1;

alter table acidentes_prf_2025
    add column acidente_fatal boolean;

update acidentes_prf_2025
set acidente_fatal = case when mortos >= 1 then true else false end;

select * from acidentes_prf_2025;

select * from acidentes_prf_2025
    where acidente_fatal is true;

select sum(acidente_fatal) as "Total de Acidentes Fatais"
    from acidentes_prf_2025;

select sum(acidente_fatal) as "Total de Acidentes Fatais"
    from acidentes_prf_2025
    where uf = 'PE';

select tipo_acidente as "Tipo de Acidente", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by tipo_acidente
        having sum(mortos) >= 100
    order by (count(mortos) filter (where mortos >= 1)) / count(id) desc;

select * from vw_acidentes_por_tipo
    where "Total de Mortos" >= 100
    order by "Taxa de Acidentes Fatais" desc;

select uf as "Estado", municipio as "Município", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by uf, municipio
    order by sum(mortos) desc;

create or replace view vw_acidentes_por_municipio as
select uf as "Estado", municipio as "Município", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025
    group by uf, municipio
    order by sum(mortos) desc;

select * from vw_acidentes_por_municipio
    where "Total de Mortos" >= 20;

select sum(acidente_fatal) / count(id) as "Taxa de Acidentes Fatais"
    from acidentes_prf_2025;

with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select tipo_acidente as "Tipo de Acidente", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by tipo_acidente, taxa_fatalidade
    order by "Lift" desc;

create or replace view vw_acidentes_por_tipo_lift as
with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select tipo_acidente as "Tipo de Acidente", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by tipo_acidente, taxa_fatalidade
    order by "Lift" desc;

with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select causa_acidente as "Causa de Acidente", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by causa_acidente, taxa_fatalidade
    order by "Lift" desc;

create or replace view vw_acidentes_por_causa_lift as
with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select causa_acidente as "Causa de Acidente", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by causa_acidente, taxa_fatalidade
    order by "Lift" desc;

with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select condicao_metereologica as "Condições Meteorológicas", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by condicao_metereologica, taxa_fatalidade
    order by "Lift" desc;

create or replace view vw_acidentes_por_condicao_metereologica_lift as
with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select condicao_metereologica as "Condições Meteorológicas", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by condicao_metereologica, taxa_fatalidade
    order by "Lift" desc;

with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select uf as "Estados", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by uf, taxa_fatalidade
    order by "Lift" desc;

create or replace view vw_acidentes_por_uf_lift as
with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select uf as "Estados", 
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by uf, taxa_fatalidade
    order by "Lift" desc;

with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select extract(year from cast(data_inversa as date)) as "Ano", 
    extract(month from cast(data_inversa as date)) as "Mês",
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by "Ano", "Mês", taxa_fatalidade
    order by "Lift" desc;
	
create or replace view vw_acidentes_por_ano_mes as
with taxa_fatalidade_global as (
    select sum(acidente_fatal) / count(id) as taxa_fatalidade
    from acidentes_prf_2025
)
select extract(year from cast(data_inversa as date)) as "Ano", 
    extract(month from cast(data_inversa as date)) as "Mês",
    count(id) as "Total de Acidentes",
    count(mortos) filter (where mortos >= 1) as "Total de Acidentes Fatais",
    sum(mortos) as "Total de Mortos",
    replace(printf('%.2f%%', 
        ((count(mortos) filter (where mortos >= 1)) / count(id)) 
            * 100.0), '.', ',')
        as "Taxa de Acidentes Fatais",
    round(((count(mortos) filter (where mortos >= 1)) / count(id)) /
    taxa_fatalidade, 2) as "Lift"
    from acidentes_prf_2025, taxa_fatalidade_global
    group by "Ano", "Mês", taxa_fatalidade
    order by "Lift" desc;

copy vw_acidentes_por_tipo_lift 
    to 'C:\Users\danso\OneDrive\Documentos\GitHub\FAP-2026-AnaliseDados\Projeto_PRF\resultados/bivariada_tipo_acidente.csv' 
        (HEADER, DELIMITER ';');

copy vw_acidentes_por_causa_lift 
    to 'C:\Users\danso\OneDrive\Documentos\GitHub\FAP-2026-AnaliseDados\Projeto_PRF\resultados/bivariada_causa_acidente.csv' 
        (HEADER, DELIMITER ';');

copy vw_acidentes_por_condicao_metereologica_lift 
    to 'C:\Users\danso\OneDrive\Documentos\GitHub\FAP-2026-AnaliseDados\Projeto_PRF\resultados/bivariada_condicao_metereologica.csv' 
        (HEADER, DELIMITER ';');

copy vw_acidentes_por_uf_lift 
    to 'C:\Users\danso\OneDrive\Documentos\GitHub\FAP-2026-AnaliseDados\Projeto_PRF\resultados/bivariada_uf.csv' 
        (HEADER, DELIMITER ';');

