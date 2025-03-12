### 📊 Nubank - Analytics Engineer  

This repository contains the solution for the Analytics Engineer case at Nubank. The project's objective is to demonstrate skills in data modeling, data transformation (ETL/ELT), and analysis to support strategic decision-making.

---

## 🚀 Technologies Used  

- **Cloud Storage** – Storage for CSV files  
- **Cloud Run** – Function to trigger file processing automatically  
- **Python** – Used for data manipulation (**pandas, Cloud Storage API, BigQuery API**)  
- **SQL (BigQuery)** – For data modeling and queries  
- **DBdiagram.io** – Creation of the diagram and data modeling  

---

## 🔄 Current Data Architecture vs. Proposed New Architecture  

The current data architecture has some areas for improvement, especially in the **Data Warehouse** structure. To optimize organization and facilitate data consumption, I proposed an architecture based on three layers:  

1. **Bronze** – Raw data layer.  
   - All data is loaded as **string** to avoid complexity and compatibility issues between data sources.  
   - **Business analysts** do not have access to this layer.  

2. **Silver** – Processed data layer.  
   - Data is **typed and undergoes minor transformations**.  
   - **Business analysts** can access and manipulate the data.  

3. **Gold** – Ready-for-reporting data layer.  
   - Contains refined and optimized tables for **reporting and dashboards**.  

---

## 🛠️ Creating Tables in the Bronze Layer  

Following the strategy described above, I made changes to the **tables_diagram** file. Instead of creating already typed tables, all columns were initially defined as **string**.  

📝 **Motivation:**  
- **Avoid incompatibility** between different data sources.  
- **Facilitate ingestion** of new files without the need for pre-transformation.  
- **Ensure greater flexibility** for later typing in the **Silver** layer.  

