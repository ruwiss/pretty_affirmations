<?php
require_once '../config/Database.php';
require_once '../config/GeminiAPI.php';

header('Content-Type: application/json');

$database = new Database();
$db = $database->getConnection();

try {
    $data = json_decode(file_get_contents('php://input'), true);

    if (!isset($data['text']) || empty($data['text'])) {
        throw new Exception('Text is required');
    }

    $model = isset($data['model']) ? $data['model'] : 'gemini-1.5-pro-002';
    // Custom prompt'u al
    $customPrompt = isset($data['customPrompt']) ? $data['customPrompt'] : '';

    $gemini = new GeminiAPI($db, $model);
    // Custom prompt'u translateStory metoduna ilet
    $result = $gemini->translateStory($data['text'], $customPrompt);

    echo json_encode($result);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
