USE HospitalManagementSystem;

-- Query 1.List patients with their appointment doctor and reason.

SELECT p.FName As patient_name,
       d.FName As doctor_name,
       a.reason As reason_name
       
FROM Appointment a
JOIN Patients p ON a.patient_Id = p.patient_Id
JOIN Doctor d ON a.doct_Id = d.doct_Id;

-- Query 2.Show nurses who have assisted in bed admissions with patient names.
SELECT n.FName As nurse_name,
       p.FName AS patient_name,
       br.admission_Date
FROM bedrecords br 
JOIN nurse n ON n.nurse_Id= br.nurse_Id
JOIN patients p ON p.patient_Id= br.patient_Id;

-- Query 3. List rooms used for surgeries, the surgeon, and the surgery type.

SELECT r.room_No,
	   d.FName,
       s.surgery_Type
       
FROM Room r
JOIN doctor d ON d.dept_Id = r.dept_Id
JOIN SurgeryRecord s On s.room_no = r.room_No;

-- Query 4. List each department with the number of doctors assigned to it.
SELECT dp.dept_Name,
        COUNT(d.doct_Id) As doctor_count
FROM Doctor d
JOIN Department dp ON dp.dept_Id = d.dept_Id
GROUP BY dp.dept_Name
ORDER BY doctor_count DESC;

-- Query 5.Show patients who had an appointment and were admitted to a bed.
SELECT p.FName As patient_name,
	   a.Appointment_Date,
       bd.patient_Id
FROM patients p
JOIN Appointment a ON p.patient_Id =a.patient_Id
JOIN BedRecords bd ON bd.patient_Id = p.patient_id;

-- Query 6.We have a new patient for the Cardiology Ward and he/she wants a bed on a specific day.
-- We want to find out which beds are empty in that ward on that particular day.

SELECT b.bed_No ,
       dp.dept_Id,
       dp.dept_Name
FROM Bed b
JOIN Ward w ON b.ward_No = w.ward_No
JOIN Department dp ON dp.dept_Id = w.dept_Id
WHERE dp.dept_Name='Cardiology'
AND w.ward_No = 502
AND b.bed_No NOT IN
(SELECT br.bed_No 
FROM BedRecords br 
WHERE '2025-05-09' BETWEEN br.admission_Date AND br.discharge_Date);

-- Query 7.There is a new virus in the city and the hospital is expecting more patients than a regular
-- day. Management wants to see if they can manage those with the current staff or not.
-- They want to check upcoming appointments for each department on 4 June 2025. 

SELECT dp.dept_Name,
	   count(a.appoIntment_Id) AS total_appointments
       
FROM Appointment a
JOIN doctor d ON d.doct_Id = a.doct_Id
JOIN Department dp ON dp.dept_Id = d.dept_Id
WHERE a.appointment_Date = '2025-06-04'
GROUP BY dp.dept_Name;

-- query 8.A doctor is asking for a salary raise due to extra work in the previous month. Verify if he/
-- she deserves a raise by retrieving their total appointments, total visits, total surgeries,
-- and total shifts.
/* SELECT       a.doct_Id As doctor_id,
             d.Fname As doctor_name,
             COUNT(sft.shift_Id) AS Total_Shifts,
             COUNT(a.appoIntment_Id) AS total_appointments,
             COUNT(tsr.surgery_Id) AS Total_Surgeory,
             COUNT(medr.visit_Date) As Total_Visit
FROM Appointment a
JOIN Doctor d ON a.doct_Id = d.doct_Id
JOIN StaffShift sft ON sft.doct_Id = a.doct_Id
JOIN SurgeryRecord tsr ON tsr.patient_Id = a.patient_Id
JOIN MedicalRecord medr ON medr.patient_id = a.patient_Id
GROUP BY a.doct_Id,d.Fname;*/
SELECT     d.Fname As doctor_name,
            (    SELECT COUNT(*)
             FROM Appointment a 
             WHERE a.doct_Id = d.doct_Id AND a.appointment_Date
             BETWEEN '01-05-2025' AND '30-05-2025') AS Total_Appointment,
             
            ( SELECT COUNT(*)
             FROM MedicalRecord medrec 
             WHERE medrec.doct_Id = d.doct_Id AND medrec.visit_Date 
             BETWEEN '01-05-2025' AND '30-05-2025') AS Total_Visit,
             ( SELECT COUNT(*)
             FROM SurgeryRecord sr
             WHERE sr.patient_Id = d.patient_Id AND sr.surgery_Date
             BETWEEN '01-05-2025' AND '30-05-2025') AS Total_Surgery,
             (SELECT COUNT(*)
             FROM StaffShift sts
             WHERE sts.doct_Id = d.doct_Id AND sts.shift_Date
             BETWEEN '01-05-2025' AND '30-05-2025') AS Total_Appointment
             
             FROM Doctor d
             WHERE d.doct_id = 1002;
			
-- Query:9 The hospital is analyzing its daily revenue and wants to calculate the revenue generated
--- on 10 May 2025 (including appointment revenue, room revenue, and bed revenue).
SELECT SUM(a.payment_amount) As Appointment_Revenue,
         SUM(rr.amount) As Room_revenue,
		 SUM(bd.amount) AS Bed_revenue,
         (SUM(a.payment_amount) + SUM(rr.amount) + SUM(bd.amount)) AS Total_Revenue
         FROM Appointment a
         LEFT JOIN RoomRecords rr ON rr.admission_Date ='2025-05-10'
         LEFT JOIN BedRecords bd ON bd.admission_Date = '2025-05-10'
         WHERE 
               a.appointment_Date = '2025-05-10'; 
      
