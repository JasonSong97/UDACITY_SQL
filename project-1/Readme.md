# Deforestation Exploration

## Table of Contents

 * [Project Introduction](#project-introduction)
 * [Steps to Complete](#steps-to-complete)
 * [Results](#results)

### Project Introduction

Act as a data analyst for **ForestQuery**, a non-profit organization on a mission to reduce deforestation around the world and which raises awareness about this important environmental topic.

The goal of this project is to understand which countries and regions around the world seem to have forests that have been shrinking in size and also which countries and regions have the most significant forest area, both in terms of amount and percent of total area. 


### Steps to Complete

1. Created a **View** called “**deforestation**” by joining all three tables - **forest_area**, **land_area**, and **regions** in the workspace.
2. Joined tables **forest_area** and **land_area** on both **country_code** AND **year**.
3. Joined **regions** table based on **country_code**
4. In the ‘forestation’ View, included the following:
    - **All of the columns of the origin tables**
    - A new column that provides the **percent of the land area that is designated as forest**.

### Results

`first-deforestation.sql` and `Deforestation project 1.pdf`