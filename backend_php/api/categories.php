<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

include_once '../config/Database.php';
include_once '../models/Affirmation.php';

$database = new Database();
$db = $database->getConnection();
$affirmation = new Affirmation($db);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get language parameter
    $language_code = isset($_GET['lang']) ? $_GET['lang'] : 'en';
    
    // Validate language code
    $valid_languages = ['en', 'ru', 'tr_TR', 'zh'];
    if (!in_array($language_code, $valid_languages)) {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Invalid language code"
        ]);
        exit();
    }
    
    try {
        $categories = $affirmation->getCategories($language_code);
        
        if ($categories) {
            http_response_code(200);
            echo json_encode([
                "status" => "success",
                "data" => $categories
            ]);
        } else {
            http_response_code(404);
            echo json_encode([
                "status" => "error",
                "message" => "No categories found for this language"
            ]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "error",
            "message" => "Error retrieving categories",
            "error" => $e->getMessage(),
            "file" => $e->getFile(),
            "line" => $e->getLine()
        ]);
    }
} else {
    http_response_code(405);
    echo json_encode([
        "status" => "error",
        "message" => "Method not allowed"
    ]);
}
?>
