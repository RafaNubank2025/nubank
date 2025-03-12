### 📊 Nubank - Analytics Engineer  

Este repositório contém a solução para o case de **Analytics Engineer** no **Nubank**. O objetivo do projeto é demonstrar habilidades em modelagem de dados, transformação de dados (**ETL/ELT**) e análise para suportar decisões estratégicas.  

---

## 🚀 Tecnologias Utilizadas  

- **Cloud Storage** – Armazenamento dos arquivos CSV  
- **Cloud Run** – Função para acionar o processamento dos arquivos automaticamente  
- **Python** – Utilizado para manipulação de dados (**pandas, API Cloud Storage, API BigQuery**)  
- **SQL (BigQuery)** – Para modelagem e consultas dos dados  
- **DBdiagram.io** – Criação do diagrama e modelagem de dados  

---

## 🔄 Arquitetura de Dados Atual x Proposta de Nova Arquitetura  

A arquitetura de dados atual apresenta alguns pontos de melhoria, especialmente na estrutura do **Data Warehouse**. Para otimizar a organização e facilitar o consumo de dados, propus uma arquitetura baseada em três camadas:  

1. **Bronze** – Camada de dados brutos.  
   - Todos os dados são carregados como **string** para evitar complexidade e problemas de compatibilidade entre fontes de dados.  
   - Os **analistas de negócios** não possuem acesso a essa camada.  

2. **Silver** – Camada de dados tratados.  
   - Os dados são **tipados e passam por pequenas transformações**.  
   - Os **analistas de negócios** podem acessar e manipular os dados.  

3. **Gold** – Camada de dados prontos para relatórios.  
   - Contém tabelas refinadas e otimizadas para **reporting e dashboards**.  

---

## 🛠️ Criação de Tabelas na Camada Bronze  

Seguindo a estratégia descrita acima, fiz alterações no arquivo **tables_diagram**. Em vez de criar tabelas já tipadas, todas as colunas foram definidas inicialmente como **string**.  

📝 **Motivação:**  
- **Evitar incompatibilidade** entre diferentes fontes de dados.  
- **Facilitar a ingestão** de novos arquivos sem necessidade de pré-transformação.  
- **Garantir maior flexibilidade** para tipagem posterior na camada **Silver**.  

