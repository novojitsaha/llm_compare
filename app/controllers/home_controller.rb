class HomeController < ApplicationController
    before_action :load_models, only: %i[index compare_models]
  
    # GET /
    def index
      # just renders the form
    end
  
    # POST /compare_models
    def compare_models
      prompt = params.require(:prompt)
      m1, m2 = params.require(:model1_id), params.require(:model2_id)
  
      @output1 = fetch_openai_response(m1, prompt)
      @output2 = fetch_openai_response(m2, prompt)
  
      render :index
    end
  
    private
  
    def load_models
      @models = %w[
        gpt-3.5-turbo
        gpt-4
      ]
    end
  
    def openai_client
      @openai_client ||= OpenAI::Client.new(
        api_key: ENV.fetch("OPENAI_API_KEY")
      )
    end
  
    def fetch_openai_response(model, prompt)
        if model.start_with?("gpt-")
          # chat endpoint
          resp = openai_client
                   .chat
                   .completions
                   .create(
                     model:      model,
                     messages:   [{ role: "user", content: prompt }],
                     max_tokens: 150
                   )
          resp.choices.first.message.content
        else
          # classic completions
          resp = openai_client
                   .completions
                   .create(
                     model:      model,
                     prompt:     prompt,
                     max_tokens: 150
                   )
          resp.choices.first.text
        end
      rescue => e
        Rails.logger.error "[OpenAI] #{e.class}: #{e.message}"
        "OpenAI error: #{e.message}"
      end
      
  end