### 🦠 COVID-19 Death and Vaccination Analysis
---
This project explores the [Our World in Data](https://ourworldindata.org/covid-deaths) COVID-19 dataset which contains data such as number of cases, deaths, vaccinations, among other important information. The goal of this project is to transform and analyze the COVID Deaths and Vaccinations dataset using SQL (BigQuery) and Excel, and use the cleaned dataset to design powerful, easy-to-understand visualizations on Tableau. Furthermore, a correlation scatterplot will be used to analyze the relationship between vaccination and infection rate.

---

## 📁 Project Structure

- /[data](https://github.com/jaylenroope-afk/CovidData/tree/main/data) - Contains raw and processed CSV files used in the project
- /[SQL Queries](https://github.com/jaylenroope-afk/CovidData/tree/main/SQL%20Queries) - Includes .sql files that were used to pull important values and transform the raw data
- /[Tableau Visualizations](https://github.com/jaylenroope-afk/CovidData/tree/main/Tableau%20Visualizations) - Includes png and twbx files of visualizations created in Tableau. 

---

## 🔧 Tools Used

- Excel (Data Cleaning, Sorting/Filtering, Scatterplot)
- BigQuery SQL (Data Transformations, Creating New Variables, Joining Datasets)
- Tableau Public (Data Visualizations)
- GitHub (Documentation)

---

## 🧐 Methods/Analysis

1. Pulled data from [Our World in Data](https://ourworldindata.org/covid-deaths), gathering data for both COVID Deaths and Vaccinations.
2. **Cleaned** each of the datasets on **Excel** by deleting columns I did not need as I was mainly focusing on the number of cases, deaths, vaccinations, population, and date. I also **filtered** out any nulls and blanks.
3. Explored the data using **BigQuery SQL** and wrote several queries that would be beneficial when making visualizations.
4. Used **JOIN** function to combine the COVID Deaths and Vaccinations datasets.
5. Calculated the mortality rate, infection rate, and vaccination rate based on the population on SQL. This allowed me to design a **correlation scatterplot** to see how **infection rate** and **vaccination rate** are related.
6. **Visualized** the data on **Tableau Public** and designed several visuals such as two **interactive** color-coded maps and a counter that shows the number of COVID Deaths over time.

---

## ✅ Results

- There is a moderate correlation between the vaccination rate and infection rate. A **correlation coefficient (R)** of **0.4797** resulted which indicates a **moderate**, **positive** relationship between vaccination rate and infection rate
- Data was only available from **January 2020 to April 2021**. Vaccinations were not introduced until Decemember 2020 with many countries not using it before the end range of this dataset. Therefore, there was not enough time to observe the full effectiveness of the vaccine. Next time, using a dataset with a longer range would be much more beneficial.
- **United States** had the most COVID deaths after 4/8/2020. The top 3 countries in COVID deaths after the end date (4/30/2020) of this dataset were the United States, Brazil, and Mexico. 

---

## 📊 Tableau Public Visualizations

[Click Here!](https://public.tableau.com/app/profile/jaylen.roope/vizzes)
