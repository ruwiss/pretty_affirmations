<?php

class GeminiAPI {
    private $apiKey;
    private $apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/';
    private $model;
    private $db;

    public function __construct($db, $model = 'gemini-1.5-pro-002') {
        $this->db = $db;
        $this->model = $model;
        $this->loadApiKey();
    }

    private function loadApiKey() {
        $query = "SELECT setting_value FROM app_settings WHERE setting_key = 'gemini_api'";
        $stmt = $this->db->prepare($query);
        $stmt->execute();
        $this->apiKey = $stmt->fetchColumn();

        if (!$this->apiKey) {
            throw new Exception('Gemini API key not found in database');
        }
    }

    private function getCategories() {
        $query = "SELECT category_key FROM categories";
        $stmt = $this->db->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }

    public function setModel($model) {
        $this->model = $model;
    }

    private function buildEndpoint() {
        return $this->apiEndpoint . $this->model . ':generateContent?key=' . $this->apiKey;
    }

    private function makeRequest($prompt) {
        if (!$this->apiKey) {
            throw new Exception('API key is not set');
        }

        $data = [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $prompt]
                    ]
                ]
            ],
            'generationConfig' => [
                'temperature' => 0.7,
                'topK' => 40,
                'topP' => 0.95,
                'maxOutputTokens' => 2048,
            ]
        ];

        $ch = curl_init($this->buildEndpoint());
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json'
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200) {
            throw new Exception('API request failed with status code: ' . $httpCode);
        }

        return json_decode($response, true);
    }

    public function translateAffirmations($text) {
        // Kategorileri al
        $categories = $this->getCategories();

        // Prompt oluştur
        $prompt = "Given the following sentences (which could be in any language), please:
1. First detect the language of the input
2. Translate the sentences into all required languages (Turkish if not Turkish, English if not English, Russian, and Chinese)
3. Suggest the most appropriate category from this list: " . implode(', ', $categories) . "

Please respond in this exact JSON format:
{
    \"translations\": {
        \"tr_TR\": [translations in Turkish (if input is not Turkish) or original sentences (if input is Turkish)],
        \"en\": [translations in English (if input is not English) or original sentences (if input is English)],
        \"ru\": [translations in Russian],
        \"zh\": [translations in Chinese]
    },
    \"suggested_category\": \"category_key\"
}

Input sentences to translate:
" . $text;

        try {
            $response = $this->makeRequest($prompt);
            // API yanıtından text kısmını al
            $content = $response['candidates'][0]['content']['parts'][0]['text'];

            // JSON başlangıç ve bitiş noktalarını bul
            $start = strpos($content, '{');
            $end = strrpos($content, '}');

            if ($start === false || $end === false) {
                throw new Exception('JSON structure not found in API response');
            }

            // Sadece JSON kısmını al
            $jsonContent = substr($content, $start, $end - $start + 1);

            // JSON'ı parse et
            $result = json_decode($jsonContent, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('Invalid JSON response from API: ' . json_last_error_msg());
            }

            return [
                'success' => true,
                'data' => $result
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    public function translateStory($text, $customPrompt = '') {
        // Kategorileri al
        $categories = $this->getCategories();

        // Ana prompt
        $basePrompt = "Given the following story (which could be in any language), please:
1. First detect the language of the input
2. Translate the story into all required languages (Turkish if not Turkish, English if not English, Russian, and Chinese)
3. Suggest a title for this content";

        // Custom prompt varsa ekle
        if (!empty($customPrompt)) {
            $basePrompt .= "\n\nAdditional instructions:\n" . $customPrompt;
        }

        // Final prompt oluştur
        $prompt = $basePrompt . "\n\nPlease respond in this exact JSON format:
{
    \"translations\": {
        \"tr_TR\": {
            \"title\": \"title in Turkish\",
            \"content\": \"translation in Turkish\"
        },
        \"en\": {
            \"title\": \"title in English\",
            \"content\": \"translation in English\"
        },
        \"ru\": {
            \"title\": \"title in Russian\",
            \"content\": \"translation in Russian\"
        },
        \"zh\": {
            \"title\": \"title in Chinese\",
            \"content\": \"translation in Chinese\"
        }
    }
}

