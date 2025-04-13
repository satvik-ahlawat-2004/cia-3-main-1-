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
    
    # Load additional data files if they exist
    additional_data = {}
    data_files = {
        "personal_details": "Personal_Details.csv",
        "address": "Address.csv",
        "parent_info": "Parent_Information.csv",
        "guardian_info": "Guardian_Information.csv",
        "family_income": "Family_Income.csv",
        "course": "Course.csv",
        "enrollment": "Enrollment.csv"
    }
    
    for key, filename in data_files.items():
        if os.path.exists(filename):
            additional_data[key] = pd.read_csv(filename)

    # Sidebar Navigation
    section = st.sidebar.radio("📁 Select Section", ["Home", "Student Details", "Attendance Overview", "Grades Overview"])

    if section == "Home":
        st.subheader("👋 Welcome to the Student Dashboard")
        st.write("Select a student to view their complete profile or use the sidebar to navigate through different data views.")
        
        # Student selector
        student_ids = student_df['student_id'].tolist()
        selected_student = st.selectbox("🔍 Select Student ID", student_ids)
        
        if st.button("View Student Profile"):
            st.subheader(f"📝 Profile for Student ID: {selected_student}")
            
            # Create columns for better layout
            col1, col2 = st.columns(2)
            
            # Student basic details
            with col1:
                st.markdown("### 👤 Basic Information")
                student_info = student_df[student_df['student_id'] == selected_student]
                st.dataframe(student_info)
                
                # Personal details if available
                if "personal_details" in additional_data:
                    personal_info = additional_data["personal_details"][additional_data["personal_details"]['student_id'] == selected_student]
                    if not personal_info.empty:
                        st.markdown("### 📋 Personal Details")
                        st.dataframe(personal_info)
                        
                        # Get address through personal details (which has address_id)
                        if "address" in additional_data and 'address_id' in personal_info.columns:
                            address_id = personal_info['address_id'].iloc[0]
                            address_info = additional_data["address"][additional_data["address"]['address_id'] == address_id]
                            if not address_info.empty:
                                st.markdown("### 🏠 Address")
                                st.dataframe(address_info)
                    else:
                        st.info("No personal details available for this student")
            
            # Academic details
            with col2:
                # Grades
                st.markdown("### 📊 Academic Performance")
                student_grades = grade_df[grade_df['student_id'] == selected_student]
                if not student_grades.empty:
                    st.dataframe(student_grades)
                    
                    # Visualize marks
                    st.markdown("#### 📈 Marks Visualization")
                    st.bar_chart(student_grades[['cia1', 'cia2', 'cia3', 'cia4', 'total_marks']].iloc[0])
                else:
                    st.info("No grade data available for this student")
                
                # Attendance
                st.markdown("### 🗓️ Attendance Record")
                student_attendance = attendance_df[attendance_df['student_id'] == selected_student]
                if not student_attendance.empty:
                    attendance_status = student_attendance['status'].value_counts()
                    st.write(f"Present: {attendance_status.get('present', 0)}, Absent: {attendance_status.get('absent', 0)}")
                    st.dataframe(student_attendance)
                else:
                    st.info("No attendance data available for this student")
            
            # Additional information in full width
            st.markdown("### 👪 Family Information")
            col3, col4 = st.columns(2)
            
            with col3:
                # Parent information
                if "parent_info" in additional_data:
                    # Get parent information through personal details (which has parent_id)
                    if "personal_details" in additional_data and not personal_info.empty and 'parent_id' in personal_info.columns:
                        parent_id = personal_info['parent_id'].iloc[0]
                        parent_info = additional_data["parent_info"][additional_data["parent_info"]['parent_id'] == parent_id]
                        if not parent_info.empty:
                            st.markdown("#### 👨‍👩‍👧 Parents")
                            st.dataframe(parent_info)
            
            with col4:
                # Guardian information
                if "guardian_info" in additional_data:
                    # Get guardian info through parent info which has guardian_id
                    if "parent_info" in additional_data and "personal_details" in additional_data and not personal_info.empty:
                        parent_id = personal_info['parent_id'].iloc[0]
                        parent_info = additional_data["parent_info"][additional_data["parent_info"]['parent_id'] == parent_id]
                        if not parent_info.empty and 'guardian_id' in parent_info.columns:
                            guardian_id = parent_info['guardian_id'].iloc[0]
                            guardian_info = additional_data["guardian_info"][additional_data["guardian_info"]['guardian_id'] == guardian_id]
                            if not guardian_info.empty:
                                st.markdown("#### 👤 Guardian")
                                st.dataframe(guardian_info)
            
            # Enrollment and Course Information
            st.markdown("### 📚 Academic Enrollment")
            if "enrollment" in additional_data:
                enrollment_info = additional_data["enrollment"][additional_data["enrollment"]['student_id'] == selected_student]
                if not enrollment_info.empty:
                    st.dataframe(enrollment_info)
                    
                    # Join with course data
                    if "course" in additional_data and 'course_id' in enrollment_info.columns:
                        course_id = enrollment_info['course_id'].iloc[0]
                        course_info = additional_data["course"][additional_data["course"]['course_id'] == course_id]
                        if not course_info.empty:
                            st.markdown("#### 📕 Course Details")
                            st.dataframe(course_info)

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