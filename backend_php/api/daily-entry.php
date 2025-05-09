<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET");

include_once '../config/Database.php';
include_once '../models/DailyEntry.php';

$database = new Database();
$db = $database->getConnection();
$dailyEntry = new DailyEntry($db);

if ($_SERVER['REQUEST_METHOD'] === 'POST' || $_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get language code
    $language_code = isset($_REQUEST['lang']) ? $_REQUEST['lang'] : 'en';

    // Validate language code
    $valid_languages = ['en', 'ru', 'tr_TR', 'zh'];
    if (!in_array($language_code, $valid_languages)) {
        http_response_code(400);
        echo json_encode(["message" => "Invalid language code"]);
        exit();
    }

    try {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            // Increment counter
            if ($dailyEntry->incrementCounter($language_code)) {
                $count = $dailyEntry->getDailyCount($language_code);
                http_response_code(200);
                echo json_encode([
                    "status" => "success",
                    "message" => "Counter incremented successfully",
                    "count" => $count
                ]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Error incrementing counter"]);
            }
        } else {
            // GET request - just return the current count
            $count = $dailyEntry->getDailyCount($language_code);
            http_response_code(200);
            echo json_encode([
                "status" => "success",
                "count" => $count
            ]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "message" => "Error processing request",
            "error" => $e->getMessage()
        ]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
