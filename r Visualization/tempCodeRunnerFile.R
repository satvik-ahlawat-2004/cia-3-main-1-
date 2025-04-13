import streamlit as st
import pandas as pd
import os

st.set_page_config(page_title="🎓 Student Support System", layout="wide")

st.title("🎓 Student Support System Dashboard")

# Check for required files
if all(os.path.exists(f) for f in ["Attendance.csv", "Grade.csv", "Student_ID_Table.csv"]):
    # Load data
    attendance_df = pd.read_csv("Attendance.csv")
    grade_df = pd.read_csv("Grade.csv")
    student_df = pd.read_csv("Student_ID_Table.csv")

    # Sidebar Navigation
    section = st.sidebar.radio("📁 Select Section", ["Home", "Student Details", "Attendance Overview", "Grades Overview"])

    if section == "Home":
        st.subheader("👋 Welcome to the Student Dashboard")
        st.write("Use the sidebar to navigate through different student data views.")

    elif section == "Student Details":
        st.subheader("📋 Student Details")
        st.dataframe(student_df)

    elif section == "Attendance Overview":
        st.subheader("📊 Attendance Summary")
        attendance_summary = attendance_df['status'].value_counts()
        st.write("✅ Overall Attendance Count")
        st.bar_chart(attendance_summary)

        st.subheader("📆 Full Attendance Table")
        st.dataframe(attendance_df)

    elif section == "Grades Overview":
        st.subheader("📈 Total Marks per Student")
        chart_data = grade_df[['student_id', 'total_marks']]
        st.bar_chart(chart_data.set_index('student_id'))

        st.markdown("🧮 *Pass/Fail Count*")
        status_chart = grade_df['status'].value_counts()
        st.write(status_chart)

        st.subheader("📄 Full Grade Sheet")
        st.dataframe(grade_df)

else:
    st.error("🚨 One or more required CSV files (Attendance.csv, Grade.csv, Student_ID_Table.csv) not found in the current directory.")