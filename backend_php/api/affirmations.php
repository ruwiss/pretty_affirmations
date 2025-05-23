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
    // Get parameters
    $language_code = isset($_GET['lang']) ? $_GET['lang'] : 'en';
    $categories = isset($_GET['categories']) ? explode(',', $_GET['categories']) : [];
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 0;
    $lastId = isset($_GET['lastId']) ? (int)$_GET['lastId'] : null;
    
    // Validate language code
    $valid_languages = ['en', 'ru', 'tr_TR', 'zh'];
    if (!in_array($language_code, $valid_languages)) {
        http_response_code(400);
        echo json_encode(["message" => "Invalid language code"]);
        exit();
    }
    
    // Validate categories
    if (empty($categories)) {
        http_response_code(400);
        echo json_encode(["message" => "Categories are required"]);
        exit();
    }
    
    try {
        $offset = $page * 6;
        $affirmations = $affirmation->getAffirmations($language_code, $categories, $offset, 6, $lastId);
        
        if ($affirmations) {
            http_response_code(200);
            echo json_encode([
                "status" => "success",
                "data" => $affirmations,
                "page" => $page,
                "count" => count($affirmations)
            ]);
        } else {
            http_response_code(404);
            echo json_encode(["message" => "No affirmations found"]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "message" => "Error retrieving affirmations",
            "error" => $e->getMessage(),
            "file" => $e->getFile(),
            "line" => $e->getLine()
        ]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
