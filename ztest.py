# -*- coding: utf-8 -*-
import requests
import base64
import json
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

API_KEY = "AIzaSyBTkuTpqFPCDdbNHzL9q7wH1PiBfjBrrV0"
IMAGE_PATH = r"D:\users\seif\Downloads\caracc.png"

# Essayer différents modèles
# Update your MODELS array with the confirmed working strings
MODELS = [
    "gemini-2.5-flash",
    "gemini-2.0-flash"
]

def test_gemini_api():
    print("[TEST] API Google Gemini...\n")
    
    try:
        with open(IMAGE_PATH, "rb") as img_file:
            image_data = img_file.read()
    except FileNotFoundError:
        print(f"[ERREUR] Image non trouvee: {IMAGE_PATH}")
        return
    
    image_base64 = base64.b64encode(image_data).decode('utf-8')
    print(f"[OK] Image encodee ({len(image_base64)} caracteres)\n")
    
    headers = {"Content-Type": "application/json"}
    
    payload = {
        "contents": [{
            "parts": [
                {
                    "text": "Analyze this traffic accident image. Return ONLY valid JSON with: {description: string, vehicles: [string], is_accident: boolean, has_fire_smoke: boolean}"
                },
                {
                    "inlineData": {
                        "mimeType": "image/jpeg",
                        "data": image_base64
                    }
                }
            ]
        }]
    }
    
    for model in MODELS:
        print(f"[TEST] Essai modele: {model}")
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={API_KEY}"        
        try:
            response = requests.post(url, json=payload, headers=headers, timeout=30)
            
            print(f"[STATUS] Code: {response.status_code}")
            
            if response.status_code == 200:
                print(f"[OK] Modele {model} FONCTIONNE!\n")
                data = response.json()
                
                if 'candidates' in data and len(data['candidates']) > 0:
                    text = data['candidates'][0]['content']['parts'][0]['text']
                    print(f"[REPONSE]\n{text}\n")
                    
                    try:
                        json_resp = json.loads(text)
                        print(f"[JSON PARSE]\n{json.dumps(json_resp, indent=2, ensure_ascii=False)}\n")
                        return
                    except Exception as e:
                        print(f"[ATTENTION] JSON invalide: {e}\n")
                        continue
            else:
                error_msg = response.json().get("error", {}).get("message", "")
                print(f"[ERREUR] {error_msg}\n")
        
        except Exception as e:
            print(f"[ERREUR] {e}\n")
    
    print("[CONCLUSION] Aucun modele n'a fonctionne. Verifiez votre API key!")

if __name__ == "__main__":
    test_gemini_api()