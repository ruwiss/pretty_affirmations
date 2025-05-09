<?php
session_start();
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers, Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With');

require_once '../config/Database.php';

$database = new Database();
$db = $database->getConnection();

// GET isteği ile ayarları getir
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $query = "SELECT setting_key, setting_value FROM app_settings WHERE setting_key NOT IN ('panel_password', 'gemini_api')";
        $stmt = $db->prepare($query);
        $stmt->execute();

        $settings = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $settings[$row['setting_key']] = $row['setting_value'];
        }

        echo json_encode([
            'status' => 'success',
            'data' => $settings
        ]);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'status' => 'error',
            'message' => 'Veritabanı hatası'
        ]);
    }
}

// POST isteği ile ayarları güncelle veya sil
elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Panel oturumu kontrolü
    if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
        http_response_code(401);
        echo json_encode([
            'status' => 'error',
            'message' => 'Bu işlem için yetkiniz yok'
        ]);
        exit;
    }

    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['setting_key'])) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Ayar anahtarı gerekli'
        ]);
        exit;
    }

    try {
        // Silme işlemi
        if (isset($data['action']) && $data['action'] === 'delete') {
            if ($data['setting_key'] === 'panel_password') {
                http_response_code(403);
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Bu ayar silinemez'
                ]);
                exit;
            }
            $query = "DELETE FROM app_settings WHERE setting_key = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$data['setting_key']]);
        }
        // Ekleme veya güncelleme işlemi
        else {
            if (!isset($data['setting_value'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Ayar değeri gerekli'
                ]);
                exit;
            }

            if ($data['setting_key'] === 'panel_password') {
                http_response_code(403);
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Bu ayar güncellenemez'
                ]);
                exit;
            }

            $query = "INSERT INTO app_settings (setting_key, setting_value)
                      VALUES (?, ?)
                      ON DUPLICATE KEY UPDATE setting_value = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([
                $data['setting_key'],
                $data['setting_value'],
                $data['setting_value']
            ]);
        }

        echo json_encode([
            'status' => 'success',
            'message' => 'İşlem başarılı'
        ]);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'status' => 'error',
            'message' => 'Veritabanı hatası'
        ]);
    }
}
?>
