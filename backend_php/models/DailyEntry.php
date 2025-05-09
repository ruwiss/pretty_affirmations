<?php
class DailyEntry {
    private $conn;
    private $table_name = "daily_entries";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function incrementCounter($language_code) {
        $today = date('Y-m-d');

        $query = "INSERT INTO " . $this->table_name . " (language_code, entry_date, counter)
                 VALUES (?, ?, 1)
                 ON DUPLICATE KEY UPDATE counter = counter + 1";

        $stmt = $this->conn->prepare($query);
        return $stmt->execute([$language_code, $today]);
    }

    public function getDailyCount($language_code) {
        $today = date('Y-m-d');

        $query = "SELECT counter
                 FROM " . $this->table_name . "
                 WHERE language_code = ?
                 AND entry_date = ?";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([$language_code, $today]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result ? $result['counter'] : 0;
    }
}
?>
