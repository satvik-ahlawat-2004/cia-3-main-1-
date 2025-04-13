import streamlit as st
import pandas as pd
import os
from PIL import Image
from datetime import datetime
from dateutil.parser import parse

# Must be the first Streamlit command
st.set_page_config(page_title="🎓 Student Support System", layout="wide")

# Initialize EventInfo.csv if it doesn't exist
def initialize_event_info():
    if not os.path.exists("EventInfo.csv"):
        event_info_df = pd.DataFrame(columns=[
            "event_id", "student_id", "event_name", "event_date",
            "event_location", "participation_type", "achievement"
        ])
        event_info_df.to_csv("EventInfo.csv", index=False)

initialize_event_info()

# Display the main title with custom styling
st.markdown("""
    <h1 style='text-align: center; color: #1f77b4;'>
        🎓 Market ke Maharathi
    </h1>
    <h2 style='text-align: center; color: #2c3e50;'>
        Student Support System Dashboard
    </h2>
""", unsafe_allow_html=True)

# Display image if it exists
image_path = "image/dashboard_image.jpg"
if os.path.exists(image_path):
    image = Image.open(image_path)
    st.image(image, use_container_width=True)
else:
    st.info("Please add your dashboard image to the 'image' folder as 'dashboard_image.jpg'")

