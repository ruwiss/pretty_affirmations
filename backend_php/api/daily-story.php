<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

include_once '../config/Database.php';
include_once '../models/Story.php';

$database = new Database();
$db = $database->getConnection();
$story = new Story($db);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get parameters
    $language_code = isset($_GET['lang']) ? $_GET['lang'] : 'en';
    
    // Validate language code
    $valid_languages = ['en', 'ru', 'tr_TR', 'zh'];
    if (!in_array($language_code, $valid_languages)) {
        http_response_code(400);
        echo json_encode(["message" => "Invalid language code"]);
        exit();
    }
    
    try {
        $daily_story = $story->getDailyStory($language_code);
        
        if ($daily_story) {
            http_response_code(200);
            echo json_encode([
                "status" => "success",
                "data" => $daily_story
            ]);
        } else {
            http_response_code(404);
            echo json_encode(["message" => "No story found"]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["message" => "Error retrieving daily story"]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
