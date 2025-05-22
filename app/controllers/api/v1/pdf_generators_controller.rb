class Api::V1::PdfGeneratorsController < ApplicationController

      def pdf_generator
           # In a real app, this data may come from current_user
                data = {
                    name: "John Doe",
                    phone: "123-456-7890",
                    email: "john@example.com",
                    education: "B.Sc. Computer Science",
                    work_experience: [
                    {
                        title: "Software Engineer",
                        company: "Tech Corp",
                        date: "2020-2024",
                        description: ["Developed scalable backend services."]
                    }
                    ],
                    projects: [
                    {
                        title: "AI Chatbot",
                        description: "Built an AI-powered chatbot for customer support."
                    }
                    ],
                    skills: "Ruby, Rails, JavaScript, React"
                }
            
                pdf = ResumeMaker::Maker.new(data).generate_pdf
            
                send_data pdf,
                            filename: "resume.pdf",
                            type: "application/pdf",
                            disposition: "attachment" # Use "inline" to show in browser
      end
end