Input story to translate:
" . $text;

        try {
            $response = $this->makeRequest($prompt);

            // Debug için response'u yazdır
            error_log("API Response: " . print_r($response, true));

            // API yanıtından text kısmını al
            $content = $response['candidates'][0]['content']['parts'][0]['text'];

            // Debug için content'i yazdır
            error_log("API Content: " . $content);

            // JSON başlangıç ve bitiş noktalarını bul
            $start = strpos($content, '{');
            $end = strrpos($content, '}');

            if ($start === false || $end === false) {
                throw new Exception('JSON structure not found in API response');
            }

            // Sadece JSON kısmını al
            $jsonContent = substr($content, $start, $end - $start + 1);

            // JSON'ı parse et
            $result = json_decode($jsonContent, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('Invalid JSON response from API: ' . json_last_error_msg());
            }

            return [
                'success' => true,
                'data' => $result
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    public function createStory($topic, $customPrompt = '') {
        try {
            // Ana prompt
            $basePrompt = "Create an inspiring story that can positively impact readers' daily lives. The story should be based on this topic: " . $topic . "

Guidelines for the story:
- Target audience: Adults
- Length: Medium-length (not too short, not too long)
- Style: Realistic and relatable, avoiding oversimplified narratives
- Purpose: Include meaningful life lessons and positive perspectives
- Tone: Uplifting but authentic";

            // Custom prompt varsa ekle
            if (!empty($customPrompt)) {
                $basePrompt .= "\n\nAdditional instructions:\n" . $customPrompt;
            }

            // Final prompt oluştur
            $prompt = $basePrompt . "\n\nPlease respond in this exact JSON format:
{
    \"translations\": {
        \"tr_TR\": {
            \"title\": \"Title in Turkish\",
            \"content\": \"Story in Turkish\"
        },
        \"en\": {
            \"title\": \"Title in English\",
            \"content\": \"Story in English\"
        },
        \"ru\": {
            \"title\": \"Title in Russian\",
            \"content\": \"Story in Russian\"
        },
        \"zh\": {
            \"title\": \"Title in Chinese\",
            \"content\": \"Story in Chinese\"
        }
    }
}";

            // API'ye istek gönder
            $response = $this->makeRequest($prompt);

            // JSON yanıtını parse et
            $text = $response['candidates'][0]['content']['parts'][0]['text'];

            // JSON formatını düzelt - başındaki ve sonundaki fazla karakterleri temizle
            $text = trim($text);
            if (strpos($text, '{') !== 0) {
                $text = substr($text, strpos($text, '{'));
            }
            if (strrpos($text, '}') !== strlen($text) - 1) {
                $text = substr($text, 0, strrpos($text, '}') + 1);
            }

            $data = json_decode($text, true);

            // Yanıtı kontrol et ve düzenle
            if (isset($data['translations'])) {
                // Her dil için title ve content kontrolü yap
                $requiredLanguages = ['tr_TR', 'en', 'ru', 'zh'];
                foreach ($requiredLanguages as $lang) {
                    if (!isset($data['translations'][$lang]) ||
                        !isset($data['translations'][$lang]['title']) ||
                        !isset($data['translations'][$lang]['content'])) {
                        throw new Exception('Eksik dil veya alan: ' . $lang);
                    }
                }

                return [
                    'success' => true,
                    'data' => [
                        'translations' => $data['translations']
                    ]
                ];
            } else {
                error_log('Invalid AI response format: ' . print_r($data, true));
                throw new Exception('AI yanıtı geçersiz format içeriyor');
            }

        } catch (Exception $e) {
            error_log('Story creation error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}