📚 O código está disponível [neste link](https://github.com/RafaNubank2025/nubank/blob/main/sql/create_table_bronze_layer.sql).  

---

## 📅 Ingestão de Arquivos CSV  

Para garantir uma solução **dinâmica e de fácil uso**, tanto para **usuários técnicos quanto não técnicos**, utilizei uma abordagem automatizada baseada em:  

- **Cloud Storage** – Responsável por armazenar os arquivos CSV.  
- **Cloud Run** – Executa automaticamente o processamento dos arquivos.  
- **BigQuery** – Base central para armazenamento e consultas dos dados.  

📌 **Fluxo de processamento:**  
1. **Upload do arquivo CSV** para o **bucket principal** (`nubank_files`):

![city](https://github.com/user-attachments/assets/7b48bb76-f455-4439-8416-63bb4a4b063e)

2. **Cloud Run** identifica o novo arquivo e aciona a função de processamento:  

![city2](https://github.com/user-attachments/assets/e6f90776-15a4-455c-b9e9-b23588b507b1)

3. O arquivo é processado para sua **respectiva tabela** na camada **Bronze do BigQuery**:

![city3](https://github.com/user-attachments/assets/d30804b7-dd1e-4958-887b-4478df9ac28f)

4. Os dados são movidos para o **bucket de arquivos processados** que possue uma classe de armazenamento mais fria (`nubank_processed_files`):

![city4](https://github.com/user-attachments/assets/347bbaa2-6c45-4b7f-ac94-463472ea4909)

💡 **Benefícios dessa solução:**  
- **Automatização** do carregamento dos arquivos.  
- **Melhor controle** e rastreabilidade dos arquivos.  
- **Facilidade de uso** para diferentes perfis de usuários.
- **Economia de custos** movimentando os arquivos processados para uma classe mais fria.  

📚 O código está disponível [neste link](https://github.com/RafaNubank2025/nubank/tree/main/python).  

---

## 🛠️ Criação de Tabelas na Camada Silver  

Agora que os dados estão carregados na camada bronze do nosso Data Warehouse, podemos seguir e popular nossa camada **silver**.
Precisei transformar a tipagem de dados de algumas colunas.

📚 O código está disponível [neste link](https://github.com/RafaNubank2025/nubank/blob/main/sql/create_table_silver_layer.sql).  

---

## Problem 1 💡

Your colleague Jane Hopper, the Business Analyst in charge of analyzing customer behavior, who directly consumes data from the Data Warehouse Environment, 
needs to get all the Account's Monthly Balances between Jan/2020 and Dec/2020. She wasn't able to do it alone, and asked for your help with the query needed!

📚 Código SQL com a resolução do problema [neste link](https://github.com/RafaNubank2025/nubank/blob/main/sql/get_all_account_monthly_balances.sql).  
📅 File output in csv format [neste link](https://github.com/RafaNubank2025/nubank/blob/main/file_csv/get_all_account_monthly_balances.csv).

---

## Problem 2 💡

Esse problema foi realmente bem legal de resolver, bastante desafiador. 
Segue imagem da nova modelagem de dados:

![Untitled (1)](https://github.com/user-attachments/assets/fe211918-9dc2-4a89-b2bc-45d41be7f859)

**A proposta de melhoria no modelo leva em consideração os aspectos abaixo:**

**Falta de uma tabela de transações unificada.**

Hoje, existem três tabelas separadas para movimentações financeiras:
transfer_ins (entradas)
transfer_outs (saídas)
pix_movements (PIX enviados e recebidos)
Isso torna consultas mais complexas e dificulta a inclusão de novos métodos de pagamento.

**Campos de data dispersos**

As tabelas de movimentação financeira usam transaction_completed_at e pix_completed_at, que são IDs referenciando d_time.
Isso adiciona um nível extra de complexidade ao modelo, dificultando consultas simples.

**Falta de suporte para novos produtos**

Hoje, a estrutura só suporta transferências entre contas.
Não há suporte para outros produtos, como seguros, cartões de crédito, empréstimos, recompensas, etc.

**Duplicação de informações de localização**

customers já possui customer_city, mas também armazena country_name, o que pode gerar inconsistências e redundâncias.
O ideal seria usar apenas city_id e garantir que a localização seja obtida por meio das tabelas de referência (city, state, country).

**Proposta de Melhoria no Modelo**

1️⃣ Criar uma Tabela Unificada para Transações (transactions)

Em vez de ter três tabelas (transfer_ins, transfer_outs e pix_movements), podemos consolidar tudo em uma única tabela transactions.

Vantagens:

✅ Facilita consultas → Em vez de fazer UNION ALL em várias tabelas, os analistas acessam uma única fonte de dados.

✅ Escalável → Se o Nubank adicionar novos tipos de transações (boletos, cartões, seguros, etc.), basta incluir novos valores em transaction_type.

✅ Melhora performance → Reduz o número de joins necessários para consultas financeiras.

2️⃣ Criar uma Tabela de Produtos Financeiros (financial_products)

Como Nubank pode expandir para novas áreas (seguros, empréstimos, cartões, etc.), podemos adicionar uma tabela para rastrear os produtos financeiros associados a cada conta.

Vantagens:

✅ Melhora a flexibilidade → Nubank pode adicionar novos produtos sem alterar a estrutura do Data Warehouse.

✅ Melhora a análise → Permite que os analistas entendam quais contas têm produtos ativos e como eles impactam a movimentação financeira.

3️⃣ Melhorar a Modelagem de Datas

Remover a necessidade de referenciar d_time.time_id em transactions.
Usar diretamente os campos de created_at ou updated_at em timestamp, que já contém a data/hora real.
d_time, d_month e d_year ainda podem existir para análises agregadas, mas não devem ser obrigatórios em todas as transações.

Vantagens:

✅ Facilita consultas temporais → Os analistas podem explorar sem precisar de joins adicionais.

✅ Reduz complexidade → Torna a modelagem mais intuitiva e eficiente.

Diagrama Melhorado
Aqui está um resumo da estrutura melhorada:

🔹 Tabelas Unificadas:

✔ transactions → Substitui transfer_ins, transfer_outs e pix_movements.

✔ financial_products → Nova tabela para gerenciar produtos financeiros.

🔹 Otimizações:

✔ transactions.created_at / transactions.updated_at → Usa timestamp em vez de d_time.time_id.

✔ customers → Remove redundância de country_name, utilizando apenas city_id.

**Trade-offs e Impacto**  

| Mudança | Benefícios | Possíveis Desafios |
|---------|------------|--------------------|
| Unificar transações em transactions | Reduz joins, melhora performance e escalabilidade | Os dados dessa tabela aumentarão consideravelmente, portanto, precisamos de um plano de rollout altamente assertivo para que os usuários compreendam a nova granularidade dos dados e a importância dos filtros. 
|||Requer migração dos dados antigos |
| Criar financial_products | Permite análise de produtos (cartão, seguros, etc.) | Pode precisar de ajustes para novos produtos |
| Remover dependência de d_time.time_id | Facilita consultas temporais | Muitas queries podem precisar de ajustes |

---

## 📌 Conclusão  

💡 Com essas mudanças, o Data Warehouse da Nubank se torna mais flexível, escalável e eficiente.  