-- Query:10  The hospital decided to give some discounts to its old customers on some services.
-- Identify patients who have visited the hospital more than 4 times in the past year.

SELECT p.patient_Id As patient_id ,
	p.FName As patient_name,
    COUNT(medrec.record_Id) As visits_count 
    FROM MedicalRecord  medrec
    JOIN patients p ON medrec.patient_Id = p.patient_Id
    WHERE medrec.visit_Date <= '2025-01-01'
	GROUP BY p.patient_Id,p.FName
    HAVING COUNT(medrec.record_Id) >4
  ORDER BY visits_count  DESC;
  
  /* Query:11  Management received a report that a patient was given the wrong amount of anesthesia
during surgery. Track which staff (doctor, nurse, and helper) was present during the
surgery of patient 967 on 16 May 2024 between 11 to 12 at night */

  SELECT p.FName As patient_name,
         d.FName As Surgeon_name,
         n.FName As nurse_name,
         h.FName AS Helper_name,
         sr.surgery_Date AS surgery_date,
         sr.start_Time As Surgery_starttime,
         sr.end_Time AS surgery_endtime
	FROM SurgeryRecord sr
        JOIN patients p ON sr.patient_id = p.patient_Id
        JOIN doctor d ON d.doct_Id = sr.surgeon_Id
        JOIN Nurse n ON n.nurse_Id = sr.nurse_id
        JOin Helpers h ON h.helper_Id = sr.helper_Id
	WHERE sr.surgery_date = '2024-05-16'
		AND p.patient_id = 967
        AND sr.start_time='23:15:52'
        AND sr.end_time ='23:45:52';
        
/* Query: 12 The management wants to pay salaries for this month and wants a record of working
hours. Each staff member should have 200 hours this month. For the month of May 2025,
calculate the total working hours of each staff member (doctors, nurses, helpers) to
check total hours according to the 200 hours baseline */

SELECT d.FName As staff_name,
       d.doct_Id AS staff_Id,
       'Doctor'As staff_type,
       SUM( CASE
       WHEN 
       ss.shift_End < ss.shift_Start 
       THEN TIMESTAMPDIFF(HOUR, ss.shift_Start, ss.shift_End)+24 END)
       AS total_hours
       FROM StaffShift ss
       JOIN Doctor d ON ss.doct_Id=	d.doct_Id
       WHERE ss.shift_Date BETWEEN '2025-05-01' AND '2025-05-31'
       GROUP BY staff_Id, staff_name
       UNION ALL
	SELECT 
    n.nurse_Id AS staff_Id,
    n.FName As staff_name,
    'Nurse' As staff_type,
    SUM( CASE
       WHEN ss.shift_End<ss.shift_Start THEN TIMESTAMPDIFF(HOUR,ss.shift_Start, ss.shift_End)+24 END)
       AS total_hours
       FROM StaffShift ss
       JOIN Nurse n  ON ss.nurse_Id=n.nurse_Id
       WHERE ss.shift_Date BETWEEN '2025-05-01' AND '2025-05-31'
       GROUP BY staff_Id, staff_name
       
       UNION ALL
       SELECT 
       h.helper_Id As staff_Id,
       h.FName As staff_name,
       'Helper' As staff_type,
        SUM( CASE
       WHEN ss.shift_End<ss.shift_Start THEN TIMESTAMPDIFF(HOUR,ss.shift_Start, ss.shift_End)+24 END)
       AS total_hours
       FROM StaffShift ss
       JOIN Helpers h ON ss.helper_id=	h.helper_Id
       WHERE ss.shift_Date BETWEEN '2025-05-01' AND '2025-05-31'
       GROUP BY staff_Id, staff_name
       
       -- Query:13 List all patients who have a follow-up appointment due this week, based on their last
-- next_Visit from MedicalRecord */

SELECT
	    p.FName As Patient_name,
		p.patient_Id As patient_id,
        medrec.next_Visit As next_vist
        FROM MedicalRecord medrec
        JOIN patients p ON medrec.patient_Id = p.patient_Id
        WHERE medrec.next_Visit IS NOT NULL
        AND medrec.next_Visit BETWEEN '2025-05-03' AND '2025-05-10';
	
     /*Query 14
Find the most preferred payment method chosen by upper-class people (defined by
users of super deluxe room types).*/
SELECT
       rr.mode_of_payment AS mode_of_payment
	FROM RoomRecords rr
    JOIN Room r ON rr.room_no = r.room_No
    JOIN patients p ON p.patient_Id = rr.patient_Id
    JOIN Appointment a ON a.patient_Id=p.patient_Id
    JOIN Doctor d ON d.doct_Id =a.doct_Id
     WHERE r.room_Type='Super Deluxe Room'
     GROUP BY  rr.mode_of_payment,r.room_Type
     
     /* Query 15
The hospital wants to analyze the performance of its surgeons' surgeries. Give the
percentage of stable patients as per declared in the notes after surgery. */

SELECT sr.surgeon_Id AS surgeon_Id,
    -- Count total surgeries for the surgeon
    COUNT(sr.surgery_Id) AS total_surgeries,
    -- Count surgeries where notes mention 'stable'
    SUM(CASE WHEN sr.notes LIKE '%stable%' THEN 1 ELSE 0 END) AS stable_surgeries,
    -- Compute the accurate percentage rounded to 2 decimal places
    ROUND(
        (SUM(CASE WHEN sr.notes LIKE '%stable%' THEN 1 ELSE 0 END) * 100.0) / COUNT(sr.surgery_Id), 
        2
    ) AS stable_patient_percentage
FROM 
    SurgeryRecord sr
GROUP BY 
    sr.surgeon_Id;

