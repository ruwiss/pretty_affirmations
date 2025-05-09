<?php
require_once 'auth_check.php';
require_once '../config/Database.php';
require_once '../config/GeminiAPI.php';

header('Content-Type: application/json');

// JSON verisini al
$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['text']) || !isset($input['model'])) {
    echo json_encode([
        'success' => false,
        'error' => 'Invalid input'
    ]);
    exit;
}

$database = new Database();
$db = $database->getConnection();

try {
    $gemini = new GeminiAPI($db);
    $gemini->setModel($input['model']);
    
    $result = $gemini->translateAffirmations($input['text']);
    echo json_encode($result);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
