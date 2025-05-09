<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

class Database {
    private $host = "localhost";
    private $debug = false; // Debug modu - true: localhost için, false: production için

    // Production credentials
    private $prod_db_name = "DB_NAME";
    private $prod_username = "DB_USERNAME";
    private $prod_password = "DB_PASSWORD";

    // Debug credentials
    private $debug_db_name = "DB_NAME";
    private $debug_username = "DB_USERNAME";
    private $debug_password = "DB_PASSWORD";

    private $conn;

    public function getConnection() {
        $this->conn = null;

        // Debug moduna göre credentials seçimi
        $db_name = $this->debug ? $this->debug_db_name : $this->prod_db_name;
        $username = $this->debug ? $this->debug_username : $this->prod_username;
        $password = $this->debug ? $this->debug_password : $this->prod_password;

        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $db_name, $username, $password);
            $this->conn->exec("set names utf8");
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $exception) {
            echo "Connection error: " . $exception->getMessage();
        }

        return $this->conn;
    }
}
?>
