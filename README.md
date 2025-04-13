# Student Information System with Event Management

This application provides a comprehensive dashboard for managing student information, including academic records, attendance, grades, and now event participation.

## Features

- **Student Details**: View and manage student information
- **Individual Student Search**: Search for specific students and view their details
- **Attendance Tracking**: Monitor student attendance
- **Grade Management**: Track student grades and performance
- **Event Information**: Record and view student participation in various events
- **Database Integration**: Store data in MySQL database with CSV fallback

## Setup Instructions

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Database Setup

1. Create a MySQL database named `StudentInformationSystem`
2. Update database connection parameters in `db_operations.py` if needed:

```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'password',  # <-- Update this with your actual password
    'database': 'StudentInformationSystem'
}
```

3. If you already have existing database tables for Student data, make sure they have the following schema structure:
   - Student table must have a `student_id` column as a primary key

### 3. Initial Data

The application will create the EventInfo table and populate it with sample data on first run. It will fall back to CSV-based data storage if the database connection fails.

### 4. Running the Application

```bash
streamlit run app.py
```

## System Design

### Database Schema

- **Student**: Stores basic student information
- **EventInfo**: Records student participation in events with the following structure:
  - event_id (Primary Key)
  - student_id (Foreign Key referencing Student.student_id)
  - event_name
  - event_date
  - event_location
  - participation_type
  - achievement

### UI Components

- The Streamlit interface provides different sections accessible via the sidebar
- The Event Information section displays all events with filtering capabilities
- The Add Event Info section allows adding new event participation records

## Fallback Mechanism

If the MySQL database connection fails, the system will automatically:
1. Create a CSV file for EventInfo data
2. Store and retrieve event information from this CSV
3. Continue to function without interruption

## Error Handling

The application includes:
- Input validation to prevent invalid data entry
- Fallback mechanisms for database connection issues
- User-friendly error messages and status indicators 