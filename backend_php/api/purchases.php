<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers, Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With');

require_once '../config/Database.php';

$database = new Database();
$db = $database->getConnection();

// POST isteği ile yeni satın alma ekle
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    $query = "INSERT INTO purchases () VALUES ()";

    $stmt = $db->prepare($query);
    $stmt->execute();

    echo "OK";
}
?>
