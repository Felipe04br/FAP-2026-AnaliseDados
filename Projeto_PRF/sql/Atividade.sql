-- Autor: Felipe Luiz da Silva Dias
-- Ferramenta utilizada: DuckDB
-- Fonte de dados: Dados públicos da PRF

-- PARTE 1: INGESTÃO E INTEGRAÇÃO DE DADOS

-- Criação da tabela consolidada integrando as três bases anuais da PRF via UNION ALL
CREATE TABLE acidentes_prf_historico AS
SELECT * FROM read_csv_auto('datatran2023.csv', delim=';', header=true, encoding = 'latin-1', sample_size=-1)
UNION ALL
SELECT * FROM read_csv_auto('datatran2024.csv', delim=';', header=true, encoding = 'latin-1', sample_size=-1)
UNION ALL
SELECT * FROM read_csv_auto('datatran2025.csv', delim=';', header=true, encoding = 'latin-1', sample_size=-1);

-- PARTE 2: LIMPEZA E SELEÇÃO DE COLUNAS

-- Remoção das colunas geodésicas (latitude, longitude) e administrativas (regional, delegacia, uop)
CREATE VIEW vw_acidentes_limpa AS
SELECT 
    id,
    data_inversa,
    dia_semana,
    horario,
    uf,
    br,
    km,
    municipio,
    causa_acidente,
    tipo_acidente,
    classificacao_acidente,
    fase_dia,
    sentido_via,
    condicao_metereologica,
    tipo_pista,
    tracado_via,
    uso_solo,
    pessoas,
    mortos,
    feridos_leves,
    feridos_graves,
    ilesos,
    ignorados,
    feridos,
    veiculos
FROM acidentes_prf_historico;

-- PARTE 3: ENGENHARIA DE RECURSOS (CRIAÇÃO DE NOVAS COLUNAS)

-- Criação da View estendida com variáveis temporais, indicadores binários e datas comemorativas
CREATE VIEW vw_acidentes_enriquecida AS
SELECT 
    *,
    -- Target binária de letalidade
    CASE WHEN mortos >= 1 THEN 1 ELSE 0 END AS acidente_fatal,
    
    -- Extração de atributos da data
    YEAR(data_inversa) AS ano_acidente,
    month(data_inversa) AS mes_acidente,
    
    -- Sinalização de final de semana (Sábado / Domingo)
    CASE 
        WHEN LOWER(dia_semana) IN ('sábado', 'domingo') THEN 1 
        ELSE 0 
    END AS fim_de_semana,
    
    -- Classificação de períodos comemorativos de alto fluxo
    CASE 
        WHEN (
            (EXTRACT(MONTH FROM CAST(data_inversa AS DATE)) = 12 AND EXTRACT(DAY FROM CAST(data_inversa AS DATE)) >= 20)
            OR 
            (EXTRACT(MONTH FROM CAST(data_inversa AS DATE)) = 1 AND EXTRACT(DAY FROM CAST(data_inversa AS DATE)) <= 2)
        ) THEN 'Fim de Ano'
        ELSE 'Normal'
    END AS data_comemorativa
FROM vw_acidentes_limpa;

-- PARTE 4: QUESTÕES DE NEGÓCIO (CONSULTAS ANALÍTICAS)

-- Nível 1: Visão Geral e Temporal

-- Questão 1: Tendência Anual e Severidade
-- Avalia volume de acidentes, mortos e a evolução da taxa global de letalidade (% fatais).
SELECT 
    ano_acidente,
    COUNT(*) AS total_acidentes,
    SUM(mortos) AS total_vitimas_fatais,
    SUM(acidente_fatal) AS total_acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS taxa_letalidade_pct
FROM vw_acidentes_enriquecida
GROUP BY ano_acidente
ORDER BY ano_acidente;
-- Conclusão: A taxa de letalidade manteve-se altamente estável (~7.14% a 7.18%), sem queda expressiva.

