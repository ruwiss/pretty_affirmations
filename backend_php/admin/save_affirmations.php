<?php
require_once 'auth_check.php';
require_once '../config/Database.php';

header('Content-Type: application/json');

// JSON verisini al
$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['category']) || !isset($input['translations'])) {
    echo json_encode([
        'success' => false,
        'error' => 'Invalid input'
    ]);
    exit;
}

$database = new Database();
$db = $database->getConnection();

try {
    // Önce category_key'e göre category_id'yi bul
    $categoryQuery = "SELECT id FROM categories WHERE category_key = :category_key";
    $categoryStmt = $db->prepare($categoryQuery);
    $categoryStmt->execute([':category_key' => $input['category']]);
    $category = $categoryStmt->fetch(PDO::FETCH_ASSOC);

    if (!$category) {
        throw new Exception('Category not found');
    }

    // Transaction başlat
    $db->beginTransaction();

    // Her dildeki cümleleri döngüyle kaydet
    $languages = ['tr_TR', 'en', 'ru', 'zh'];
    $insertQuery = "INSERT INTO affirmations (content, language_code, category_id, created_at) VALUES (:content, :language, :category_id, NOW())";
    $stmt = $db->prepare($insertQuery);

    foreach ($languages as $lang) {
        if (!isset($input['translations'][$lang])) continue;

        foreach ($input['translations'][$lang] as $content) {
            $stmt->execute([
                ':content' => $content,
                ':language' => $lang,
                ':category_id' => $category['id']
            ]);
        }
    }

    // Transaction'ı tamamla
    $db->commit();

    echo json_encode([
        'success' => true
    ]);
} catch (Exception $e) {
    // Hata durumunda rollback yap
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