📚 The code is available [at this link](https://github.com/RafaNubank2025/nubank/blob/main/sql/create_table_bronze_layer.sql).  

---

## 📅 CSV File Ingestion  

To ensure a **dynamic and user-friendly solution** for both **technical and non-technical users**, I implemented an automated approach based on:  

- **Cloud Storage** – Responsible for storing CSV files.  
- **Cloud Run** – Automatically triggers file processing.  
- **BigQuery** – Central repository for data storage and queries.  

📌 **Processing Flow:**  
1. **CSV file upload** to the **main bucket** (`nubank_files`):  

   ![city](https://github.com/user-attachments/assets/7b48bb76-f455-4439-8416-63bb4a4b063e)  

2. **Cloud Run** detects the new file and triggers the processing function:  

   ![city2](https://github.com/user-attachments/assets/e6f90776-15a4-455c-b9e9-b23588b507b1)  

3. The file is processed into its **respective table** in the **BigQuery Bronze layer**:  

   ![city3](https://github.com/user-attachments/assets/d30804b7-dd1e-4958-887b-4478df9ac28f)  

4. The data is moved to the **processed files bucket**, which has a colder storage class (`nubank_processed_files`):  

   ![city4](https://github.com/user-attachments/assets/347bbaa2-6c45-4b7f-ac94-463472ea4909)  

💡 **Benefits of this solution:**  
- **Automated** file loading.  
- **Better control** and traceability of files.  
- **Ease of use** for different user profiles.  
- **Cost savings** by moving processed files to a colder storage class.  

📚 The code is available [at this link](https://github.com/RafaNubank2025/nubank/tree/main/python).  

---

## 🛠️ Creating Tables in the Silver Layer  

Now that the data is loaded into the Bronze layer of our Data Warehouse, we can proceed to populate the **Silver** layer.  
I had to transform the data types of some columns.  

📚 The code is available [at this link](https://github.com/RafaNubank2025/nubank/blob/main/sql/create_table_silver_layer.sql).  

---

## Problem 1 💡  

Your colleague Jane Hopper, the Business Analyst in charge of analyzing customer behavior, who directly consumes data from the Data Warehouse Environment,  
needs to get all the Account's Monthly Balances between Jan/2020 and Dec/2020. She wasn't able to do it alone and asked for your help with the query needed!  

📚 SQL code with the solution [at this link](https://github.com/RafaNubank2025/nubank/blob/main/sql/get_all_account_monthly_balances.sql).  
📅 File output in CSV format [at this link](https://github.com/RafaNubank2025/nubank/blob/main/file_csv/get_all_account_monthly_balances.csv).  

---

## Problem 2 💡  

This problem was really exciting to solve—quite challenging!  
Below is an image of the new data model:  

![Untitled (1)](https://github.com/user-attachments/assets/fe211918-9dc2-4a89-b2bc-45d41be7f859)  

**The proposed improvements to the model consider the following aspects:**  

### **Lack of a unified transactions table**  

Currently, there are three separate tables for financial transactions:  
- `transfer_ins` (incoming transfers)  
- `transfer_outs` (outgoing transfers)  
- `pix_movements` (PIX transactions, sent and received)  

This setup makes queries more complex and complicates the inclusion of new payment methods.  

### **Scattered date fields**  

The financial movement tables use `transaction_completed_at` and `pix_completed_at`, which reference `d_time`.  
This adds an extra level of complexity to the model, making simple queries harder.  

### **Lack of support for new products**  

Currently, the structure only supports account-to-account transfers.  
It does not support other financial products like insurance, credit cards, loans, or rewards.  

### **Duplicate location information**  

The `customers` table already contains `customer_city`, but it also stores `country_name`, which can lead to inconsistencies and redundancies.  
The ideal solution is to use only `city_id` and ensure location data is obtained via reference tables (`city`, `state`, `country`).  

---

## **Proposed Model Improvements**  

### **1️⃣ Create a Unified Transactions Table (`transactions`)**  

Instead of maintaining three tables (`transfer_ins`, `transfer_outs`, and `pix_movements`), we can consolidate them into a single `transactions` table.  

#### **Advantages:**  
✅ **Simplified queries** → Analysts can access a single source of data instead of performing `UNION ALL` operations.  
✅ **Scalability** → If Nubank adds new transaction types (e.g., bills, credit cards, insurance), we only need to add new `transaction_type` values.  
✅ **Better performance** → Reduces the number of `JOIN` operations required for financial queries.  

---

### **2️⃣ Create a Financial Products Table (`financial_products`)**  

Since Nubank may expand into new areas (insurance, loans, credit cards, etc.), we should introduce a table to track financial products linked to each account.  

#### **Advantages:**  
✅ **Greater flexibility** → New products can be added without changing the Data Warehouse structure.  
✅ **Better analysis** → Helps analysts understand which accounts have active products and how they impact financial transactions.  

---

### **3️⃣ Improve Date Modeling**  

We should remove the dependency on `d_time.time_id` in `transactions`.  
Instead, we should store direct timestamps (`created_at`, `updated_at`) containing actual date-time values.  

**The `d_time`, `d_month`, and `d_year` tables can still exist for aggregated analyses but should not be mandatory in every transaction.**  

#### **Advantages:**  
✅ **Easier time-based queries** → Analysts can explore data without extra `JOIN` operations.  
✅ **Lower complexity** → Makes the model more intuitive and efficient.  

---

## **Improved Data Model Summary**  

🔹 **Unified Tables:**  
✔ `transactions` → Replaces `transfer_ins`, `transfer_outs`, and `pix_movements`.  
✔ `financial_products` → New table to manage financial products.  

🔹 **Optimizations:**  
✔ `transactions.created_at` / `transactions.updated_at` → Uses timestamps instead of `d_time.time_id`.  
✔ `customers` → Removes redundancy of `country_name`, relying only on `city_id`.  

---

## **Trade-offs & Impact**  

| Change | Benefits | Possible Challenges |  
|--------|----------|---------------------|  
| **Unifying transactions into `transactions`** | Reduces `JOINs`, improves performance and scalability | The table will grow significantly, requiring a well-planned rollout to ensure users understand the new data structure and filtering importance. |  
|  |  | Requires migration of old data |  
| **Creating `financial_products`** | Enables product analysis (cards, insurance, etc.) | May require adjustments for future products |  
| **Removing dependency on `d_time.time_id`** | Simplifies date-based queries | Many queries may need adjustments |  

---

## 📌 **Conclusion**  

💡 **With these changes, Nubank’s Data Warehouse becomes more flexible, scalable, and efficient.** 🚀  

