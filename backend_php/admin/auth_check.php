<?php
session_start();
require_once '../config/Database.php';

// Check session first
if(isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    // Already logged in via session
    return;
}

// If no session, check for cookie
if(isset($_COOKIE['admin_auth'])) {
    // Verify cookie value
    $database = new Database();
    $db = $database->getConnection();
    
    try {
        $query = "SELECT setting_value FROM app_settings WHERE setting_key = 'panel_password'";
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $stored_password = $row['setting_value'];
            
            // If cookie is valid, set session
            if (password_verify($stored_password, $_COOKIE['admin_auth'])) {
                $_SESSION['admin_logged_in'] = true;
                return;
            }
        }
    } catch(PDOException $e) {
        // If there's an error, proceed to login
    }
}

// If no valid session or cookie, redirect to login
if(!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit();
}
?>
