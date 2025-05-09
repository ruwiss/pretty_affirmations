<?php
require_once '../config/Database.php';
require_once '../helpers/GeminiTranslator.php';

header('Content-Type: application/json');

// Gelen JSON verisini al
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data || !isset($data['title']) || !isset($data['content']) || !isset($data['target_language'])) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'Gerekli alanlar eksik'
    ]);
    exit;
}

try {
    $database = new Database();
    $db = $database->getConnection();

    // API anahtarını veritabanından al
    $stmt = $db->prepare("SELECT setting_value FROM app_settings WHERE setting_key = 'gemini_api'");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$result) {
        throw new Exception('Gemini API anahtarı bulunamadı');
    }

    $api_key = $result['setting_value'];
    $translator = new GeminiTranslator($api_key);

    // Başlık ve içeriği birlikte çevir
    $translations = $translator->translateStory(
        $data['title'],
        $data['content'],
        $data['target_language']
    );

    echo json_encode([
        'status' => 'success',
        'translations' => $translations
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