# Check for required files
if all(os.path.exists(f) for f in ["Attendance.csv", "Grade.csv", "Student_ID_Table.csv"]):
    # Load data
    attendance_df = pd.read_csv("Attendance.csv")
    grade_df = pd.read_csv("Grade.csv")
    student_df = pd.read_csv("Student_ID_Table.csv")
    
    # Load EventInfo from CSV
    if os.path.exists("EventInfo.csv"):
        event_info_df = pd.read_csv("EventInfo.csv")
    else:
        event_info_df = pd.DataFrame()

    # Sidebar Navigation
    section = st.sidebar.radio("📁 Select Section", 
                             ["Home", "Student Details", "Individual Student Search", 
                              "Attendance Overview", "Grades Overview", 
                              "Event Information", "➕ Add Event Info"])

    if section == "Home":
        st.subheader("👋 Welcome to the Student Dashboard")
        st.write("Use the sidebar to navigate through different student data views.")

    elif section == "Student Details":
        st.subheader("📋 Student Details")
        st.dataframe(student_df)

    elif section == "Individual Student Search":
        st.subheader("🔍 Search Individual Student")
        
        # Get list of student IDs
        student_ids = student_df['student_id'].unique()
        
        # Create a selectbox for student IDs
        selected_student = st.selectbox("Select Student ID", student_ids)
        
        if st.button("Show Details"):
            # Get student details
            student_info = student_df[student_df['student_id'] == selected_student].iloc[0]
            attendance_info = attendance_df[attendance_df['student_id'] == selected_student]
            grade_info = grade_df[grade_df['student_id'] == selected_student]
            
            # Get student events
            if not event_info_df.empty:
                student_events = event_info_df[event_info_df['student_id'] == selected_student]
            else:
                student_events = pd.DataFrame()
            
            # Create three columns
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.markdown("### 👤 Student Information")
                st.write(f"**Student ID:** {student_info['student_id']}")
                st.write(f"**Personal Details:** {student_info['personal_details']}")
                st.write(f"**Academic Details:** {student_info['academic_details']}")
            
            with col2:
                st.markdown("### 📊 Attendance Summary")
                attendance_count = attendance_info['status'].value_counts()
                st.write("**Present:** ", attendance_count.get('Present', 0))
                st.write("**Absent:** ", attendance_count.get('Absent', 0))
                if len(attendance_info) > 0:
                    attendance_percentage = (attendance_count.get('Present', 0) / len(attendance_info)) * 100
                    st.write(f"**Attendance Percentage:** {attendance_percentage:.2f}%")
            
            with col3:
                st.markdown("### 📈 Grade Information")
                if not grade_info.empty:
                    latest_grade = grade_info.iloc[0]
                    st.write(f"**Total Marks:** {latest_grade['total_marks']}")
                    st.write(f"**Status:** {latest_grade['status']}")
                    st.write(f"**Remarks:** {latest_grade['remark']}")
            
            # Show detailed attendance record
            st.markdown("### 📅 Detailed Attendance Record")
            st.dataframe(attendance_info)
            
            # Show student events
            if not student_events.empty:
                st.markdown("### 🎭 Student Event Participation")
                st.dataframe(student_events)

    elif section == "Attendance Overview":
        st.subheader("📊 Attendance Summary")
        attendance_summary = attendance_df['status'].value_counts()
        st.write("✅ Overall Attendance Count")
        st.bar_chart(attendance_summary)

        # Calculate attendance percentage by student
        attendance_by_student = attendance_df.groupby('student_id')['status'].apply(
            lambda x: (x == 'Present').mean() * 100
        ).reset_index()
        attendance_by_student.columns = ['Student ID', 'Attendance %']
        
        st.subheader("📊 Attendance Percentage by Student")
        st.bar_chart(attendance_by_student.set_index('Student ID'))

        st.subheader("📆 Full Attendance Table")
        st.dataframe(attendance_df)

    elif section == "Grades Overview":
        st.subheader("📈 Total Marks per Student")
        chart_data = grade_df[['student_id', 'total_marks']]
        st.bar_chart(chart_data.set_index('student_id'))

        st.markdown("🧮 *Pass/Fail Count*")
        status_chart = grade_df['status'].value_counts()
        st.write(status_chart)

        # Calculate average marks
        avg_marks = grade_df.groupby('student_id')['total_marks'].mean().reset_index()
        st.subheader("📊 Average Marks by Student")
        st.bar_chart(avg_marks.set_index('student_id'))

        st.subheader("📄 Full Grade Sheet")
        st.dataframe(grade_df)
        
    elif section == "Event Information":
        st.subheader("🎭 Student Event Participation Records")
        
        # Check if we have event info data
        if not event_info_df.empty:
            # Display event information with filtering options
            st.markdown("### 🔍 Filter Events")
            
            # Get unique student IDs and event names for filtering
            unique_students = sorted(event_info_df['student_id'].unique())
            unique_events = sorted(event_info_df['event_name'].unique())
            
            # Create filters
            col1, col2 = st.columns(2)
            
            with col1:
                selected_student = st.selectbox("Filter by Student ID", ["All"] + list(unique_students))
            
            with col2:
                selected_event = st.selectbox("Filter by Event Name", ["All"] + list(unique_events))
            
            # Apply filters
            filtered_df = event_info_df.copy()
            
            if selected_student != "All":
                filtered_df = filtered_df[filtered_df['student_id'] == selected_student]
            
            if selected_event != "All":
                filtered_df = filtered_df[filtered_df['event_name'] == selected_event]
            
            # Display filtered data
            st.dataframe(filtered_df)
            
            # Display participation metrics
            st.markdown("### 📊 Event Participation Metrics")
            
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric("Total Events", len(event_info_df['event_name'].unique()))
            
            with col2:
                st.metric("Total Student Participants", len(event_info_df['student_id'].unique()))
            
            with col3:
                achievements = event_info_df['achievement'].dropna()
                st.metric("Total Achievements", len(achievements))
        else:
            st.info("No event information available. Add events using the '➕ Add Event Info' section.")
        
    elif section == "➕ Add Event Info":
        st.subheader("➕ Add New Event Information")
        
        # Create form for adding new event info
        with st.form("add_event_form"):
            # Get list of student IDs
            student_ids = student_df['student_id'].unique()
            
            # Form fields
            student_id = st.selectbox("Student ID *", options=student_ids)
            event_name = st.text_input("Event Name *")
            event_date = st.date_input("Event Date *", datetime.today())
            event_location = st.text_input("Event Location")
            participation_type = st.selectbox(
                "Participation Type", 
                ["Participant", "Organizer", "Volunteer", "Speaker", "Presenter", "Attendee", "Other"]
            )
            achievement = st.text_input("Achievement (if any)")
            
            # Submit button
            submit_button = st.form_submit_button("Add Event")
            
            if submit_button:
                if not event_name:
                    st.error("Event Name is required")
                else:
                    try:
                        # Read existing events
                        if os.path.exists("EventInfo.csv"):
                            event_info_df = pd.read_csv("EventInfo.csv")
                            new_event_id = event_info_df['event_id'].max() + 1 if not event_info_df.empty else 1
                        else:
                            event_info_df = pd.DataFrame()
                            new_event_id = 1
                        
                        # Create new event record
                        new_event = {
                            "event_id": new_event_id,
                            "student_id": student_id,
                            "event_name": event_name,
                            "event_date": event_date.strftime("%Y-%m-%d"),
                            "event_location": event_location,
                            "participation_type": participation_type,
                            "achievement": achievement if achievement else None
                        }
                        
                        # Append to dataframe and save
                        event_info_df = pd.concat([event_info_df, pd.DataFrame([new_event])], ignore_index=True)
                        event_info_df.to_csv("EventInfo.csv", index=False)
                        
                        st.success(f"Event added successfully for student {student_id}")
                    except Exception as e:
                        st.error(f"Failed to add event: {e}")

else:
    st.error("🚨 One or more required CSV files (Attendance.csv, Grade.csv, Student_ID_Table.csv) not found in the current directory.") 