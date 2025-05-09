<?php
require_once 'auth_check.php';
require_once '../config/Database.php';

header('Content-Type: application/json');

// Get and decode JSON data
$input = json_decode(file_get_contents('php://input'), true);

// Debug logging
error_log('Received input: ' . print_r($input, true));

// Validate input
if (!isset($input['translations']) || !is_array($input['translations'])) {
    error_log('Invalid input structure: translations array missing or not an array');
    echo json_encode([
        'success' => false,
        'error' => 'Invalid input: translations array is required'
    ]);
    exit;
}

// Validate required languages
$requiredLanguages = ['tr_TR', 'en', 'ru', 'zh'];
$missingLanguages = [];

foreach ($requiredLanguages as $lang) {
    if (!isset($input['translations'][$lang]) ||
        !isset($input['translations'][$lang]['title']) ||
        !isset($input['translations'][$lang]['content'])) {
        $missingLanguages[] = $lang;
    }
}

if (!empty($missingLanguages)) {
    error_log('Missing languages or required fields: ' . implode(', ', $missingLanguages));
    echo json_encode([
        'success' => false,
        'error' => 'Missing translations for languages: ' . implode(', ', $missingLanguages)
    ]);
    exit;
}

$database = new Database();
$db = $database->getConnection();

try {
    // Start transaction
    $db->beginTransaction();

    // Save stories for each language
    $insertQuery = "INSERT INTO stories (title, content, language_code, created_at) VALUES (:title, :content, :language, NOW())";
    $stmt = $db->prepare($insertQuery);

    foreach ($requiredLanguages as $lang) {
        $content = trim($input['translations'][$lang]['content']);
        $title = trim($input['translations'][$lang]['title']);

        if (empty($content) || empty($title)) {
            continue;
        }

        try {
            $stmt->execute([
                ':title' => $title,
                ':content' => $content,
                ':language' => $lang
            ]);
        } catch (PDOException $e) {
            error_log("Database error for language $lang: " . $e->getMessage());
            throw $e;
        }
    }

    // Commit transaction
    $db->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Stories saved successfully'
    ]);
} catch (Exception $e) {
    // Rollback on error
    if ($db->inTransaction()) {
        $db->rollBack();
    }

    error_log('Save error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Database error: ' . $e->getMessage()
    ]);
}
