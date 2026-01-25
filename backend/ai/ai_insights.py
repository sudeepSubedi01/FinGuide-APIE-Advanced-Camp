import json, os, re
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

MODEL_NAME = "gemini-2.5-flash"

def call_gemini(prompt: str) -> str:
    try:
        model = genai.GenerativeModel(MODEL_NAME)
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        raise Exception(f"Gemini API error: {str(e)}")

def format_for_gemini(user_profile, summary, category_dist, period):
    data = {
        "user_profile": user_profile,
        "period": period,
        "summary": summary,
        "category_distribution": category_dist,
    }

    return json.dumps(data, indent=2)

def generate_gemini_insights(user_profile, summary, category_dist, period, user_preference=None):
    json_data = format_for_gemini(
        user_profile=user_profile,
        summary=summary,
        category_dist=category_dist,
        period=period
    )
    preference_text = f"\nUser preference: {user_preference}" if user_preference else ""

    prompt = f"""
You are a financial assistant helping a student improve spending habits.

Here is the user's financial data:
{json_data}
{preference_text}

Tasks:
1. Explain the user's spending behavior simply.
2. Identify concerning patterns if any.
3. Suggest 3 practical and realistic improvements.
4. Do not assume missing data.
5. Keep suggestions budget-friendly.

Respond strictly in JSON format:
{{
  "summary": "...",
  "patterns": [],
  "suggestions": []
}}
"""

    try:
        ai_response = call_gemini(prompt)

        stripped = re.sub(r"^```json\s*|```$", "", ai_response.strip(), flags=re.MULTILINE)

        # print(ai_response)
        # print("=================================================================")
        # print(stripped)

#         stripped = """
# {
#   "summary": "Your financial data for January 2026 shows an income of 0 NPR and expenses of 0 NPR, resulting in 0 NPR in savings. Currently, there is no spending activity recorded, so we cannot analyze your spending behavior or provide insights into your financial habits based on the provided information.",
#   "patterns": [
#     "No spending patterns can be identified at this time, as there is no financial data recorded for income, expenses, or category distribution."
#   ],
#   "suggestions": [
#     "Start tracking all your income and expenses: To understand and improve your spending habits, the first step is to accurately record every amount you earn and spend. Even small purchases matter. You can use this app, a simple spreadsheet, or a notebook.",
#     "Create a basic budget plan: Once you start tracking, you'll see where your money goes. Even as a student with variable income, setting a general budget (e.g., 'X' amount for food, 'Y' for transport) can help you prioritize and control spending. Start small and adjust as you go.",
#     "Set a small, achievable financial goal: Whether it's saving 500 NPR for an emergency, a new book, or a specific outing, having a goal can motivate you to stick to your tracking and budgeting efforts. This makes managing money more tangible and rewarding."
#   ]
# }
# """

        parsed_response = json.loads(stripped)
        return parsed_response

    except json.JSONDecodeError:
        return {"error": "AI returned invalid JSON", "raw_response": ai_response}
        # return {"error": "AI returned invalid JSON", "raw_response": "displaying ai_response"}

    except Exception as e:
        return {"error": str(e)}

