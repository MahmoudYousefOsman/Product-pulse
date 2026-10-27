# 📦 Enterprise Inventory & Sales Management Engine

A robust, cross-platform ERP and inventory management solution engineered for seamless product tracking, sales workflows, and real-time financial data consistency across Android, iOS, and Web.

---

## 🏗️ Architecture & Core Principles

The application is built adhering to **Clean Architecture** principles to enforce a strict separation of concerns, high testability, and long-term maintainability:

- **Domain Layer:** Business logic, entities, and use cases completely decoupled from frameworks.
- **Data Layer:** Repository implementations, data sources (Supabase REST/Realtime), and caching.
- **Presentation Layer:** State management handling clean UI/UX rendering and smooth workflow transitions.

---

## 🔥 Key Technical Highlights

* **Automated Sales & Invoicing Engine:** Dynamic calculation of taxes, discounts, and line-item totals with real-time invoice generation.
* **Inventory Movement Tracking:** Real-time inbound/outbound flow control to maintain inventory integrity.
* **Relational Data Modeling:** Optimized PostgreSQL schema (via Supabase) handling complex relations between Products, Orders, Customers, and Suppliers.
* **Enterprise Security:** JWT-based session handling and encrypted credential persistent storage via `Flutter Secure Storage`.
* **Optimized Search & Filtering:** High-performance filtering mechanism designed for large product and client catalogs.

---

## 🛠️ Tech Stack & Infrastructure

- **Frontend:** Flutter (Dart) — Cross-Platform (Android, iOS, Web)
- **Backend & Database:** Supabase (PostgreSQL, Realtime Subscriptions, Auth)
- **Security:** Flutter Secure Storage (Encrypted Key-Value Store)
- **State Management:** Provider / BLoC *(اختر ما يناسب مشروعك)*

---

## 🎯 Engineering Challenges & Solutions

* **Data Consistency:** Managed concurrent inventory deductions during high-frequency sales transactions using transactional operations on PostgreSQL.
* **State & Performance:** Optimized list rendering and asynchronous image caching to maintain 60 FPS across native and web builds.

---

## 📸 App Screenshots

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/5e93bf8b-c6b3-4793-b06d-a1db40365b0a" width="280" alt="Screen 1" />
      <br />
      <sub><b>Dashboard / Overview</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/12097811-c7e5-474a-bb09-ebd957cf5bf0" width="280" alt="Screen 2" />
      <br />
      <sub><b>Product Management</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/be3f158a-47dc-48d9-b2ab-99e32f9b8dec" width="280" alt="Screen 3" />
      <br />
      <sub><b>Sales & Invoicing</b></sub>
    </td>
  </tr>
</table>

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps:

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YOUR_USERNAME/YOUR_REPOSITORY_NAME.git](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY_NAME.git)
