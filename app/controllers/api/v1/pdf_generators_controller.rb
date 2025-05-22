class Api::V1::PdfGeneratorsController < ApplicationController

    skip_before_action :authenticate_user!, only: [:pdf_generator]

      def pdf_generator
           # In a real app, this data may come from current_user

           form_data = params.dig(:pdf_generator, :formData) || {}

           personal_info = form_data[:personalInfo] || {}
           education_info = form_data[:educationInfo] || {}
           experiences = form_data[:addresses] || []
           projects = form_data[:projects] || []
           skills_info = form_data[:SkillsInfo] || {}
         
           data = {
             name: personal_info[:firstName] || "N/A",
             phone: personal_info[:phone] || "N/A",
             email: personal_info[:email] || "N/A",
             education: "#{education_info[:degree]} - #{education_info[:college_university]} #{education_info[:graduation_date]}".strip,
             work_experience: experiences.map do |exp|
               {
                 title: exp[:position] || "N/A",
                 company: exp[:company] || "N/A",
                 date: "#{exp[:duration]} years",
                 description: [exp[:responsibilities] || "N/A"]
               }
             end,
             projects: projects.map do |project|
               {
                 title: project[:project_name] || "Untitled",
                 description: project[:description] || "No description"
               }
             end,
             skills: skills_info[:technical_skills] || "N/A"
           }

           
                # data = {
                #     name: "John Doe",
                #     phone: "123-456-7890",
                #     email: "john@example.com",
                #     education: "B.Sc. Computer Science",
                #     work_experience: [
                #     {
                #         title: "Software Engineer",
                #         company: "Tech Corp",
                #         date: "2020-2024",
                #         description: ["Developed scalable backend services."]
                #     }
                #     ],
                #     projects: [
                #     {
                #         title: "AI Chatbot",
                #         description: "Built an AI-powered chatbot for customer support."
                #     }
                #     ],
                #     skills: "Ruby, Rails, JavaScript, React"
                # }
            
                pdf = ResumeMaker::Maker.new(data).generate_pdf
            
                send_data pdf,
                            filename: "resume.pdf",
                            type: "application/pdf",
                            disposition: "attachment" # Use "inline" to show in browser
      end
end