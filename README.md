# Smart Home Database Project  

**Developer**: Francesco Moretti
**University**: Universty of Pisa

## Overview  
This project focuses on designing and implementing a **database system for a smart home**, aiming to manage devices, energy usage, comfort, and security efficiently. The database is designed to handle complex data operations, analytics, and real-time interactions with smart devices, ensuring scalability and reliability.

### Key Features  
- **Comprehensive Entity-Relationship (E-R) Modeling**:  
  - Initial and restructured E-R diagrams are included for better visualization of the database structure.  
- **Database Creation**:  
  - Fully scripted in `CreazioneDB.sql` to initialize the smart home database.  
- **Functional Operations**:  
  - Operations such as CRUD (Create, Read, Update, Delete) for managing devices, energy, and user interactions are implemented in `Operazioni.sql`.  
- **Triggers for Automation**:  
  - Implemented in `Trigger.sql` to ensure automatic updates and data consistency within the database.  
- **Advanced Analytics**:  
  - Includes two key analytics modules:
    - `Analytic1_Apriori.sql`: Implements association rule mining for identifying usage patterns.  
    - `Analytic2_EffEnerg.sql`: Analyzes energy efficiency across devices and rooms.  

### Documentation  
The documentation provides detailed insights into the project, including:  
1. **Glossary**: Definitions and terminologies related to smart home systems.  
2. **Entity-Relationship Diagrams**:  
   - *Non-restructured*: Initial design.  
   - *Restructured*: Optimized for better normalization and efficiency.  
3. **Data Volume Estimation**: Outlines expected data growth to ensure scalability.  
4. **Data Operations**: Detailed analysis of database interactions and their implementation.  
5. **Logical Design and Normalization**: Ensures consistency and removes redundancies through functional dependency analysis.  
6. **Analytics Area**: Advanced queries and operations for actionable insights.  

### 📂 Files Included  
- **`CreazioneDB.sql`**: Script to create the database structure.  
- **`Operazioni.sql`**: Defines database operations such as CRUD functionalities.  
- **`Trigger.sql`**: Contains triggers for automating database updates.  
- **`Analytic1_Apriori.sql`**: Implements the Apriori algorithm for usage pattern analysis.  
- **`Analytic2_EffEnerg.sql`**: Performs energy efficiency analysis.  
- **`Schema E-R (Non Ristrutturato).pdf`**: Initial E-R diagram.  
- **`Schema E-R (Ristrutturato).pdf`**: Optimized E-R diagram.  
- **`Documentazione.pdf`**: Full project documentation with detailed descriptions and diagrams.  

### 🚀 How to Use  
1. Run `CreazioneDB.sql` to create the database.  
2. Populate the database with sample data (if any).  
3. Execute `Operazioni.sql` to test the database functionalities.  
4. Use `Trigger.sql` to enable automatic updates and consistency checks.  
5. Perform analytics using `Analytic1_Apriori.sql` and `Analytic2_EffEnerg.sql`.  

### 🔗 Future Improvements  
- Expand the analytics area to include predictive models for energy consumption and device failure detection.  
- Integrate real-time data inputs from IoT devices.  
- Optimize queries for larger datasets.  
