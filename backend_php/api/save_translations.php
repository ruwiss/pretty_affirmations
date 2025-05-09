<?php
session_start();
header('Content-Type: application/json');

// Admin oturum kontrolü
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(401);
    echo json_encode([
        'status' => 'error',
        'message' => 'Yetkisiz erişim'
    ]);
    exit;
}

require_once '../config/Database.php';

// Veritabanı bağlantısı
$database = new Database();
$db = $database->getConnection();

// POST verilerini al
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['translations']) || !isset($data['category_id']) || !isset($data['source_language'])) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'Çeviriler, kategori ID ve kaynak dil gerekli'
    ]);
    exit;
}

$translations = $data['translations'];
$category_id = $data['category_id'];
$source_language = $data['source_language'];

// Kategori kontrolü
try {
    $query = "SELECT id FROM categories WHERE id = :category_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':category_id', $category_id);
    $stmt->execute();
    
    if (!$stmt->fetch()) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Geçersiz kategori ID'
        ]);
        exit;
    }
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Kategori kontrolü hatası: ' . $e->getMessage()
    ]);
    exit;
}

try {
    // Her dil için çeviriyi kaydet (kaynak dil hariç)
    $query = "INSERT INTO affirmations (content, language_code, category_id, created_at) VALUES (:content, :language, :category_id, NOW())";
    $stmt = $db->prepare($query);
    
    foreach ($translations as $language => $content) {
        // Kaynak dili atla
        if ($language === $source_language) {
            continue;
        }
        
        $stmt->bindParam(':content', $content);
        $stmt->bindParam(':language', $language);
        $stmt->bindParam(':category_id', $category_id);
        $stmt->execute();
    }
    
    echo json_encode([
        'status' => 'success',
        'message' => 'Çeviriler başarıyla kaydedildi'
    ]);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
