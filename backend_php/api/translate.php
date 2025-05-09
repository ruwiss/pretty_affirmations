<?php
session_start();
header('Content-Type: application/json');

// Admin oturum kontrolü
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'error' => 'Yetkisiz erişim'
    ]);
    exit;
}

require_once '../config/Database.php';
require_once '../config/GeminiAPI.php';

// POST verilerini al
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['text']) || empty($data['text']) || !isset($data['type'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Geçersiz istek'
    ]);
    exit;
}

try {
    $database = new Database();
    $db = $database->getConnection();
    $gemini = new GeminiAPI($db);

    $text = $data['text'];
    $type = $data['type'];

    if ($type === 'story') {
        $result = $gemini->translateStory($text);
    } else {
        $result = $gemini->translateAffirmations($text);
    }

    if (!$result['success']) {
        throw new Exception($result['error']);
    }

    echo json_encode([
        'success' => true,
        'translations' => $result['data']['translations'],
        'suggested_category' => $result['data']['suggested_category']
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
