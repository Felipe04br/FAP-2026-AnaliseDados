# Análise de Dados de Acidentes PRF 2025

## 📋 Visão Geral do Projeto

Este projeto realiza análise de acidentes rodoviários registrados pela Polícia Rodoviária Federal (PRF) utilizando dados abertos de 2025, com foco em agrupamento e análise por ocorrência.

---

## 📊 Informações do Projeto

### Fonte de Dados
- **Origem**: Dados Abertos PRF
- **Período**: 2025
- **Granularidade**: Acidentes agrupados por ocorrência

### Ferramentas Utilizadas
- **Banco de Dados**: DuckDB
- **Linguagem**: SQL
- **Script Principal**: `sql/modulo3_prf.sql`

### Saídas
- **Formato**: CSV
- **Diretório**: `resultados/*.csv`

---

## 📈 Métricas de Controle

### Número de Controle
| Métrica | Valor | Status |
|---------|-------|--------|
| `total_ocorrencias` | 72.529 | Ok |
| `total_acidentes_fatais` | 5.210 | Ok |

## 🗂️ Estrutura do Projeto

```
Projeto_PRF/
├── docs/
│   └── README_SQL.md
├── sql/
│   └── modulo3_prf.sql
└── resultados/
    └── *.csv
```

---

## ✅ Checklist de Execução

- [ X ] Verificar dados de entrada disponíveis
- [ X ] Executar `sql/modulo3_prf.sql`
- [ X ] Validar saídas em `resultados/`
- [ X ] Atualizar `total_ocorrencias`
- [ X ] Revisar observações
- [ X ] Compartilhar resultados