-- Questão 2: Sazonalidade Mensal das Ocorrências
-- Identifica meses de maior gravidade relativa.
SELECT 
    mes_acidente,
    COUNT(*) AS total_acidentes,
    SUM(mortos) AS total_vitimas_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS taxa_letalidade_pct
FROM vw_acidentes_enriquecida
GROUP BY mes_acidente
ORDER BY taxa_letalidade_pct DESC;
-- Conclusão: Maio (7.71%) e Junho (7.68%) apresentam os maiores picos de letalidade, superando os meses de fim de ano.

-- Questão 3: A Influência da Luminosidade (Fase do Dia)
-- Compara o volume total versus a proporção de acidentes fatais por luminosidade.
SELECT 
    fase_dia,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS taxa_letalidade_pct
FROM vw_acidentes_enriquecida
GROUP BY fase_dia
ORDER BY taxa_letalidade_pct DESC;
-- Conclusão: Embora o "Pleno dia" concentre o maior volume absoluto, "Amanhecer" (11.36%) e "Plena Noite" (10.09%) possuem o dobro da taxa de letalidade.

-- Questão 4: O Impacto dos Finais de Semana
-- Compara a gravidade entre dias úteis (0) e finais de semana (1).
SELECT 
    CASE WHEN fim_de_semana = 1 THEN 'Fim de Semana' ELSE 'Dia Útil' END AS periodo,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS taxa_letalidade_pct
FROM vw_acidentes_enriquecida
GROUP BY fim_de_semana
ORDER BY fim_de_semana;
-- Conclusão: O risco relativo aumenta substancialmente nos finais de semana (8.43% vs 6.56% nos dias úteis).

-- Nível 2: Análise de Risco (Cálculo de Lift e Fatores de Causa)

-- Questão 5: O Perigo Oculto na Dinâmica da Colisão (Tipo de Acidente)
-- Calcula o Lift de letalidade por tipo de acidente (mínimo 100 ocorrências).
WITH taxa_global AS (
    SELECT CAST(SUM(acidente_fatal) AS FLOAT) / COUNT(*) AS media_global 
    FROM vw_acidentes_enriquecida
)
SELECT 
    t.tipo_acidente,
    COUNT(*) AS total_ocorrencias,
    ROUND(100.0 * SUM(t.acidente_fatal) / COUNT(*), 2) AS taxa_tipo_pct,
    ROUND((SUM(t.acidente_fatal) * 1.0 / COUNT(*)) / g.media_global, 2) AS lift_letalidade
FROM vw_acidentes_enriquecida t, taxa_global g
GROUP BY t.tipo_acidente, g.media_global
HAVING COUNT(*) >= 100
ORDER BY lift_letalidade DESC;
-- Conclusão: "Colisão frontal" (Lift 4.16) e "Atropelamento de Pedestre" (Lift 4.04) aumentam em mais de 4x o risco de morte.

-- Questão 6: Ranking de Causas Associadas à Letalidade
-- Retorna as 5 causas presumíveis com maior Lift em relação à média global.
WITH taxa_global AS (
    SELECT CAST(SUM(acidente_fatal) AS FLOAT) / COUNT(*) AS media_global 
    FROM vw_acidentes_enriquecida
)
SELECT 
    c.causa_acidente,
    COUNT(*) AS total_ocorrencias,
    ROUND(100.0 * SUM(c.acidente_fatal) / COUNT(*), 2) AS taxa_causa_pct,
    ROUND((SUM(c.acidente_fatal) * 1.0 / COUNT(*)) / g.media_global, 2) AS lift_letalidade
FROM vw_acidentes_enriquecida c, taxa_global g
GROUP BY c.causa_acidente, g.media_global
HAVING COUNT(*) >= 100
ORDER BY lift_letalidade DESC
LIMIT 5;
-- Conclusão: Destacam-se causas associadas a pedestres na pista e "Transitar na contramão" (Lift 4.04).

-- Questão 7: Análise da Infraestrutura (Traçado da Via)
-- Avalia o comportamento do risco em diferentes geometrias da via (> 500 registros).
SELECT 
    tracado_via,
    COUNT(*) AS total_acidentes,
    SUM(acidente_fatal) AS acidentes_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS taxa_letalidade_pct
