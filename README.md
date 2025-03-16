# Dairy Delivery Optimization: TSP & VRPTW Models

## 📌 Project Overview
This repository contains **GAMS models** for solving two classic **logistics and optimization problems**:
1. **Traveling Salesman Problem with Time Windows (TSP-TW)**
2. **Vehicle Routing Problem with Time Windows (VRPTW)**

These models are implemented in **GAMS (General Algebraic Modeling System)** and solve real-world logistics challenges using mathematical programming techniques.

---

## 📝 Problem Descriptions

### **1️⃣ Traveling Salesman Problem with Time Windows (TSP-TW)**
A farmer delivers self-produced dairy products to **40 customers**. Each customer has a predefined **time window** within which they must receive their delivery. The objective is to **minimize the total travel distance** while ensuring all time constraints are met.

#### **Model Outputs**:
- **Optimal delivery route**
- **Total distance traveled**
- **Arrival times at each customer**
- **Customer visit sequence**

---

### **2️⃣ Vehicle Routing Problem with Time Windows (VRPTW)**
The farmer expands his fleet to **3 vehicles**, each serving a maximum of **8 customers**. Due to equipment failure, only **20 customers** can be served. The problem is extended to a VRPTW, where each vehicle follows an optimized route while considering time constraints.

#### **Model Outputs**:
- **Optimal routes for each vehicle**
- **Assignment of customers to vehicles**
- **Total travel distance for all vehicles**

---

## 🛠️ Implementation Details
- **Input Data**: Provided in `Data1.xlsx` & `Data2.xlsx`
- **Constraints Modeled**:
  - Time window constraints
  - Vehicle capacity constraints
  - Flow preservation conditions
  - TSP-to-VRPTW transformation
- **Generated Files**:
  - `.gms` (GAMS model files)
  - `.lst` (Listing files with results)
  - `.txt` (Solution output files)

---

## 🚀 How to Run the Models
1. **Install GAMS**: Ensure GAMS is installed on your system.
2. **Clone the repository**:
   ```sh
   git clone https://github.com/your-username/Dairy-Delivery-Optimization.git
   cd Dairy-Delivery-Optimization
   ```
3. **Run the GAMS models**:
   - For **TSP-TW**:
     ```sh
     gams TSP_Model.gms
     ```
   - For **VRPTW**:
     ```sh
     gams VRPTW_Model.gms
     ```
4. **Check the results** in the generated `.lst` and `.txt` files.

