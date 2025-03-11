require 'csv'
require 'bcrypt'

namespace :import do
  desc "Import data from a CSV file"
  task courses: :environment do
    file_path = "Courses_db.csv"

    CSV.foreach(file_path, headers: true).each_with_index do |row, index|
      break if index > 8
      ActiveRecord::Base.transaction do
        # Create a default password_digest for imported users
        default_password = BCrypt::Password.create('password123')
        # Find or create owner user
        owner = User.find_or_initialize_by(id: row["Record Id"]) do |user|
          user.email_address = (row['Email'] || row['Secondary Email'] || "user_#{row['Course Owner.id']}@example.com")
          user.email_opt_out = row['Email Opt Out'] == 'true'
          user.password_digest = default_password
        end
        owner.save(validate: false) if owner.new_record?

        # Find or create creator and modifier users
        creator = User.find_or_initialize_by(id: row["Created By.id"]) do |user|
          user.email_address = "user_#{row['Created By.id']}@example.com"
          user.password_digest = default_password
        end
        creator.save(validate: false) if creator.new_record?
        
        modifier = User.find_or_initialize_by(id: row["Modified By.id"]) do |user|
          user.email_address = "user_#{row['Modified By.id']}@example.com"
          user.password_digest = default_password
        end
        modifier.save(validate: false) if modifier.new_record?

        # Find or create institution with a name
        institution = Institution.find_or_initialize_by(id: row['Institute Name.id']) do |inst|
          inst.name = row['Institute Name'] || "Institution_#{row['Institute Name.id']}"
        end
        institution.save(validate: false)
        department = Department.find_or_create_by(name: row['Department'])
        tag = Tag.find_or_create_by(tag_name: row['Tag'])
        currency = Currency.find_or_create_by(currency_code: row['Currency'],exchange_rate: row['Exchange Rate'])
        # Create Course record
        course = Course.new(
          record_id: row['Record Id'],
          name: row['Course Name'],
          owner_id: owner.id,
          creator_id: creator.id,
          modifier_id: modifier.id,
          created_at: row['Created Time'],
          updated_at: row['Modified Time'],
          last_activity_time: row['Last Activity Time'],
          layout_id: row['Layout.id'],
          user_modified_time: row['User Modified Time'],
          system_modified_time: row['System Modified Time'],
          user_related_activity_time: row['User Related Activity Time'],
          system_related_activity_time: row['System Related Activity Time'],
          record_approval_status: row['Record Approval Status'],
          is_record_duplicate: row['Is Record Duplicate'] == 'true',
          course_image: row['Course Image'],
          course_weblink: row['Course Weblink'],
          level_of_course: row['Level of Course'],
          course_code: row['Course Code'],
          course_duration: row['Course Duration (in months)'],
          institution_id: institution.id,
          department_id: department.id,
          title: row['Course Title'],
          tuition_fee_international: row['Tuition Fee (International - Per Annum)'],
          application_fee: row['Application Fee'],
          tuition_fee_local: row['Tuition Fee (Local - Per Annum)'],
          intake: row['Intake'],
          delivery_method: row['Delivery Method'],
          internship_period: row['Internship Period (in weeks)'],
          delete_record: row['Should we delete this record'] == 'true',
          locked: row['Locked'] == 'true',
          record_status: row['Record Status'],
          module_subjects: row["Modules / Subjects Taught"]&.gsub!("\n", " ")
        )
        course.save(validate: false)
        course_tag = CourseTag.new(course: course, tag: tag)
        course_tag.save(validate: false)
        # Create CourseRequirement record
        requirement = CourseRequirement.new(
          course: course,
          selt_waived_off: row['Can SELT be waived off'] == 'true',
          type_of_ielts_required: row['Type of IELTS required'],
          previous_degree_subject: row['Previous degree or diploma in which subject'],
          similar_subjects_tags: row['Similar Subjects (Tags)'],
          unsubscribed_mode: row['Unsubscribed Mode'],
          unsubscribed_time: row['Unsubscribed Time'],
          cv_mandatory: row['Is CV Mandatory'] == 'true',
          lor_mandatory: row['Is LOR Mandatory'] == 'true',
          sop_mandatory: row['Is SOP Mandatory'] == 'true',
          color_scan_mandatory: row['Is Colour Scan Copy of Documents Mandatory'] == 'true',
          international_students_allowed: row['Availability for International Students'],
          interview_mandatory: row['Is Interview Mandatory'] == 'true',
          sealed_transcript_mandatory: row['Is Sealed Transcript Mandatory'] == 'true',
          attested_docs_mandatory: row['Are Attested Documents Mandatory'] == 'true',
          change_of_agent_allowed: row['Is Change of Agent Allowed'] == 'true',
          agent_appointment_allowed: row['Is Appointment of Agent Allowed'] == 'true',
          lateral_entry_possible: row['Possibility of Lateral Entry'] == 'true',
          initial_fee_visa_letter: row['Initial Fee Required for visa letter'],
          min_work_experience_years: row['Minimum Work Experience Required (in years)'],
          gap_after_degree: row['Gap Acceptable after degree (no of yrs)'],
          gap_after_class_12_years: row['Gap Acceptable after Class 12 (no of years)'],
          doubts_or_observations: row['Please mention your doubts or observations here'],
          grad_validity_moi_months: row['Validity of Graduation No of Months for MOI'],
          moi_tier1_accepted: row['Tier 1 University degree is accepted for MOI'] == 'true',
          moi_tier2_accepted: row['Tier 2 University degree is accepted for MOI'] == 'true',
          moi_tier3_accepted: row['Tier 3 University degree is accepted for MOI'] == 'true',
          moi_any_university_accepted: row['Any University degree is accepted for MOI'] == 'true',
          work_experience_factor: row['Work Experience Factor'],
          previous_academic_grades: row['Previous Academic Grades'],
          all_rounder_capabilities: row['All Rounder Capabilities'],
          admission_process_notes: row['Any other information related to admission process'],
          weightage_class_10: row['Weightage for Class 10'],
          weightage_class_12: row['Weightage for Class 12 Grades'],
          weightage_grad_score: row['Weightage for Grad Score'],
          gmat_score: row['GMAT Score'],
          gre_score: row['GRE Score'],
          sat_score: row['SAT Score'] 
        )
        requirement.save(validate: false)

        # Create test requirements for standardized tests
        standardized_tests = {
          'PTE' => ['Reading', 'Writing', 'Speaking', 'Listening', 'Overall'],
          'IELTS' => ['Reading', 'Writing', 'Speaking', 'Listening', 'Overall'],
          'TOEFL' => ['Reading', 'Writing', 'Speaking', 'Listening', 'Overall']
        }

        standardized_tests.each do |test_name, exam_types|
          exam_types.each do |exam_type|
            test = StandardizedTest.find_by(test_name: test_name, exam_type: exam_type)
            next unless test

            test_req = CourseTestRequirement.new(
              course: course,
              standardized_test: test,
              min_score: row["#{test_name} #{exam_type}"]
            )
            test_req.save(validate: false)
          end
        end

        # Create subject requirements for different boards
        academic_boards = {
          'Class 12' => [
            'CBSE / ISC', 'NIOS', 'IB', 'Gujarat Board', 'Karnataka Board',
            'Punjab State Board', 'Telangana Board', 'Maharashtra Board',
            'Andhra Pradesh Board', 'West Bengal Board', 'Other State Boards'
          ]
        }

        academic_boards.each do |level_name, board_names|
          board_names.each do |board_name|
            academic_level = AcademicLevel.find_by(level_name: level_name)
            education_board = EducationBoard.find_by(board_name: board_name)
            subject = Subject.find_by(
              academic_level: academic_level,
              education_board: education_board,
              name: 'English'
            )

            next unless subject

            subject_req = CourseSubjectRequirement.new(
              course: course,
              subject: subject,
              min_score: row["Year #{level_name} English (#{board_name})"]
            )
            subject_req.save(validate: false)
          end
        end

        # Create remarks
        remark = Remark.new(
          course: course,
          user_id: owner.id,
          remarks_course_desc: row['Remarks (related to Course Description)'],
          remarks_selt: row['Remarks (related to SELT)'],
          remarks_entry_req: row['Remarks Related to Entry Requirements (if any)']
        )
        remark.save(validate: false)

        puts "Successfully imported course: #{course.name}"
      end
      rescue StandardError => e
        puts "Error importing row: #{e.message}"
        puts e.backtrace
        raise
      end
  end
end