FROM vw_acidentes_enriquecida
GROUP BY tracado_via
HAVING COUNT(*) > 500
ORDER BY taxa_letalidade_pct DESC;
-- Conclusão: Trechos combinados com declives/pontes apresentam maior taxa de mortalidade do que retas simples ou curvas puras.

-- Nível 3: Análise Multivariada (Cruzamentos de Variáveis)

-- Questão 8: Condições Agravantes (Pista vs. Clima)
-- Cruzamento entre tipo de pista e condição meteorológica (mínimo 50 acidentes).
SELECT 
    tipo_pista,
    condicao_metereologica,
    COUNT(*) AS total_acidentes,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS taxa_letalidade_pct
FROM vw_acidentes_enriquecida
GROUP BY tipo_pista, condicao_metereologica
HAVING COUNT(*) >= 50
ORDER BY taxa_letalidade_pct DESC
LIMIT 10;
-- Conclusão: Pistas simples combinadas com nevoeiro/neblina geram a maior letalidade registrada (13.95%).

-- Questão 9: Pontos Críticos Noturnos (BR x Fase do Dia)
-- Ranking das 10 BRs com maior total de vítimas fatais especificamente à noite.
SELECT 
    br,
    COUNT(*) AS total_acidentes_noturnos,
    SUM(mortos) AS total_mortos_noturnos
FROM vw_acidentes_enriquecida
WHERE fase_dia = 'Plena Noite' AND br IS NOT NULL
GROUP BY br
ORDER BY total_mortos_noturnos DESC
LIMIT 10;
-- Conclusão: As rodovias BR-116 e BR-101 lideram isoladamente o número absoluto de mortes noturnas.

-- Questão 10: O Efeito de Períodos Festivos
-- Comparativo de volume e severidade entre 'Fim de Ano', 'Carnaval' e dias 'Normais'.
SELECT 
    data_comemorativa,
    COUNT(*) AS total_acidentes,
    SUM(mortos) AS total_vitimas_fatais,
    ROUND(100.0 * SUM(acidente_fatal) / COUNT(*), 2) AS taxa_letalidade_pct
FROM vw_acidentes_enriquecida
GROUP BY data_comemorativa
ORDER BY taxa_letalidade_pct DESC;

-- Nível 4: Casos Críticos e Foco Geográfico

-- Questão 11: Acidentes de Altíssima Gravidade (Múltiplas Vítimas >= 3)
-- UF líder e principal causa associada em acidentes com 3 ou mais mortos.
WITH estado_lider AS (
    SELECT uf
    FROM vw_acidentes_enriquecida
    WHERE mortos >= 3
    GROUP BY uf
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT 
    a.uf,
    a.causa_acidente,
    COUNT(*) AS qtd_acidentes_extremos,
    SUM(a.mortos) AS total_mortos
FROM vw_acidentes_enriquecida a
JOIN estado_lider e ON a.uf = e.uf
WHERE a.mortos >= 3
GROUP BY a.uf, a.causa_acidente
ORDER BY qtd_acidentes_extremos DESC
LIMIT 1;
-- Conclusão: Minas Gerais (MG) lidera o ranking de acidentes de altíssima gravidade, tendo "Transitar na contramão" como causa primária.

-- Questão 12: Direcionamento Regional em Pernambuco (Alocação de Viaturas)
-- Top 5 municípios de PE com maior total de acidentes fatais nos anos de 2024 e 2025.
SELECT 
    municipio,
    COUNT(*) AS acidentes_fatais_2024_2025
FROM vw_acidentes_enriquecida
WHERE uf = 'PE' 
  AND ano_acidente IN (2024, 2025)
  AND acidente_fatal = 1
GROUP BY municipio
ORDER BY acidentes_fatais_2024_2025 DESC
LIMIT 5;
-- Conclusão: Recife, Jaboatão dos Guararapes, Garanhuns, Caruaru e Petrolina concentram a maior necessidade de alocação de viaturas de resgate.