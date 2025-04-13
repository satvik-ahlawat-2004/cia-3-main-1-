import mysql.connector
from mysql.connector import Error
import pandas as pd
import os
import streamlit as st

# Database connection configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'password',  # Replace with actual password
    'database': 'StudentInformationSystem'
}

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            return connection
    except Error as e:
        st.error(f"Error connecting to MySQL database: {e}")
        return None

def close_connection(connection, cursor=None):
    """Close database connection and cursor"""
    if cursor:
        cursor.close()
    if connection and connection.is_connected():
        connection.close()

def initialize_database():
    """Initialize database tables if they don't exist"""
    connection = get_db_connection()
    if not connection:
        return False
    
    cursor = connection.cursor()
    try:
        # Read SQL file and execute
        with open('create_event_info_table.sql', 'r') as file:
            sql_commands = file.read()
            
        # Split commands by semicolon and execute each
        for command in sql_commands.split(';'):
            if command.strip():
                cursor.execute(command)
        
        connection.commit()
        return True
    except Error as e:
        st.error(f"Error initializing database: {e}")
        return False
    finally:
        close_connection(connection, cursor)

def student_exists(student_id):
    """Check if a student exists in the database"""
    # For CSV-based approach
    if os.path.exists("Student.csv"):
        student_df = pd.read_csv("Student.csv")
        return student_id in student_df['student_id'].values
    
    # For SQL-based approach
    connection = get_db_connection()
    if not connection:
        return False
    
    cursor = connection.cursor()
    try:
        cursor.execute("SELECT 1 FROM Student WHERE student_id = %s", (student_id,))
        result = cursor.fetchone()
        return result is not None
    except Error as e:
        st.error(f"Error checking if student exists: {e}")
        return False
    finally:
        close_connection(connection, cursor)

def add_event_info(student_id, event_name, event_date, event_location=None, 
                  participation_type=None, achievement=None):
    """Add a new event information record to the database"""
    # Validate student_id
    if not student_exists(student_id):
        return False, "Student ID does not exist"
    
    connection = get_db_connection()
    if not connection:
        return False, "Database connection failed"
    
    cursor = connection.cursor()
    try:
        # Insert new event info
        insert_query = """
        INSERT INTO EventInfo 
        (student_id, event_name, event_date, event_location, participation_type, achievement) 
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor.execute(insert_query, (
            student_id, event_name, event_date, event_location, 
            participation_type, achievement
        ))
        
        connection.commit()
        return True, f"Event information added successfully for student {student_id}"
    except Error as e:
        connection.rollback()
        return False, f"Error adding event info: {e}"
    finally:
        close_connection(connection, cursor)

def get_all_events():
    """Get all events from the database"""
    connection = get_db_connection()
    if not connection:
        return pd.DataFrame()
    
    try:
        query = """
        SELECT e.event_id, e.student_id, e.event_name, e.event_date, 
               e.event_location, e.participation_type, e.achievement
        FROM EventInfo e
        JOIN Student s ON e.student_id = s.student_id
        ORDER BY e.event_date DESC
        """
        return pd.read_sql(query, connection)
    except Error as e:
        st.error(f"Error retrieving events: {e}")
        return pd.DataFrame()
    finally:
        close_connection(connection)

def get_student_events(student_id):
    """Get all events for a specific student"""
    connection = get_db_connection()
    if not connection:
        return pd.DataFrame()
    
    try:
        query = """
        SELECT event_id, event_name, event_date, event_location, 
               participation_type, achievement
        FROM EventInfo
        WHERE student_id = %s
        ORDER BY event_date DESC
        """
        return pd.read_sql(query, connection, params=(student_id,))
    except Error as e:
        st.error(f"Error retrieving student events: {e}")
        return pd.DataFrame()
    finally:
        close_connection(connection)

def create_dummy_event_info_csv():
    """Create a CSV file with dummy event data if SQL connection fails"""
    if not os.path.exists("EventInfo.csv"):
        # Create student IDs from existing Student.csv
        student_ids = pd.read_csv("Student.csv")["student_id"].tolist()
        
        # Create a DataFrame for EventInfo
        event_info_data = []
        event_id = 1
        
        # Event templates
        events = [
            "Annual Tech Symposium", "Cultural Fest", "Hackathon", "Sports Meet",
            "Debate Competition", "Science Exhibition", "Workshop on AI", "Coding Contest",
            "Alumni Meet", "Industrial Visit"
        ]
        
        # Create 50 dummy records
        for i in range(50):
            student_id = student_ids[i % len(student_ids)]
            event_name = events[i % len(events)] + f" {2023 + (i // 10)}"
            event_info_data.append({
                "event_id": event_id,
                "student_id": student_id,
                "event_name": event_name,
                "event_date": f"2023-{(i % 12) + 1:02d}-{(i % 28) + 1:02d}",
                "event_location": "Campus",
                "participation_type": "Participant",
                "achievement": "Completed" if i % 3 == 0 else None
            })
            event_id += 1
        
        # Create DataFrame and save to CSV
        event_info_df = pd.DataFrame(event_info_data)
        event_info_df.to_csv("EventInfo.csv", index=False)
        return True
    return False 