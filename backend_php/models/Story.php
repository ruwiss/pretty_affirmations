<?php
class Story {
    private $conn;
    private $table_name = "stories";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function getDailyStory($language_code) {
        $today = date('Y-m-d');
        
        // First check if we have a story for today
        $query = "SELECT id, title, content 
                 FROM " . $this->table_name . "
                 WHERE language_code = ? 
                 AND used_date = ?
                 LIMIT 1";
                 
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$language_code, $today]);
        $story = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($story) {
            return $story;
        }
        
        // If no story for today, get a new unused story
        $query = "SELECT id, title, content 
                 FROM " . $this->table_name . "
                 WHERE language_code = ? 
                 AND (is_used = 0 OR used_date IS NULL)
                 ORDER BY RAND()
                 LIMIT 1";
                 
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$language_code]);
        $story = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($story) {
            // Mark the story as used
            $update = "UPDATE " . $this->table_name . "
                      SET is_used = 1, used_date = ?
                      WHERE id = ?";
            $stmt = $this->conn->prepare($update);
            $stmt->execute([$today, $story['id']]);
            
            return $story;
        }
        
        // If all stories are used, reset and get a new one
        $this->resetStories($language_code);
        return $this->getDailyStory($language_code);
    }

    private function resetStories($language_code) {
        $query = "UPDATE " . $this->table_name . "
                 SET is_used = 0, used_date = NULL
                 WHERE language_code = ?";
                 
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$language_code]);
    }
}
?>
